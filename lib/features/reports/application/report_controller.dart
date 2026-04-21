import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';

import '../../../data/local_metarix_gateway.dart';
import '../../../repositories/report_repository.dart';
import '../../../runtime/activity/activity_event.dart';
import '../../../runtime/activity/activity_event_type.dart';
import '../domain/report_models.dart';

class ReportController extends ChangeNotifier {
  ReportController(this._reportRepository, this._gateway) {
    _gateway.addListener(notifyListeners);
  }

  final ReportRepository _reportRepository;
  final LocalMetarixGateway _gateway;

  ReportSnapshot get snapshot => _gateway.loadReportDataSync();

  String _exportStatus = 'Export not started.';

  String get exportStatus => _exportStatus;

  Future<void> saveTakeaway(Takeaway takeaway) async {
    await _reportRepository.saveTakeaway(takeaway);
    await _recordActivity(
      periodId: takeaway.reportPeriodId,
      eventType: ActivityEventType.updated,
      eventClass: ActivityEventClass.normalAction,
      reason: 'Report takeaway was saved.',
    );
  }

  Future<void> saveLearning(LearningEntry learning) async {
    await _reportRepository.saveLearning(learning);
    await _recordActivity(
      periodId: learning.reportPeriodId,
      eventType: ActivityEventType.updated,
      eventClass: ActivityEventClass.normalAction,
      reason: 'Report learning was saved.',
    );
  }

  Future<void> saveRecommendation(Recommendation recommendation) async {
    await _reportRepository.saveRecommendation(recommendation);
    await _recordActivity(
      periodId: recommendation.reportPeriodId,
      eventType: ActivityEventType.recommendationCreated,
      eventClass: ActivityEventClass.recommendation,
      reason: 'A report recommendation was created or updated.',
      detail: recommendation.title,
    );
  }

  Future<void> generateReport(String periodId) {
    return _recordActivity(
      periodId: periodId,
      eventType: ActivityEventType.reportGenerated,
      eventClass: ActivityEventClass.systemAction,
      reason: 'Report snapshot generated from current workspace metrics.',
    );
  }

  Future<void> exportReport(String periodId, String format) async {
    final snapshot = _gateway.loadReportDataSync();
    final period = snapshot.reportPeriods.firstWhere(
      (entry) => entry.id == periodId,
    );
    final signalSummary = snapshot.signalSummaryFor(periodId);
    final exportDir = await _exportDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final safeFormat = format.toLowerCase();
    final file = File(
      '${exportDir.path}\\${period.id}-$timestamp.$safeFormat',
    );

    final payload = {
      'workspace': _gateway.workspace.name,
      'period': period.toJson(),
      'successSnapshot': snapshot.successSnapshot,
      'signalSummary': {
        'engagement': signalSummary.engagement == null
            ? null
            : {
                'topChannelLabel': signalSummary.engagement!.topChannelLabel,
                'totalImpressions': signalSummary.engagement!.totalImpressions,
                'totalReach': signalSummary.engagement!.totalReach,
                'totalEngagements': signalSummary.engagement!.totalEngagements,
                'totalClicks': signalSummary.engagement!.totalClicks,
                'comparisonDelta': signalSummary.engagement!.comparisonDelta,
                'comparisonLabel': signalSummary.engagement!.comparisonLabel,
              },
        'topContentUnits': signalSummary.topContentUnits
            .map(
              (entry) => {
                'channelLabel': entry.channelLabel,
                'title': entry.title,
                'engagements': entry.engagements,
                'clicks': entry.clicks,
              },
            )
            .toList(),
        'takeaways': snapshot.takeaways
            .where((entry) => entry.reportPeriodId == periodId)
            .map((entry) => entry.toJson())
            .toList(),
        'learningEntries': snapshot.overallLearnings
            .where((entry) => entry.reportPeriodId == periodId)
            .map((entry) => entry.toJson())
            .toList(),
        'futureActions': snapshot.futureActions
            .where((entry) => entry.reportPeriodId == periodId)
            .map((entry) => entry.toJson())
            .toList(),
        'standoutResults': snapshot.standoutResults
            .where((entry) => entry.reportPeriodId == periodId)
            .map((entry) => entry.toJson())
            .toList(),
      },
    };

    if (safeFormat == 'json') {
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(payload),
      );
    } else {
      final reportText = StringBuffer()
        ..writeln('# MetaRix Report Export')
        ..writeln('Workspace: ${_gateway.workspace.name}')
        ..writeln('Period: ${period.label}')
        ..writeln('Format: ${format.toUpperCase()}')
        ..writeln()
        ..writeln('## Success Snapshot')
        ..writeln(snapshot.successSnapshot)
        ..writeln()
        ..writeln('## Takeaways')
        ..writeln(
          snapshot.takeaways
              .where((entry) => entry.reportPeriodId == periodId)
              .map((entry) => '- ${entry.title}: ${entry.whatWeLearned}')
              .join('\n'),
        )
        ..writeln()
        ..writeln('## Future Actions')
        ..writeln(
          snapshot.futureActions
              .where((entry) => entry.reportPeriodId == periodId)
              .map(
                (entry) =>
                    '- ${entry.title} (${entry.actionType.label}) - ${entry.owner}',
              )
              .join('\n'),
        );
      await file.writeAsString(reportText.toString());
    }

    _exportStatus = 'Exported ${period.label} to ${file.path}';
    notifyListeners();
    await _recordActivity(
      periodId: periodId,
      eventType: ActivityEventType.reportGenerated,
      eventClass: ActivityEventClass.systemAction,
      reason: 'Report export was generated.',
      detail: file.path,
    );
  }

  Future<void> _recordActivity({
    required String periodId,
    required ActivityEventType eventType,
    required ActivityEventClass eventClass,
    required String reason,
    String? detail,
  }) {
    final period = _gateway.snapshot.reportPeriods.firstWhere(
      (entry) => entry.id == periodId,
    );
    return _gateway.recordActivityEvent(
      ActivityEvent(
        id: _gateway.createId('activity'),
        workspaceId: _gateway.workspace.id,
        objectType: ActivityObjectType.report,
        objectId: periodId,
        objectLabel: period.label,
        eventType: eventType,
        eventClass: eventClass,
        actorUserId: _gateway.currentUser.id,
        actorName: _gateway.currentUser.name,
        reason: reason,
        detail: detail,
        occurredAt: DateTime.now(),
      ),
    );
  }

  Future<Directory> _exportDirectory() async {
    final home = Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        Directory.current.path;
    final directory = Directory('$home\\Documents\\MetaRix\\exports');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  @override
  void dispose() {
    _gateway.removeListener(notifyListeners);
    super.dispose();
  }
}
