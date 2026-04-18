import 'package:flutter/material.dart';

import '../../../app/metarix_scope.dart';
import '../../../runtime/activity/activity_event_type.dart';
import '../../activity/object_activity_panel.dart';
import '../../admin/domain/admin_models.dart';
import '../application/listening_controller.dart';
import '../domain/listening_models.dart';

class ListeningScreen extends StatefulWidget {
  const ListeningScreen({super.key});

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> {
  String? _selectedQueryId;

  @override
  Widget build(BuildContext context) {
    final services = MetarixScope.of(context);
    final controller = services.listeningController;
    final canManage = services.accessControlService.canPerform(
      services.gateway.currentUserRole,
      RuntimeAction.manageListeningQueries,
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final snapshot = controller.snapshot;
        final selectedQuery = snapshot.queries.isEmpty
            ? null
            : snapshot.queries.firstWhere(
                (query) =>
                    query.id == (_selectedQueryId ?? snapshot.queries.first.id),
                orElse: () => snapshot.queries.first,
              );
        final signalSummary = snapshot.signalSummaryFor(selectedQuery?.id);
        final watchSummary = signalSummary.mentionWatch;
        final queryMentions = selectedQuery == null
            ? snapshot.mentions
            : snapshot.mentions
                  .where((entry) => entry.queryId == selectedQuery.id)
                  .toList();
        final querySpikes = selectedQuery == null
            ? snapshot.spikes
            : snapshot.spikes
                  .where((entry) => entry.queryId == selectedQuery.id)
                  .toList();

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Listening Workspace',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SummaryCard(
                  title: 'Mention watch',
                  value: watchSummary == null
                      ? 'No watch summary'
                      : '${watchSummary.mentionCount} mentions / ${watchSummary.spikeCount} spikes',
                ),
                _SummaryCard(
                  title: 'Action queue',
                  value: watchSummary == null
                      ? 'No actions queued'
                      : '${watchSummary.actionQueueCount} items',
                ),
                _SummaryCard(
                  title: 'Top watch',
                  value: watchSummary == null
                      ? 'No active watch signal'
                      : watchSummary.topWatchLabel,
                ),
                _SummaryCard(
                  title: 'Sentiment bucket',
                  value: signalSummary.sentimentBucket == null
                      ? 'No sentiment bucket'
                      : '${signalSummary.sentimentBucket!.label} (${signalSummary.sentimentBucket!.count})',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Panel(
                    title: 'Query registry',
                    actionLabel: 'New query',
                    actionEnabled: canManage.allowed,
                    onAction: () => _showQueryDialog(context, controller, null),
                    child: Column(
                      children: snapshot.queries
                          .map(
                            (query) => ListTile(
                              selected: selectedQuery?.id == query.id,
                              title: Text(query.name),
                              subtitle: Text(
                                '${query.queryFamily.label}\n${query.queryText}',
                              ),
                              isThreeLine: true,
                              onTap: () =>
                                  setState(() => _selectedQueryId = query.id),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: canManage.allowed
                                    ? () => _showQueryDialog(
                                        context,
                                        controller,
                                        query,
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
                  child: Column(
                    children: [
                      _Panel(
                        title: 'Mention feed',
                        actionLabel: null,
                        actionEnabled: false,
                        onAction: null,
                        child: Column(
                          children: queryMentions
                              .map(
                                (mention) => ListTile(
                                  title: Text(mention.source),
                                  subtitle: Text(
                                    '${mention.excerpt}\nSentiment: ${mention.sentimentLabel}',
                                  ),
                                  isThreeLine: true,
                                  trailing: DropdownButton<InsightAction>(
                                    value: mention.recommendedAction,
                                    items: InsightAction.values
                                        .map(
                                          (entry) => DropdownMenuItem(
                                            value: entry,
                                            child: Text(entry.label),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: canManage.allowed
                                        ? (value) {
                                            if (value != null) {
                                              controller.routeMention(
                                                mention,
                                                value,
                                              );
                                            }
                                          }
                                        : null,
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
                            child: _Panel(
                              title: 'Spike alerts',
                              actionLabel: null,
                              actionEnabled: false,
                              onAction: null,
                              child: Column(
                                children: querySpikes
                                    .map(
                                      (spike) => ListTile(
                                        title: Text(spike.headline),
                                        subtitle: Text(
                                          '${spike.mentionCount} mentions - ${spike.sentimentLabel}',
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _Panel(
                              title: 'Sentiment summary',
                              actionLabel: null,
                              actionEnabled: false,
                              onAction: null,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Positive: ${snapshot.sentimentSummary.positive}',
                                  ),
                                  Text(
                                    'Mixed: ${snapshot.sentimentSummary.mixed}',
                                  ),
                                  Text(
                                    'Negative: ${snapshot.sentimentSummary.negative}',
                                  ),
                                  if (signalSummary.sentimentBucket != null)
                                    Text(
                                      'Dominant bucket: ${signalSummary.sentimentBucket!.label}',
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Panel(
                    title: 'Competitor watch',
                    actionLabel: null,
                    actionEnabled: false,
                    onAction: null,
                    child: Column(
                      children: snapshot.competitorWatch
                          .map(
                            (entry) => ListTile(
                              title: Text(entry.competitorName),
                              subtitle: Text(
                                'Share of voice: ${(entry.shareOfVoice * 100).toStringAsFixed(0)}% - ${entry.sentimentLabel}',
                              ),
                              trailing: Text(entry.recommendedAction.label),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _Panel(
                    title: 'Insight action queue',
                    actionLabel: null,
                    actionEnabled: false,
                    onAction: null,
                    child: Column(
                      children: snapshot.mentions
                          .where(
                            (mention) =>
                                mention.recommendedAction !=
                                InsightAction.observe,
                          )
                          .map(
                            (mention) => ListTile(
                              title: Text(mention.recommendedAction.label),
                              subtitle: Text(mention.excerpt),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
            if (selectedQuery != null) ...[
              const SizedBox(height: 16),
              ObjectActivityPanel(
                title: 'Listening timeline',
                objectType: ActivityObjectType.listeningQuery,
                objectId: selectedQuery.id,
                emptyState:
                    'No activity recorded for this listening query yet.',
              ),
            ],
            if (!canManage.allowed) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(canManage.reason),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _showQueryDialog(
    BuildContext context,
    ListeningController controller,
    ListeningQuery? existing,
  ) async {
    final services = MetarixScope.of(context);
    final nameController = TextEditingController(text: existing?.name ?? '');
    final queryTextController = TextEditingController(
      text: existing?.queryText ?? '',
    );
    final tagsController = TextEditingController(
      text: existing?.tags.join(', ') ?? '',
    );
    final competitorsController = TextEditingController(
      text: existing?.targetCompetitors.join(', ') ?? '',
    );
    QueryFamily selectedFamily = existing?.queryFamily ?? QueryFamily.brand;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          existing == null ? 'New listening query' : 'Edit listening query',
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              DropdownButtonFormField<QueryFamily>(
                initialValue: selectedFamily,
                items: QueryFamily.values
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry,
                        child: Text(entry.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedFamily = value;
                  }
                },
              ),
              TextField(
                controller: queryTextController,
                decoration: const InputDecoration(labelText: 'Query text'),
              ),
              TextField(
                controller: tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                ),
              ),
              TextField(
                controller: competitorsController,
                decoration: const InputDecoration(
                  labelText: 'Target competitors (comma separated)',
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

    await controller.saveQuery(
      ListeningQuery(
        id: existing?.id ?? services.gateway.createId('query'),
        brandId: services.gateway.brand.id,
        name: nameController.text,
        queryFamily: selectedFamily,
        queryText: queryTextController.text,
        tags: _splitCsv(tagsController.text),
        targetCompetitors: _splitCsv(competitorsController.text),
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
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.actionLabel,
    required this.actionEnabled,
    required this.onAction,
    required this.child,
  });

  final String title;
  final String? actionLabel;
  final bool actionEnabled;
  final VoidCallback? onAction;
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
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (actionLabel != null)
                  TextButton.icon(
                    onPressed: actionEnabled ? onAction : null,
                    icon: const Icon(Icons.add),
                    label: Text(actionLabel!),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Text(value),
            ],
          ),
        ),
      ),
    );
  }
}
