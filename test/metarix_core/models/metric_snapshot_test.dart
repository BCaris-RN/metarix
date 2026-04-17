import 'package:flutter_test/flutter_test.dart';

import 'package:metarix/metarix_core/models/models.dart';

void main() {
  test('metric snapshot serializes and deserializes with content linkage', () {
    final snapshot = MetricSnapshot(
      snapshotId: 'snapshot_instagram_day_20260415',
      platform: SocialPlatform.instagram,
      accountId: 'acct_instagram_demo',
      contentId: 'content_launch_week_01',
      periodStart: DateTime.utc(2026, 4, 15),
      periodEnd: DateTime.utc(2026, 4, 15, 23, 59, 59),
      impressions: 18340,
      reach: 12112,
      engagements: 1048,
      clicks: 214,
      followerDelta: 38,
      videoViews: 7302,
      saves: 76,
      shares: 58,
      comments: 34,
      likes: 880,
    );

    final roundTrip = MetricSnapshot.fromJson(snapshot.toJson());

    expect(roundTrip.snapshotId, snapshot.snapshotId);
    expect(roundTrip.platform, SocialPlatform.instagram);
    expect(roundTrip.contentId, 'content_launch_week_01');
    expect(roundTrip.engagements, 1048);
  });

  test('metric snapshot preserves null content id for account rollups', () {
    final snapshot = MetricSnapshot(
      snapshotId: 'snapshot_linkedin_rollup_20260415',
      platform: SocialPlatform.linkedin,
      accountId: 'acct_linkedin_demo',
      contentId: null,
      periodStart: DateTime.utc(2026, 4, 15),
      periodEnd: DateTime.utc(2026, 4, 15, 23, 59, 59),
      impressions: 6400,
      reach: 4200,
      engagements: 312,
      clicks: 44,
      followerDelta: 9,
      videoViews: 0,
      saves: 12,
      shares: 18,
      comments: 11,
      likes: 271,
    );

    final roundTrip = MetricSnapshot.fromJson(snapshot.toJson());
    final cleared = roundTrip.copyWith(clearContentId: true);

    expect(roundTrip.contentId, isNull);
    expect(cleared.contentId, isNull);
    expect(cleared.followerDelta, 9);
  });
}
