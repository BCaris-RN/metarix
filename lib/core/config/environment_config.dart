import 'runtime_environment.dart';

class EnvironmentConfig {
  const EnvironmentConfig({
    required this.environment,
    required this.showDemoData,
    required this.allowIncompleteFeatures,
    required this.dangerousActionsDisabled,
  });

  final RuntimeEnvironment environment;
  final bool showDemoData;
  final bool allowIncompleteFeatures;
  final bool dangerousActionsDisabled;

  factory EnvironmentConfig.fromEnvironment() {
    const environmentName = String.fromEnvironment(
      'METARIX_ENVIRONMENT',
      defaultValue: 'demo',
    );
    final environment = RuntimeEnvironmentX.fromName(environmentName);

    return EnvironmentConfig(
      environment: environment,
      showDemoData: environment != RuntimeEnvironment.productionLike,
      allowIncompleteFeatures: environment != RuntimeEnvironment.productionLike,
      dangerousActionsDisabled: environment == RuntimeEnvironment.productionLike,
    );
  }
}
