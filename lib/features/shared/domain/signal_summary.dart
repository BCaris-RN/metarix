class SignalSummary {
  const SignalSummary({
    required this.scopeId,
    required this.scopeLabel,
    this.engagement,
    this.topContentUnits = const [],
    this.mentionWatch,
    this.sentimentBucket,
  });

  final String scopeId;
  final String scopeLabel;
  final EngagementSummary? engagement;
  final List<TopContentUnitSummary> topContentUnits;
  final MentionWatchSummary? mentionWatch;
  final StatusBucketSummary? sentimentBucket;
}

class EngagementSummary {
  const EngagementSummary({
    required this.totalEngagements,
    required this.totalReach,
    required this.totalImpressions,
    required this.totalClicks,
    required this.topChannelLabel,
    required this.comparisonLabel,
    required this.comparisonDelta,
  });

  final int totalEngagements;
  final int totalReach;
  final int totalImpressions;
  final int totalClicks;
  final String topChannelLabel;
  final String comparisonLabel;
  final int comparisonDelta;
}

class TopContentUnitSummary {
  const TopContentUnitSummary({
    required this.id,
    required this.title,
    required this.channelLabel,
    required this.statusLabel,
    required this.engagements,
    required this.clicks,
  });

  final String id;
  final String title;
  final String channelLabel;
  final String statusLabel;
  final int engagements;
  final int clicks;
}

class MentionWatchSummary {
  const MentionWatchSummary({
    required this.mentionCount,
    required this.spikeCount,
    required this.actionQueueCount,
    required this.competitorWatchCount,
    required this.topWatchLabel,
  });

  final int mentionCount;
  final int spikeCount;
  final int actionQueueCount;
  final int competitorWatchCount;
  final String topWatchLabel;
}

class StatusBucketSummary {
  const StatusBucketSummary({
    required this.label,
    required this.count,
    required this.description,
  });

  final String label;
  final int count;
  final String description;
}
