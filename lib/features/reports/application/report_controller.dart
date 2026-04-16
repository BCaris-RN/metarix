import 'package:flutter/foundation.dart';

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

  ReportSnapshot get snapshot => ReportSnapshot(
        activePeriodId: _gateway.snapshot.reportPeriods.first.id,
        reportPeriods: _gateway.snapshot.reportPeriods,
        comparisonPeriods: _gateway.snapshot.comparisonPeriods,
        normalizedMetrics: _gateway.snapshot.normalizedMetrics,
        channelPerformance: _gateway.loadReportDataSync().channelPerformance,
        standoutResults: _gateway.snapshot.standoutResults,
        takeaways: _gateway.snapshot.takeaways,
        overallLearnings: _gateway.snapshot.overallLearnings,
        futureActions: _gateway.snapshot.futureActions,
        recommendationInsights: _gateway.snapshot.recommendationInsights,
        successSnapshot: _gateway.snapshot.successSnapshot,
        topPostPlaceholder: _gateway.snapshot.topPostPlaceholder,
      );

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

  @override
  void dispose() {
    _gateway.removeListener(notifyListeners);
    super.dispose();
  }
}
