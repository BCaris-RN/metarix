import '../features/reports/domain/report_models.dart';

abstract interface class ReportRepository {
  Future<ReportSnapshot> loadReportData();

  Future<void> saveTakeaway(Takeaway takeaway);

  Future<void> saveLearning(LearningEntry learning);

  Future<void> saveRecommendation(Recommendation recommendation);
}
