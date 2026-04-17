import 'package:flutter/material.dart';

import '../../../app/metarix_scope.dart';
import '../../activity/object_activity_panel.dart';
import '../../admin/domain/admin_models.dart';
import '../../publish/domain/publish_models.dart';
import '../../../runtime/activity/activity_event_type.dart';
import '../../schedule/domain/schedule_models.dart';
import '../../shared/domain/core_models.dart';
import '../../workflow/domain/workflow_models.dart';

class WorkflowScreen extends StatefulWidget {
  const WorkflowScreen({super.key});

  @override
  State<WorkflowScreen> createState() => _WorkflowScreenState();
}

class _WorkflowScreenState extends State<WorkflowScreen> {
  String? _selectedDraftId;

  @override
  Widget build(BuildContext context) {
    final services = MetarixScope.of(context);
    final controller = services.workflowController;
    final publishController = services.publishController;

    return AnimatedBuilder(
      animation: Listenable.merge([controller, publishController]),
      builder: (context, _) {
        final drafts = controller.drafts;
        final selectedDraft = drafts.isEmpty
            ? null
            : drafts.firstWhere(
                (draft) => draft.id == (_selectedDraftId ?? drafts.first.id),
                orElse: () => drafts.first,
              );
        final posture = selectedDraft == null
            ? null
            : controller.postureFor(selectedDraft);
        final publishStatus = selectedDraft == null
            ? PublishRecordStatus.draft
            : publishController.recordForDraft(selectedDraft.id)?.status ??
                  PublishRecordStatus.draft;
        final evidenceRequirements = services.policies.evidenceFor(
          'publish_eligibility',
        );

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Workflow Workspace',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Draft queue',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          ...drafts.map(
                            (draft) => ListTile(
                              selected: draft.id == selectedDraft?.id,
                              title: Text(draft.title),
                              subtitle: Text(
                                '${draft.targetNetwork.label} · ${draft.currentState.label}',
                              ),
                              onTap: () =>
                                  setState(() => _selectedDraftId = draft.id),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: selectedDraft == null || posture == null
                          ? const Text('Select a draft to see workflow detail.')
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedDraft.title,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    Chip(
                                      label: Text(
                                        'State: ${selectedDraft.currentState.label}',
                                      ),
                                    ),
                                    Chip(
                                      label: Text(
                                        'Approval: ${posture.approvalRequirement.label}',
                                      ),
                                    ),
                                    Chip(
                                      label: Text(
                                        'Schedule support: ${posture.channelSupportsSchedule ? 'Yes' : 'No'}',
                                      ),
                                    ),
                                    Chip(
                                      label: Text(
                                        'Publish posture: ${posture.posture.label}',
                                      ),
                                    ),
                                    Chip(
                                      label: Text(
                                        'Publish state: ${publishStatus.label}',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Approval satisfied: ${posture.approvalSatisfied ? 'Yes' : 'No'}',
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Blocked actions',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                ...RuntimeAction.values.map((action) {
                                  final decision = controller.accessFor(
                                    action,
                                    draft: selectedDraft,
                                  );
                                  return ListTile(
                                    dense: true,
                                    title: Text(action.label),
                                    subtitle: Text(decision.reason),
                                    trailing: Icon(
                                      decision.allowed
                                          ? Icons.check_circle_outline
                                          : Icons.block_outlined,
                                    ),
                                  );
                                }),
                                const Divider(),
                                Text(
                                  'Evidence checklist',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                ...evidenceRequirements.map(
                                  (code) => CheckboxListTile(
                                    dense: true,
                                    value: selectedDraft.evidenceCodes.contains(
                                      code,
                                    ),
                                    onChanged: (_) => controller.toggleEvidence(
                                      selectedDraft,
                                      code,
                                    ),
                                    title: Text(code),
                                  ),
                                ),
                                const Divider(),
                                if (posture.denialReasons.isNotEmpty) ...[
                                  Text(
                                    'Denial reasons',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  ...posture.denialReasons.map(
                                    (reason) => ListTile(
                                      dense: true,
                                      leading: const Icon(
                                        Icons.warning_amber_outlined,
                                      ),
                                      title: Text(reason.code),
                                      subtitle: Text(reason.message),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    FilledButton(
                                      onPressed: () => controller.requestReview(
                                        selectedDraft,
                                      ),
                                      child: const Text('Request Review'),
                                    ),
                                    OutlinedButton(
                                      onPressed: () => controller
                                          .requestChanges(selectedDraft),
                                      child: const Text('Request Changes'),
                                    ),
                                    FilledButton.tonal(
                                      onPressed: () => controller.approveDraft(
                                        selectedDraft,
                                      ),
                                      child: const Text('Approve'),
                                    ),
                                    FilledButton.tonal(
                                      onPressed: () => controller.scheduleDraft(
                                        selectedDraft,
                                        DateTime.now().add(
                                          const Duration(days: 1),
                                        ),
                                      ),
                                      child: const Text('Schedule'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ObjectActivityPanel(
                                  title: 'Draft timeline',
                                  objectType: ActivityObjectType.draft,
                                  objectId: selectedDraft.id,
                                  emptyState:
                                      'No activity recorded for this draft yet.',
                                ),
                              ],
                            ),
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
}
