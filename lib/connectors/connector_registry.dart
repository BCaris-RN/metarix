import '../features/shared/domain/core_models.dart';
import '../services/caris_policy_service.dart';
import 'base_connector.dart';
import 'connector_capability_adapter.dart';
import 'instagram_connector.dart';
import 'x_connector.dart';

class ConnectorRegistry {
  ConnectorRegistry(CarisPolicyBundle policies)
      : _connectors = _buildConnectors(ConnectorCapabilityAdapter(policies));

  final Map<SocialChannel, BaseConnector> _connectors;

  BaseConnector connectorFor(SocialChannel channel) => _connectors[channel]!;

  Iterable<BaseConnector> get all => _connectors.values;

  static Map<SocialChannel, BaseConnector> _buildConnectors(
    ConnectorCapabilityAdapter capabilities,
  ) {
    return {
      SocialChannel.instagram: InstagramConnector(
        canSchedule: capabilities.canSchedule(SocialChannel.instagram),
        canPublish: capabilities.canPublish(SocialChannel.instagram),
        canFetchAnalytics: capabilities.canFetchAnalytics(SocialChannel.instagram),
      ),
      SocialChannel.x: XConnector(
        canSchedule: capabilities.canSchedule(SocialChannel.x),
        canPublish: capabilities.canPublish(SocialChannel.x),
        canFetchAnalytics: capabilities.canFetchAnalytics(SocialChannel.x),
      ),
      for (final channel in SocialChannel.values.where(
        (entry) => entry != SocialChannel.instagram && entry != SocialChannel.x,
      ))
        channel: PolicyBackedConnector(
          channel: channel,
          canSchedule: capabilities.canSchedule(channel),
          canPublish: capabilities.canPublish(channel),
          canFetchAnalytics: capabilities.canFetchAnalytics(channel),
          analyticsPayloadBuilder: (reportPeriodId) => {
            'reportPeriodId': reportPeriodId,
            'followers': 10000 + channel.index * 1200,
            'reach': 20000 + channel.index * 14000,
            'impressions': 42000 + channel.index * 23000,
            'engagement': 1800 + channel.index * 900,
            'clicks': 160 + channel.index * 120,
            'views': 15000 + channel.index * 5000,
            'shares': 90 + channel.index * 25,
            'comments': 48 + channel.index * 20,
            'sentiment_score': 0.6 + (channel.index * 0.03),
            'response_time': 3.5 + channel.index,
          },
        ),
    };
  }
}
