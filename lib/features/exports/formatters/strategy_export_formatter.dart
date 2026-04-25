import '../../strategy/domain/strategy_models.dart';

class StrategyExportFormatter {
  const StrategyExportFormatter();

  String format(StrategyRecord strategy) {
    return [
      'Strategy Summary',
      strategy.brand.name,
      strategy.workspace.name,
      '',
      'Goals:',
      ...strategy.businessGoals.map((goal) => '- ${goal.title}: ${goal.summary}'),
      '',
      'Personas:',
      ...strategy.personas.map((persona) => '- ${persona.name}: ${persona.summary}'),
      '',
      'Content Pillars:',
      ...strategy.contentPillars.map(
        (pillar) => '- ${pillar.name}: ${pillar.description}',
      ),
    ].join('\n');
  }
}
