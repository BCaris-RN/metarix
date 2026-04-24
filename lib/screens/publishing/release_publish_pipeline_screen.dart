import 'package:flutter/material.dart';

import '../../app/metarix_scope.dart';
import '../../metarix_core/release/publishing/publish_pipeline_controller.dart';

class ReleasePublishPipelineScreen extends StatefulWidget {
  const ReleasePublishPipelineScreen({super.key});

  @override
  State<ReleasePublishPipelineScreen> createState() =>
      _ReleasePublishPipelineScreenState();
}

class _ReleasePublishPipelineScreenState
    extends State<ReleasePublishPipelineScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final services = MetarixScope.of(context);
      services.publishPipelineController
          .loadJobs(services.gateway.workspace.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final services = MetarixScope.of(context);
    final schedulerController = services.schedulerController;
    final publishController = services.publishPipelineController;
    return AnimatedBuilder(
      animation: Listenable.merge([schedulerController, publishController]),
      builder: (context, _) {
        final jobs = publishController.jobs;
        final selectedJob = publishController.selectedJob;
        final selectedAudit = publishController.auditEvents;
        final scheduledPosts = schedulerController.posts;
        final latestScheduled =
            scheduledPosts.isEmpty ? null : scheduledPosts.first;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'local/demo publish pipeline',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Convert scheduled posts into local execution state and audit events.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton(
                  onPressed: latestScheduled == null
                      ? null
                      : () async {
                          await publishController.createJobFromScheduledPost(
                            latestScheduled,
                          );
                        },
                  child: const Text('Create local job from scheduled post'),
                ),
                OutlinedButton(
                  onPressed: jobs.isEmpty
                      ? null
                      : () async {
                          await publishController.queueJob(jobs.first.id);
                        },
                  child: const Text('Queue action'),
                ),
                FilledButton.tonal(
                  onPressed: () async {
                    await publishController.runLocalDueJobs(
                      services.gateway.workspace.id,
                    );
                  },
                  child: const Text('Run local due jobs'),
                ),
                OutlinedButton(
                  onPressed: selectedJob == null
                      ? null
                      : () async {
                          await publishController.cancelJob(
                            selectedJob.id,
                            'Canceled locally.',
                          );
                        },
                  child: const Text('Cancel'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (publishController.errorMessage != null)
              Text(
                publishController.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (jobs.isEmpty) const Text('No local publish jobs yet.'),
            ...jobs.map(
              (job) => Card(
                child: ListTile(
                  title: Text('${job.platform.name} · ${job.publishStatus.name}'),
                  subtitle: Text(
                    'scheduledPostId=${job.scheduledPostId ?? job.id} · account=${job.target.connectedAccountId}',
                  ),
                  trailing: Chip(label: Text(job.publishStatus.name)),
                  onTap: () => publishController.selectJob(job),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (selectedJob != null) ...[
              Text('Audit trail', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...selectedAudit.map(
                (event) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(event.message),
                  subtitle: Text('${event.type.name} · ${event.createdAtIso}'),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
