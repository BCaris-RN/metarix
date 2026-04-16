import '../../reports/domain/metric_family.dart';
import '../../reports/domain/normalized_metric_record.dart';
import '../../shared/domain/core_models.dart';

class ChannelMetricMapper {
  const ChannelMetricMapper();

  List<NormalizedMetricRecord> mapPayload({
    required SocialChannel channel,
    required String reportPeriodId,
    required Map<String, dynamic> payload,
    required String metricVersion,
  }) {
    final units = <MetricFamily, String>{
      MetricFamily.followers: 'count',
      MetricFamily.reach: 'count',
      MetricFamily.impressions: 'count',
      MetricFamily.engagement: 'count',
      MetricFamily.clicks: 'count',
      MetricFamily.views: 'count',
      MetricFamily.shares: 'count',
      MetricFamily.comments: 'count',
      MetricFamily.sentimentScore: 'score',
      MetricFamily.responseTime: 'hours',
    };

    return MetricFamily.values
        .where((family) => payload.containsKey(family.storageName))
        .map(
          (family) => NormalizedMetricRecord(
            id: '$reportPeriodId-${channel.name}-${family.storageName}',
            reportPeriodId: reportPeriodId,
            channel: channel,
            family: family,
            value: (payload[family.storageName] as num).toDouble(),
            unit: units[family]!,
            metricVersion: metricVersion,
            source: '${channel.name}_sandbox',
          ),
        )
        .toList();
  }
}
