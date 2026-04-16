import 'package:flutter/material.dart';

import '../../../app/metarix_scope.dart';
import '../../admin/domain/admin_models.dart';
import '../governance_center_screen.dart';
import '../job_center_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = MetarixScope.of(context);
    final controller = services.adminController;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final canManageMembers = services.accessControlService.canPerform(
          controller.currentRole,
          RuntimeAction.manageMembers,
        );
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Admin Workspace',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _InfoCard(
                  title: 'Workspace',
                  value: services.gateway.workspace.name,
                ),
                _InfoCard(
                  title: 'Current user',
                  value: controller.currentUser.name,
                ),
                _InfoCard(
                  title: 'Current role',
                  value: controller.currentRole.label,
                ),
                _InfoCard(
                  title: 'Backend mode',
                  value: services.backendConfig.mode.name,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Demo user selector',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    DropdownButton<String>(
                      value: controller.currentUser.id,
                      items: controller.users
                          .map(
                            (user) => DropdownMenuItem(
                              value: user.id,
                              child: Text('${user.name} · ${user.email}'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.switchUser(value);
                        }
                      },
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
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Memberships',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          ...controller.memberships.map(
                            (membership) {
                              final user = controller.users.firstWhere(
                                (entry) => entry.id == membership.userId,
                              );
                              return ListTile(
                                title: Text(user.name),
                                subtitle: Text(user.email),
                                trailing: DropdownButton<UserRole>(
                                  value: membership.role,
                                  items: UserRole.values
                                      .map(
                                        (role) => DropdownMenuItem(
                                          value: role,
                                          child: Text(role.label),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: canManageMembers.allowed
                                      ? (role) {
                                          if (role != null) {
                                            controller.saveMembership(
                                              membership.copyWith(role: role),
                                            );
                                          }
                                        }
                                      : null,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Policy visibility',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Text('Capabilities: ${services.policies.capabilityVersion}'),
                          Text('Permissions: ${services.policies.permissionVersion}'),
                          Text('Approvals: ${services.policies.approvalVersion}'),
                          Text('Publish posture: ${services.policies.publishVersion}'),
                          Text('Evidence: ${services.policies.evidenceVersion}'),
                          const Divider(),
                          Text(
                            'Visible actions',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          ...controller.visibleActions
                              .map((action) => ListTile(title: Text(action.label))),
                          const Divider(),
                          Text(
                            'Blocked actions',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          ...RuntimeAction.values
                              .where((action) => !controller.visibleActions.contains(action))
                              .map(
                                (action) => ListTile(
                                  title: Text(action.label),
                                  subtitle: Text(
                                    services.accessControlService
                                        .canPerform(controller.currentRole, action)
                                        .reason,
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GovernanceCenterScreen(
              policies: services.policies,
              connectorRegistry: services.connectorRegistry,
              publishResults: services.workflowController.drafts
                  .map(
                    (draft) => services.publishPostureEvaluator.evaluate(
                      draft: draft,
                      approvals: services.workflowController.approvals,
                      schedule: services.workflowController.scheduleFor(draft.id),
                    ),
                  )
                  .toList(),
              loadedAtLabel: DateTime.now().toIso8601String(),
            ),
            if (!canManageMembers.allowed) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(canManageMembers.reason),
                ),
              ),
            ],
            const SizedBox(height: 16),
            const JobCenterScreen(),
          ],
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.value,
  });

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
              Text(title),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
      ),
    );
  }
}
