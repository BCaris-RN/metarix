import '../../shared/domain/core_models.dart';
import '../../reports/domain/report_models.dart';

class ReportExportFormatter {
  const ReportExportFormatter();

  String format({
    required ReportPeriod period,
    required List<ChannelPerformanceRecord> metrics,
    required List<Takeaway> takeaways,
  }) {
    return [
      'Report Packet',
      period.label,
      '',
      'Metrics:',
      ...metrics.map(
        (metric) =>
            '- ${metric.channel.label}: reach ${metric.reach}, impressions ${metric.impressions}, clicks ${metric.clicks}',
      ),
      '',
      'Takeaways:',
      ...takeaways.map((takeaway) => '- ${takeaway.title}: ${takeaway.whatWeLearned}'),
    ].join('\n');
  }
}
