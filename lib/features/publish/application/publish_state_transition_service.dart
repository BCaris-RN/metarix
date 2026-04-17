import '../../schedule/domain/schedule_models.dart';
import '../../workflow/domain/workflow_models.dart';
import '../domain/publish_models.dart';

class PublishStateTransitionService {
  const PublishStateTransitionService();

  static const Map<PublishRecordStatus, Set<PublishRecordStatus>>
  _allowedTransitions = {
    PublishRecordStatus.draft: {
      PublishRecordStatus.draft,
      PublishRecordStatus.scheduled,
      PublishRecordStatus.blocked,
    },
    PublishRecordStatus.scheduled: {
      PublishRecordStatus.scheduled,
      PublishRecordStatus.queued,
      PublishRecordStatus.published,
      PublishRecordStatus.failed,
      PublishRecordStatus.blocked,
    },
    PublishRecordStatus.queued: {
      PublishRecordStatus.queued,
      PublishRecordStatus.published,
      PublishRecordStatus.failed,
      PublishRecordStatus.blocked,
    },
    PublishRecordStatus.failed: {
      PublishRecordStatus.failed,
      PublishRecordStatus.scheduled,
      PublishRecordStatus.queued,
    },
    PublishRecordStatus.blocked: {
      PublishRecordStatus.blocked,
      PublishRecordStatus.scheduled,
    },
    PublishRecordStatus.published: {PublishRecordStatus.published},
  };

  bool canTransition(
    PublishRecordStatus currentStatus,
    PublishRecordStatus nextStatus,
  ) {
    return _allowedTransitions[currentStatus]!.contains(nextStatus);
  }

  ScheduledPostRecord syncDraftRecord({
    required PostDraft draft,
    required String campaignName,
    required ScheduledPostRecord? existing,
    required ScheduleRecord? schedule,
    DateTime? occurredAt,
  }) {
    final timestamp = occurredAt ?? DateTime.now();
    final status =
        existing?.status ?? _statusForDraft(draft, schedule: schedule);
    final denialReasons = status == PublishRecordStatus.blocked
        ? (schedule?.denialReasons ?? existing?.denialReasons ?? const [])
        : const <DenialReason>[];

    return ScheduledPostRecord(
      id: existing?.id ?? 'publish-${draft.id}',
      draftId: draft.id,
      campaignId: draft.campaignId,
      campaignName: campaignName,
      title: draft.title,
      channel: draft.targetNetwork,
      status: status,
      scheduledAt:
          schedule?.scheduledAt ??
          draft.plannedPublishAt ??
          existing?.scheduledAt,
      queuedAt: existing?.queuedAt,
      publishedAt: existing?.publishedAt,
      updatedAt: timestamp,
      lastError: existing?.lastError,
      denialReasons: denialReasons,
    );
  }

  ScheduledPostRecord transition(
    ScheduledPostRecord record,
    PublishRecordStatus nextStatus, {
    DateTime? occurredAt,
    DateTime? scheduledAt,
    String? errorMessage,
    List<DenialReason>? denialReasons,
  }) {
    if (!canTransition(record.status, nextStatus)) {
      throw StateError('Cannot transition ${record.status} to $nextStatus');
    }

    final transitionTime = occurredAt ?? DateTime.now();
    final nextScheduledAt = scheduledAt ?? record.scheduledAt;
    if (nextStatus != PublishRecordStatus.draft && nextScheduledAt == null) {
      throw StateError('A scheduled time is required for $nextStatus');
    }

    return record.copyWith(
      status: nextStatus,
      scheduledAt: nextScheduledAt,
      queuedAt: nextStatus == PublishRecordStatus.queued
          ? transitionTime
          : nextStatus == PublishRecordStatus.scheduled ||
                nextStatus == PublishRecordStatus.blocked
          ? null
          : record.queuedAt,
      clearQueuedAt:
          nextStatus == PublishRecordStatus.scheduled ||
          nextStatus == PublishRecordStatus.blocked,
      publishedAt: nextStatus == PublishRecordStatus.published
          ? transitionTime
          : record.publishedAt,
      clearPublishedAt:
          nextStatus != PublishRecordStatus.published &&
          nextStatus != PublishRecordStatus.queued &&
          nextStatus != PublishRecordStatus.failed,
      updatedAt: transitionTime,
      lastError: nextStatus == PublishRecordStatus.failed
          ? errorMessage ?? record.lastError ?? 'Publish attempt failed.'
          : null,
      clearLastError: nextStatus != PublishRecordStatus.failed,
      denialReasons: nextStatus == PublishRecordStatus.blocked
          ? denialReasons ?? record.denialReasons
          : const <DenialReason>[],
    );
  }

  PublishRecordStatus _statusForDraft(
    PostDraft draft, {
    required ScheduleRecord? schedule,
  }) {
    if (draft.currentState == ContentState.published) {
      return PublishRecordStatus.published;
    }
    if (draft.currentState == ContentState.publishDenied ||
        (schedule?.denialReasons.isNotEmpty ?? false)) {
      return PublishRecordStatus.blocked;
    }
    if (draft.currentState == ContentState.scheduled || schedule != null) {
      return PublishRecordStatus.scheduled;
    }
    return PublishRecordStatus.draft;
  }
}
