import 'package:flutter/material.dart';

import '../domain/comment_record.dart';

class CommentPanel extends StatelessWidget {
  const CommentPanel({
    required this.comments,
    required this.onAdd,
    super.key,
  });

  final List<CommentRecord> comments;
  final Future<void> Function(CommentType type, String text) onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Comments',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                PopupMenuButton<CommentType>(
                  itemBuilder: (context) => CommentType.values
                      .map(
                        (type) => PopupMenuItem<CommentType>(
                          value: type,
                          child: Text('Add ${type.label}'),
                        ),
                      )
                      .toList(),
                  onSelected: (type) => _showComposer(context, type),
                  child: const Icon(Icons.add_comment_outlined),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (comments.isEmpty)
              const Text('No comments yet.')
            else
              ...comments.map(
                (comment) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(comment.authorName),
                  subtitle: Text(comment.text),
                  trailing: Chip(label: Text(comment.type.label)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showComposer(BuildContext context, CommentType type) async {
    final controller = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New ${type.label.toLowerCase()}'),
        content: TextField(
          controller: controller,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'Comment'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved == true) {
      await onAdd(type, controller.text);
    }
  }
}
