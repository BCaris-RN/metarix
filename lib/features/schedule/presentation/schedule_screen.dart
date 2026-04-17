import 'package:flutter/material.dart';

import '../../../app/metarix_scope.dart';
import '../../publish/domain/publish_models.dart';
import '../../shared/domain/core_models.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = MetarixScope.of(context);
    final publishController = services.publishController;

    return AnimatedBuilder(
      animation: publishController,
      builder: (context, _) {
        final records = publishController.records;
        final counts = {
          for (final status in PublishRecordStatus.values)
            status: records.where((record) => record.status == status).length,
        };

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
                      'Publish queue',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: PublishRecordStatus.values
                          .map(
                            (status) => Chip(
                              label: Text(
                                '${status.label}: ${counts[status] ?? 0}',
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    if (records.isEmpty)
                      const Text('No publish records have been persisted yet.'),
                    ...records.map(
                      (record) => _PublishRecordTile(record: record),
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

class _PublishRecordTile extends StatelessWidget {
  const _PublishRecordTile({required this.record});

  final ScheduledPostRecord record;

  @override
  Widget build(BuildContext context) {
    final services = MetarixScope.of(context);
    final publishController = services.publishController;
    final timestamp = record.scheduledAt ?? record.updatedAt;
    final subtitle = [
      record.campaignName,
      record.channel.label,
      timestamp.toIso8601String().split('T').join(' '),
    ].join(' | ');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(subtitle),
                    ],
                  ),
                ),
                Chip(label: Text(record.status.label)),
              ],
            ),
            if (record.lastError != null) ...[
              const SizedBox(height: 8),
              Text(
                'Error: ${record.lastError}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (record.denialReasons.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...record.denialReasons.map(
                (reason) => Text('${reason.code}: ${reason.message}'),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (record.status == PublishRecordStatus.scheduled)
                  FilledButton.tonal(
                    onPressed: () => publishController.queueRecord(record),
                    child: const Text('Queue'),
                  ),
                if (record.status == PublishRecordStatus.queued)
                  FilledButton(
                    onPressed: () => publishController.markPublished(record),
                    child: const Text('Mark Published'),
                  ),
                if (record.status == PublishRecordStatus.failed)
                  OutlinedButton(
                    onPressed: () => publishController.markScheduled(record),
                    child: const Text('Restore Scheduled'),
                  ),
                if (record.status == PublishRecordStatus.scheduled ||
                    record.status == PublishRecordStatus.queued)
                  OutlinedButton(
                    onPressed: () => publishController.markFailed(record),
                    child: const Text('Mark Failed'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
