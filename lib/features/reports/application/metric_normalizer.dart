import '../../../connectors/connector_registry.dart';
import '../../shared/domain/core_models.dart';
import '../../connectors/adapters/channel_metric_mapper.dart';
import '../domain/normalized_metric_record.dart';

class MetricNormalizer {
  MetricNormalizer(
    this._connectorRegistry,
    this._metricMapper,
    this._metricVersion,
  );

  final ConnectorRegistry _connectorRegistry;
  final ChannelMetricMapper _metricMapper;
  final String _metricVersion;

  List<NormalizedMetricRecord> normalizeForPeriods(
    List<String> reportPeriodIds,
  ) {
    final records = <NormalizedMetricRecord>[];
    for (final reportPeriodId in reportPeriodIds) {
      for (final channel in SocialChannel.values) {
        final connector = _connectorRegistry.connectorFor(channel);
        if (!connector.canFetchAnalytics) {
          continue;
        }
        final payload = connector.fetchAnalyticsPayload(reportPeriodId);
        records.addAll(
          _metricMapper.mapPayload(
            channel: channel,
            reportPeriodId: reportPeriodId,
            payload: payload,
            metricVersion: _metricVersion,
          ),
        );
      }
    }
    return records;
  }
}
