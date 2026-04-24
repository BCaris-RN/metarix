import 'package:flutter/material.dart';

import '../../app/metarix_scope.dart';
import '../../metarix_core/release/accounts/connected_social_account.dart';
import '../../metarix_core/release/content/content_asset.dart';
import '../../metarix_core/release/scheduler/publish_target.dart';
import '../../metarix_core/release/scheduler/scheduled_post.dart';
import '../../metarix_core/release/scheduler/scheduler_controller.dart';

class ReleaseSchedulerScreen extends StatefulWidget {
  const ReleaseSchedulerScreen({super.key});

  @override
  State<ReleaseSchedulerScreen> createState() => _ReleaseSchedulerScreenState();
}

class _ReleaseSchedulerScreenState extends State<ReleaseSchedulerScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = MetarixScope.of(context);
    final controller = services.schedulerController;
    final contentAssets = services.contentAssetController.assets;
    final socialAccounts = services.socialAccountController.accounts;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final selected = controller.selectedPost;
        final error = controller.errorMessage;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Scheduler+', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            const Text('Local/demo scheduler'),
            const SizedBox(height: 16),
            if (error != null)
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(error),
                ),
              ),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: controller.isLoading
                      ? null
                      : () => _createDemoSchedule(
                            context,
                            controller,
                            contentAssets,
                            socialAccounts,
                            services.gateway.workspace.id,
                            services.appSessionController.session?.userId ?? 'user-local',
                          ),
                  icon: const Icon(Icons.add),
                  label: const Text('Create demo schedule with demo dependencies'),
                ),
                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(labelText: 'Search posts'),
                    onChanged: (value) {
                      controller.updateFilters(
                        controller.filters.copyWith(query: value),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (controller.posts.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No scheduled posts yet. Create a demo schedule to get started.'),
                ),
              )
            else
              ...controller.posts.map(
                (post) => Card(
                  child: ListTile(
                    selected: selected?.id == post.id,
                    onTap: () => controller.selectPost(post),
                    title: Text(post.title ?? 'Scheduled post'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Scheduled: ${post.scheduledAtIso}'),
                        Text('Timezone: ${post.timezone}'),
                        Text('Assets: ${post.contentAssetIds.length}'),
                        Text(
                          'Targets: ${post.targets.map((target) => target.targetDisplayName).join(', ')}',
                        ),
                        if (post.validationErrors.isNotEmpty)
                          Text(
                            'Validation: ${post.validationErrors.join(' | ')}',
                            style: TextStyle(color: Theme.of(context).colorScheme.error),
                          ),
                      ],
                    ),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        Chip(label: Text(post.status.name)),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => controller.cancelScheduledPost(post.id, 'Canceled locally.'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            if (selected != null)
              _DetailCard(
                post: selected,
                onApprove: () => controller.approveDraft(
                  postId: selected.id,
                  approvedByUserId: services.appSessionController.session?.userId ?? 'user-local',
                ),
                onSchedule: () => controller.scheduleApprovedPost(selected.id),
                onCancel: () => controller.cancelScheduledPost(selected.id, 'Canceled locally.'),
              ),
          ],
        );
      },
    );
  }

  Future<void> _createDemoSchedule(
    BuildContext context,
    SchedulerController controller,
    List<ContentAsset> contentAssets,
    List<ConnectedSocialAccount> socialAccounts,
    String workspaceId,
    String createdByUserId,
  ) async {
    if (contentAssets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a demo content asset first.')),
      );
      return;
    }
    if (socialAccounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a connected social account first.')),
      );
      return;
    }
    final asset = contentAssets.first;
    final account = socialAccounts.first;
    final now = DateTime.now().toUtc();
    await controller.createDraft(
      workspaceId: workspaceId,
      contentAssetIds: [asset.id],
      targets: [
        PublishTarget(
          id: 'target-${now.microsecondsSinceEpoch}',
          createdAtIso: now.toIso8601String(),
          updatedAtIso: now.toIso8601String(),
          platform: account.platform,
          connectedAccountId: account.accountId,
          targetDisplayName: account.displayName,
          platformMetadata: <String, Object?>{'mode': 'demo'},
          accountHandle: account.username,
          accountId: account.accountId,
          channelLabel: account.username,
          isPrimary: true,
          note: 'Demo scheduler target',
        ),
      ],
      scheduledAtIso: now.add(const Duration(hours: 6)).toIso8601String(),
      timezone: 'UTC',
      createdByUserId: createdByUserId,
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.post,
    required this.onApprove,
    required this.onSchedule,
    required this.onCancel,
  });

  final ScheduledPost post;
  final VoidCallback onApprove;
  final VoidCallback onSchedule;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selected post', style: Theme.of(context).textTheme.titleLarge),
            Text('Status: ${post.status.name}'),
            Text('Approval: ${post.approvalStatus}'),
            Text('Targets: ${post.targets.length}'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                FilledButton(onPressed: onApprove, child: const Text('Approve')),
                FilledButton.tonal(onPressed: onSchedule, child: const Text('Schedule')),
                OutlinedButton(onPressed: onCancel, child: const Text('Cancel')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
