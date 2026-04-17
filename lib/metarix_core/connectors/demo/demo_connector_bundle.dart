import '../../models/model_types.dart';
import '../connector_bundle.dart';
import 'demo_account_connector.dart';
import 'demo_analytics_connector.dart';
import 'demo_conversation_connector.dart';
import 'demo_listening_connector.dart';
import 'demo_publish_connector.dart';
import 'demo_smart_link_service.dart';

class DemoConnectorBundle {
  const DemoConnectorBundle._();

  static ConnectorBundle create() {
    return ConnectorBundle(
      runtimeKind: ConnectorRuntimeKind.demo,
      accountConnectors: {
        for (final platform in SocialPlatform.values)
          platform: DemoAccountConnector(platform),
      },
      publishConnectors: {
        for (final platform in SocialPlatform.values)
          platform: DemoPublishConnector(platform),
      },
      analyticsConnectors: {
        for (final platform in SocialPlatform.values)
          platform: DemoAnalyticsConnector(platform),
      },
      conversationConnectors: {
        for (final platform in SocialPlatform.values)
          platform: DemoConversationConnector(platform),
      },
      listeningConnectors: {
        for (final platform in SocialPlatform.values)
          platform: DemoListeningConnector(platform),
      },
      smartLinkService: const DemoSmartLinkService(),
    );
  }
}
