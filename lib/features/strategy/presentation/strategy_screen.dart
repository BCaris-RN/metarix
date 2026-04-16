import 'package:flutter/material.dart';

import '../../../app/metarix_scope.dart';
import '../../shared/domain/core_models.dart';
import '../application/strategy_controller.dart';
import '../domain/strategy_models.dart';

class StrategyScreen extends StatelessWidget {
  const StrategyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = MetarixScope.of(context);
    final controller = services.strategyController;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final strategy = controller.strategy;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Strategy Workspace',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${strategy.brand.name} for ${strategy.workspace.name}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SummaryCard(
                  label: 'Business goals',
                  value: strategy.businessGoals.length.toString(),
                ),
                _SummaryCard(
                  label: 'Personas',
                  value: strategy.personas.length.toString(),
                ),
                _SummaryCard(
                  label: 'Competitors',
                  value: strategy.competitors.length.toString(),
                ),
                _SummaryCard(
                  label: 'Content pillars',
                  value: strategy.contentPillars.length.toString(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SectionFrame(
              title: 'Goals',
              actionLabel: 'Add goal',
              onAction: () => _showGoalDialog(
                context,
                controller,
                strategy.businessGoals.isNotEmpty
                    ? strategy.businessGoals.first
                    : null,
              ),
              child: Column(
                children: strategy.businessGoals.map((goal) {
                  final linkedGoals = strategy.socialGoals
                      .where((socialGoal) => socialGoal.businessGoalId == goal.id)
                      .toList();
                  return ListTile(
                    title: Text(goal.title),
                    subtitle: Text(
                      '${goal.summary}\n${linkedGoals.map((entry) => entry.type.label).join(', ')}',
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showGoalDialog(context, controller, goal),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            _SectionFrame(
              title: 'Audience personas',
              actionLabel: 'Add persona',
              onAction: () => _showPersonaDialog(context, controller, null),
              child: Column(
                children: strategy.personas
                    .map(
                      (persona) => ListTile(
                        title: Text(persona.name),
                        subtitle: Text(
                          '${persona.role}\n${persona.summary}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () =>
                              _showPersonaDialog(context, controller, persona),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            _SectionFrame(
              title: 'Competitor watchlist',
              actionLabel: 'Add competitor',
              onAction: () => _showCompetitorDialog(context, controller, null),
              child: Column(
                children: strategy.competitors
                    .map(
                      (competitor) => ListTile(
                        title: Text(competitor.name),
                        subtitle: Text(competitor.notes),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _showCompetitorDialog(
                            context,
                            controller,
                            competitor,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            _SectionFrame(
              title: 'Content pillars',
              actionLabel: 'Add pillar',
              onAction: () => _showPillarDialog(context, controller, null),
              child: Column(
                children: strategy.contentPillars
                    .map(
                      (pillar) => ListTile(
                        title: Text(pillar.name),
                        subtitle: Text(
                          '${pillar.description}\nTarget metric: ${pillar.targetMetric}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () =>
                              _showPillarDialog(context, controller, pillar),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _SectionFrame(
                    title: 'SWOT notes',
                    actionLabel: 'Add note',
                    onAction: () => _showSwotDialog(context, controller, null),
                    child: Column(
                      children: strategy.swotEntries
                          .map(
                            (entry) => ListTile(
                              title: Text(entry.category.label),
                              subtitle: Text(entry.note),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SectionFrame(
                    title: 'Audit notes',
                    actionLabel: 'Add note',
                    onAction: () => _showAuditDialog(context, controller, null),
                    child: Column(
                      children: strategy.auditFindings
                          .map(
                            (finding) => ListTile(
                              title: Text(finding.title),
                              subtitle: Text(
                                '${finding.observation}\nImpact: ${finding.impact}',
                              ),
                              isThreeLine: true,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _showGoalDialog(
    BuildContext context,
    StrategyController controller,
    BusinessGoal? existing,
  ) async {
    final services = MetarixScope.of(context);
    final linkedSocialGoal = existing == null
        ? null
        : controller.strategy.socialGoals.firstWhere(
            (goal) => goal.businessGoalId == existing.id,
            orElse: () => SocialGoal(
              id: services.gateway.createId('social-goal'),
              businessGoalId: existing.id,
              type: SocialGoalType.awareness,
              summary: '',
              metricTargets: const [
                MetricTarget(metricName: 'reach', targetValue: 0, unit: 'count'),
              ],
            ),
          );
    final titleController = TextEditingController(text: existing?.title ?? '');
    final summaryController = TextEditingController(text: existing?.summary ?? '');
    final socialSummaryController =
        TextEditingController(text: linkedSocialGoal?.summary ?? '');
    final metricController = TextEditingController(
      text: linkedSocialGoal?.metricTargets.first.metricName ?? 'reach',
    );
    SocialGoalType selectedType = linkedSocialGoal?.type ?? SocialGoalType.awareness;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existing == null ? 'New goal' : 'Edit goal'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Business goal'),
                ),
                TextField(
                  controller: summaryController,
                  decoration: const InputDecoration(labelText: 'Summary'),
                ),
                DropdownButtonFormField<SocialGoalType>(
                  initialValue: selectedType,
                  items: SocialGoalType.values
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry,
                          child: Text(entry.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedType = value;
                    }
                  },
                ),
                TextField(
                  controller: socialSummaryController,
                  decoration: const InputDecoration(labelText: 'Social goal summary'),
                ),
                TextField(
                  controller: metricController,
                  decoration: const InputDecoration(labelText: 'Primary metric'),
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
        );
      },
    );

    if (saved != true) {
      return;
    }

    final goalId = existing?.id ?? services.gateway.createId('goal');
    await controller.saveBusinessGoal(
      BusinessGoal(
        id: goalId,
        brandId: services.gateway.brand.id,
        title: titleController.text,
        summary: summaryController.text,
        socialGoalIds: [linkedSocialGoal?.id ?? services.gateway.createId('social-goal')],
      ),
      SocialGoal(
        id: linkedSocialGoal?.id ?? services.gateway.createId('social-goal'),
        businessGoalId: goalId,
        type: selectedType,
        summary: socialSummaryController.text,
        metricTargets: [
          MetricTarget(
            metricName: metricController.text,
            targetValue: 1,
            unit: 'target',
          ),
        ],
      ),
    );
  }

  Future<void> _showPersonaDialog(
    BuildContext context,
    StrategyController controller,
    AudiencePersona? existing,
  ) async {
    final services = MetarixScope.of(context);
    final nameController = TextEditingController(text: existing?.name ?? '');
    final roleController = TextEditingController(text: existing?.role ?? '');
    final summaryController = TextEditingController(text: existing?.summary ?? '');
    final goalsController =
        TextEditingController(text: existing?.goals.join(', ') ?? '');
    final painPointsController =
        TextEditingController(text: existing?.painPoints.join(', ') ?? '');
    final channelsController = TextEditingController(
      text: existing?.preferredNetworks.map((entry) => entry.name).join(', ') ?? '',
    );

    final saved = await _showSimpleDialog(context, existing == null ? 'New persona' : 'Edit persona', [
      _DialogField(nameController, 'Name'),
      _DialogField(roleController, 'Role'),
      _DialogField(summaryController, 'Summary'),
      _DialogField(goalsController, 'Goals (comma separated)'),
      _DialogField(painPointsController, 'Pain points (comma separated)'),
      _DialogField(channelsController, 'Networks (comma separated enum names)'),
    ]);
    if (!saved) {
      return;
    }

    await controller.savePersona(
      AudiencePersona(
        id: existing?.id ?? services.gateway.createId('persona'),
        brandId: services.gateway.brand.id,
        name: nameController.text,
        role: roleController.text,
        summary: summaryController.text,
        preferredNetworks: _parseChannels(channelsController.text),
        goals: _splitCsv(goalsController.text),
        painPoints: _splitCsv(painPointsController.text),
      ),
    );
  }

  Future<void> _showCompetitorDialog(
    BuildContext context,
    StrategyController controller,
    Competitor? existing,
  ) async {
    final services = MetarixScope.of(context);
    final nameController = TextEditingController(text: existing?.name ?? '');
    final notesController = TextEditingController(text: existing?.notes ?? '');
    final channelsController = TextEditingController(
      text: existing?.primaryChannels.map((entry) => entry.name).join(', ') ?? '',
    );
    final saved = await _showSimpleDialog(context, existing == null ? 'New competitor' : 'Edit competitor', [
      _DialogField(nameController, 'Name'),
      _DialogField(channelsController, 'Channels (comma separated enum names)'),
      _DialogField(notesController, 'Notes'),
    ]);
    if (!saved) {
      return;
    }
    await controller.saveCompetitor(
      Competitor(
        id: existing?.id ?? services.gateway.createId('competitor'),
        brandId: services.gateway.brand.id,
        name: nameController.text,
        primaryChannels: _parseChannels(channelsController.text),
        notes: notesController.text,
      ),
    );
  }

  Future<void> _showPillarDialog(
    BuildContext context,
    StrategyController controller,
    ContentPillar? existing,
  ) async {
    final services = MetarixScope.of(context);
    final nameController = TextEditingController(text: existing?.name ?? '');
    final descriptionController =
        TextEditingController(text: existing?.description ?? '');
    final metricController =
        TextEditingController(text: existing?.targetMetric ?? '');
    final toneController = TextEditingController(text: existing?.tone ?? '');
    final saved = await _showSimpleDialog(context, existing == null ? 'New pillar' : 'Edit pillar', [
      _DialogField(nameController, 'Name'),
      _DialogField(descriptionController, 'Description'),
      _DialogField(metricController, 'Target metric'),
      _DialogField(toneController, 'Tone'),
    ]);
    if (!saved) {
      return;
    }
    await controller.saveContentPillar(
      ContentPillar(
        id: existing?.id ?? services.gateway.createId('pillar'),
        brandId: services.gateway.brand.id,
        name: nameController.text,
        description: descriptionController.text,
        targetMetric: metricController.text,
        tone: toneController.text,
      ),
    );
  }

  Future<void> _showSwotDialog(
    BuildContext context,
    StrategyController controller,
    SwotEntry? existing,
  ) async {
    final services = MetarixScope.of(context);
    final noteController = TextEditingController(text: existing?.note ?? '');
    SwotCategory category = existing?.category ?? SwotCategory.strength;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'New SWOT note' : 'Edit SWOT note'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<SwotCategory>(
                initialValue: category,
                items: SwotCategory.values
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry,
                        child: Text(entry.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    category = value;
                  }
                },
              ),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Note'),
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
    await controller.saveSwotEntry(
      SwotEntry(
        id: existing?.id ?? services.gateway.createId('swot'),
        brandId: services.gateway.brand.id,
        category: category,
        note: noteController.text,
      ),
    );
  }

  Future<void> _showAuditDialog(
    BuildContext context,
    StrategyController controller,
    AuditFinding? existing,
  ) async {
    final services = MetarixScope.of(context);
    final titleController = TextEditingController(text: existing?.title ?? '');
    final observationController =
        TextEditingController(text: existing?.observation ?? '');
    final impactController = TextEditingController(text: existing?.impact ?? '');
    final saved = await _showSimpleDialog(context, existing == null ? 'New audit note' : 'Edit audit note', [
      _DialogField(titleController, 'Title'),
      _DialogField(observationController, 'Observation'),
      _DialogField(impactController, 'Impact'),
    ]);
    if (!saved) {
      return;
    }
    await controller.saveAuditFinding(
      AuditFinding(
        id: existing?.id ?? services.gateway.createId('audit'),
        brandId: services.gateway.brand.id,
        title: titleController.text,
        observation: observationController.text,
        impact: impactController.text,
      ),
    );
  }

  List<String> _splitCsv(String value) {
    return value
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
  }

  List<SocialChannel> _parseChannels(String value) {
    return _splitCsv(value).map(SocialChannelX.fromName).toList();
  }

  Future<bool> _showSimpleDialog(
    BuildContext context,
    String title,
    List<_DialogField> fields,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: fields
                    .map(
                      (field) => TextField(
                        controller: field.controller,
                        decoration: InputDecoration(labelText: field.label),
                      ),
                    )
                    .toList(),
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
        ) ??
        false;
  }
}

class _DialogField {
  const _DialogField(this.controller, this.label);

  final TextEditingController controller;
  final String label;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionFrame extends StatelessWidget {
  const _SectionFrame({
    required this.title,
    required this.actionLabel,
    required this.onAction,
    required this.child,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;
  final Widget child;

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
                  child: Text(title, style: Theme.of(context).textTheme.titleLarge),
                ),
                TextButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add),
                  label: Text(actionLabel),
                ),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
