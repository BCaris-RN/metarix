import 'package:flutter_test/flutter_test.dart';

import 'package:metarix/metarix_core/models/models.dart';

void main() {
  test('publish job serializes and deserializes', () {
    final publishJob = PublishJob(
      publishJobId: 'job_launch_instagram_01',
      contentId: 'content_launch_week_01',
      platform: SocialPlatform.instagram,
      accountId: 'acct_instagram_demo',
      scheduledAt: DateTime.utc(2026, 4, 18, 18),
      executionStatus: PublishExecutionStatus.queued,
      remotePostId: null,
      attemptCount: 0,
      lastError: null,
      createdAt: DateTime.utc(2026, 4, 15, 9, 35),
      updatedAt: DateTime.utc(2026, 4, 15, 9, 35),
    );

    final roundTrip = PublishJob.fromJson(publishJob.toJson());

    expect(roundTrip.publishJobId, publishJob.publishJobId);
    expect(roundTrip.executionStatus, PublishExecutionStatus.queued);
    expect(roundTrip.remotePostId, isNull);
    expect(roundTrip.scheduledAt, DateTime.utc(2026, 4, 18, 18));
  });

  test('publish job tracks execution transitions', () {
    final queued = PublishJob(
      publishJobId: 'job_launch_instagram_01',
      contentId: 'content_launch_week_01',
      platform: SocialPlatform.instagram,
      accountId: 'acct_instagram_demo',
      scheduledAt: DateTime.utc(2026, 4, 18, 18),
      executionStatus: PublishExecutionStatus.queued,
      remotePostId: null,
      attemptCount: 0,
      lastError: null,
      createdAt: DateTime.utc(2026, 4, 15, 9, 35),
      updatedAt: DateTime.utc(2026, 4, 15, 9, 35),
    );

    final running = queued.transitionTo(
      PublishExecutionStatus.running,
      occurredAt: DateTime.utc(2026, 4, 18, 18, 0, 5),
    );
    final failed = running.transitionTo(
      PublishExecutionStatus.failed,
      occurredAt: DateTime.utc(2026, 4, 18, 18, 0, 8),
      lastError: 'Media validation failed',
    );
    final requeued = failed.transitionTo(
      PublishExecutionStatus.queued,
      occurredAt: DateTime.utc(2026, 4, 18, 18, 1),
    );

    expect(running.attemptCount, 1);
    expect(failed.lastError, 'Media validation failed');
    expect(requeued.lastError, isNull);
    expect(
      () => requeued.transitionTo(PublishExecutionStatus.succeeded),
      throwsA(isA<StateError>()),
    );
  });
}
