import 'package:flutter/material.dart';

import '../../../app/metarix_scope.dart';
import '../../activity/object_activity_panel.dart';
import '../../admin/domain/admin_models.dart';
import '../../../runtime/activity/activity_event_type.dart';
import '../../shared/domain/core_models.dart';
import '../application/report_controller.dart';
import '../domain/report_models.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String? _selectedPeriodId;

  @override
  Widget build(BuildContext context) {
    final services = MetarixScope.of(context);
    final controller = services.reportController;
    final decision = services.accessControlService.canPerform(
      services.gateway.currentUserRole,
      RuntimeAction.generateReport,
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final snapshot = controller.snapshot;
        final activePeriodId = _selectedPeriodId ?? snapshot.activePeriodId;
        final activePeriod = snapshot.reportPeriods.firstWhere(
          (period) => period.id == activePeriodId,
        );
        final comparisonPeriodId = snapshot.comparisonPeriods[activePeriodId]!;
        final comparisonPeriod = snapshot.reportPeriods.firstWhere(
          (period) => period.id == comparisonPeriodId,
        );
        final metrics = snapshot.channelPerformance
            .where((record) => record.reportPeriodId == activePeriodId)
            .toList();
        final takeaways = snapshot.takeaways
            .where((entry) => entry.reportPeriodId == activePeriodId)
            .toList();
        final learnings = snapshot.overallLearnings
            .where((entry) => entry.reportPeriodId == activePeriodId)
            .toList();
        final actions = snapshot.futureActions
            .where((entry) => entry.reportPeriodId == activePeriodId)
            .toList();
        final standout = snapshot.standoutResults
            .where((entry) => entry.reportPeriodId == activePeriodId)
            .toList();

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Reports Workspace',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: decision.allowed
                      ? () => controller.generateReport(activePeriodId)
                      : null,
                  icon: const Icon(Icons.auto_graph_outlined),
                  label: const Text('Generate Report'),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: activePeriodId,
                  items: snapshot.reportPeriods
                      .map(
                        (period) => DropdownMenuItem(
                          value: period.id,
                          child: Text(period.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedPeriodId = value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricCard(
                  title: 'Success snapshot',
                  value: snapshot.successSnapshot,
                ),
                _MetricCard(
                  title: 'Comparison range',
                  value: comparisonPeriod.label,
                ),
                _MetricCard(
                  title: 'Top post',
                  value: snapshot.topPostPlaceholder,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Channel performance',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    DataTable(
                      columns: const [
                        DataColumn(label: Text('Channel')),
                        DataColumn(label: Text('Reach')),
                        DataColumn(label: Text('Impressions')),
                        DataColumn(label: Text('Engagements')),
                        DataColumn(label: Text('Clicks')),
                        DataColumn(label: Text('Sentiment')),
                      ],
                      rows: metrics
                          .map(
                            (record) => DataRow(
                              cells: [
                                DataCell(Text(record.channel.label)),
                                DataCell(Text('${record.reach}')),
                                DataCell(Text('${record.impressions}')),
                                DataCell(Text('${record.engagements}')),
                                DataCell(Text('${record.clicks}')),
                                DataCell(
                                  Text(
                                    record.sentimentScore.toStringAsFixed(2),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _EditableSection(
                    title: 'Standout results',
                    actionLabel: null,
                    onAction: null,
                    children: standout
                        .map(
                          (entry) => ListTile(
                            title: Text(entry.headline),
                            subtitle: Text(entry.detail),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _EditableSection(
                    title: 'Takeaways',
                    actionLabel: 'Add takeaway',
                    onAction: decision.allowed
                        ? () => _showTakeawayDialog(
                            context,
                            controller,
                            activePeriod.id,
                            null,
                          )
                        : null,
                    children: takeaways
                        .map(
                          (entry) => ListTile(
                            title: Text(entry.title),
                            subtitle: Text(entry.whatWeLearned),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: decision.allowed
                                  ? () => _showTakeawayDialog(
                                      context,
                                      controller,
                                      activePeriod.id,
                                      entry,
                                    )
                                  : null,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _EditableSection(
                    title: 'Overall learnings',
                    actionLabel: 'Add learning',
                    onAction: decision.allowed
                        ? () => _showLearningDialog(
                            context,
                            controller,
                            activePeriod.id,
                            null,
                          )
                        : null,
                    children: learnings
                        .map((entry) => ListTile(title: Text(entry.text)))
                        .toList(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _EditableSection(
                    title: 'Future actions',
                    actionLabel: 'Add action',
                    onAction: decision.allowed
                        ? () => _showRecommendationDialog(
                            context,
                            controller,
                            activePeriod.id,
                            null,
                          )
                        : null,
                    children: actions
                        .map(
                          (entry) => ListTile(
                            title: Text(entry.title),
                            subtitle: Text(entry.actionType.label),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: decision.allowed
                                  ? () => _showRecommendationDialog(
                                      context,
                                      controller,
                                      activePeriod.id,
                                      entry,
                                    )
                                  : null,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
            if (!decision.allowed) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(decision.reason),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Period: ${activePeriod.start.toIso8601String().split('T').first} - ${activePeriod.end.toIso8601String().split('T').first}',
            ),
            const SizedBox(height: 16),
            ObjectActivityPanel(
              title: 'Report timeline',
              objectType: ActivityObjectType.report,
              objectId: activePeriod.id,
              emptyState: 'No report activity recorded for this period yet.',
            ),
          ],
        );
      },
    );
  }

  Future<void> _showTakeawayDialog(
    BuildContext context,
    ReportController controller,
    String periodId,
    Takeaway? existing,
  ) async {
    final services = MetarixScope.of(context);
    final titleController = TextEditingController(text: existing?.title ?? '');
    final whatController = TextEditingController(
      text: existing?.whatHappened ?? '',
    );
    final whyController = TextEditingController(
      text: existing?.whyItHappened ?? '',
    );
    final howController = TextEditingController(
      text: existing?.howWeKnow ?? '',
    );
    final learnedController = TextEditingController(
      text: existing?.whatWeLearned ?? '',
    );
    final saved = await _showDialog(
      context,
      existing == null ? 'New takeaway' : 'Edit takeaway',
      [
        _Field(titleController, 'Title'),
        _Field(whatController, 'What happened'),
        _Field(whyController, 'Why it happened'),
        _Field(howController, 'How we know'),
        _Field(learnedController, 'What we learned'),
      ],
    );
    if (!saved) {
      return;
    }
    await controller.saveTakeaway(
      Takeaway(
        id: existing?.id ?? services.gateway.createId('takeaway'),
        reportPeriodId: periodId,
        title: titleController.text,
        whatHappened: whatController.text,
        whyItHappened: whyController.text,
        howWeKnow: howController.text,
        whatWeLearned: learnedController.text,
      ),
    );
  }

  Future<void> _showLearningDialog(
    BuildContext context,
    ReportController controller,
    String periodId,
    LearningEntry? existing,
  ) async {
    final services = MetarixScope.of(context);
    final textController = TextEditingController(text: existing?.text ?? '');
    final saved = await _showDialog(
      context,
      existing == null ? 'New learning' : 'Edit learning',
      [_Field(textController, 'Learning')],
    );
    if (!saved) {
      return;
    }
    await controller.saveLearning(
      LearningEntry(
        id: existing?.id ?? services.gateway.createId('learning'),
        reportPeriodId: periodId,
        text: textController.text,
      ),
    );
  }

  Future<void> _showRecommendationDialog(
    BuildContext context,
    ReportController controller,
    String periodId,
    Recommendation? existing,
  ) async {
    final services = MetarixScope.of(context);
    final titleController = TextEditingController(text: existing?.title ?? '');
    final rationaleController = TextEditingController(
      text: existing?.rationale ?? '',
    );
    final ownerController = TextEditingController(text: existing?.owner ?? '');
    final benefitController = TextEditingController(
      text: existing?.expectedBenefit ?? '',
    );
    ReportActionType selectedType =
        existing?.actionType ?? ReportActionType.startAction;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'New action' : 'Edit action'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              DropdownButtonFormField<ReportActionType>(
                initialValue: selectedType,
                items: ReportActionType.values
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
                controller: rationaleController,
                decoration: const InputDecoration(labelText: 'Rationale'),
              ),
              TextField(
                controller: ownerController,
                decoration: const InputDecoration(labelText: 'Owner'),
              ),
              TextField(
                controller: benefitController,
                decoration: const InputDecoration(
                  labelText: 'Expected benefit',
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
    await controller.saveRecommendation(
      Recommendation(
        id: existing?.id ?? services.gateway.createId('recommendation'),
        reportPeriodId: periodId,
        title: titleController.text,
        actionType: selectedType,
        rationale: rationaleController.text,
        owner: ownerController.text,
        expectedBenefit: benefitController.text,
      ),
    );
  }

  Future<bool> _showDialog(
    BuildContext context,
    String title,
    List<_Field> fields,
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

class _EditableSection extends StatelessWidget {
  const _EditableSection({
    required this.title,
    required this.actionLabel,
    required this.onAction,
    required this.children,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final List<Widget> children;

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
                if (actionLabel != null)
                  TextButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.add),
                    label: Text(actionLabel!),
                  ),
              ],
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(title), const SizedBox(height: 8), Text(value)],
          ),
        ),
      ),
    );
  }
}

class _Field {
  const _Field(this.controller, this.label);

  final TextEditingController controller;
  final String label;
}
