import 'package:flutter_test/flutter_test.dart';

import 'package:metarix/features/reports/report_assembly_service.dart';
import 'package:metarix/metarix_core/models/models.dart';

void main() {
  const service = ReportAssemblyService();

  final currentMetrics = [
    MetricSnapshot(
      snapshotId: 'curr-ig-1',
      platform: SocialPlatform.instagram,
      accountId: 'acct-ig',
      contentId: 'content-ig-launch',
      periodStart: DateTime.utc(2026, 4, 1),
      periodEnd: DateTime.utc(2026, 4, 15),
      impressions: 18000,
      reach: 12000,
      engagements: 1450,
      clicks: 210,
      followerDelta: 42,
      videoViews: 5200,
      saves: 90,
      shares: 40,
      comments: 34,
      likes: 1286,
    ),
    MetricSnapshot(
      snapshotId: 'curr-ig-2',
      platform: SocialPlatform.instagram,
      accountId: 'acct-ig',
      contentId: 'content-ig-launch',
      periodStart: DateTime.utc(2026, 4, 1),
      periodEnd: DateTime.utc(2026, 4, 15),
      impressions: 2000,
      reach: 1400,
      engagements: 110,
      clicks: 18,
      followerDelta: 4,
      videoViews: 620,
      saves: 8,
      shares: 2,
      comments: 5,
      likes: 95,
    ),
    MetricSnapshot(
      snapshotId: 'curr-li-1',
      platform: SocialPlatform.linkedin,
      accountId: 'acct-li',
      contentId: 'content-li-essay',
      periodStart: DateTime.utc(2026, 4, 1),
      periodEnd: DateTime.utc(2026, 4, 15),
      impressions: 9600,
      reach: 7100,
      engagements: 860,
      clicks: 265,
      followerDelta: 25,
      videoViews: 0,
      saves: 24,
      shares: 33,
      comments: 49,
      likes: 754,
    ),
  ];

  final previousMetrics = [
    MetricSnapshot(
      snapshotId: 'prev-ig-1',
      platform: SocialPlatform.instagram,
      accountId: 'acct-ig',
      contentId: 'content-ig-older',
      periodStart: DateTime.utc(2026, 3, 16),
      periodEnd: DateTime.utc(2026, 3, 31),
      impressions: 15000,
      reach: 10100,
      engagements: 1210,
      clicks: 180,
      followerDelta: 31,
      videoViews: 4300,
      saves: 71,
      shares: 32,
      comments: 25,
      likes: 1082,
    ),
    MetricSnapshot(
      snapshotId: 'prev-li-1',
      platform: SocialPlatform.linkedin,
      accountId: 'acct-li',
      contentId: 'content-li-older',
      periodStart: DateTime.utc(2026, 3, 16),
      periodEnd: DateTime.utc(2026, 3, 31),
      impressions: 8800,
      reach: 6450,
      engagements: 740,
      clicks: 230,
      followerDelta: 20,
      videoViews: 0,
      saves: 16,
      shares: 28,
      comments: 39,
      likes: 657,
    ),
  ];

  test(
    'assembly derives platform summaries and comparisons for every platform',
    () {
      final assembly = service.assemble(
        currentMetrics: currentMetrics,
        previousMetrics: previousMetrics,
        notableInsights: const ['Lead carousel hooks lifted comments.'],
      );

      expect(assembly.platformSummaries.length, 5);

      final instagram = assembly.platformSummaries.firstWhere(
        (summary) => summary.platform == SocialPlatform.instagram,
      );

      expect(instagram.impressions, 20000);
      expect(instagram.engagements, 1560);
      expect(instagram.topContent?.contentId, 'content-ig-launch');
      expect(instagram.engagementComparison.deltaValue, 350);
    },
  );

  test(
    'assembly includes success snapshot, standout results, and analysis',
    () {
      final assembly = service.assemble(
        currentMetrics: currentMetrics,
        previousMetrics: previousMetrics,
        notableInsights: const ['Lead carousel hooks lifted comments.'],
      );

      expect(assembly.successSnapshot.totalEngagements, 2420);
      expect(assembly.standoutResults, isNotEmpty);
      expect(assembly.analysis.last.body, contains('Lead carousel hooks'));
      expect(assembly.futureStrategy, isNotEmpty);
    },
  );
}
