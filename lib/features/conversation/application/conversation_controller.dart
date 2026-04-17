import 'package:flutter/foundation.dart';

import '../../../data/local_metarix_gateway.dart';
import '../../../metarix_core/models/connector_models.dart';
import '../../../repositories/conversation_repository.dart';
import 'conversation_state_transition_service.dart';

class ConversationController extends ChangeNotifier {
  ConversationController(
    this._repository,
    this._gateway,
    this._transitionService,
  ) {
    _gateway.addListener(notifyListeners);
  }

  final ConversationRepository _repository;
  final LocalMetarixGateway _gateway;
  final ConversationStateTransitionService _transitionService;

  List<ConversationThread> get threads {
    final items = List<ConversationThread>.from(
      _gateway.snapshot.conversationThreads,
    );
    items.sort(
      (left, right) => right.lastMessageAt.compareTo(left.lastMessageAt),
    );
    return items;
  }

  ConversationThread? threadById(String threadId) {
    for (final thread in _gateway.snapshot.conversationThreads) {
      if (thread.threadId == threadId) {
        return thread;
      }
    }
    return null;
  }

  List<ConversationMessage> messagesFor(String threadId) {
    final items = _gateway.snapshot.conversationMessages
        .where((entry) => entry.threadId == threadId)
        .toList();
    items.sort((left, right) => left.sentAt.compareTo(right.sentAt));
    return items;
  }

  Future<void> markThreadViewed(String threadId) async {
    final thread = threadById(threadId);
    if (thread == null) {
      return;
    }
    await _repository.saveConversationThread(
      _transitionService.markViewed(thread),
    );
  }

  Future<void> assignThread(String threadId, String userId) async {
    final thread = threadById(threadId);
    if (thread == null) {
      return;
    }
    await _repository.saveConversationThread(
      _transitionService.assign(thread, userId: userId),
    );
  }

  Future<void> assignThreadToCurrentUser(String threadId) {
    return assignThread(threadId, _gateway.currentUser.id);
  }

  Future<void> resolveThread(String threadId) async {
    final thread = threadById(threadId);
    if (thread == null) {
      return;
    }
    await _repository.saveConversationThread(
      _transitionService.resolve(thread),
    );
  }

  Future<void> sendReply(String threadId, String body) async {
    final thread = threadById(threadId);
    if (thread == null || body.trim().isEmpty) {
      return;
    }

    final now = DateTime.now();
    await _repository.saveConversationMessage(
      ConversationMessage(
        messageId: _gateway.createId('message'),
        threadId: threadId,
        platform: thread.platform,
        authorHandle: _handleForCurrentUser(),
        body: body.trim(),
        isOutbound: true,
        sentAt: now,
      ),
    );
    await _repository.saveConversationThread(
      _transitionService.applyReply(thread, repliedAt: now),
    );
  }

  String? assigneeNameFor(ConversationThread thread) {
    final assignedToUserId = thread.assignedToUserId;
    if (assignedToUserId == null) {
      return null;
    }
    for (final user in _gateway.snapshot.users) {
      if (user.id == assignedToUserId) {
        return user.name;
      }
    }
    return assignedToUserId;
  }

  String _handleForCurrentUser() {
    final localPart = _gateway.currentUser.email.split('@').first;
    return '@$localPart';
  }

  @override
  void dispose() {
    _gateway.removeListener(notifyListeners);
    super.dispose();
  }
}
