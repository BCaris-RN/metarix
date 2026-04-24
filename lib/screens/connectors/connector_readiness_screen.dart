import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/metarix_scope.dart';
import '../../metarix_core/release/connectors/connector_readiness_controller.dart';
import '../../metarix_core/release/connectors/provider_connection_summary.dart';
import '../../metarix_core/release/connectors/provider_status.dart';

class ConnectorReadinessScreen extends StatefulWidget {
  const ConnectorReadinessScreen({super.key});

  @override
  State<ConnectorReadinessScreen> createState() =>
      _ConnectorReadinessScreenState();
}

class _ConnectorReadinessScreenState extends State<ConnectorReadinessScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final services = MetarixScope.of(context);
      services.connectorReadinessController.load();
      services.connectorReadinessController
          .refreshWorkspace(services.gateway.workspace.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final services = MetarixScope.of(context);
    final controller = services.connectorReadinessController;
    final workspaceId = services.gateway.workspace.id;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Connectors',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('No posting yet. This is readiness and setup only.'),
            const SizedBox(height: 16),
            if (controller.errorMessage != null)
              Text(
                controller.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ...controller.providerStatuses.map(
              (status) {
                final summary = controller.connectionSummaries[status.provider];
                return _ProviderCard(
                  status: status,
                  summary: summary,
                  workspaceId: workspaceId,
                  controller: controller,
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.status,
    required this.summary,
    required this.workspaceId,
    required this.controller,
  });

  final ProviderStatus status;
  final ProviderConnectionSummary? summary;
  final String workspaceId;
  final ConnectorReadinessController controller;

  @override
  Widget build(BuildContext context) {
    final safeSummary = summary;
    final connected = summary?.connected == true;
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
                    status.displayName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Chip(
                  label: Text(
                    !status.configured
                        ? 'missing env'
                        : connected
                            ? 'connected'
                            : 'not connected',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Redirect URI: ${status.redirectUriConfigured ? 'configured' : 'missing'}'),
            const SizedBox(height: 8),
            Text('Scopes: ${status.scopes.join(', ')}'),
            const SizedBox(height: 8),
            Text('Docs: ${status.docsHint}'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: !status.configured
                      ? null
                      : () async {
                          final result = await controller.getLoginUrl(
                            status.provider,
                            workspaceId,
                          );
                          if (!context.mounted) return;
                          if (result.success && result.value != null) {
                            await Clipboard.setData(
                              ClipboardData(text: result.value!),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Copied login URL for ${status.displayName}.')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result.userMessage ?? 'Unable to build login URL.')),
                            );
                          }
                        },
                  child: const Text('Login URL'),
                ),
                OutlinedButton(
                  onPressed: connected
                      ? () async {
                          final result = await controller.disconnect(
                            status.provider,
                            workspaceId,
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result.success ? 'Disconnected.' : (result.userMessage ?? 'Unable to disconnect.'))),
                          );
                        }
                      : null,
                  child: const Text('Disconnect'),
                ),
              ],
            ),
            if (safeSummary != null) ...[
              const SizedBox(height: 12),
              Text(
                'Connection summary: ${safeSummary.displayName ?? 'No display name'}',
              ),
              Text('Page count: ${safeSummary.pageCount}'),
            ],
          ],
        ),
      ),
    );
  }
}
