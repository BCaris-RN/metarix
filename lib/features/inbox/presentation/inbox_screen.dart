import 'package:flutter/material.dart';

import '../../../app/metarix_scope.dart';
import '../../../metarix_core/models/connector_models.dart';
import '../../../metarix_core/models/model_types.dart';
import '../../conversation/presentation/conversation_thread_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  String? _selectedThreadId;

  @override
  Widget build(BuildContext context) {
    final services = MetarixScope.of(context);
    final controller = services.conversationController;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final threads = controller.threads;
        final selectedThread = threads.isEmpty
            ? null
            : threads.firstWhere(
                (thread) =>
                    thread.threadId ==
                    (_selectedThreadId ?? threads.first.threadId),
                orElse: () => threads.first,
              );

        final listPane = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inbox Workspace',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: threads.isEmpty
                  ? const Center(
                      child: Text(
                        'No persisted conversations are available yet.',
                      ),
                    )
                  : ListView.separated(
                      itemCount: threads.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final thread = threads[index];
                        final assignedName = controller.assigneeNameFor(thread);
                        return ListTile(
                          selected: thread.threadId == selectedThread?.threadId,
                          title: Text(thread.title),
                          subtitle: Text(
                            [
                              thread.platform.label,
                              thread.participantHandles.join(', '),
                              assignedName ?? 'Unassigned',
                            ].join(' | '),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Chip(label: Text(thread.status.label)),
                              if (thread.unreadCount > 0)
                                Text(
                                  '${thread.unreadCount} unread',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                          onTap: () {
                            setState(() => _selectedThreadId = thread.threadId);
                          },
                        );
                      },
                    ),
            ),
          ],
        );

        final detailPane = selectedThread == null
            ? const Center(
                child: Text('Choose a conversation to open the thread view.'),
              )
            : ConversationThreadScreen(threadId: selectedThread.threadId);

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 1000;
            if (!isWide) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Expanded(child: listPane),
                    const SizedBox(height: 16),
                    Expanded(child: detailPane),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: listPane,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: detailPane,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
