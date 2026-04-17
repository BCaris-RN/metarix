import 'package:flutter/foundation.dart';

import '../../../data/local_metarix_gateway.dart';
import '../../../features/admin/domain/admin_models.dart';
import '../../../features/publish/application/publish_state_transition_service.dart';
import '../../../features/publish/domain/publish_models.dart';
import '../../../features/schedule/domain/schedule_models.dart';
import '../../../repositories/approval_repository.dart';
import '../../../repositories/draft_repository.dart';
import '../../../repositories/publish_state_repository.dart';
import '../../../repositories/schedule_repository.dart';
import '../../../runtime/activity/activity_event.dart';
import '../../../runtime/activity/activity_event_type.dart';
import '../../../services/access_control_service.dart';
import '../../../services/workflow_services.dart';
import '../domain/workflow_models.dart';

class WorkflowController extends ChangeNotifier {
  WorkflowController(
    this._draftRepository,
    this._approvalRepository,
    this._scheduleRepository,
    this._publishStateRepository,
    this._gateway,
    this._accessControlService,
    this._publishPostureEvaluator,
    this._publishStateTransitionService,
  ) {
    _gateway.addListener(notifyListeners);
  }

  final DraftRepository _draftRepository;
  final ApprovalRepository _approvalRepository;
  final ScheduleRepository _scheduleRepository;
  final PublishStateRepository _publishStateRepository;
  final LocalMetarixGateway _gateway;
  final AccessControlService _accessControlService;
  final PublishPostureEvaluator _publishPostureEvaluator;
  final PublishStateTransitionService _publishStateTransitionService;

  List<PostDraft> get drafts => _gateway.snapshot.drafts;

  List<ApprovalRecord> get approvals => _gateway.snapshot.approvals;

  List<ScheduleRecord> get schedules => _gateway.snapshot.schedules;

  ScheduledPostRecord? publishRecordFor(String draftId) {
    for (final record in _gateway.snapshot.scheduledPosts) {
      if (record.draftId == draftId) {
        return record;
      }
    }
    return null;
  }

  ApprovalRequirement approvalRequirementFor(PostDraft draft) {
    return _publishPostureEvaluator
        .evaluate(
          draft: draft,
          approvals: approvals,
          schedule: scheduleFor(draft.id),
        )
        .approvalRequirement;
  }

  AccessDecision accessFor(RuntimeAction action, {PostDraft? draft}) {
    return _accessControlService.canPerform(
      _gateway.currentUserRole,
      action,
      approvalRequirement: draft == null ? null : approvalRequirementFor(draft),
    );
  }

  ScheduleRecord? scheduleFor(String draftId) {
    for (final schedule in schedules) {
      if (schedule.draftId == draftId) {
        return schedule;
      }
    }
    return null;
  }

  PublishPostureResult postureFor(PostDraft draft) {
    return _publishPostureEvaluator.evaluate(
      draft: draft,
      approvals: approvals,
      schedule: scheduleFor(draft.id),
    );
  }

  Future<void> requestReview(PostDraft draft) async {
    final updatedDraft = draft.copyWith(currentState: ContentState.inReview);
    await _draftRepository.updateDraft(updatedDraft);
    await _syncPublishRecord(updatedDraft);
    await _recordActivity(
      objectType: ActivityObjectType.draft,
      objectId: draft.id,
      objectLabel: draft.title,
      eventType: ActivityEventType.reviewed,
      reason: 'Draft was submitted for review.',
    );
  }

  Future<void> requestChanges(PostDraft draft) async {
    final updatedDraft = draft.copyWith(
      currentState: ContentState.changesRequested,
    );
    await _draftRepository.updateDraft(updatedDraft);
    await _syncPublishRecord(updatedDraft);
    await _recordActivity(
      objectType: ActivityObjectType.draft,
      objectId: draft.id,
      objectLabel: draft.title,
      eventType: ActivityEventType.updated,
      reason: 'Changes were requested before approval.',
    );
  }

  Future<void> approveDraft(PostDraft draft) async {
    final decision = accessFor(RuntimeAction.approveContent, draft: draft);
    if (!decision.allowed) {
      await _recordActivity(
        objectType: ActivityObjectType.draft,
        objectId: draft.id,
        objectLabel: draft.title,
        eventType: ActivityEventType.denied,
        eventClass: ActivityEventClass.denial,
        reason: decision.reason,
      );
      return;
    }

    final approval = ApprovalRecord(
      id: _gateway.createId('approval'),
      draftId: draft.id,
      requirement: draft.requiredApproval,
      reviewerRole: _gateway.currentUserRole.name,
      approved: true,
      note: 'Approved in Phoenix demo flow.',
      decidedAt: DateTime.now(),
    );
    await _approvalRepository.createApprovalRecord(approval);
    final updatedDraft = draft.copyWith(currentState: ContentState.approved);
    await _draftRepository.updateDraft(updatedDraft);
    await _syncPublishRecord(updatedDraft);
    await _recordActivity(
      objectType: ActivityObjectType.approval,
      objectId: approval.id,
      objectLabel: draft.title,
      eventType: ActivityEventType.approved,
      reason: 'Approval record created for the draft.',
    );
    await _recordActivity(
      objectType: ActivityObjectType.draft,
      objectId: draft.id,
      objectLabel: draft.title,
      eventType: ActivityEventType.approved,
      reason: 'Draft approval requirement was satisfied.',
    );
  }

  Future<void> scheduleDraft(PostDraft draft, DateTime scheduledAt) async {
    final decision = accessFor(RuntimeAction.schedulePost, draft: draft);
    if (!decision.allowed) {
      await _recordActivity(
        objectType: ActivityObjectType.draft,
        objectId: draft.id,
        objectLabel: draft.title,
        eventType: ActivityEventType.denied,
        eventClass: ActivityEventClass.denial,
        reason: decision.reason,
      );
      return;
    }

    final updatedDraft = draft.copyWith(
      currentState: ContentState.scheduled,
      plannedPublishAt: scheduledAt,
    );
    final scheduleRecord = ScheduleRecord(
      id: scheduleFor(draft.id)?.id ?? _gateway.createId('schedule'),
      draftId: draft.id,
      channel: draft.targetNetwork,
      scheduledAt: scheduledAt,
      denialReasons: const [],
    );
    final posture = _publishPostureEvaluator.evaluate(
      draft: updatedDraft,
      approvals: approvals,
      schedule: scheduleRecord,
    );

    await _draftRepository.updateDraft(updatedDraft);
    final savedSchedule = await _scheduleRepository.saveScheduleRecord(
      ScheduleRecord(
        id: scheduleRecord.id,
        draftId: scheduleRecord.draftId,
        channel: scheduleRecord.channel,
        scheduledAt: scheduleRecord.scheduledAt,
        denialReasons: posture.denialReasons,
      ),
    );
    await _syncPublishRecord(
      updatedDraft,
      scheduleRecord: savedSchedule,
      nextStatus: posture.denialReasons.isEmpty
          ? PublishRecordStatus.scheduled
          : PublishRecordStatus.blocked,
    );
    await _recordActivity(
      objectType: ActivityObjectType.schedule,
      objectId: scheduleRecord.id,
      objectLabel: draft.title,
      eventType: ActivityEventType.scheduled,
      reason: 'Draft scheduled for ${scheduledAt.toIso8601String()}.',
    );
    await _recordActivity(
      objectType: ActivityObjectType.draft,
      objectId: draft.id,
      objectLabel: draft.title,
      eventType: ActivityEventType.scheduled,
      reason: 'Draft moved into the scheduled state.',
    );
    if (posture.posture == PublishPosture.publishDenied &&
        posture.denialReasons.isNotEmpty) {
      await _recordActivity(
        objectType: ActivityObjectType.draft,
        objectId: draft.id,
        objectLabel: draft.title,
        eventType: ActivityEventType.denied,
        eventClass: ActivityEventClass.denial,
        reason: 'Publish boundary blocked the scheduled draft.',
        detail: posture.denialReasons.map((reason) => reason.message).join(' '),
      );
    }
  }

  Future<void> toggleEvidence(PostDraft draft, String evidenceCode) async {
    final nextEvidence = List<String>.from(draft.evidenceCodes);
    if (nextEvidence.contains(evidenceCode)) {
      nextEvidence.remove(evidenceCode);
    } else {
      nextEvidence.add(evidenceCode);
    }

    final updatedDraft = draft.copyWith(evidenceCodes: nextEvidence);
    await _draftRepository.updateDraft(updatedDraft);
    await _syncPublishRecord(updatedDraft);
  }

  Future<void> _syncPublishRecord(
    PostDraft draft, {
    ScheduleRecord? scheduleRecord,
    PublishRecordStatus? nextStatus,
  }) async {
    final existing = publishRecordFor(draft.id);
    final baseRecord = _publishStateTransitionService.syncDraftRecord(
      draft: draft,
      campaignName: _campaignNameFor(draft.campaignId),
      existing: existing,
      schedule: scheduleRecord ?? scheduleFor(draft.id),
    );
    final nextRecord = nextStatus == null
        ? baseRecord
        : _publishStateTransitionService.transition(
            baseRecord,
            nextStatus,
            occurredAt: DateTime.now(),
            scheduledAt: scheduleRecord?.scheduledAt ?? draft.plannedPublishAt,
            denialReasons: scheduleRecord?.denialReasons,
          );
    await _publishStateRepository.saveScheduledPostRecord(nextRecord);
  }

  String _campaignNameFor(String campaignId) {
    for (final campaign in _gateway.snapshot.campaigns) {
      if (campaign.id == campaignId) {
        return campaign.name;
      }
    }
    return campaignId;
  }

  Future<void> _recordActivity({
    required ActivityObjectType objectType,
    required String objectId,
    required String objectLabel,
    required ActivityEventType eventType,
    required String reason,
    ActivityEventClass eventClass = ActivityEventClass.normalAction,
    String? detail,
  }) {
    return _gateway.recordActivityEvent(
      ActivityEvent(
        id: _gateway.createId('activity'),
        workspaceId: _gateway.workspace.id,
        objectType: objectType,
        objectId: objectId,
        objectLabel: objectLabel,
        eventType: eventType,
        eventClass: eventClass,
        actorUserId: _gateway.currentUser.id,
        actorName: _gateway.currentUser.name,
        reason: reason,
        detail: detail,
        occurredAt: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _gateway.removeListener(notifyListeners);
    super.dispose();
  }
}
