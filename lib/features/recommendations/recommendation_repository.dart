import 'domain/recommendation_model.dart';

abstract interface class RecommendationRepository {
  Future<List<RecommendationInsight>> listRecommendationInsights(
    String reportPeriodId,
  );

  Future<void> saveRecommendationInsight(RecommendationInsight recommendation);
}
