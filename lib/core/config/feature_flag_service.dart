import 'environment_config.dart';

class FeatureFlagService {
  const FeatureFlagService(this._config);

  final EnvironmentConfig _config;

  bool isEnabled(String flag) {
    const alwaysOn = {
      'assets_library',
      'collaboration',
      'connector_sandbox',
      'exports',
      'global_search',
      'governance_center',
      'listening_v15',
      'normalized_metrics',
      'recommendation_engine',
    };
    if (alwaysOn.contains(flag)) {
      return true;
    }
    return _config.allowIncompleteFeatures;
  }
}
