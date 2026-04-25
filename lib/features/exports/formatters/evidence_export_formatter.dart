import '../../schedule/domain/schedule_models.dart';
import '../../shared/domain/core_models.dart';
import '../../workflow/domain/workflow_models.dart';

class EvidenceExportFormatter {
  const EvidenceExportFormatter();

  String format({
    required PostDraft draft,
    required ScheduleRecord? schedule,
    required List<DenialReason> denialReasons,
  }) {
    final posture = denialReasons.isEmpty ? 'complete' : 'partial';
    return [
      'Evidence Bundle',
      'Draft: ${draft.title}',
      'Posture: $posture',
      'Evidence codes:',
      ...draft.evidenceCodes.map((code) => '- $code'),
      if (schedule != null) ...[
        '',
        'Schedule:',
        '- ${schedule.channel.label} at ${schedule.scheduledAt.toIso8601String()}',
      ],
      if (denialReasons.isNotEmpty) ...[
        '',
        'Denial reasons:',
        ...denialReasons.map((reason) => '- ${reason.message}'),
      ],
    ].join('\n');
  }
}
