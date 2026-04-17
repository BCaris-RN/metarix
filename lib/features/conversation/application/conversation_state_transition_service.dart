import '../../../metarix_core/models/connector_models.dart';

class ConversationStateTransitionService {
  const ConversationStateTransitionService();

  static const Map<ConversationStatus, Set<ConversationStatus>>
  _allowedTransitions = {
    ConversationStatus.unread: {
      ConversationStatus.unread,
      ConversationStatus.open,
      ConversationStatus.assigned,
      ConversationStatus.resolved,
    },
    ConversationStatus.open: {
      ConversationStatus.open,
      ConversationStatus.assigned,
      ConversationStatus.resolved,
    },
    ConversationStatus.assigned: {
      ConversationStatus.open,
      ConversationStatus.assigned,
      ConversationStatus.resolved,
    },
    ConversationStatus.resolved: {
      ConversationStatus.open,
      ConversationStatus.assigned,
      ConversationStatus.resolved,
    },
  };

  bool canTransition(
    ConversationStatus currentStatus,
    ConversationStatus nextStatus,
  ) {
    return _allowedTransitions[currentStatus]!.contains(nextStatus);
  }

  ConversationThread transition(
    ConversationThread thread,
    ConversationStatus nextStatus, {
    String? assignedToUserId,
    bool clearAssignedToUserId = false,
    int? unreadCount,
    DateTime? lastMessageAt,
  }) {
    if (!canTransition(thread.status, nextStatus)) {
      throw StateError('Cannot transition ${thread.status} to $nextStatus');
    }

    return thread.copyWith(
      status: nextStatus,
      assignedToUserId: assignedToUserId,
      clearAssignedToUserId: clearAssignedToUserId,
      unreadCount: unreadCount,
      lastMessageAt: lastMessageAt,
    );
  }

  ConversationThread markViewed(
    ConversationThread thread, {
    DateTime? viewedAt,
  }) {
    final nextStatus = switch (thread.status) {
      ConversationStatus.unread when thread.assignedToUserId != null =>
        ConversationStatus.assigned,
      ConversationStatus.unread => ConversationStatus.open,
      _ => thread.status,
    };

    return transition(
      thread,
      nextStatus,
      unreadCount: 0,
      lastMessageAt: viewedAt ?? thread.lastMessageAt,
    );
  }

  ConversationThread assign(
    ConversationThread thread, {
    required String userId,
    DateTime? assignedAt,
  }) {
    return transition(
      thread,
      ConversationStatus.assigned,
      assignedToUserId: userId,
      lastMessageAt: assignedAt ?? thread.lastMessageAt,
    );
  }

  ConversationThread resolve(
    ConversationThread thread, {
    DateTime? resolvedAt,
  }) {
    return transition(
      thread,
      ConversationStatus.resolved,
      unreadCount: 0,
      lastMessageAt: resolvedAt ?? thread.lastMessageAt,
    );
  }

  ConversationThread applyReply(
    ConversationThread thread, {
    DateTime? repliedAt,
  }) {
    final nextStatus = thread.assignedToUserId == null
        ? ConversationStatus.open
        : ConversationStatus.assigned;
    return transition(
      thread,
      nextStatus,
      unreadCount: 0,
      lastMessageAt: repliedAt ?? DateTime.now(),
    );
  }
}
