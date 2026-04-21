import 'package:flutter_test/flutter_test.dart';

import 'package:metarix/features/publish/domain/publish_models.dart';
import 'package:metarix/features/shared/domain/core_models.dart';

void main() {
  test('scheduled post record round-trips platform persistence fields', () {
    final record = ScheduledPostRecord(
      id: 'publish-1',
      draftId: 'draft-1',
      campaignId: 'campaign-1',
      campaignName: 'Launch',
      title: 'LinkedIn launch post',
      channel: SocialChannel.linkedin,
      status: PublishRecordStatus.published,
      scheduledAt: DateTime.utc(2026, 4, 18, 18, 0),
      queuedAt: DateTime.utc(2026, 4, 18, 18, 2),
      publishedAt: DateTime.utc(2026, 4, 18, 18, 5),
      updatedAt: DateTime.utc(2026, 4, 18, 18, 5),
      lastError: null,
      denialReasons: const [],
      externalPlatformPostId: 'urn:li:share:123456789',
      externalAccountId: 'urn:li:person:abc123',
      platformPublishStatus: 'published',
      platformErrorCode: null,
      platformErrorMessage: null,
      publishedAtIso: '2026-04-18T18:05:00.000Z',
    );

    final roundTrip = ScheduledPostRecord.fromJson(record.toJson());

    expect(roundTrip.externalPlatformPostId, 'urn:li:share:123456789');
    expect(roundTrip.externalAccountId, 'urn:li:person:abc123');
    expect(roundTrip.platformPublishStatus, 'published');
    expect(roundTrip.publishedAtIso, '2026-04-18T18:05:00.000Z');
  });
}
