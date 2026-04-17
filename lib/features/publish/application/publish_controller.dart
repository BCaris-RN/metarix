import 'package:flutter/foundation.dart';

import '../../../data/local_metarix_gateway.dart';
import '../../../repositories/draft_repository.dart';
import '../../../repositories/publish_state_repository.dart';
import '../../../runtime/activity/activity_event.dart';
import '../../../runtime/activity/activity_event_type.dart';
import '../../workflow/domain/workflow_models.dart';
import '../domain/publish_models.dart';
import 'publish_state_transition_service.dart';

class PublishController extends ChangeNotifier {
  PublishController(
    this._publishStateRepository,
    this._draftRepository,
    this._gateway,
    this._transitionService,
  ) {
    _gateway.addListener(notifyListeners);
  }

  final PublishStateRepository _publishStateRepository;
  final DraftRepository _draftRepository;
  final LocalMetarixGateway _gateway;
  final PublishStateTransitionService _transitionService;

  List<ScheduledPostRecord> get records {
    final items = List<ScheduledPostRecord>.from(
      _gateway.snapshot.scheduledPosts,
    );
    items.sort((left, right) {
      final leftTime = left.scheduledAt ?? left.updatedAt;
      final rightTime = right.scheduledAt ?? right.updatedAt;
      return leftTime.compareTo(rightTime);
    });
    return items;
  }

  ScheduledPostRecord? recordForDraft(String draftId) {
    for (final record in _gateway.snapshot.scheduledPosts) {
      if (record.draftId == draftId) {
        return record;
      }
    }
    return null;
  }

  Future<void> markScheduled(ScheduledPostRecord record) {
    return _transitionRecord(record, PublishRecordStatus.scheduled);
  }

  Future<void> queueRecord(ScheduledPostRecord record) {
    return _transitionRecord(record, PublishRecordStatus.queued);
  }

  Future<void> markPublished(ScheduledPostRecord record) {
    return _transitionRecord(record, PublishRecordStatus.published);
  }

  Future<void> markFailed(
    ScheduledPostRecord record, {
    String errorMessage = 'Publish attempt failed in the internal queue.',
  }) {
    return _transitionRecord(
      record,
      PublishRecordStatus.failed,
      errorMessage: errorMessage,
    );
  }

  Future<void> _transitionRecord(
    ScheduledPostRecord record,
    PublishRecordStatus nextStatus, {
    String? errorMessage,
  }) async {
    final nextRecord = _transitionService.transition(
      record,
      nextStatus,
      occurredAt: DateTime.now(),
      errorMessage: errorMessage,
    );
    await _publishStateRepository.saveScheduledPostRecord(nextRecord);
    await _syncDraftState(nextRecord);
    await _recordActivity(nextRecord);
  }

  Future<void> _syncDraftState(ScheduledPostRecord record) async {
    final draft = _findDraft(record.draftId);
    if (draft == null) {
      return;
    }

    final nextState = switch (record.status) {
      PublishRecordStatus.draft => ContentState.draft,
      PublishRecordStatus.scheduled ||
      PublishRecordStatus.queued => ContentState.scheduled,
      PublishRecordStatus.published => ContentState.published,
      PublishRecordStatus.blocked => ContentState.publishDenied,
      PublishRecordStatus.failed => ContentState.scheduled,
    };

    if (draft.currentState == nextState &&
        draft.plannedPublishAt == record.scheduledAt) {
      return;
    }

    await _draftRepository.updateDraft(
      draft.copyWith(
        currentState: nextState,
        plannedPublishAt: record.scheduledAt,
      ),
    );
  }

  PostDraft? _findDraft(String draftId) {
    for (final draft in _gateway.snapshot.drafts) {
      if (draft.id == draftId) {
        return draft;
      }
    }
    return null;
  }

  Future<void> _recordActivity(ScheduledPostRecord record) {
    final eventType = switch (record.status) {
      PublishRecordStatus.scheduled => ActivityEventType.scheduled,
      PublishRecordStatus.published => ActivityEventType.published,
      PublishRecordStatus.blocked => ActivityEventType.denied,
      PublishRecordStatus.queued ||
      PublishRecordStatus.failed ||
      PublishRecordStatus.draft => ActivityEventType.updated,
    };
    final eventClass = switch (record.status) {
      PublishRecordStatus.blocked => ActivityEventClass.denial,
      PublishRecordStatus.queued ||
      PublishRecordStatus.failed => ActivityEventClass.systemAction,
      _ => ActivityEventClass.normalAction,
    };
    final reason = switch (record.status) {
      PublishRecordStatus.scheduled => 'Post is ready in the publish schedule.',
      PublishRecordStatus.queued => 'Post entered the internal publish queue.',
      PublishRecordStatus.published =>
        'Post was marked as published in the internal pipeline.',
      PublishRecordStatus.failed =>
        record.lastError ?? 'Post failed inside the internal publish pipeline.',
      PublishRecordStatus.blocked =>
        record.denialReasons.isEmpty
            ? 'Post was blocked in the internal publish pipeline.'
            : record.denialReasons.map((reason) => reason.message).join(' '),
      PublishRecordStatus.draft => 'Post returned to draft status.',
    };

    return _gateway.recordActivityEvent(
      ActivityEvent(
        id: _gateway.createId('activity'),
        workspaceId: _gateway.workspace.id,
        objectType: ActivityObjectType.schedule,
        objectId: record.id,
        objectLabel: record.title,
        eventType: eventType,
        eventClass: eventClass,
        actorUserId: _gateway.currentUser.id,
        actorName: _gateway.currentUser.name,
        reason: reason,
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
