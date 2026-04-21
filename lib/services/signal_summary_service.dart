import '../data/metarix_snapshot.dart';
import '../features/listening/domain/listening_models.dart';
import '../features/publish/domain/publish_models.dart';
import '../features/reports/domain/metric_family.dart';
import '../features/reports/domain/report_models.dart';
import '../features/shared/domain/core_models.dart';
import '../features/shared/domain/signal_summary.dart';
import '../features/workflow/domain/workflow_models.dart';

class ListeningSignalSummarySet {
  const ListeningSignalSummarySet({
    required this.workspaceSignalSummary,
    required this.querySignalSummaries,
  });

  final SignalSummary workspaceSignalSummary;
  final Map<String, SignalSummary> querySignalSummaries;
}

class SignalSummaryService {
  const SignalSummaryService();

  Map<String, SignalSummary> buildReportSignalSummaries(
    MetarixSnapshot snapshot,
  ) {
    final channelPerformance = _buildChannelPerformance(snapshot);
    return {
      for (final period in snapshot.reportPeriods)
        period.id: _buildReportSignalSummary(
          snapshot: snapshot,
          reportPeriod: period,
          channelPerformance: channelPerformance,
        ),
    };
  }

  SignalSummary buildListeningSignalSummary(
    MetarixSnapshot snapshot, {
    String? queryId,
  }) {
    final query = queryId == null
        ? null
        : snapshot.listeningQueries.firstWhere((entry) => entry.id == queryId);
    final mentions = query == null
        ? snapshot.mentions
        : snapshot.mentions
              .where((entry) => entry.queryId == query.id)
              .toList();
    final spikes = query == null
        ? snapshot.spikes
        : snapshot.spikes.where((entry) => entry.queryId == query.id).toList();
    final competitorWatch = query == null || query.targetCompetitors.isEmpty
        ? snapshot.competitorWatch
        : snapshot.competitorWatch
              .where(
                (entry) =>
                    query.targetCompetitors.contains(entry.competitorName),
              )
              .toList();

    return SignalSummary(
      scopeId: query?.id ?? 'workspace-listening',
      scopeLabel: query?.name ?? 'Workspace listening',
      mentionWatch: MentionWatchSummary(
        mentionCount: mentions.length,
        spikeCount: spikes.length,
        actionQueueCount: mentions
            .where((entry) => entry.recommendedAction != InsightAction.observe)
            .length,
        competitorWatchCount: competitorWatch.length,
        topWatchLabel: _topWatchLabel(spikes, competitorWatch, mentions),
      ),
      sentimentBucket: _listeningSentimentBucket(
        snapshot: snapshot,
        workspaceScope: query == null,
        mentions: mentions,
      ),
    );
  }

  ListeningSignalSummarySet buildListeningSignalSummaries(
    MetarixSnapshot snapshot,
  ) {
    return ListeningSignalSummarySet(
      workspaceSignalSummary: buildListeningSignalSummary(snapshot),
      querySignalSummaries: {
        for (final query in snapshot.listeningQueries)
          query.id: buildListeningSignalSummary(snapshot, queryId: query.id),
      },
    );
  }

  String buildTopContentPlaceholder({
    required String activePeriodId,
    required Map<String, SignalSummary> signalSummaries,
  }) {
    final activeSummary = signalSummaries[activePeriodId];
    if (activeSummary == null || activeSummary.topContentUnits.isEmpty) {
      return 'No linked content unit';
    }
    return activeSummary.topContentUnits.first.title;
  }

  SignalSummary _buildReportSignalSummary({
    required MetarixSnapshot snapshot,
    required ReportPeriod reportPeriod,
    required List<ChannelPerformanceRecord> channelPerformance,
  }) {
    final comparisonPeriodId =
        snapshot.comparisonPeriods[reportPeriod.id] ?? reportPeriod.id;
    final comparisonPeriod = snapshot.reportPeriods.firstWhere(
      (entry) => entry.id == comparisonPeriodId,
      orElse: () => reportPeriod,
    );
    final records =
        channelPerformance
            .where((entry) => entry.reportPeriodId == reportPeriod.id)
            .toList()
          ..sort(
            (left, right) => right.engagements.compareTo(left.engagements),
          );
    final comparisonRecords = channelPerformance
        .where((entry) => entry.reportPeriodId == comparisonPeriodId)
        .toList();
    final topChannelLabel = records.isEmpty
        ? 'No channel data'
        : records.first.channel.label;
    final totalEngagements = _sum(records, (entry) => entry.engagements);

    return SignalSummary(
      scopeId: reportPeriod.id,
      scopeLabel: reportPeriod.label,
      engagement: EngagementSummary(
        totalEngagements: totalEngagements,
        totalReach: _sum(records, (entry) => entry.reach),
        totalImpressions: _sum(records, (entry) => entry.impressions),
        totalClicks: _sum(records, (entry) => entry.clicks),
        topChannelLabel: topChannelLabel,
        comparisonLabel: comparisonPeriod.label,
        comparisonDelta:
            totalEngagements -
            _sum(comparisonRecords, (entry) => entry.engagements),
      ),
      topContentUnits: records
          .map(
            (record) => _resolveContentUnit(
              snapshot: snapshot,
              reportPeriod: reportPeriod,
              record: record,
            ),
          )
          .toList(),
      sentimentBucket: _analyticsSentimentBucket(records),
    );
  }

  TopContentUnitSummary _resolveContentUnit({
    required MetarixSnapshot snapshot,
    required ReportPeriod reportPeriod,
    required ChannelPerformanceRecord record,
  }) {
    final scheduledCandidates =
        snapshot.scheduledPosts
            .where((entry) => entry.channel == record.channel)
            .where((entry) => _fallsInPeriod(_signalDate(entry), reportPeriod))
            .toList()
          ..sort(
            (left, right) => _signalDate(right).compareTo(_signalDate(left)),
          );
    final draftCandidates =
        snapshot.drafts
            .where((entry) => entry.targetNetwork == record.channel)
            .where(
              (entry) => _fallsInPeriod(entry.plannedPublishAt, reportPeriod),
            )
            .toList()
          ..sort((left, right) {
            final leftDate =
                left.plannedPublishAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final rightDate =
                right.plannedPublishAt ??
                DateTime.fromMillisecondsSinceEpoch(0);
            return rightDate.compareTo(leftDate);
          });

    final scheduled = scheduledCandidates.isNotEmpty
        ? scheduledCandidates.first
        : null;
    if (scheduled != null) {
      return TopContentUnitSummary(
        id: scheduled.id,
        title: scheduled.title,
        channelLabel: scheduled.channel.label,
        statusLabel: scheduled.status.label,
        engagements: record.engagements,
        clicks: record.clicks,
      );
    }

    final draft = draftCandidates.isNotEmpty ? draftCandidates.first : null;
    if (draft != null) {
      return TopContentUnitSummary(
        id: draft.id,
        title: draft.title,
        channelLabel: draft.targetNetwork.label,
        statusLabel: draft.currentState.label,
        engagements: record.engagements,
        clicks: record.clicks,
      );
    }

    return TopContentUnitSummary(
      id: 'content-unit-${record.id}',
      title: '${record.channel.label} content unit',
      channelLabel: record.channel.label,
      statusLabel: 'Unlinked',
      engagements: record.engagements,
      clicks: record.clicks,
    );
  }

  StatusBucketSummary _analyticsSentimentBucket(
    List<ChannelPerformanceRecord> records,
  ) {
    final counts = <String, int>{'Positive': 0, 'Mixed': 0, 'Negative': 0};
    for (final record in records) {
      final label = _analyticsBucketLabel(record.sentimentScore);
      counts[label] = (counts[label] ?? 0) + 1;
    }

    final leader = _leadingBucket(counts);
    return StatusBucketSummary(
      label: leader.key,
      count: leader.value,
      description:
          '${leader.value} channel signals landed in the ${leader.key.toLowerCase()} bucket.',
    );
  }

  StatusBucketSummary _listeningSentimentBucket({
    required MetarixSnapshot snapshot,
    required bool workspaceScope,
    required List<Mention> mentions,
  }) {
    final counts = workspaceScope
        ? <String, int>{
            'Positive': snapshot.sentimentSummary.positive,
            'Mixed': snapshot.sentimentSummary.mixed,
            'Negative': snapshot.sentimentSummary.negative,
          }
        : <String, int>{'Positive': 0, 'Mixed': 0, 'Negative': 0};

    if (!workspaceScope) {
      for (final mention in mentions) {
        final label = _normalizeSentimentLabel(mention.sentimentLabel);
        counts[label] = (counts[label] ?? 0) + 1;
      }
    }

    final leader = _leadingBucket(counts);
    return StatusBucketSummary(
      label: leader.key,
      count: leader.value,
      description:
          '${leader.value} listening records are in the ${leader.key.toLowerCase()} bucket.',
    );
  }

  MapEntry<String, int> _leadingBucket(Map<String, int> counts) {
    final order = <String, int>{'Positive': 0, 'Mixed': 1, 'Negative': 2};
    final ordered = counts.entries.toList()
      ..sort((left, right) {
        final byValue = right.value.compareTo(left.value);
        if (byValue != 0) {
          return byValue;
        }
        return (order[left.key] ?? order.length).compareTo(
          order[right.key] ?? order.length,
        );
      });
    return ordered.first;
  }

  String _analyticsBucketLabel(double score) {
    if (score >= 0.67) {
      return 'Positive';
    }
    if (score >= 0.45) {
      return 'Mixed';
    }
    return 'Negative';
  }

  String _topWatchLabel(
    List<SpikeEvent> spikes,
    List<CompetitorWatchEntry> competitorWatch,
    List<Mention> mentions,
  ) {
    if (spikes.isNotEmpty) {
      return spikes.first.headline;
    }
    if (competitorWatch.isNotEmpty) {
      final ordered = List<CompetitorWatchEntry>.from(
        competitorWatch,
      )..sort((left, right) => right.shareOfVoice.compareTo(left.shareOfVoice));
      return ordered.first.competitorName;
    }
    if (mentions.isNotEmpty) {
      return mentions.first.source;
    }
    return 'No active watch signal';
  }

  String _normalizeSentimentLabel(String value) {
    switch (value.toLowerCase()) {
      case 'positive':
        return 'Positive';
      case 'negative':
        return 'Negative';
      default:
        return 'Mixed';
    }
  }

  DateTime _signalDate(ScheduledPostRecord record) {
    return record.publishedAt ??
        record.scheduledAt ??
        record.queuedAt ??
        record.updatedAt;
  }

  bool _fallsInPeriod(DateTime? value, ReportPeriod reportPeriod) {
    if (value == null) {
      return false;
    }
    final endExclusive = reportPeriod.end.add(const Duration(days: 1));
    return !value.isBefore(reportPeriod.start) && value.isBefore(endExclusive);
  }

  int _sum(
    List<ChannelPerformanceRecord> records,
    int Function(ChannelPerformanceRecord entry) selector,
  ) {
    var total = 0;
    for (final entry in records) {
      total += selector(entry);
    }
    return total;
  }

  List<ChannelPerformanceRecord> _buildChannelPerformance(
    MetarixSnapshot snapshot,
  ) {
    if (snapshot.normalizedMetrics.isEmpty) {
      return snapshot.channelPerformance;
    }

    final grouped = <String, Map<MetricFamily, double>>{};
    for (final metric in snapshot.normalizedMetrics) {
      final key = '${metric.reportPeriodId}:${metric.channel.name}';
      grouped.putIfAbsent(key, () => <MetricFamily, double>{});
      grouped[key]!.update(
        metric.family,
        (value) => value + metric.value,
        ifAbsent: () => metric.value,
      );
    }

    return grouped.entries.map((entry) {
      final parts = entry.key.split(':');
      final reportPeriodId = parts.first;
      final channel = SocialChannelX.fromName(parts.last);
      final values = entry.value;
      return ChannelPerformanceRecord(
        id: 'performance-${channel.name}-$reportPeriodId',
        reportPeriodId: reportPeriodId,
        channel: channel,
        reach: (values[MetricFamily.reach] ?? 0).round(),
        impressions: (values[MetricFamily.impressions] ?? 0).round(),
        engagements: (values[MetricFamily.engagement] ?? 0).round(),
        clicks: (values[MetricFamily.clicks] ?? 0).round(),
        sentimentScore: values[MetricFamily.sentimentScore] ?? 0,
      );
    }).toList();
  }
}
