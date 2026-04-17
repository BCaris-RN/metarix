import '../models/connector_models.dart';
import '../models/model_types.dart';
import 'connector_result.dart';

abstract class ConversationConnector {
  SocialPlatform get platform;

  Future<ConnectorResult<List<ConversationThread>>> syncThreads({
    required String accountId,
  });

  Future<ConnectorResult<List<ConversationMessage>>> syncComments({
    required String threadId,
  });

  Future<ConnectorResult<ConversationMessage>> replyToComment({
    required String threadId,
    required String commentId,
    required String message,
  });

  Future<ConnectorResult<ConversationThread>> markHandled(String threadId);
}
