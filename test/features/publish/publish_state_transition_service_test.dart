import 'package:flutter_test/flutter_test.dart';

import 'package:metarix/features/publish/application/publish_state_transition_service.dart';
import 'package:metarix/features/publish/domain/publish_models.dart';
import 'package:metarix/features/shared/domain/core_models.dart';
import 'package:metarix/features/workflow/domain/workflow_models.dart';

void main() {
  const service = PublishStateTransitionService();

  ScheduledPostRecord buildRecord({
    PublishRecordStatus status = PublishRecordStatus.scheduled,
  }) {
    return ScheduledPostRecord(
      id: 'publish-1',
      draftId: 'draft-1',
      campaignId: 'campaign-1',
      campaignName: 'Campaign',
      title: 'Queued post',
      channel: SocialChannel.linkedin,
      status: status,
      scheduledAt: DateTime(2026, 4, 18, 9),
      queuedAt: null,
      publishedAt: null,
      updatedAt: DateTime(2026, 4, 18, 8),
      lastError: null,
      denialReasons: const [],
    );
  }

  test('allows scheduled to queued to published transitions', () {
    final queued = service.transition(
      buildRecord(),
      PublishRecordStatus.queued,
      occurredAt: DateTime(2026, 4, 18, 9, 5),
    );
    final published = service.transition(
      queued,
      PublishRecordStatus.published,
      occurredAt: DateTime(2026, 4, 18, 9, 10),
    );

    expect(queued.status, PublishRecordStatus.queued);
    expect(queued.queuedAt, DateTime(2026, 4, 18, 9, 5));
    expect(published.status, PublishRecordStatus.published);
    expect(published.publishedAt, DateTime(2026, 4, 18, 9, 10));
  });

  test('blocks invalid published to failed transition', () {
    expect(
      () => service.transition(
        buildRecord(status: PublishRecordStatus.published),
        PublishRecordStatus.failed,
      ),
      throwsStateError,
    );
  });

  test('captures denial reasons when blocked', () {
    final blocked = service.transition(
      buildRecord(),
      PublishRecordStatus.blocked,
      denialReasons: const [
        DenialReason(
          code: 'approval_missing',
          message: 'Approval is still required.',
        ),
      ],
    );

    expect(blocked.status, PublishRecordStatus.blocked);
    expect(blocked.denialReasons, hasLength(1));
    expect(blocked.denialReasons.first.code, 'approval_missing');
  });
}
