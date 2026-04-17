import 'package:flutter_test/flutter_test.dart';

import 'package:metarix/features/conversation/application/conversation_state_transition_service.dart';
import 'package:metarix/metarix_core/models/connector_models.dart';
import 'package:metarix/metarix_core/models/model_types.dart';

void main() {
  const service = ConversationStateTransitionService();

  ConversationThread buildThread({
    ConversationStatus status = ConversationStatus.unread,
    String? assignedToUserId,
    int unreadCount = 2,
  }) {
    return ConversationThread(
      threadId: 'thread-1',
      platform: SocialPlatform.instagram,
      accountId: 'account-instagram-main',
      remoteThreadId: 'remote-thread-1',
      title: 'Thread',
      participantHandles: const ['@customer_demo'],
      status: status,
      assignedToUserId: assignedToUserId,
      lastMessageAt: DateTime(2026, 4, 17, 9),
      unreadCount: unreadCount,
    );
  }

  test('viewing unread threads reopens them without losing ownership', () {
    final unassigned = service.markViewed(buildThread());
    final assigned = service.markViewed(
      buildThread(assignedToUserId: 'user-lena'),
    );

    expect(unassigned.status, ConversationStatus.open);
    expect(unassigned.unreadCount, 0);
    expect(assigned.status, ConversationStatus.assigned);
    expect(assigned.assignedToUserId, 'user-lena');
    expect(assigned.unreadCount, 0);
  });

  test('reply path reopens resolved threads through the assigned state', () {
    final resolved = buildThread(
      status: ConversationStatus.resolved,
      assignedToUserId: 'user-olivia',
      unreadCount: 0,
    );

    final reopened = service.applyReply(
      resolved,
      repliedAt: DateTime(2026, 4, 17, 10),
    );

    expect(reopened.status, ConversationStatus.assigned);
    expect(reopened.assignedToUserId, 'user-olivia');
    expect(reopened.lastMessageAt, DateTime(2026, 4, 17, 10));
  });
}
