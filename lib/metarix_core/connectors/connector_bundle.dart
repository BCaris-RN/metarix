import '../models/model_types.dart';
import 'account_connector.dart';
import 'analytics_connector.dart';
import 'conversation_connector.dart';
import 'listening_connector.dart';
import 'publish_connector.dart';
import 'smart_link_service.dart';

enum ConnectorRuntimeKind { demo, localConnected }

class ConnectorBundle {
  const ConnectorBundle({
    required this.runtimeKind,
    required this.accountConnectors,
    required this.publishConnectors,
    required this.analyticsConnectors,
    required this.conversationConnectors,
    required this.listeningConnectors,
    required this.smartLinkService,
  });

  final ConnectorRuntimeKind runtimeKind;
  final Map<SocialPlatform, AccountConnector> accountConnectors;
  final Map<SocialPlatform, PublishConnector> publishConnectors;
  final Map<SocialPlatform, AnalyticsConnector> analyticsConnectors;
  final Map<SocialPlatform, ConversationConnector> conversationConnectors;
  final Map<SocialPlatform, ListeningConnector> listeningConnectors;
  final SmartLinkService smartLinkService;

  AccountConnector accountConnectorFor(SocialPlatform platform) =>
      accountConnectors[platform]!;

  PublishConnector publishConnectorFor(SocialPlatform platform) =>
      publishConnectors[platform]!;

  AnalyticsConnector analyticsConnectorFor(SocialPlatform platform) =>
      analyticsConnectors[platform]!;

  ConversationConnector conversationConnectorFor(SocialPlatform platform) =>
      conversationConnectors[platform]!;

  ListeningConnector listeningConnectorFor(SocialPlatform platform) =>
      listeningConnectors[platform]!;
}
