import '../../models/connector_models.dart';
import '../../models/model_types.dart';
import '../connector_result.dart';
import '../conversation_connector.dart';

class DemoConversationConnector implements ConversationConnector {
  const DemoConversationConnector(this.platform);

  @override
  final SocialPlatform platform;

  @override
  Future<ConnectorResult<List<ConversationThread>>> syncThreads({
    required String accountId,
  }) async {
    return ConnectorResult.success(
      value: [
        ConversationThread(
          threadId: 'demo-${platform.name}-thread',
          platform: platform,
          accountId: accountId,
          remoteThreadId: 'remote-demo-${platform.name}-thread',
          title: '${platform.label} product question',
          participantHandles: ['@customer_demo'],
          status: ConversationStatus.open,
          assignedToUserId: null,
          lastMessageAt: DateTime.now().subtract(const Duration(hours: 2)),
          unreadCount: 1,
        ),
      ],
    );
  }

  @override
  Future<ConnectorResult<List<ConversationMessage>>> syncComments({
    required String threadId,
  }) async {
    return ConnectorResult.success(
      value: [
        ConversationMessage(
          messageId: '$threadId-message-1',
          threadId: threadId,
          platform: platform,
          authorHandle: '@customer_demo',
          body: 'Is this available this week?',
          isOutbound: false,
          sentAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ],
    );
  }

  @override
  Future<ConnectorResult<ConversationMessage>> replyToComment({
    required String threadId,
    required String commentId,
    required String message,
  }) async {
    return ConnectorResult.success(
      value: ConversationMessage(
        messageId: 'reply-$commentId',
        threadId: threadId,
        platform: platform,
        authorHandle: '@metarix_${platform.name}',
        body: message,
        isOutbound: true,
        sentAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<ConnectorResult<ConversationThread>> markHandled(
    String threadId,
  ) async {
    return ConnectorResult.success(
      value: ConversationThread(
        threadId: threadId,
        platform: platform,
        accountId: 'demo-${platform.name}-account',
        remoteThreadId: 'remote-$threadId',
        title: '${platform.label} handled thread',
        participantHandles: const ['@customer_demo'],
        status: ConversationStatus.resolved,
        assignedToUserId: null,
        lastMessageAt: DateTime.now(),
        unreadCount: 0,
      ),
    );
  }
}
