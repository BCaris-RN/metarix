import '../domain/normalized_metric_record.dart';

abstract interface class NormalizedMetricRepository {
  Future<List<NormalizedMetricRecord>> loadNormalizedMetrics({
    String? reportPeriodId,
  });

  Future<void> saveNormalizedMetrics(List<NormalizedMetricRecord> metrics);
}
