import '../features/strategy/domain/strategy_models.dart';

abstract interface class StrategyRepository {
  Future<StrategyRecord> loadStrategy(String brandId);

  Future<void> saveBusinessGoal(BusinessGoal goal);

  Future<void> saveSocialGoal(SocialGoal goal);

  Future<void> saveAudiencePersona(AudiencePersona persona);

  Future<void> saveCompetitor(Competitor competitor);

  Future<void> saveSwotEntry(SwotEntry entry);

  Future<void> saveAuditFinding(AuditFinding finding);

  Future<void> saveContentPillar(ContentPillar pillar);
}
