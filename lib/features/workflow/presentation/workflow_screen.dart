import 'package:flutter/material.dart';

import '../../../app/metarix_scope.dart';
import '../../../metarix_core/models/connected_social_account.dart';
import '../../../metarix_core/models/model_types.dart';
import '../../../runtime/activity/activity_event_type.dart';
import '../../activity/object_activity_panel.dart';
import '../../planning/domain/planning_models.dart';
import '../../publish/application/publish_controller.dart';
import '../../publish/domain/publish_models.dart';
import '../../schedule/domain/schedule_models.dart';
import '../../shared/domain/core_models.dart';
import '../../strategy/domain/strategy_models.dart';
import '../../../services/workflow_services.dart';
import '../domain/workflow_models.dart';

class WorkflowScreen extends StatefulWidget {
  const WorkflowScreen({super.key});

  @override
  State<WorkflowScreen> createState() => _WorkflowScreenState();
}

class _WorkflowScreenState extends State<WorkflowScreen> {
  String? _selectedDraftId;
  String? _composerCampaignId;
  String? _composerPillarId;
  SocialChannel _composerChannel = SocialChannel.instagram;
  final TextEditingController _titleController = TextEditingController(
    text: 'Spring partner launch',
  );
  final TextEditingController _copyController = TextEditingController(
    text:
        'Field-tested launch story with proof points for Instagram, Facebook, and LinkedIn.',
  );
  bool _submittingComposer = false;

  @override
  void dispose() {
    _titleController.dispose();
    _copyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = MetarixScope.of(context);
    final controller = services.workflowController;
    final planningController = services.planningController;
    final publishController = services.publishController;

    return AnimatedBuilder(
      animation: Listenable.merge([controller, planningController, publishController]),
      builder: (context, _) {
        final drafts = controller.drafts;
        final selectedDraft = drafts.isEmpty
            ? null
            : drafts.firstWhere(
                (draft) => draft.id == (_selectedDraftId ?? drafts.first.id),
                orElse: () => drafts.first,
              );
        final selectedPosture =
            selectedDraft == null ? null : controller.postureFor(selectedDraft);
        final connectedAccounts = services.gateway.connectedAccounts
            .where(
              (account) => const ['instagram', 'facebook', 'linkedin'].contains(account.platformKey),
            )
            .toList();
        final isWide = MediaQuery.of(context).size.width >= 1180;
        final campaigns = planningController.campaigns;
        final contentPillars = planningController.contentPillars;
        final effectiveCampaignId = _composerCampaignId ?? (campaigns.isEmpty ? null : campaigns.first.id);
        final effectiveCampaign = effectiveCampaignId == null
            ? null
            : campaigns.firstWhere(
                (campaign) => campaign.id == effectiveCampaignId,
                orElse: () => campaigns.first,
              );
        final effectivePillarId =
            _composerPillarId ?? effectiveCampaign?.contentPillarId ?? (contentPillars.isEmpty ? null : contentPillars.first.id);

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _WorkspaceHero(
              draftCount: drafts.length,
              connectedCount: connectedAccounts.length,
              scheduledCount: publishController.records
                  .where((record) => record.status == PublishRecordStatus.scheduled)
                  .length,
              publishedCount: publishController.records
                  .where((record) => record.status == PublishRecordStatus.published)
                  .length,
              onPublishEverywhere: selectedDraft == null
                  ? null
                  : () => _publishTargets(
                        context,
                        selectedDraft,
                        const [
                          SocialPlatform.instagram,
                          SocialPlatform.facebook,
                          SocialPlatform.linkedin,
                        ],
                        successLabel: 'Published everywhere',
                      ),
            ),
            const SizedBox(height: 20),
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 8,
                    child: _ComposerPanel(
                      titleController: _titleController,
                      copyController: _copyController,
                      campaigns: campaigns,
                      contentPillars: contentPillars,
                      selectedCampaignId: effectiveCampaignId,
                      selectedPillarId: effectivePillarId,
                      selectedChannel: _composerChannel,
                      submitting: _submittingComposer,
                      onCampaignChanged: (value) {
                        setState(() {
                          _composerCampaignId = value;
                          final nextCampaign = campaigns.firstWhere(
                            (campaign) => campaign.id == value,
                            orElse: () => campaigns.first,
                          );
                          _composerPillarId = nextCampaign.contentPillarId;
                        });
                      },
                      onPillarChanged: (value) {
                        setState(() => _composerPillarId = value);
                      },
                      onChannelChanged: (value) {
                        setState(() => _composerChannel = value);
                      },
                      onCreateDraft: effectiveCampaign == null || effectivePillarId == null
                          ? null
                          : () => _createDraft(
                                context,
                                campaignId: effectiveCampaign.id,
                                pillarId: effectivePillarId,
                                publishEverywhere: false,
                              ),
                      onCreateAndPublish: effectiveCampaign == null || effectivePillarId == null
                          ? null
                          : () => _createDraft(
                                context,
                                campaignId: effectiveCampaign.id,
                                pillarId: effectivePillarId,
                                publishEverywhere: true,
                              ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 5,
                    child: _ChannelPosturePanel(accounts: connectedAccounts),
                  ),
                ],
              )
            else ...[
              _ComposerPanel(
                titleController: _titleController,
                copyController: _copyController,
                campaigns: campaigns,
                contentPillars: contentPillars,
                selectedCampaignId: effectiveCampaignId,
                selectedPillarId: effectivePillarId,
                selectedChannel: _composerChannel,
                submitting: _submittingComposer,
                onCampaignChanged: (value) {
                  setState(() {
                    _composerCampaignId = value;
                    final nextCampaign = campaigns.firstWhere(
                      (campaign) => campaign.id == value,
                      orElse: () => campaigns.first,
                    );
                    _composerPillarId = nextCampaign.contentPillarId;
                  });
                },
                onPillarChanged: (value) {
                  setState(() => _composerPillarId = value);
                },
                onChannelChanged: (value) {
                  setState(() => _composerChannel = value);
                },
                onCreateDraft: effectiveCampaign == null || effectivePillarId == null
                    ? null
                    : () => _createDraft(
                          context,
                          campaignId: effectiveCampaign.id,
                          pillarId: effectivePillarId,
                          publishEverywhere: false,
                        ),
                onCreateAndPublish: effectiveCampaign == null || effectivePillarId == null
                    ? null
                    : () => _createDraft(
                          context,
                          campaignId: effectiveCampaign.id,
                          pillarId: effectivePillarId,
                          publishEverywhere: true,
                        ),
              ),
              const SizedBox(height: 16),
              _ChannelPosturePanel(accounts: connectedAccounts),
            ],
            const SizedBox(height: 20),
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: _DraftQueuePanel(
                      drafts: drafts,
                      selectedDraftId: selectedDraft?.id,
                      publishController: publishController,
                      onSelectDraft: (draftId) => setState(() => _selectedDraftId = draftId),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 6,
                    child: _SelectedDraftPanel(
                      draft: selectedDraft,
                      posture: selectedPosture,
                      publishController: publishController,
                      onRequestReview: selectedDraft == null
                          ? null
                          : () => controller.requestReview(selectedDraft),
                      onApprove: selectedDraft == null
                          ? null
                          : () => controller.approveDraft(selectedDraft),
                      onSchedule: selectedDraft == null
                          ? null
                          : () => controller.scheduleDraft(
                                selectedDraft,
                                DateTime.now().add(const Duration(hours: 6)),
                              ),
                      onPublishInstagram: selectedDraft == null
                          ? null
                          : () => _publishTargets(
                                context,
                                selectedDraft,
                                const [SocialPlatform.instagram],
                                successLabel: 'Published to Instagram',
                              ),
                      onPublishFacebook: selectedDraft == null
                          ? null
                          : () => _publishTargets(
                                context,
                                selectedDraft,
                                const [SocialPlatform.facebook],
                                successLabel: 'Published to Facebook',
                              ),
                      onPublishLinkedIn: selectedDraft == null
                          ? null
                          : () => _publishTargets(
                                context,
                                selectedDraft,
                                const [SocialPlatform.linkedin],
                                successLabel: 'Published to LinkedIn',
                              ),
                      onPublishEverywhere: selectedDraft == null
                          ? null
                          : () => _publishTargets(
                                context,
                                selectedDraft,
                                const [
                                  SocialPlatform.instagram,
                                  SocialPlatform.facebook,
                                  SocialPlatform.linkedin,
                                ],
                                successLabel: 'Published everywhere',
                              ),
                    ),
                  ),
                ],
              )
            else ...[
              _SelectedDraftPanel(
                draft: selectedDraft,
                posture: selectedPosture,
                publishController: publishController,
                onRequestReview: selectedDraft == null ? null : () => controller.requestReview(selectedDraft),
                onApprove: selectedDraft == null ? null : () => controller.approveDraft(selectedDraft),
                onSchedule: selectedDraft == null
                    ? null
                    : () => controller.scheduleDraft(
                          selectedDraft,
                          DateTime.now().add(const Duration(hours: 6)),
                        ),
                onPublishInstagram: selectedDraft == null
                    ? null
                    : () => _publishTargets(
                          context,
                          selectedDraft,
                          const [SocialPlatform.instagram],
                          successLabel: 'Published to Instagram',
                        ),
                onPublishFacebook: selectedDraft == null
                    ? null
                    : () => _publishTargets(
                          context,
                          selectedDraft,
                          const [SocialPlatform.facebook],
                          successLabel: 'Published to Facebook',
                        ),
                onPublishLinkedIn: selectedDraft == null
                    ? null
                    : () => _publishTargets(
                          context,
                          selectedDraft,
                          const [SocialPlatform.linkedin],
                          successLabel: 'Published to LinkedIn',
                        ),
                onPublishEverywhere: selectedDraft == null
                    ? null
                    : () => _publishTargets(
                          context,
                          selectedDraft,
                          const [
                            SocialPlatform.instagram,
                            SocialPlatform.facebook,
                            SocialPlatform.linkedin,
                          ],
                          successLabel: 'Published everywhere',
                        ),
              ),
              const SizedBox(height: 16),
              _DraftQueuePanel(
                drafts: drafts,
                selectedDraftId: selectedDraft?.id,
                publishController: publishController,
                onSelectDraft: (draftId) => setState(() => _selectedDraftId = draftId),
              ),
            ],
            const SizedBox(height: 20),
            if (selectedDraft != null)
              ObjectActivityPanel(
                title: 'Publish timeline',
                objectType: ActivityObjectType.draft,
                objectId: selectedDraft.id,
                emptyState: 'No activity recorded for this draft yet.',
              ),
          ],
        );
      },
    );
  }

  Future<void> _createDraft(
    BuildContext context, {
    required String campaignId,
    required String pillarId,
    required bool publishEverywhere,
  }) async {
    final services = MetarixScope.of(context);
    final planningController = services.planningController;
    final evidenceCodes = List<String>.from(
      services.policies.evidenceFor('publish_eligibility'),
    );
    final draft = PostDraft(
      id: services.gateway.createId('draft'),
      campaignId: campaignId,
      title: _titleController.text.trim(),
      targetNetwork: _composerChannel,
      contentPillarId: pillarId,
      copy: _copyController.text.trim(),
      assetRefs: const [],
      plannedPublishAt: DateTime.now().add(const Duration(hours: 2)),
      currentState: ContentState.approved,
      requiredApproval: ApprovalRequirement.none,
      evidenceCodes: evidenceCodes,
    );

    if (draft.title.isEmpty || draft.copy.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a title and message before creating a draft.')),
      );
      return;
    }

    setState(() => _submittingComposer = true);
    await planningController.saveDraft(draft);
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedDraftId = draft.id;
      _submittingComposer = false;
    });

    if (publishEverywhere) {
      await _publishTargets(
        context,
        draft,
        const [
          SocialPlatform.instagram,
          SocialPlatform.facebook,
          SocialPlatform.linkedin,
        ],
        successLabel: 'Draft created and pushed to connected channels',
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Draft created and ready in the publish queue.')),
    );
  }

  Future<void> _publishTargets(
    BuildContext context,
    PostDraft draft,
    List<SocialPlatform> targets, {
    required String successLabel,
  }) async {
    final services = MetarixScope.of(context);
    final results = await services.workflowController.publishDraftToTargets(
      draft,
      targets: targets,
    );
    if (!mounted) {
      return;
    }
    final successes = results.where((entry) => entry.isSuccess).length;
    final failures = results.where((entry) => !entry.isSuccess).map((entry) => entry.error).whereType<String>().join(' | ');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          failures.isEmpty
              ? '$successLabel. $successes/${results.length} succeeded.'
              : '$successLabel. $successes/${results.length} succeeded. $failures',
        ),
      ),
    );
  }
}

class _WorkspaceHero extends StatelessWidget {
  const _WorkspaceHero({
    required this.draftCount,
    required this.connectedCount,
    required this.scheduledCount,
    required this.publishedCount,
    required this.onPublishEverywhere,
  });

  final int draftCount;
  final int connectedCount;
  final int scheduledCount;
  final int publishedCount;
  final VoidCallback? onPublishEverywhere;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Publish Workspace',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Compose once, queue cleanly, and push to the connected social stack without hunting through admin-only surfaces.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: onPublishEverywhere,
                  icon: const Icon(Icons.rocket_launch_outlined),
                  label: const Text('Publish Everywhere'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatTile(label: 'Connected channels', value: '$connectedCount / 3'),
                _StatTile(label: 'Drafts in queue', value: '$draftCount'),
                _StatTile(label: 'Scheduled', value: '$scheduledCount'),
                _StatTile(label: 'Published', value: '$publishedCount'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ComposerPanel extends StatelessWidget {
  const _ComposerPanel({
    required this.titleController,
    required this.copyController,
    required this.campaigns,
    required this.contentPillars,
    required this.selectedCampaignId,
    required this.selectedPillarId,
    required this.selectedChannel,
    required this.submitting,
    required this.onCampaignChanged,
    required this.onPillarChanged,
    required this.onChannelChanged,
    required this.onCreateDraft,
    required this.onCreateAndPublish,
  });

  final TextEditingController titleController;
  final TextEditingController copyController;
  final List<Campaign> campaigns;
  final List<ContentPillar> contentPillars;
  final String? selectedCampaignId;
  final String? selectedPillarId;
  final SocialChannel selectedChannel;
  final bool submitting;
  final ValueChanged<String> onCampaignChanged;
  final ValueChanged<String> onPillarChanged;
  final ValueChanged<SocialChannel> onChannelChanged;
  final VoidCallback? onCreateDraft;
  final VoidCallback? onCreateAndPublish;

  @override
  Widget build(BuildContext context) {
    return _PanelFrame(
      title: 'Quick composer',
      subtitle: 'Start with a message, anchor it to a campaign, and turn it into a publish-ready draft in one move.',
      child: Column(
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Post title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: copyController,
            minLines: 4,
            maxLines: 6,
            decoration: const InputDecoration(labelText: 'Message'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: selectedCampaignId,
                  decoration: const InputDecoration(labelText: 'Campaign'),
                  items: campaigns
                      .map<DropdownMenuItem<String>>(
                        (campaign) => DropdownMenuItem<String>(
                          value: campaign.id,
                          child: Text(campaign.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onCampaignChanged(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: selectedPillarId,
                  decoration: const InputDecoration(labelText: 'Pillar'),
                  items: contentPillars
                      .map<DropdownMenuItem<String>>(
                        (pillar) => DropdownMenuItem<String>(
                          value: pillar.id,
                          child: Text(pillar.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onPillarChanged(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<SocialChannel>(
                  initialValue: selectedChannel,
                  decoration: const InputDecoration(labelText: 'Primary channel'),
                  items: const [
                    SocialChannel.instagram,
                    SocialChannel.facebook,
                    SocialChannel.linkedin,
                  ]
                      .map<DropdownMenuItem<SocialChannel>>(
                        (channel) => DropdownMenuItem<SocialChannel>(
                          value: channel,
                          child: Text(channel.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onChannelChanged(value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton.icon(
                onPressed: submitting ? null : onCreateDraft,
                icon: const Icon(Icons.edit_note_outlined),
                label: Text(submitting ? 'Creating...' : 'Create Draft'),
              ),
              const SizedBox(width: 12),
              FilledButton.tonalIcon(
                onPressed: submitting ? null : onCreateAndPublish,
                icon: const Icon(Icons.send_outlined),
                label: const Text('Create and Publish Everywhere'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChannelPosturePanel extends StatelessWidget {
  const _ChannelPosturePanel({required this.accounts});

  final List<ConnectedSocialAccount> accounts;

  @override
  Widget build(BuildContext context) {
    final accountMap = {
      for (final account in accounts) account.platformKey: account,
    };
    return _PanelFrame(
      title: 'Connected channel posture',
      subtitle: 'First launch now shows a believable connected stack so the publish surface feels alive immediately.',
      child: Column(
        children: [
          _ChannelStatusCard(
            platformLabel: 'Instagram',
            account: accountMap['instagram'],
            accent: const Color(0xFFE35D8F),
          ),
          const SizedBox(height: 12),
          _ChannelStatusCard(
            platformLabel: 'Facebook',
            account: accountMap['facebook'],
            accent: const Color(0xFF1877F2),
          ),
          const SizedBox(height: 12),
          _ChannelStatusCard(
            platformLabel: 'LinkedIn',
            account: accountMap['linkedin'],
            accent: const Color(0xFF0A66C2),
          ),
        ],
      ),
    );
  }
}

class _DraftQueuePanel extends StatelessWidget {
  const _DraftQueuePanel({
    required this.drafts,
    required this.selectedDraftId,
    required this.publishController,
    required this.onSelectDraft,
  });

  final List<PostDraft> drafts;
  final String? selectedDraftId;
  final PublishController publishController;
  final ValueChanged<String> onSelectDraft;

  @override
  Widget build(BuildContext context) {
    return _PanelFrame(
      title: 'Draft queue',
      subtitle: 'This is the working queue the team can scan before scheduling or pushing live.',
      child: Column(
        children: drafts
            .map((draft) {
              final record = publishController.recordForDraft(draft.id);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: draft.id == selectedDraftId
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.10)
                      : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  selected: draft.id == selectedDraftId,
                  title: Text(draft.title),
                  subtitle: Text(
                    '${draft.targetNetwork.label} | ${draft.currentState.label} | ${record?.status.label ?? 'Draft'}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => onSelectDraft(draft.id),
                ),
              );
            })
            .toList(),
      ),
    );
  }
}

class _SelectedDraftPanel extends StatelessWidget {
  const _SelectedDraftPanel({
    required this.draft,
    required this.posture,
    required this.publishController,
    required this.onRequestReview,
    required this.onApprove,
    required this.onSchedule,
    required this.onPublishInstagram,
    required this.onPublishFacebook,
    required this.onPublishLinkedIn,
    required this.onPublishEverywhere,
  });

  final PostDraft? draft;
  final PublishPostureResult? posture;
  final PublishController publishController;
  final VoidCallback? onRequestReview;
  final VoidCallback? onApprove;
  final VoidCallback? onSchedule;
  final VoidCallback? onPublishInstagram;
  final VoidCallback? onPublishFacebook;
  final VoidCallback? onPublishLinkedIn;
  final VoidCallback? onPublishEverywhere;

  @override
  Widget build(BuildContext context) {
    if (draft == null || posture == null) {
      return _PanelFrame(
        title: 'Selected draft',
        subtitle: 'Pick a draft from the queue to see publish controls.',
        child: const Text('No draft selected.'),
      );
    }

    final publishRecord = publishController.recordForDraft(draft!.id);

    return _PanelFrame(
      title: 'Selected draft',
      subtitle: 'Operate the publish lifecycle from one place instead of bouncing across planning and schedule views.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            draft!.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('Primary: ${draft!.targetNetwork.label}')),
              Chip(label: Text('State: ${draft!.currentState.label}')),
              Chip(label: Text('Posture: ${posture!.posture.label}')),
              Chip(label: Text('Queue: ${publishRecord?.status.label ?? 'Draft'}')),
            ],
          ),
          const SizedBox(height: 12),
          Text(draft!.copy),
          const SizedBox(height: 12),
          if (draft!.plannedPublishAt != null)
            Text('Planned publish: ${draft!.plannedPublishAt!.toLocal()}'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(onPressed: onRequestReview, child: const Text('Request Review')),
              OutlinedButton(onPressed: onApprove, child: const Text('Approve')),
              OutlinedButton(onPressed: onSchedule, child: const Text('Schedule for Later')),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Push live',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(onPressed: onPublishInstagram, child: const Text('Instagram')),
              FilledButton.tonal(onPressed: onPublishFacebook, child: const Text('Facebook')),
              OutlinedButton(onPressed: onPublishLinkedIn, child: const Text('LinkedIn')),
              FilledButton.icon(
                onPressed: onPublishEverywhere,
                icon: const Icon(Icons.rocket_launch_outlined),
                label: const Text('Publish Everywhere'),
              ),
            ],
          ),
          if (posture!.denialReasons.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Boundary notes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...posture!.denialReasons.map(
              (reason) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('${reason.code}: ${reason.message}'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PanelFrame extends StatelessWidget {
  const _PanelFrame({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _ChannelStatusCard extends StatelessWidget {
  const _ChannelStatusCard({
    required this.platformLabel,
    required this.account,
    required this.accent,
  });

  final String platformLabel;
  final ConnectedSocialAccount? account;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final connected = account?.status == SocialConnectionStatus.connected;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: accent.withValues(alpha: 0.10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: accent.withValues(alpha: 0.20),
            foregroundColor: accent,
            child: Text(platformLabel.substring(0, 1)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(platformLabel, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  account == null ? 'Not connected' : account!.accountHandle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Chip(label: Text(connected ? 'Connected' : 'Missing')),
        ],
      ),
    );
  }
}
