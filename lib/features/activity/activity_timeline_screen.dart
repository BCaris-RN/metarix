import 'package:flutter/material.dart';

import '../../app/metarix_scope.dart';
import '../../runtime/activity/activity_event.dart';
import '../../runtime/activity/activity_event_type.dart';

class ActivityTimelineScreen extends StatefulWidget {
  const ActivityTimelineScreen({super.key});

  @override
  State<ActivityTimelineScreen> createState() => _ActivityTimelineScreenState();
}

class _ActivityTimelineScreenState extends State<ActivityTimelineScreen> {
  ActivityObjectType? _selectedObjectType;
  int? _selectedRangeDays;

  @override
  Widget build(BuildContext context) {
    final services = MetarixScope.of(context);
    final controller = services.activityController;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final from = _selectedRangeDays == null
            ? null
            : DateTime.now().subtract(Duration(days: _selectedRangeDays!));
        final events = controller.workspaceEvents(
          objectType: _selectedObjectType,
          from: from,
        );

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Activity Timeline',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text('${services.gateway.workspace.name} audit-ready ledger'),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    DropdownButton<ActivityObjectType?>(
                      value: _selectedObjectType,
                      items: [
                        const DropdownMenuItem<ActivityObjectType?>(
                          value: null,
                          child: Text('All objects'),
                        ),
                        ...ActivityObjectType.values.map(
                          (type) => DropdownMenuItem<ActivityObjectType?>(
                            value: type,
                            child: Text(type.label),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedObjectType = value);
                      },
                    ),
                    DropdownButton<int?>(
                      value: _selectedRangeDays,
                      items: const [
                        DropdownMenuItem<int?>(
                          value: 7,
                          child: Text('Last 7 days'),
                        ),
                        DropdownMenuItem<int?>(
                          value: 30,
                          child: Text('Last 30 days'),
                        ),
                        DropdownMenuItem<int?>(
                          value: 90,
                          child: Text('Last 90 days'),
                        ),
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text('All time'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedRangeDays = value);
                      },
                    ),
                    Text('Events: ${events.length}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: events.isEmpty
                    ? const Text('No activity matched the current filters.')
                    : Column(
                        children: events
                            .map((event) => _ActivityEventTile(event: event))
                            .toList(),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ActivityEventTile extends StatelessWidget {
  const _ActivityEventTile({required this.event});

  final ActivityEvent event;

  @override
  Widget build(BuildContext context) {
    final detailSuffix = event.detail == null ? '' : '\n${event.detail}';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('${event.eventType.label}: ${event.objectLabel}'),
          Chip(label: Text(event.eventClass.label)),
          Chip(label: Text(event.objectType.label)),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          '${event.actorName} - ${_formatTimestamp(event.occurredAt)}\n${event.reason}$detailSuffix',
        ),
      ),
      isThreeLine: event.detail != null,
    );
  }

  static String _formatTimestamp(DateTime value) {
    final date = value.toIso8601String().split('T').first;
    final time = value.toIso8601String().split('T').last.substring(0, 5);
    return '$date $time';
  }
}
