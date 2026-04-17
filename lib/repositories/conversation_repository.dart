import '../metarix_core/models/connector_models.dart';

abstract interface class ConversationRepository {
  Future<ConversationThread> saveConversationThread(ConversationThread thread);

  Future<List<ConversationThread>> listConversationThreads();

  Future<ConversationMessage> saveConversationMessage(
    ConversationMessage message,
  );

  Future<List<ConversationMessage>> listConversationMessages(String threadId);
}
