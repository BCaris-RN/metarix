import '../../../data/local_metarix_gateway.dart';
import '../../reports/domain/report_models.dart';
import '../../schedule/domain/schedule_models.dart';
import '../../strategy/domain/strategy_models.dart';
import '../../workflow/domain/workflow_models.dart';
import '../domain/export_artifact.dart';
import '../formatters/evidence_export_formatter.dart';
import '../formatters/report_export_formatter.dart';
import '../formatters/strategy_export_formatter.dart';

class ExportService {
  ExportService(
    this._gateway,
    this._strategyFormatter,
    this._reportFormatter,
    this._evidenceFormatter,
  );

  final LocalMetarixGateway _gateway;
  final StrategyExportFormatter _strategyFormatter;
  final ReportExportFormatter _reportFormatter;
  final EvidenceExportFormatter _evidenceFormatter;

  Future<ExportArtifact> exportStrategySummary(StrategyRecord strategy) async {
    final artifact = ExportArtifact(
      id: _gateway.createId('export'),
      type: ExportArtifactType.strategySummary,
      objectId: strategy.brand.id,
      fileName:
          'strategy-${strategy.brand.name.toLowerCase().replaceAll(' ', '-')}.txt',
      posture: 'complete',
      content: _strategyFormatter.format(strategy),
      generatedAt: DateTime.now(),
    );
    await _gateway.saveExportArtifact(artifact);
    return artifact;
  }

  Future<ExportArtifact> exportReportPacket({
    required ReportPeriod period,
    required List<ChannelPerformanceRecord> metrics,
    required List<Takeaway> takeaways,
  }) async {
    final artifact = ExportArtifact(
      id: _gateway.createId('export'),
      type: ExportArtifactType.reportPacket,
      objectId: period.id,
      fileName: 'report-${period.label.toLowerCase().replaceAll(' ', '-')}.txt',
      posture: 'complete',
      content: _reportFormatter.format(
        period: period,
        metrics: metrics,
        takeaways: takeaways,
      ),
      generatedAt: DateTime.now(),
    );
    await _gateway.saveExportArtifact(artifact);
    return artifact;
  }

  Future<ExportArtifact> exportEvidenceBundle({
    required PostDraft draft,
    required ScheduleRecord? schedule,
    required List<DenialReason> denialReasons,
  }) async {
    final artifact = ExportArtifact(
      id: _gateway.createId('export'),
      type: ExportArtifactType.evidenceBundle,
      objectId: draft.id,
      fileName: 'evidence-${draft.title.toLowerCase().replaceAll(' ', '-')}.txt',
      posture: denialReasons.isEmpty ? 'complete' : 'partial',
      content: _evidenceFormatter.format(
        draft: draft,
        schedule: schedule,
        denialReasons: denialReasons,
      ),
      generatedAt: DateTime.now(),
    );
    await _gateway.saveExportArtifact(artifact);
    return artifact;
  }
}
