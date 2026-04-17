import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:metarix/data/local_metarix_gateway.dart';
import 'package:metarix/features/conversation/application/conversation_controller.dart';
import 'package:metarix/features/conversation/application/conversation_state_transition_service.dart';
import 'package:metarix/metarix_core/models/connector_models.dart';
import 'package:metarix/metarix_core/models/model_types.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ConversationController buildController(LocalMetarixGateway gateway) {
    return ConversationController(
      gateway,
      gateway,
      const ConversationStateTransitionService(),
    );
  }

  test('conversation persistence round-trip survives gateway reload', () async {
    SharedPreferences.setMockInitialValues({});
    final firstGateway = await LocalMetarixGateway.bootstrap();

    const threadId = 'thread-persistence-check';
    await firstGateway.saveConversationThread(
      ConversationThread(
        threadId: threadId,
        platform: SocialPlatform.linkedin,
        accountId: 'account-linkedin-main',
        remoteThreadId: 'remote-thread-persistence-check',
        title: 'Persistence check',
        participantHandles: const ['@buyer_check'],
        status: ConversationStatus.open,
        assignedToUserId: 'user-olivia',
        lastMessageAt: DateTime(2026, 4, 17, 11),
        unreadCount: 0,
      ),
    );
    await firstGateway.saveConversationMessage(
      ConversationMessage(
        messageId: 'message-persistence-check',
        threadId: threadId,
        platform: SocialPlatform.linkedin,
        authorHandle: '@buyer_check',
        body: 'Checking that this survives persistence.',
        isOutbound: false,
        sentAt: DateTime(2026, 4, 17, 11),
      ),
    );

    final reloadedGateway = await LocalMetarixGateway.bootstrap();
    expect(
      reloadedGateway.snapshot.conversationThreads.any(
        (thread) => thread.threadId == threadId,
      ),
      isTrue,
    );
    expect(
      reloadedGateway.snapshot.conversationMessages.any(
        (message) => message.threadId == threadId,
      ),
      isTrue,
    );
  });

  test('inbox list and thread messages load from persisted records', () async {
    SharedPreferences.setMockInitialValues({});
    final gateway = await LocalMetarixGateway.bootstrap();
    final controller = buildController(gateway);

    expect(controller.threads.first.threadId, 'thread-linkedin-retail-buyer');

    final thread = controller.threadById('thread-instagram-fit-guide');
    expect(thread, isNotNull);

    final messages = controller.messagesFor('thread-instagram-fit-guide');
    expect(messages, isNotEmpty);
    expect(messages.last.body, contains('fit checklist'));
    expect(
      messages.every((message) => message.threadId == thread!.threadId),
      isTrue,
    );
  });

  test(
    'conversation status changes stay on the persisted thread path',
    () async {
      SharedPreferences.setMockInitialValues({});
      final gateway = await LocalMetarixGateway.bootstrap();
      final controller = buildController(gateway);

      await controller.markThreadViewed('thread-linkedin-retail-buyer');
      var thread = controller.threadById('thread-linkedin-retail-buyer')!;
      expect(thread.status, ConversationStatus.open);
      expect(thread.unreadCount, 0);

      await controller.assignThreadToCurrentUser(thread.threadId);
      thread = controller.threadById(thread.threadId)!;
      expect(thread.status, ConversationStatus.assigned);
      expect(thread.assignedToUserId, gateway.currentUser.id);

      await controller.resolveThread(thread.threadId);
      thread = controller.threadById(thread.threadId)!;
      expect(thread.status, ConversationStatus.resolved);
      expect(thread.assignedToUserId, gateway.currentUser.id);

      await controller.sendReply(
        thread.threadId,
        'We have the retail proof deck ready.',
      );
      thread = controller.threadById(thread.threadId)!;
      expect(thread.status, ConversationStatus.assigned);

      final messages = controller.messagesFor(thread.threadId);
      expect(messages.last.isOutbound, isTrue);
      expect(messages.last.body, 'We have the retail proof deck ready.');
    },
  );
}
