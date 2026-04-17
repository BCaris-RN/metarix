import '../../shared/domain/core_models.dart';
import 'metric_family.dart';

class NormalizedMetricRecord {
  const NormalizedMetricRecord({
    required this.id,
    required this.reportPeriodId,
    required this.channel,
    required this.family,
    required this.value,
    required this.unit,
    required this.metricVersion,
    required this.source,
  });

  final String id;
  final String reportPeriodId;
  final SocialChannel channel;
  final MetricFamily family;
  final double value;
  final String unit;
  final String metricVersion;
  final String source;

  Map<String, dynamic> toJson() => {
    'id': id,
    'reportPeriodId': reportPeriodId,
    'channel': channel.name,
    'family': family.storageName,
    'value': value,
    'unit': unit,
    'metricVersion': metricVersion,
    'source': source,
  };

  factory NormalizedMetricRecord.fromJson(Map<String, dynamic> json) =>
      NormalizedMetricRecord(
        id: json['id'] as String,
        reportPeriodId: json['reportPeriodId'] as String,
        channel: SocialChannelX.fromName(json['channel'] as String),
        family: MetricFamilyX.fromName(json['family'] as String),
        value: (json['value'] as num).toDouble(),
        unit: json['unit'] as String,
        metricVersion: json['metricVersion'] as String,
        source: json['source'] as String,
      );
}
