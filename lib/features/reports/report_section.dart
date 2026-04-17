import '../../metarix_core/models/model_types.dart';

enum ReportSection {
  successSnapshot,
  platformPerformance,
  standoutResults,
  analysis,
  futureStrategy,
}

extension ReportSectionX on ReportSection {
  String get label => switch (this) {
    ReportSection.successSnapshot => 'Success Snapshot',
    ReportSection.platformPerformance => 'Platform Performance',
    ReportSection.standoutResults => 'Standout Results',
    ReportSection.analysis => 'Analysis',
    ReportSection.futureStrategy => 'Future Strategy',
  };
}

class PeriodComparison {
  const PeriodComparison({
    required this.currentValue,
    required this.previousValue,
    required this.deltaValue,
    required this.deltaPercent,
  });

  final int currentValue;
  final int previousValue;
  final int deltaValue;
  final double deltaPercent;
}

class TopPerformingContent {
  const TopPerformingContent({
    required this.contentId,
    required this.engagements,
    required this.impressions,
    required this.clicks,
  });

  final String contentId;
  final int engagements;
  final int impressions;
  final int clicks;
}

class SuccessSnapshot {
  const SuccessSnapshot({
    required this.headline,
    required this.totalImpressions,
    required this.totalReach,
    required this.totalEngagements,
    required this.totalClicks,
    required this.totalFollowerDelta,
    required this.engagementComparison,
  });

  final String headline;
  final int totalImpressions;
  final int totalReach;
  final int totalEngagements;
  final int totalClicks;
  final int totalFollowerDelta;
  final PeriodComparison engagementComparison;
}

class PlatformPerformanceSummary {
  const PlatformPerformanceSummary({
    required this.platform,
    required this.impressions,
    required this.reach,
    required this.engagements,
    required this.clicks,
    required this.followerDelta,
    required this.videoViews,
    required this.topContent,
    required this.engagementComparison,
  });

  final SocialPlatform platform;
  final int impressions;
  final int reach;
  final int engagements;
  final int clicks;
  final int followerDelta;
  final int videoViews;
  final TopPerformingContent? topContent;
  final PeriodComparison engagementComparison;
}

class StandoutResultItem {
  const StandoutResultItem({required this.title, required this.summary});

  final String title;
  final String summary;
}

class AnalysisInsight {
  const AnalysisInsight({required this.title, required this.body});

  final String title;
  final String body;
}

class FutureStrategyItem {
  const FutureStrategyItem({required this.title, required this.rationale});

  final String title;
  final String rationale;
}

class ReportAssembly {
  const ReportAssembly({
    required this.sectionOrder,
    required this.successSnapshot,
    required this.platformSummaries,
    required this.standoutResults,
    required this.analysis,
    required this.futureStrategy,
    required this.exportMessage,
  });

  final List<ReportSection> sectionOrder;
  final SuccessSnapshot successSnapshot;
  final List<PlatformPerformanceSummary> platformSummaries;
  final List<StandoutResultItem> standoutResults;
  final List<AnalysisInsight> analysis;
  final List<FutureStrategyItem> futureStrategy;
  final String exportMessage;
}
