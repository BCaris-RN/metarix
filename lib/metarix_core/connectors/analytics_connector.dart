import '../models/connector_models.dart';
import '../models/metric_snapshot.dart';
import '../models/model_types.dart';
import 'connector_result.dart';

abstract class AnalyticsConnector {
  SocialPlatform get platform;

  Future<ConnectorResult<List<MetricSnapshot>>> syncAccountMetrics(
    String accountId, {
    required DateTime periodStart,
    required DateTime periodEnd,
  });

  Future<ConnectorResult<List<MetricSnapshot>>> syncPostMetrics(
    String contentId, {
    required DateTime periodStart,
    required DateTime periodEnd,
  });

  Future<ConnectorResult<AccountAnalyticsSummary>> getAccountSummary(
    String accountId,
  );
}
