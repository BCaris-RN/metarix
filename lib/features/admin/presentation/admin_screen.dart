import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/metarix_scope.dart';
import '../../../core/app_services.dart';
import '../../../metarix_core/models/connected_social_account.dart';
import '../../../metarix_core/models/connector_runtime_state.dart';
import '../../../services/linkedin/linkedin_auth_session.dart';
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
        final linkedInAccount = services.gateway.connectedAccountFor(
          'linkedin',
        );
        final linkedInRuntimeState =
            services.gateway.connectorRuntimeStateFor('linkedin') ??
            services.backendConfig.linkedInRuntimeState(
              connected:
                  linkedInAccount?.status == SocialConnectionStatus.connected,
            );
        final pendingLinkedInSession =
            services.gateway.pendingLinkedInAuthSession;
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
            _ConnectorStatusPanel(
              runtimeState: linkedInRuntimeState,
              connectedAccount: linkedInAccount,
              pendingAuthSession: pendingLinkedInSession,
              onStartConnect: services.backendConfig.isLinkedInConfigured
                  ? () async {
                      try {
                        final session = services.linkedInAuthService
                            .startAuthSession(services.backendConfig);
                        await services.gateway.savePendingLinkedInAuthSession(
                          session,
                        );
                      } on Object catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.toString())),
                          );
                        }
                      }
                    }
                  : null,
            ),
            const SizedBox(height: 16),
            LinkedInCallbackPastePanel(
              services: services,
              isConfigured: services.backendConfig.isLinkedInConfigured,
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
                          ...controller.memberships.map((membership) {
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
                          }),
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
                          Text(
                            'Capabilities: ${services.policies.capabilityVersion}',
                          ),
                          Text(
                            'Permissions: ${services.policies.permissionVersion}',
                          ),
                          Text(
                            'Approvals: ${services.policies.approvalVersion}',
                          ),
                          Text(
                            'Publish posture: ${services.policies.publishVersion}',
                          ),
                          Text(
                            'Evidence: ${services.policies.evidenceVersion}',
                          ),
                          const Divider(),
                          Text(
                            'Visible actions',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          ...controller.visibleActions.map(
                            (action) => ListTile(title: Text(action.label)),
                          ),
                          const Divider(),
                          Text(
                            'Blocked actions',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          ...RuntimeAction.values
                              .where(
                                (action) =>
                                    !controller.visibleActions.contains(action),
                              )
                              .map(
                                (action) => ListTile(
                                  title: Text(action.label),
                                  subtitle: Text(
                                    services.accessControlService
                                        .canPerform(
                                          controller.currentRole,
                                          action,
                                        )
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
                      schedule: services.workflowController.scheduleFor(
                        draft.id,
                      ),
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

class _ConnectorStatusPanel extends StatelessWidget {
  const _ConnectorStatusPanel({
    required this.runtimeState,
    required this.connectedAccount,
    required this.pendingAuthSession,
    required this.onStartConnect,
  });

  final ConnectorRuntimeState runtimeState;
  final ConnectedSocialAccount? connectedAccount;
  final LinkedInAuthSession? pendingAuthSession;
  final Future<void> Function()? onStartConnect;

  @override
  Widget build(BuildContext context) {
    final hasPendingAuth =
        runtimeState.availability != ConnectorAvailabilityState.notConfigured &&
        pendingAuthSession?.status ==
            LinkedInAuthSessionStatus.awaitingCallback;
    final label = _statusLabel(
      runtimeState,
      connectedAccount,
      hasPendingAuth ? pendingAuthSession : null,
    );
    final details = <String>[
      if (runtimeState.availability ==
              ConnectorAvailabilityState.notConfigured &&
          !runtimeState.clientIdPresent)
        'Client ID missing',
      if (runtimeState.availability ==
              ConnectorAvailabilityState.notConfigured &&
          !runtimeState.redirectUriPresent)
        'Redirect URI missing',
      if (runtimeState.availability == ConnectorAvailabilityState.configured)
        'Configured but not connected',
      if (hasPendingAuth) 'Awaiting callback',
      if (hasPendingAuth &&
          (pendingAuthSession?.authorizationUrl.trim().isNotEmpty ?? false))
        pendingAuthSession!.authorizationUrl,
        if (runtimeState.availability == ConnectorAvailabilityState.connected &&
            connectedAccount != null)
          connectedAccount!.displayName,
        if (runtimeState.availability == ConnectorAvailabilityState.connected &&
            (connectedAccount?.authorUrn?.isNotEmpty ?? false))
          connectedAccount!.authorUrn!,
        if (runtimeState.availability == ConnectorAvailabilityState.connected &&
            (connectedAccount?.profileImageUrl?.isNotEmpty ?? false))
          connectedAccount!.profileImageUrl!,
        if (runtimeState.availability == ConnectorAvailabilityState.connected &&
            (connectedAccount?.scope?.isNotEmpty ?? false))
          'Scope: ${connectedAccount!.scope!}',
      if (runtimeState.note != null && runtimeState.note!.trim().isNotEmpty)
        runtimeState.note!,
      if (connectedAccount?.note != null &&
          connectedAccount!.note!.trim().isNotEmpty)
        connectedAccount!.note!,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connector status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LinkedIn',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      for (final detail in details)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(detail),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Chip(label: Text(label)),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: onStartConnect,
                      child: const Text('Start LinkedIn Connect'),
                    ),
                    if (hasPendingAuth &&
                        (pendingAuthSession?.authorizationUrl
                                .trim()
                                .isNotEmpty ??
                            false)) ...[
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(
                              text: pendingAuthSession!.authorizationUrl,
                            ),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('LinkedIn auth URL copied.'),
                              ),
                            );
                          }
                        },
                        child: const Text('Copy auth URL'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(
    ConnectorRuntimeState runtimeState,
    ConnectedSocialAccount? connectedAccount,
    LinkedInAuthSession? pendingAuthSession,
  ) {
    if (pendingAuthSession?.status ==
        LinkedInAuthSessionStatus.awaitingCallback) {
      return 'Awaiting callback';
    }
    if (runtimeState.availability == ConnectorAvailabilityState.notConfigured) {
      return 'Not configured';
    }
    if (runtimeState.availability == ConnectorAvailabilityState.unavailable) {
      return 'Unavailable';
    }
    if (runtimeState.availability == ConnectorAvailabilityState.connected ||
        connectedAccount?.status == SocialConnectionStatus.connected) {
      return 'Connected';
    }
    return 'Configured';
  }
}

class LinkedInCallbackPastePanel extends StatefulWidget {
  const LinkedInCallbackPastePanel({
    required this.services,
    required this.isConfigured,
    super.key,
  });

  final AppServices services;
  final bool isConfigured;

  @override
  State<LinkedInCallbackPastePanel> createState() =>
      _LinkedInCallbackPastePanelState();
}

class _LinkedInCallbackPastePanelState
    extends State<LinkedInCallbackPastePanel> {
  final TextEditingController _callbackController = TextEditingController();
  String? _statusMessage;

  @override
  void dispose() {
    _callbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paste LinkedIn Callback',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _callbackController,
              enabled: widget.isConfigured,
              decoration: const InputDecoration(
                labelText: 'Callback URL',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: widget.isConfigured
                  ? () async {
                      try {
                        await widget.services.linkedInConnectionService
                            .completeFromCallbackUrl(
                              config: widget.services.backendConfig,
                              callbackUrl: _callbackController.text,
                            );
                        if (!mounted) {
                          return;
                        }
                        setState(() {
                          _statusMessage =
                              'LinkedIn connection completed. Awaiting callback cleared.';
                        });
                      } on Object catch (error) {
                        if (!mounted) {
                          return;
                        }
                        setState(() {
                          _statusMessage = error.toString();
                        });
                      }
                    }
                  : null,
              child: const Text('Complete LinkedIn Connect'),
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 12),
              Text(_statusMessage!),
            ],
            if (widget.services.gateway.connectedAccountFor('linkedin')
                    ?.status ==
                SocialConnectionStatus.connected) ...[
              const SizedBox(height: 12),
              Text(
                widget.services.gateway.connectedAccountFor('linkedin')?.note ??
                    '',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.value});

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
