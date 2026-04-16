import 'package:flutter/material.dart';

import '../../app/metarix_scope.dart';
import '../../runtime/activity/activity_event_type.dart';

class ObjectActivityPanel extends StatelessWidget {
  const ObjectActivityPanel({
    required this.title,
    required this.objectType,
    required this.objectId,
    required this.emptyState,
    this.maxItems = 5,
    super.key,
  });

  final String title;
  final ActivityObjectType objectType;
  final String objectId;
  final String emptyState;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    final services = MetarixScope.of(context);
    final controller = services.activityController;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final events =
            controller.objectEvents(objectType, objectId).take(maxItems).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                if (events.isEmpty)
                  Text(emptyState)
                else
                  ...events.map(
                    (event) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(event.eventType.label),
                      subtitle: Text(
                        '${event.actorName} - ${_formatTimestamp(event.occurredAt)}\n${event.reason}',
                      ),
                      trailing: Chip(label: Text(event.eventClass.label)),
                      isThreeLine: true,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(DateTime value) {
    final date = value.toIso8601String().split('T').first;
    final time = value.toIso8601String().split('T').last.substring(0, 5);
    return '$date $time';
  }
}
