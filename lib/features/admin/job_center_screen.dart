import 'package:flutter/material.dart';

import '../../app/metarix_scope.dart';
import '../../runtime/jobs/job_record.dart';
import '../../runtime/jobs/job_status.dart';
import '../../runtime/jobs/job_type.dart';

class JobCenterScreen extends StatelessWidget {
  const JobCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = MetarixScope.of(context);
    final queue = services.jobQueueService;

    return AnimatedBuilder(
      animation: queue,
      builder: (context, _) {
        final jobs = queue.jobs;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Job Center',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  'Queue critical work instead of executing it directly from the UI.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: JobType.values
                      .map(
                        (type) => FilledButton.tonal(
                          onPressed: () {
                            queue.queueJob(
                              workspaceId: services.gateway.workspace.id,
                              jobType: type,
                              title: type.label,
                              objectType: _defaultObjectType(type),
                              objectId: 'demo-${type.name}',
                              details: 'Queued from Job Center.',
                            );
                          },
                          child: Text(type.label),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                if (jobs.isEmpty)
                  const Text('No jobs recorded yet.')
                else
                  ...jobs.map(
                    (job) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _JobTile(
                        job: job,
                        onStart: job.status == JobStatus.queued
                            ? () => queue.updateJobStatus(
                                  job.id,
                                  JobStatus.running,
                                  details: 'Job started in the runtime queue.',
                                )
                            : null,
                        onComplete: job.status == JobStatus.running
                            ? () => queue.updateJobStatus(
                                  job.id,
                                  JobStatus.completed,
                                  outcome: 'Job completed successfully.',
                                )
                            : null,
                        onFail: job.status == JobStatus.running
                            ? () => queue.updateJobStatus(
                                  job.id,
                                  JobStatus.failed,
                                  outcome: 'Job failed in the runtime queue.',
                                )
                            : null,
                        onBlock: job.status == JobStatus.queued
                            ? () => queue.updateJobStatus(
                                  job.id,
                                  JobStatus.blocked,
                                  outcome: 'Job blocked by runtime policy.',
                                )
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String? _defaultObjectType(JobType type) {
    return switch (type) {
      JobType.schedulePrepare || JobType.publishAttempt => 'draft',
      JobType.reportGenerate => 'report',
      JobType.evidenceAssemble => 'draft',
      JobType.connectorSync => 'campaign',
      JobType.listeningRefresh => 'listening_query',
    };
  }
}

class _JobTile extends StatelessWidget {
  const _JobTile({
    required this.job,
    required this.onStart,
    required this.onComplete,
    required this.onFail,
    required this.onBlock,
  });

  final JobRecord job;
  final VoidCallback? onStart;
  final VoidCallback? onComplete;
  final VoidCallback? onFail;
  final VoidCallback? onBlock;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(job.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('${job.jobType.label} - ${job.status.label}'),
            const SizedBox(height: 4),
            Text(job.details ?? job.outcome ?? 'No details recorded.'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (onStart != null)
                  TextButton(onPressed: onStart, child: const Text('Start')),
                if (onComplete != null)
                  TextButton(onPressed: onComplete, child: const Text('Complete')),
                if (onFail != null)
                  TextButton(onPressed: onFail, child: const Text('Fail')),
                if (onBlock != null)
                  TextButton(onPressed: onBlock, child: const Text('Block')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
