import '../../../data/local_metarix_gateway.dart';
import '../../publish/domain/publish_models.dart';
import '../../reports/domain/metric_family.dart';
import '../../reports/domain/report_models.dart';
import '../../shared/domain/core_models.dart';
import '../../shared/domain/signal_summary.dart';
import '../../workflow/domain/workflow_models.dart';

class AnalyticsSignalService {
  const AnalyticsSignalService(this._gateway);

  final LocalMetarixGateway _gateway;

  SignalSummary signalForPeriod(String reportPeriodId) {
    final reportPeriods = _gateway.snapshot.reportPeriods;
    final period = reportPeriods.firstWhere(
      (entry) => entry.id == reportPeriodId,
    );
    final comparisonPeriodId =
        _gateway.snapshot.comparisonPeriods[reportPeriodId] ?? reportPeriodId;
    final comparisonPeriod = reportPeriods.firstWhere(
      (entry) => entry.id == comparisonPeriodId,
      orElse: () => period,
    );
    final channelPerformance = _buildChannelPerformance();
    final records =
        channelPerformance
            .where((entry) => entry.reportPeriodId == reportPeriodId)
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
      scopeId: period.id,
      scopeLabel: period.label,
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
          .map((record) => _resolveContentUnit(period, record))
          .toList(),
      sentimentBucket: _sentimentBucket(records),
    );
  }

  TopContentUnitSummary _resolveContentUnit(
    ReportPeriod period,
    ChannelPerformanceRecord record,
  ) {
    final scheduledCandidates =
        _gateway.snapshot.scheduledPosts
            .where((entry) => entry.channel == record.channel)
            .where((entry) => _fallsInPeriod(_signalDate(entry), period))
            .toList()
          ..sort(
            (left, right) => _signalDate(right).compareTo(_signalDate(left)),
          );
    final draftCandidates =
        _gateway.snapshot.drafts
            .where((entry) => entry.targetNetwork == record.channel)
            .where((entry) => _fallsInPeriod(entry.plannedPublishAt, period))
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

  StatusBucketSummary _sentimentBucket(List<ChannelPerformanceRecord> records) {
    final counts = <String, int>{'Positive': 0, 'Mixed': 0, 'Negative': 0};
    for (final record in records) {
      final label = _bucketLabel(record.sentimentScore);
      counts[label] = (counts[label] ?? 0) + 1;
    }

    final ordered = counts.entries.toList()
      ..sort((left, right) => right.value.compareTo(left.value));
    final leader = ordered.first;
    return StatusBucketSummary(
      label: leader.key,
      count: leader.value,
      description:
          '${leader.value} channel signals landed in the ${leader.key.toLowerCase()} bucket.',
    );
  }

  String _bucketLabel(double score) {
    if (score >= 0.67) {
      return 'Positive';
    }
    if (score >= 0.45) {
      return 'Mixed';
    }
    return 'Negative';
  }

  DateTime _signalDate(ScheduledPostRecord record) {
    return record.publishedAt ??
        record.scheduledAt ??
        record.queuedAt ??
        record.updatedAt;
  }

  bool _fallsInPeriod(DateTime? value, ReportPeriod period) {
    if (value == null) {
      return false;
    }
    final endExclusive = period.end.add(const Duration(days: 1));
    return !value.isBefore(period.start) && value.isBefore(endExclusive);
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

  List<ChannelPerformanceRecord> _buildChannelPerformance() {
    if (_gateway.snapshot.normalizedMetrics.isEmpty) {
      return _gateway.snapshot.channelPerformance;
    }

    final grouped = <String, Map<MetricFamily, double>>{};
    for (final metric in _gateway.snapshot.normalizedMetrics) {
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
