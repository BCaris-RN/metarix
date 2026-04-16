import 'package:flutter/material.dart';

import '../../../app/metarix_scope.dart';
import '../domain/schedule_models.dart';
import '../../shared/domain/core_models.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = MetarixScope.of(context);
    final workflowController = services.workflowController;

    return AnimatedBuilder(
      animation: workflowController,
      builder: (context, _) {
        final drafts = workflowController.drafts
            .where((draft) => draft.plannedPublishAt != null)
            .toList()
          ..sort(
            (left, right) => left.plannedPublishAt!.compareTo(right.plannedPublishAt!),
          );

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Schedule Workspace',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scheduled items',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ...drafts.map(
                      (draft) {
                        final posture = workflowController.postureFor(draft);
                        return ListTile(
                          title: Text(draft.title),
                          subtitle: Text(
                            '${draft.targetNetwork.label} · ${draft.plannedPublishAt!.toIso8601String().split('T').join(' ')}',
                          ),
                          trailing: Chip(label: Text(posture.posture.label)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
