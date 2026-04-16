import 'package:flutter/foundation.dart';

import '../../../data/local_metarix_gateway.dart';
import '../../../repositories/strategy_repository.dart';
import '../domain/strategy_models.dart';

class StrategyController extends ChangeNotifier {
  StrategyController(
    this._strategyRepository,
    this._gateway,
  ) {
    _gateway.addListener(notifyListeners);
  }

  final StrategyRepository _strategyRepository;
  final LocalMetarixGateway _gateway;

  StrategyRecord get strategy => StrategyRecord(
        workspace: _gateway.workspace,
        brand: _gateway.brand,
        businessGoals: _gateway.snapshot.businessGoals,
        socialGoals: _gateway.snapshot.socialGoals,
        personas: _gateway.snapshot.personas,
        competitors: _gateway.snapshot.competitors,
        swotEntries: _gateway.snapshot.swotEntries,
        auditFindings: _gateway.snapshot.auditFindings,
        contentPillars: _gateway.snapshot.contentPillars,
      );

  Future<void> saveBusinessGoal(BusinessGoal goal, SocialGoal socialGoal) async {
    await _strategyRepository.saveBusinessGoal(goal);
    await _strategyRepository.saveSocialGoal(socialGoal);
  }

  Future<void> savePersona(AudiencePersona persona) =>
      _strategyRepository.saveAudiencePersona(persona);

  Future<void> saveCompetitor(Competitor competitor) =>
      _strategyRepository.saveCompetitor(competitor);

  Future<void> saveSwotEntry(SwotEntry entry) =>
      _strategyRepository.saveSwotEntry(entry);

  Future<void> saveAuditFinding(AuditFinding finding) =>
      _strategyRepository.saveAuditFinding(finding);

  Future<void> saveContentPillar(ContentPillar pillar) =>
      _strategyRepository.saveContentPillar(pillar);

  @override
  void dispose() {
    _gateway.removeListener(notifyListeners);
    super.dispose();
  }
}
