import '../features/shared/domain/core_models.dart';
import '../services/caris_policy_service.dart';

class ConnectorCapabilityAdapter {
  const ConnectorCapabilityAdapter(this._policies);

  final CarisPolicyBundle _policies;

  bool canSchedule(SocialChannel channel) =>
      _policies.supports(channel, 'schedule_supported');

  bool canPublish(SocialChannel channel) =>
      _policies.supports(channel, 'publish_supported');

  bool canFetchAnalytics(SocialChannel channel) =>
      _policies.supports(channel, 'analytics_ingest_supported');
}
