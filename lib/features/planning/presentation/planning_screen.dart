import 'package:flutter/material.dart';

import '../../../app/metarix_scope.dart';
import '../../admin/domain/admin_models.dart';
import '../../publish/domain/publish_models.dart';
import '../../shared/domain/core_models.dart';
import '../../workflow/domain/workflow_models.dart';
import '../application/planning_controller.dart';
import '../domain/planning_models.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  String? _selectedCampaignId;
  String? _selectedDraftId;
  DateTime _calendarMonth = DateTime(2026, 4);

  @override
  Widget build(BuildContext context) {
    final services = MetarixScope.of(context);
    final controller = services.planningController;
    final canCreateCampaign = services.accessControlService.canPerform(
      services.gateway.currentUserRole,
      RuntimeAction.createCampaign,
    );
    final canEditDraft = services.accessControlService.canPerform(
      services.gateway.currentUserRole,
      RuntimeAction.editDraft,
    );
    final publishController = services.publishController;

    return AnimatedBuilder(
      animation: Listenable.merge([controller, publishController]),
      builder: (context, _) {
        final campaigns = controller.campaigns;
        final selectedCampaign = campaigns.isEmpty
            ? null
            : campaigns.firstWhere(
                (campaign) =>
                    campaign.id == (_selectedCampaignId ?? campaigns.first.id),
                orElse: () => campaigns.first,
              );
        final drafts = selectedCampaign == null
            ? controller.drafts
            : controller.drafts
                  .where((draft) => draft.campaignId == selectedCampaign.id)
                  .toList();
        final selectedDraft = drafts.isEmpty
            ? null
            : drafts.firstWhere(
                (draft) => draft.id == (_selectedDraftId ?? drafts.first.id),
                orElse: () => drafts.first,
              );

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Planning Workspace',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _Panel(
                    title: 'Campaigns',
                    actionLabel: 'New campaign',
                    actionEnabled: canCreateCampaign.allowed,
                    onAction: () =>
                        _showCampaignDialog(context, controller, null),
                    body: Column(
                      children: campaigns
                          .map(
                            (campaign) => ListTile(
                              selected: selectedCampaign?.id == campaign.id,
                              title: Text(campaign.name),
                              subtitle: Text(
                                '${campaign.summary}\n${campaign.startDate.toIso8601String().split('T').first} - ${campaign.endDate.toIso8601String().split('T').first}',
                              ),
                              isThreeLine: true,
                              onTap: () {
                                setState(() {
                                  _selectedCampaignId = campaign.id;
                                  _selectedDraftId = null;
                                });
                              },
                              trailing: IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: canCreateCampaign.allowed
                                    ? () => _showCampaignDialog(
                                        context,
                                        controller,
                                        campaign,
                                      )
                                    : null,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: _Panel(
                    title: 'Campaign detail',
                    actionLabel: 'New draft',
                    actionEnabled:
                        canEditDraft.allowed && selectedCampaign != null,
                    onAction: selectedCampaign == null
                        ? null
                        : () => _showDraftDialog(
                            context,
                            controller,
                            selectedCampaign,
                            null,
                          ),
                    body: selectedCampaign == null
                        ? const Text('Select a campaign to see details.')
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedCampaign.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(selectedCampaign.summary),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: selectedCampaign.channels
                                    .map(
                                      (channel) =>
                                          Chip(label: Text(channel.label)),
                                    )
                                    .toList(),
                              ),
                              const SizedBox(height: 12),
                              const Text('Drafts'),
                              const SizedBox(height: 8),
                              ...drafts.map((draft) {
                                final publishStatus =
                                    publishController
                                        .recordForDraft(draft.id)
                                        ?.status ??
                                    PublishRecordStatus.draft;
                                return ListTile(
                                  selected: selectedDraft?.id == draft.id,
                                  title: Text(draft.title),
                                  subtitle: Text(
                                    '${draft.currentState.label} | Publish: ${publishStatus.label}',
                                  ),
                                  onTap: () => setState(
                                    () => _selectedDraftId = draft.id,
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: canEditDraft.allowed
                                        ? () => _showDraftDialog(
                                            context,
                                            controller,
                                            selectedCampaign,
                                            draft,
                                          )
                                        : null,
                                  ),
                                );
                              }),
                            ],
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _Panel(
                    title: 'Editorial calendar',
                    actionLabel: 'Shift month',
                    actionEnabled: true,
                    onAction: () {
                      setState(() {
                        _calendarMonth = DateTime(
                          _calendarMonth.year,
                          _calendarMonth.month + 1,
                          1,
                        );
                      });
                    },
                    body: _CalendarGrid(
                      days: controller.monthView(_calendarMonth),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _Panel(
                        title: 'Draft detail',
                        actionLabel: 'Edit draft',
                        actionEnabled:
                            canEditDraft.allowed &&
                            selectedCampaign != null &&
                            selectedDraft != null,
                        onAction:
                            selectedCampaign == null || selectedDraft == null
                            ? null
                            : () => _showDraftDialog(
                                context,
                                controller,
                                selectedCampaign,
                                selectedDraft,
                              ),
                        body: selectedDraft == null
                            ? const Text('Select a draft to inspect it.')
                            : Builder(
                                builder: (context) {
                                  final publishStatus =
                                      publishController
                                          .recordForDraft(selectedDraft.id)
                                          ?.status ??
                                      PublishRecordStatus.draft;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedDraft.title,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(selectedDraft.copy),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Network: ${selectedDraft.targetNetwork.label}',
                                      ),
                                      Text(
                                        'Planned at: ${selectedDraft.plannedPublishAt?.toIso8601String().split('T').join(' ') ?? 'Not set'}',
                                      ),
                                      Text(
                                        'State: ${selectedDraft.currentState.label}',
                                      ),
                                      Text(
                                        'Publish status: ${publishStatus.label}',
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 16),
                      _Panel(
                        title: 'Evergreen library',
                        actionLabel: 'Add evergreen',
                        actionEnabled: canEditDraft.allowed,
                        onAction: () =>
                            _showEvergreenDialog(context, controller, null),
                        body: Column(
                          children: controller.evergreenItems
                              .map(
                                (item) => ListTile(
                                  title: Text(item.title),
                                  subtitle: Text(item.summary),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!canCreateCampaign.allowed || !canEditDraft.allowed) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    !canCreateCampaign.allowed
                        ? canCreateCampaign.reason
                        : canEditDraft.reason,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _showCampaignDialog(
    BuildContext context,
    PlanningController controller,
    Campaign? existing,
  ) async {
    final services = MetarixScope.of(context);
    final nameController = TextEditingController(text: existing?.name ?? '');
    final summaryController = TextEditingController(
      text: existing?.summary ?? '',
    );
    final channelsController = TextEditingController(
      text:
          existing?.channels.map((channel) => channel.name).join(', ') ??
          'linkedin, instagram',
    );
    final initialPillar = controller.contentPillars.isEmpty
        ? null
        : controller.contentPillars.first;
    String? selectedPillarId = existing?.contentPillarId ?? initialPillar?.id;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'New campaign' : 'Edit campaign'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Campaign name'),
              ),
              TextField(
                controller: summaryController,
                decoration: const InputDecoration(labelText: 'Summary'),
              ),
              TextField(
                controller: channelsController,
                decoration: const InputDecoration(
                  labelText: 'Channels (comma separated enum names)',
                ),
              ),
              DropdownButtonFormField<String>(
                initialValue: selectedPillarId,
                items: controller.contentPillars
                    .map(
                      (pillar) => DropdownMenuItem(
                        value: pillar.id,
                        child: Text(pillar.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedPillarId = value;
                  }
                },
              ),
            ],
          ),
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
    if (saved != true) {
      return;
    }

    await controller.saveCampaign(
      Campaign(
        id: existing?.id ?? services.gateway.createId('campaign'),
        brandId: services.gateway.brand.id,
        name: nameController.text,
        summary: summaryController.text,
        startDate: existing?.startDate ?? DateTime.now(),
        endDate:
            existing?.endDate ?? DateTime.now().add(const Duration(days: 30)),
        channels: _parseChannels(channelsController.text),
        contentPillarId: selectedPillarId ?? '',
      ),
    );
  }

  Future<void> _showDraftDialog(
    BuildContext context,
    PlanningController controller,
    Campaign campaign,
    PostDraft? existing,
  ) async {
    final services = MetarixScope.of(context);
    final titleController = TextEditingController(text: existing?.title ?? '');
    final copyController = TextEditingController(text: existing?.copy ?? '');
    final assetController = TextEditingController(
      text: existing?.assetRefs.map((asset) => asset.label).join(', ') ?? '',
    );
    SocialChannel selectedChannel =
        existing?.targetNetwork ?? campaign.channels.first;
    String selectedPillarId =
        existing?.contentPillarId ?? campaign.contentPillarId;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'New draft' : 'Edit draft'),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              DropdownButtonFormField<SocialChannel>(
                initialValue: selectedChannel,
                items: campaign.channels
                    .map(
                      (channel) => DropdownMenuItem(
                        value: channel,
                        child: Text(channel.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedChannel = value;
                  }
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: selectedPillarId,
                items: controller.contentPillars
                    .map(
                      (pillar) => DropdownMenuItem(
                        value: pillar.id,
                        child: Text(pillar.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedPillarId = value;
                  }
                },
              ),
              TextField(
                controller: copyController,
                decoration: const InputDecoration(labelText: 'Copy'),
                minLines: 3,
                maxLines: 5,
              ),
              TextField(
                controller: assetController,
                decoration: const InputDecoration(
                  labelText: 'Asset labels (comma separated)',
                ),
              ),
            ],
          ),
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
    if (saved != true) {
      return;
    }

    final approvalRequirement = services.policies.approvalRequirementFor(
      selectedChannel,
      'publish_attempt',
    );

    await controller.saveDraft(
      PostDraft(
        id: existing?.id ?? services.gateway.createId('draft'),
        campaignId: campaign.id,
        title: titleController.text,
        targetNetwork: selectedChannel,
        contentPillarId: selectedPillarId,
        copy: copyController.text,
        assetRefs: _buildAssetRefs(assetController.text, services),
        plannedPublishAt:
            existing?.plannedPublishAt ??
            DateTime.now().add(const Duration(days: 3)),
        currentState: existing?.currentState ?? ContentState.draft,
        requiredApproval: approvalRequirement,
        evidenceCodes: existing?.evidenceCodes ?? const ['draft_snapshot'],
      ),
    );
  }

  Future<void> _showEvergreenDialog(
    BuildContext context,
    PlanningController controller,
    EvergreenContentItem? existing,
  ) async {
    final services = MetarixScope.of(context);
    final titleController = TextEditingController(text: existing?.title ?? '');
    final summaryController = TextEditingController(
      text: existing?.summary ?? '',
    );
    final initialPillar = controller.contentPillars.isEmpty
        ? null
        : controller.contentPillars.first;
    String? selectedPillarId = existing?.contentPillarId ?? initialPillar?.id;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          existing == null ? 'New evergreen item' : 'Edit evergreen item',
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: summaryController,
                decoration: const InputDecoration(labelText: 'Summary'),
              ),
              DropdownButtonFormField<String>(
                initialValue: selectedPillarId,
                items: controller.contentPillars
                    .map(
                      (pillar) => DropdownMenuItem(
                        value: pillar.id,
                        child: Text(pillar.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedPillarId = value;
                  }
                },
              ),
            ],
          ),
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
    if (saved != true) {
      return;
    }
    await controller.saveEvergreen(
      EvergreenContentItem(
        id: existing?.id ?? services.gateway.createId('evergreen'),
        brandId: services.gateway.brand.id,
        title: titleController.text,
        summary: summaryController.text,
        contentPillarId: selectedPillarId ?? '',
        assetRefs: const [],
        suggestedChannels: const [
          SocialChannel.instagram,
          SocialChannel.linkedin,
        ],
      ),
    );
  }

  List<SocialChannel> _parseChannels(String value) {
    return value
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .map(SocialChannelX.fromName)
        .toList();
  }

  List<AssetRef> _buildAssetRefs(String value, services) {
    return value
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .map(
          (entry) => AssetRef(
            id: services.gateway.createId('asset'),
            label: entry,
            kind: 'reference',
            location: 'demo://$entry',
          ),
        )
        .toList();
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.actionLabel,
    required this.actionEnabled,
    required this.onAction,
    required this.body,
  });

  final String title;
  final String actionLabel;
  final bool actionEnabled;
  final VoidCallback? onAction;
  final Widget body;

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
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton.icon(
                  onPressed: actionEnabled ? onAction : null,
                  icon: const Icon(Icons.add),
                  label: Text(actionLabel),
                ),
              ],
            ),
            const SizedBox(height: 12),
            body,
          ],
        ),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({required this.days});

  final List<EditorialCalendarDay> days;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: days.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        mainAxisExtent: 110,
      ),
      itemBuilder: (context, index) {
        final day = days[index];
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${day.date.day}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              ...day.drafts
                  .take(2)
                  .map(
                    (draft) => Text(
                      draft.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}
