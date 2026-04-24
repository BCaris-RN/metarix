import 'package:flutter_test/flutter_test.dart';
import 'package:metarix/metarix_core/release/release.dart';

void main() {
  test('connected social account round trips registry fields', () {
    final account = ConnectedSocialAccount(
      id: 'acct-1',
      createdAtIso: '2026-04-23T00:00:00.000Z',
      updatedAtIso: '2026-04-23T00:00:00.000Z',
      platform: SocialPlatform.instagram,
      accountId: 'acct-1',
      workspaceId: 'workspace-1',
      providerAccountId: 'provider-1',
      displayName: 'Instagram Demo',
      username: '@demo',
      profileImageUrl: null,
      scopes: const ['instagram_business_content_publish'],
      missingScopes: const ['pages_manage_posts'],
      tokenStatus: TokenStatus.active,
      expiresAtIso: '2026-05-01T00:00:00.000Z',
      lastHealthCheckIso: '2026-04-23T01:00:00.000Z',
      connectionStatus: ConnectionStatus.connected,
      metadata: const {'mode': 'demo'},
      tokenRef: 'ref-1',
      note: 'demo',
    );

    expect(ConnectedSocialAccount.fromJson(account.toJson()).toJson(), account.toJson());
  });

  test('platform capability manifest exposes demo and gated states', () {
    const service = PlatformCapabilityService();
    final instagram = service.manifestFor(SocialPlatform.instagram);
    final demo = service.manifestFor(SocialPlatform.demo);

    expect(instagram.canPublishNow, isFalse);
    expect(instagram.requiresBusinessAccount, isTrue);
    expect(demo.canPublishNow, isTrue);
    expect(demo.unsupportedReason, isNull);
  });
}
