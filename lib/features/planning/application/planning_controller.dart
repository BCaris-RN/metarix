import 'package:flutter/foundation.dart';

import '../../../data/local_metarix_gateway.dart';
import '../../../repositories/campaign_repository.dart';
import '../../../repositories/draft_repository.dart';
import '../../../repositories/publish_state_repository.dart';
import '../../../runtime/activity/activity_event.dart';
import '../../../runtime/activity/activity_event_type.dart';
import '../../publish/application/publish_state_transition_service.dart';
import '../../publish/domain/publish_models.dart';
import '../../schedule/domain/schedule_models.dart';
import '../../strategy/domain/strategy_models.dart';
import '../domain/planning_models.dart';
import '../../workflow/domain/workflow_models.dart';

class PlanningController extends ChangeNotifier {
  PlanningController(
    this._campaignRepository,
    this._draftRepository,
    this._publishStateRepository,
    this._gateway,
    this._publishStateTransitionService,
  ) {
    _gateway.addListener(notifyListeners);
  }

  final CampaignRepository _campaignRepository;
  final DraftRepository _draftRepository;
  final PublishStateRepository _publishStateRepository;
  final LocalMetarixGateway _gateway;
  final PublishStateTransitionService _publishStateTransitionService;

  List<Campaign> get campaigns => _gateway.snapshot.campaigns;

  List<EvergreenContentItem> get evergreenItems =>
      _gateway.snapshot.evergreenItems;

  List<PostDraft> get drafts => _gateway.snapshot.drafts;

  List<ContentPillar> get contentPillars => _gateway.snapshot.contentPillars;

  Future<void> saveCampaign(Campaign campaign) async {
    final existing = campaigns.any((entry) => entry.id == campaign.id);
    await _campaignRepository.createCampaign(campaign);
    await _syncCampaignPublishRecords(campaign);
    await _recordActivity(
      objectType: ActivityObjectType.campaign,
      objectId: campaign.id,
      objectLabel: campaign.name,
      eventType: existing
          ? ActivityEventType.updated
          : ActivityEventType.created,
      reason: existing
          ? 'Campaign details were updated in planning.'
          : 'Campaign was created in planning.',
    );
  }

  Future<void> saveEvergreen(EvergreenContentItem item) =>
      _campaignRepository.saveEvergreenItem(item);

  Future<void> saveDraft(PostDraft draft) async {
    final existingIds = drafts.map((entry) => entry.id).toSet();
    if (existingIds.contains(draft.id)) {
      final savedDraft = await _draftRepository.updateDraft(draft);
      await _syncDraftPublishRecord(savedDraft);
      await _recordActivity(
        objectType: ActivityObjectType.draft,
        objectId: draft.id,
        objectLabel: draft.title,
        eventType: ActivityEventType.updated,
        reason: 'Draft content or schedule details were updated.',
      );
    } else {
      final savedDraft = await _draftRepository.createDraft(draft);
      await _syncDraftPublishRecord(savedDraft);
      await _recordActivity(
        objectType: ActivityObjectType.draft,
        objectId: draft.id,
        objectLabel: draft.title,
        eventType: ActivityEventType.created,
        reason: 'Draft was created from the planning workspace.',
      );
    }
  }

  Future<void> _recordActivity({
    required ActivityObjectType objectType,
    required String objectId,
    required String objectLabel,
    required ActivityEventType eventType,
    required String reason,
  }) {
    return _gateway.recordActivityEvent(
      ActivityEvent(
        id: _gateway.createId('activity'),
        workspaceId: _gateway.workspace.id,
        objectType: objectType,
        objectId: objectId,
        objectLabel: objectLabel,
        eventType: eventType,
        eventClass: ActivityEventClass.normalAction,
        actorUserId: _gateway.currentUser.id,
        actorName: _gateway.currentUser.name,
        reason: reason,
        occurredAt: DateTime.now(),
      ),
    );
  }

  List<EditorialCalendarDay> monthView(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final nextMonth = DateTime(month.year, month.month + 1, 1);
    final dayCount = nextMonth.difference(firstDay).inDays;

    return List.generate(dayCount, (index) {
      final date = DateTime(month.year, month.month, index + 1);
      final dayDrafts = drafts
          .where(
            (draft) =>
                draft.plannedPublishAt?.year == date.year &&
                draft.plannedPublishAt?.month == date.month &&
                draft.plannedPublishAt?.day == date.day,
          )
          .toList();
      return EditorialCalendarDay(date: date, drafts: dayDrafts);
    });
  }

  Future<void> _syncDraftPublishRecord(PostDraft draft) async {
    final campaignName = _campaignNameFor(draft.campaignId);
    final existing = _publishRecordForDraft(draft.id);
    final schedule = _scheduleForDraft(draft.id);
    final record = _publishStateTransitionService.syncDraftRecord(
      draft: draft,
      campaignName: campaignName,
      existing: existing,
      schedule: schedule,
    );
    await _publishStateRepository.saveScheduledPostRecord(record);
  }

  Future<void> _syncCampaignPublishRecords(Campaign campaign) async {
    final timestamp = DateTime.now();
    final records = _gateway.snapshot.scheduledPosts
        .where((entry) => entry.campaignId == campaign.id)
        .toList();
    for (final record in records) {
      await _publishStateRepository.saveScheduledPostRecord(
        record.copyWith(campaignName: campaign.name, updatedAt: timestamp),
      );
    }
  }

  String _campaignNameFor(String campaignId) {
    for (final campaign in _gateway.snapshot.campaigns) {
      if (campaign.id == campaignId) {
        return campaign.name;
      }
    }
    return campaignId;
  }

  ScheduleRecord? _scheduleForDraft(String draftId) {
    for (final schedule in _gateway.snapshot.schedules) {
      if (schedule.draftId == draftId) {
        return schedule;
      }
    }
    return null;
  }

  ScheduledPostRecord? _publishRecordForDraft(String draftId) {
    for (final record in _gateway.snapshot.scheduledPosts) {
      if (record.draftId == draftId) {
        return record;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _gateway.removeListener(notifyListeners);
    super.dispose();
  }
}
