import '../../metarix_core/models/metric_snapshot.dart';
import '../../metarix_core/models/model_types.dart';
import 'report_section.dart';

class ReportAssemblyService {
  const ReportAssemblyService();

  ReportAssembly assemble({
    required List<MetricSnapshot> currentMetrics,
    required List<MetricSnapshot> previousMetrics,
    required List<String> notableInsights,
  }) {
    final platformSummaries = SocialPlatform.values
        .map(
          (platform) => _buildPlatformSummary(
            platform: platform,
            currentMetrics: currentMetrics
                .where((entry) => entry.platform == platform)
                .toList(),
            previousMetrics: previousMetrics
                .where((entry) => entry.platform == platform)
                .toList(),
          ),
        )
        .toList();

    final successSnapshot = _buildSuccessSnapshot(
      currentMetrics: currentMetrics,
      previousMetrics: previousMetrics,
      platformSummaries: platformSummaries,
    );

    return ReportAssembly(
      sectionOrder: const [
        ReportSection.successSnapshot,
        ReportSection.platformPerformance,
        ReportSection.standoutResults,
        ReportSection.analysis,
        ReportSection.futureStrategy,
      ],
      successSnapshot: successSnapshot,
      platformSummaries: platformSummaries,
      standoutResults: _buildStandoutResults(platformSummaries),
      analysis: _buildAnalysis(platformSummaries, notableInsights),
      futureStrategy: _buildFutureStrategy(platformSummaries),
      exportMessage:
          'PDF and PPT export are stubbed until live export wiring is added.',
    );
  }

  PlatformPerformanceSummary _buildPlatformSummary({
    required SocialPlatform platform,
    required List<MetricSnapshot> currentMetrics,
    required List<MetricSnapshot> previousMetrics,
  }) {
    final currentEngagements = _sum(
      currentMetrics,
      (entry) => entry.engagements,
    );
    final previousEngagements = _sum(
      previousMetrics,
      (entry) => entry.engagements,
    );
    final groupedContent = <String, List<MetricSnapshot>>{};

    for (final metric in currentMetrics) {
      final contentId = metric.contentId;
      if (contentId == null) {
        continue;
      }
      groupedContent
          .putIfAbsent(contentId, () => <MetricSnapshot>[])
          .add(metric);
    }

    TopPerformingContent? topContent;
    if (groupedContent.isNotEmpty) {
      final sorted = groupedContent.entries.toList()
        ..sort((left, right) {
          final rightScore = _sum(right.value, (entry) => entry.engagements);
          final leftScore = _sum(left.value, (entry) => entry.engagements);
          return rightScore.compareTo(leftScore);
        });
      final winner = sorted.first;
      topContent = TopPerformingContent(
        contentId: winner.key,
        engagements: _sum(winner.value, (entry) => entry.engagements),
        impressions: _sum(winner.value, (entry) => entry.impressions),
        clicks: _sum(winner.value, (entry) => entry.clicks),
      );
    }

    return PlatformPerformanceSummary(
      platform: platform,
      impressions: _sum(currentMetrics, (entry) => entry.impressions),
      reach: _sum(currentMetrics, (entry) => entry.reach),
      engagements: currentEngagements,
      clicks: _sum(currentMetrics, (entry) => entry.clicks),
      followerDelta: _sum(currentMetrics, (entry) => entry.followerDelta),
      videoViews: _sum(currentMetrics, (entry) => entry.videoViews),
      topContent: topContent,
      engagementComparison: _comparison(
        currentEngagements,
        previousEngagements,
      ),
    );
  }

  SuccessSnapshot _buildSuccessSnapshot({
    required List<MetricSnapshot> currentMetrics,
    required List<MetricSnapshot> previousMetrics,
    required List<PlatformPerformanceSummary> platformSummaries,
  }) {
    final strongestPlatform = platformSummaries.reduce((left, right) {
      return right.engagements > left.engagements ? right : left;
    });
    final currentEngagements = _sum(
      currentMetrics,
      (entry) => entry.engagements,
    );
    final previousEngagements = _sum(
      previousMetrics,
      (entry) => entry.engagements,
    );

    return SuccessSnapshot(
      headline:
          '${strongestPlatform.platform.label} led the reporting window with ${strongestPlatform.engagements} engagements.',
      totalImpressions: _sum(currentMetrics, (entry) => entry.impressions),
      totalReach: _sum(currentMetrics, (entry) => entry.reach),
      totalEngagements: currentEngagements,
      totalClicks: _sum(currentMetrics, (entry) => entry.clicks),
      totalFollowerDelta: _sum(currentMetrics, (entry) => entry.followerDelta),
      engagementComparison: _comparison(
        currentEngagements,
        previousEngagements,
      ),
    );
  }

  List<StandoutResultItem> _buildStandoutResults(
    List<PlatformPerformanceSummary> platformSummaries,
  ) {
    final strongestPlatform = platformSummaries.reduce((left, right) {
      return right.engagements > left.engagements ? right : left;
    });
    final highestFollowerLift = platformSummaries.reduce((left, right) {
      return right.followerDelta > left.followerDelta ? right : left;
    });
    final bestTopContent =
        platformSummaries
            .where((summary) => summary.topContent != null)
            .map((summary) => summary.topContent!)
            .toList()
          ..sort(
            (left, right) => right.engagements.compareTo(left.engagements),
          );

    return [
      StandoutResultItem(
        title: '${strongestPlatform.platform.label} performance',
        summary:
            '${strongestPlatform.engagements} engagements and ${strongestPlatform.clicks} clicks made this the strongest platform section.',
      ),
      StandoutResultItem(
        title: '${highestFollowerLift.platform.label} audience growth',
        summary:
            '${highestFollowerLift.followerDelta} net followers created the best audience lift in the current period.',
      ),
      if (bestTopContent.isNotEmpty)
        StandoutResultItem(
          title: 'Top content winner',
          summary:
              '${bestTopContent.first.contentId} generated ${bestTopContent.first.engagements} engagements.',
        ),
    ];
  }

  List<AnalysisInsight> _buildAnalysis(
    List<PlatformPerformanceSummary> platformSummaries,
    List<String> notableInsights,
  ) {
    final videoLeader = platformSummaries.reduce((left, right) {
      return right.videoViews > left.videoViews ? right : left;
    });
    final clickLeader = platformSummaries.reduce((left, right) {
      return right.clicks > left.clicks ? right : left;
    });

    final insights = <AnalysisInsight>[
      AnalysisInsight(
        title: 'Video momentum',
        body:
            '${videoLeader.platform.label} drove the strongest video response with ${videoLeader.videoViews} views.',
      ),
      AnalysisInsight(
        title: 'Traffic quality',
        body:
            '${clickLeader.platform.label} produced the most clicks at ${clickLeader.clicks}, making it the clearest traffic lever.',
      ),
    ];

    insights.addAll(
      notableInsights.map(
        (entry) => AnalysisInsight(title: 'Notable insight', body: entry),
      ),
    );
    return insights;
  }

  List<FutureStrategyItem> _buildFutureStrategy(
    List<PlatformPerformanceSummary> platformSummaries,
  ) {
    final strongestPlatform = platformSummaries.reduce((left, right) {
      return right.engagements > left.engagements ? right : left;
    });
    final clickLeader = platformSummaries.reduce((left, right) {
      return right.clicks > left.clicks ? right : left;
    });

    return [
      FutureStrategyItem(
        title: 'Double down on ${strongestPlatform.platform.label}',
        rationale:
            'Keep a larger share of the next planning cycle on the platform with the strongest engagement density.',
      ),
      FutureStrategyItem(
        title:
            'Build more conversion-focused posts for ${clickLeader.platform.label}',
        rationale:
            'This platform is translating attention into action more reliably than the rest of the mix.',
      ),
    ];
  }

  PeriodComparison _comparison(int currentValue, int previousValue) {
    final deltaValue = currentValue - previousValue;
    final double deltaPercent = previousValue == 0
        ? 0.0
        : (deltaValue / previousValue) * 100;
    return PeriodComparison(
      currentValue: currentValue,
      previousValue: previousValue,
      deltaValue: deltaValue,
      deltaPercent: deltaPercent,
    );
  }

  int _sum(
    List<MetricSnapshot> metrics,
    int Function(MetricSnapshot) selector,
  ) {
    var total = 0;
    for (final entry in metrics) {
      total += selector(entry);
    }
    return total;
  }
}
