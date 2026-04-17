import '../../models/connector_models.dart';
import '../../models/metric_snapshot.dart';
import '../../models/model_types.dart';
import '../analytics_connector.dart';
import '../connector_result.dart';

class DemoAnalyticsConnector implements AnalyticsConnector {
  const DemoAnalyticsConnector(this.platform);

  @override
  final SocialPlatform platform;

  @override
  Future<ConnectorResult<List<MetricSnapshot>>> syncAccountMetrics(
    String accountId, {
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    return ConnectorResult.success(
      value: [
        MetricSnapshot(
          snapshotId: 'demo-${platform.name}-$accountId',
          platform: platform,
          accountId: accountId,
          contentId: null,
          periodStart: periodStart,
          periodEnd: periodEnd,
          impressions: 42000 + platform.index * 1200,
          reach: 28000 + platform.index * 900,
          engagements: 2100 + platform.index * 120,
          clicks: 260 + platform.index * 20,
          followerDelta: 140 + platform.index * 8,
          videoViews: 12000 + platform.index * 700,
          saves: 240 + platform.index * 12,
          shares: 90 + platform.index * 6,
          comments: 55 + platform.index * 4,
          likes: 1700 + platform.index * 80,
        ),
      ],
    );
  }

  @override
  Future<ConnectorResult<List<MetricSnapshot>>> syncPostMetrics(
    String contentId, {
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    return ConnectorResult.success(
      value: [
        MetricSnapshot(
          snapshotId: 'demo-${platform.name}-$contentId',
          platform: platform,
          accountId: 'demo-${platform.name}-account',
          contentId: contentId,
          periodStart: periodStart,
          periodEnd: periodEnd,
          impressions: 9000 + platform.index * 400,
          reach: 6100 + platform.index * 300,
          engagements: 740 + platform.index * 45,
          clicks: 88 + platform.index * 7,
          followerDelta: 22 + platform.index,
          videoViews: 2200 + platform.index * 180,
          saves: 58 + platform.index * 3,
          shares: 34 + platform.index * 2,
          comments: 19 + platform.index,
          likes: 620 + platform.index * 30,
        ),
      ],
    );
  }

  @override
  Future<ConnectorResult<AccountAnalyticsSummary>> getAccountSummary(
    String accountId,
  ) async {
    final now = DateTime.now();
    return ConnectorResult.success(
      value: AccountAnalyticsSummary(
        platform: platform,
        accountId: accountId,
        periodStart: now.subtract(const Duration(days: 30)),
        periodEnd: now,
        impressions: 42000 + platform.index * 1200,
        reach: 28000 + platform.index * 900,
        engagements: 2100 + platform.index * 120,
        clicks: 260 + platform.index * 20,
        followerCount: 18000 + platform.index * 1500,
        followerDelta: 140 + platform.index * 8,
      ),
    );
  }
}
