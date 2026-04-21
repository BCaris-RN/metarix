import 'package:flutter/material.dart';

import '../../../app/metarix_scope.dart';
import '../../../metarix_core/models/connector_models.dart';
import '../../../metarix_core/models/model_types.dart';

class ConversationThreadScreen extends StatefulWidget {
  const ConversationThreadScreen({required this.threadId, super.key});

  final String threadId;

  @override
  State<ConversationThreadScreen> createState() =>
      _ConversationThreadScreenState();
}

class _ConversationThreadScreenState extends State<ConversationThreadScreen> {
  final TextEditingController _replyController = TextEditingController();
  String? _viewedThreadId;

  static const _quickReplies = [
    'Thanks for flagging this. I’m on it now and will follow up shortly.',
    'I reviewed the thread and pushed it into the approval workflow.',
    'Looks good from my side. I’m marking this resolved for now.',
    'I need one more detail before I can action this. Can you confirm?',
  ];

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = MetarixScope.of(context);
    final controller = services.conversationController;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final thread = controller.threadById(widget.threadId);
        if (thread == null) {
          return const Center(
            child: Text('Select a conversation to read the thread.'),
          );
        }

        if (_viewedThreadId != widget.threadId) {
          _viewedThreadId = widget.threadId;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.markThreadViewed(widget.threadId);
          });
        }

        final messages = controller.messagesFor(widget.threadId);
        final assignedName = controller.assigneeNameFor(thread);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(thread.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(thread.platform.label)),
                Chip(label: Text(thread.status.label)),
                Chip(
                  label: Text(
                    assignedName == null
                        ? 'Unassigned'
                        : 'Owner: $assignedName',
                  ),
                ),
                Chip(label: Text('Unread: ${thread.unreadCount}')),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              thread.participantHandles.join(', '),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: messages.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return Align(
                    alignment: message.isOutbound
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: message.isOutbound
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.authorHandle,
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(message.body),
                              const SizedBox(height: 4),
                              Text(
                                message.sentAt
                                    .toIso8601String()
                                    .split('T')
                                    .join(' '),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: () =>
                      controller.assignThreadToCurrentUser(widget.threadId),
                  child: const Text('Assign To Me'),
                ),
                FilledButton.tonal(
                  onPressed: thread.status == ConversationStatus.resolved
                      ? null
                      : () => controller.resolveThread(widget.threadId),
                  child: const Text('Resolve'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickReplies
                  .map(
                    (reply) => ActionChip(
                      label: Text(reply),
                      onPressed: () {
                        _replyController.text = reply;
                        _replyController.selection = TextSelection.collapsed(
                          offset: reply.length,
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: const InputDecoration(labelText: 'Reply'),
                    minLines: 1,
                    maxLines: 4,
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () async {
                    final message = _replyController.text;
                    await controller.sendReply(widget.threadId, message);
                    _replyController.clear();
                  },
                  child: const Text('Send'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: thread.status == ConversationStatus.resolved
                    ? null
                    : () async {
                        final message = _replyController.text;
                        if (message.trim().isNotEmpty) {
                          await controller.sendReply(widget.threadId, message);
                        }
                        await controller.resolveThread(widget.threadId);
                        _replyController.clear();
                      },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Send and resolve'),
              ),
            ),
          ],
        );
      },
    );
  }
}
