import 'package:flutter_test/flutter_test.dart';

import 'package:metarix/metarix_core/models/models.dart';

void main() {
  test('content item serializes and deserializes', () {
    final contentItem = ContentItem(
      contentId: 'content_launch_week_01',
      title: 'Launch week reel',
      campaign: 'Spring Launch',
      pillar: 'Product Story',
      objective: 'Drive profile visits',
      status: ContentStatus.scheduled,
      targetPlatforms: const [
        SocialPlatform.instagram,
        SocialPlatform.facebook,
      ],
      assetIds: const ['asset_reel_launch_01'],
      captionVariantIds: const [
        'caption_instagram_launch_01',
        'caption_facebook_launch_01',
      ],
      scheduledAt: DateTime.utc(2026, 4, 18, 18),
      publishedAt: null,
      createdAt: DateTime.utc(2026, 4, 13, 14),
      updatedAt: DateTime.utc(2026, 4, 15, 9, 30),
    );

    final roundTrip = ContentItem.fromJson(contentItem.toJson());

    expect(roundTrip.contentId, contentItem.contentId);
    expect(roundTrip.status, ContentStatus.scheduled);
    expect(roundTrip.targetPlatforms, contentItem.targetPlatforms);
    expect(roundTrip.scheduledAt, DateTime.utc(2026, 4, 18, 18));
    expect(roundTrip.publishedAt, isNull);
  });

  test('content item supports valid status transitions', () {
    final drafted = ContentItem(
      contentId: 'content_launch_week_01',
      title: 'Launch week reel',
      campaign: 'Spring Launch',
      pillar: 'Product Story',
      objective: 'Drive profile visits',
      status: ContentStatus.draft,
      targetPlatforms: const [SocialPlatform.instagram],
      assetIds: const ['asset_reel_launch_01'],
      captionVariantIds: const ['caption_instagram_launch_01'],
      scheduledAt: null,
      publishedAt: null,
      createdAt: DateTime.utc(2026, 4, 13, 14),
      updatedAt: DateTime.utc(2026, 4, 13, 14),
    );

    final approved = drafted.transitionTo(
      ContentStatus.approved,
      occurredAt: DateTime.utc(2026, 4, 15, 9),
    );
    final scheduled = approved.transitionTo(
      ContentStatus.scheduled,
      occurredAt: DateTime.utc(2026, 4, 18, 18),
    );
    final published = scheduled.transitionTo(
      ContentStatus.published,
      occurredAt: DateTime.utc(2026, 4, 18, 18, 5),
    );

    expect(approved.status, ContentStatus.approved);
    expect(scheduled.scheduledAt, DateTime.utc(2026, 4, 18, 18));
    expect(published.publishedAt, DateTime.utc(2026, 4, 18, 18, 5));
    expect(
      () => published.transitionTo(ContentStatus.draft),
      throwsA(isA<StateError>()),
    );
  });
}
