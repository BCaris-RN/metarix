import 'package:flutter_test/flutter_test.dart';
import 'package:metarix/metarix_core/release/release.dart';

void main() {
  test('enum parsing falls back defensively', () {
    expect(SocialPlatformX.fromName('unknown'), SocialPlatform.demo);
    expect(ConnectionStatusX.fromName('bad'), ConnectionStatus.disconnected);
    expect(PublishStatusX.fromName('bad'), PublishStatus.draft);
    expect(AssetStatusX.fromName('bad'), AssetStatus.local);
  });

  test('connected account round trips json', () {
    final account = ConnectedSocialAccount(
      id: 'acct-1',
      createdAtIso: '2026-04-23T00:00:00.000Z',
      updatedAtIso: '2026-04-23T00:00:00.000Z',
      platform: SocialPlatform.instagram,
      accountId: 'acct-1',
      workspaceId: 'workspace-1',
      providerAccountId: 'provider-1',
      displayName: 'MetaRix IG',
      username: '@metarix',
      profileImageUrl: null,
      scopes: const ['content_publish'],
      missingScopes: const [],
      tokenStatus: TokenStatus.active,
      expiresAtIso: '2026-05-23T00:00:00.000Z',
      lastHealthCheckIso: '2026-04-23T00:00:00.000Z',
      connectionStatus: ConnectionStatus.connected,
      metadata: const {'demo': true},
      tokenRef: 'ref-1',
      note: 'ready',
    );

    expect(ConnectedSocialAccount.fromJson(account.toJson()).toJson(), account.toJson());
  });

  test('publish job round trips json', () {
    final job = PublishJob(
      id: 'job-1',
      createdAtIso: '2026-04-23T00:00:00.000Z',
      updatedAtIso: '2026-04-23T01:00:00.000Z',
      platform: SocialPlatform.youtube,
      target: PublishTarget(
        id: 'target-1',
        createdAtIso: '2026-04-23T00:00:00.000Z',
        updatedAtIso: '2026-04-23T00:00:00.000Z',
        platform: SocialPlatform.youtube,
        connectedAccountId: 'acct-youtube',
        targetDisplayName: 'Metarix Channel',
        platformMetadata: const <String, Object?>{},
        accountHandle: 'Metarix Channel',
        accountId: 'acct-youtube',
        channelLabel: 'Main',
        isPrimary: true,
        note: null,
      ),
      publishStatus: PublishStatus.scheduled,
      contentAssetId: 'asset-1',
      scheduledAtIso: '2026-04-23T02:00:00.000Z',
      attempts: const [],
      remotePostId: 'yt-1',
      lastErrorCode: null,
      lastErrorMessage: null,
      retryable: false,
    );

    expect(PublishJob.fromJson(job.toJson()).toJson(), job.toJson());
  });

  test('scheduled post round trips json', () {
    final post = ScheduledPost(
      id: 'post-1',
      createdAtIso: '2026-04-23T00:00:00.000Z',
      updatedAtIso: '2026-04-23T00:00:00.000Z',
      workspaceId: 'workspace-1',
      contentAssetIds: const ['asset-1'],
      targets: [
        PublishTarget(
          id: 'target-1',
          createdAtIso: '2026-04-23T00:00:00.000Z',
          updatedAtIso: '2026-04-23T00:00:00.000Z',
          platform: SocialPlatform.instagram,
          connectedAccountId: 'acct-1',
          targetDisplayName: 'Vencer Health',
          platformMetadata: const <String, Object?>{},
          accountHandle: '@vencerhealth',
          accountId: 'acct-1',
          channelLabel: 'Instagram',
          isPrimary: true,
          note: null,
        ),
      ],
      scheduledAtIso: '2026-04-23T02:00:00.000Z',
      timezone: 'UTC',
      status: PublishStatus.pendingApproval,
      validationErrors: const ['none'],
      approvalStatus: 'pendingApproval',
      createdByUserId: 'user-1',
      approvedByUserId: null,
      publishedJobIds: const ['job-1'],
      title: 'Demo scheduled post',
      caption: 'Demo caption',
      platform: SocialPlatform.instagram,
      target: PublishTarget(
        id: 'target-1',
        createdAtIso: '2026-04-23T00:00:00.000Z',
        updatedAtIso: '2026-04-23T00:00:00.000Z',
        platform: SocialPlatform.instagram,
        connectedAccountId: 'acct-1',
        targetDisplayName: 'Vencer Health',
        platformMetadata: const <String, Object?>{},
        accountHandle: '@vencerhealth',
        accountId: 'acct-1',
        channelLabel: 'Instagram',
        isPrimary: true,
        note: null,
      ),
      publishStatus: PublishStatus.pendingApproval,
      contentAssetId: 'asset-1',
      approvalState: 'pendingApproval',
      validationMessage: null,
      asset: null,
    );

    expect(ScheduledPost.fromJson(post.toJson()).toJson(), post.toJson());
  });
}
