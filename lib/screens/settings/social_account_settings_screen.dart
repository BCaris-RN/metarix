import 'package:flutter/material.dart';

import '../../metarix_core/release/accounts/connected_social_account.dart';
import '../../metarix_core/release/accounts/social_account_controller.dart';
import '../../metarix_core/release/accounts/social_platform.dart';
import '../../metarix_core/release/platforms/platform_capability_service.dart';

class SocialAccountSettingsScreen extends StatefulWidget {
  const SocialAccountSettingsScreen({
    required this.controller,
    super.key,
  });

  final SocialAccountController controller;

  @override
  State<SocialAccountSettingsScreen> createState() =>
      _SocialAccountSettingsScreenState();
}

class _SocialAccountSettingsScreenState extends State<SocialAccountSettingsScreen> {
  final PlatformCapabilityService _capabilities = const PlatformCapabilityService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Social Accounts')),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _StatusCard(
                title: 'Connection status',
                subtitle: widget.controller.isLoading
                    ? 'Loading accounts...'
                    : widget.controller.accounts.isEmpty
                        ? 'No connected accounts yet.'
                        : '${widget.controller.accounts.length} connected account(s).',
                errorText: widget.controller.errorCode == null
                    ? null
                    : '${widget.controller.errorCode}: ${widget.controller.message ?? ''}',
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: SocialPlatform.values.map((platform) {
                  final manifest = _capabilities.manifestFor(platform);
                  final accounts = widget.controller.accounts
                      .where((entry) => entry.platform == platform)
                      .toList(growable: false);
                  return SizedBox(
                    width: 320,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(platform.label, style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 6),
                            Text(manifest.unsupportedReason ?? 'Supported for local release setup.'),
                            Text('Connect: ${manifest.canConnect}'),
                            Text('Upload media: ${manifest.canUploadMedia}'),
                            Text('Publish now: ${manifest.canPublishNow}'),
                            Text('Schedule: ${manifest.canSchedule}'),
                            Text('Images: ${manifest.supportsImages}'),
                            Text('Video: ${manifest.supportsVideo}'),
                            Text('Multi-account: ${manifest.supportsMultiAccount}'),
                            Text('Business account required: ${manifest.requiresBusinessAccount}'),
                            Text(
                              'Required scopes: ${manifest.requiredScopes.isEmpty ? 'none' : manifest.requiredScopes.join(', ')}',
                            ),
                            const Divider(),
                            if (accounts.isEmpty)
                              const Text('No connected accounts.')
                            else
                              ...accounts.map(
                                (account) => _AccountTile(
                                  account: account,
                                  onDisconnect: () => widget.controller.disconnect(account.accountId),
                                  onExpire: () => widget.controller.markExpired(
                                    account.accountId,
                                    'Marked expired from settings.',
                                  ),
                                ),
                              ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () => widget.controller.save(
                                () {
                                  final nowIso = DateTime.now().toUtc().toIso8601String();
                                  return ConnectedSocialAccount(
                                  id: '${platform.name}-demo-${DateTime.now().microsecondsSinceEpoch}',
                                  createdAtIso: nowIso,
                                  updatedAtIso: nowIso,
                                  platform: platform,
                                  accountId: '${platform.name}-acct-demo',
                                  workspaceId: 'workspace-demo',
                                  providerAccountId: '${platform.name}-provider-demo',
                                  displayName: '${platform.label} Demo',
                                  username: '@${platform.name}_demo',
                                  profileImageUrl: null,
                                  scopes: manifest.requiredScopes,
                                  missingScopes: const <String>[],
                                  tokenStatus: TokenStatus.active,
                                  expiresAtIso: DateTime.now().toUtc().add(const Duration(hours: 8)).toIso8601String(),
                                  lastHealthCheckIso: DateTime.now().toUtc().toIso8601String(),
                                  connectionStatus: ConnectionStatus.connected,
                                  metadata: <String, Object?>{
                                    'mode': 'demo',
                                    'supported': true,
                                  },
                                  tokenRef: 'demo-token-ref',
                                  note: 'Demo account created locally.',
                                  );
                                }(),
                              ),
                              child: const Text('Create demo account'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.account,
    required this.onDisconnect,
    required this.onExpire,
  });

  final ConnectedSocialAccount account;
  final VoidCallback onDisconnect;
  final VoidCallback onExpire;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(account.displayName),
            Text(account.username),
            Text('Status: ${account.connectionStatus.name}'),
            Text('Scopes: ${account.scopes.join(', ')}'),
            Text('Missing scopes: ${account.missingScopes.join(', ')}'),
            Text('Expires: ${account.expiresAtIso ?? 'n/a'}'),
            Text('Last health check: ${account.lastHealthCheckIso ?? 'n/a'}'),
            if (account.metadata.isNotEmpty) Text('Metadata: ${account.metadata}'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(onPressed: onExpire, child: const Text('Mark expired')),
                OutlinedButton(onPressed: onDisconnect, child: const Text('Disconnect')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.subtitle,
    this.errorText,
  });

  final String title;
  final String subtitle;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(subtitle),
            if (errorText != null) ...[
              const SizedBox(height: 8),
              Text(errorText!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
      ),
    );
  }
}
