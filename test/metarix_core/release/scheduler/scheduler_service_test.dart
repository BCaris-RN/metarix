import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:metarix/metarix_core/release/release.dart';

Future<_SchedulerFixture> _buildFixture() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final contentRepository = await LocalContentAssetRepository.create();
  final accountRepository = await LocalSocialAccountRepository.create();
  final scheduledRepository = await LocalScheduledPostRepository.create();
  final service = SchedulerService(
    scheduledRepository,
    contentRepository,
    accountRepository,
    const PlatformCapabilityService(),
  );
  final contentService = ContentAssetService(
    contentRepository,
    const PlatformCapabilityService(),
  );
  final nowIso = '2026-04-23T00:00:00.000Z';
  final assetResult = await contentService.createDemoAsset(
    workspaceId: 'workspace-1',
    filename: 'demo-image.jpg',
    mimeType: 'image/jpeg',
    platformTargets: const <String>['instagram'],
  );
  expect(assetResult.success, isTrue);
  final account = ConnectedSocialAccount(
    id: 'account-1',
    createdAtIso: nowIso,
    updatedAtIso: nowIso,
    platform: SocialPlatform.instagram,
    accountId: 'account-1',
    workspaceId: 'workspace-1',
    providerAccountId: 'provider-1',
    displayName: 'Vencer Health',
    username: '@vencerhealth',
    profileImageUrl: null,
    scopes: const ['content_publish'],
    missingScopes: const [],
    tokenStatus: TokenStatus.active,
    expiresAtIso: '2026-05-23T00:00:00.000Z',
    lastHealthCheckIso: nowIso,
    connectionStatus: ConnectionStatus.connected,
    metadata: const <String, Object?>{'demo': true},
    tokenRef: 'ref-1',
  );
  await accountRepository.saveAccount(account);
  return _SchedulerFixture(
    service: service,
    workspaceId: 'workspace-1',
    contentAssetId: assetResult.value!.id,
    account: account,
  );
}

const String _futureIso = '2099-04-24T00:00:00.000Z';
const String _pastIso = '2000-01-01T00:00:00.000Z';

class _SchedulerFixture {
  _SchedulerFixture({
    required this.service,
    required this.workspaceId,
    required this.contentAssetId,
    required this.account,
  });

  final SchedulerService service;
  final String workspaceId;
  final String contentAssetId;
  final ConnectedSocialAccount account;
}

PublishTarget _target({
  required _SchedulerFixture fixture,
}) {
  final nowIso = '2026-04-23T00:00:00.000Z';
  return PublishTarget(
    id: 'target-1',
    createdAtIso: nowIso,
    updatedAtIso: nowIso,
    platform: fixture.account.platform,
    connectedAccountId: fixture.account.accountId,
    targetDisplayName: fixture.account.displayName,
    platformMetadata: const <String, Object?>{'mode': 'demo'},
    accountHandle: fixture.account.username,
    accountId: fixture.account.accountId,
    channelLabel: fixture.account.username,
    isPrimary: true,
    note: 'demo target',
  );
}

void main() {
  test('rejects empty workspaceId', () async {
    final fixture = await _buildFixture();
    final result = await fixture.service.createDraft(
      workspaceId: '',
      contentAssetIds: [fixture.contentAssetId],
      targets: [_target(fixture: fixture)],
      scheduledAtIso: _futureIso,
      timezone: 'UTC',
      createdByUserId: 'user-1',
    );
    expect(result.success, isFalse);
    expect(result.errorCode, 'scheduler.invalid_input');
  });

  test('rejects empty contentAssetIds', () async {
    final fixture = await _buildFixture();
    final result = await fixture.service.createDraft(
      workspaceId: fixture.workspaceId,
      contentAssetIds: const [],
      targets: [_target(fixture: fixture)],
      scheduledAtIso: _futureIso,
      timezone: 'UTC',
      createdByUserId: 'user-1',
    );
    expect(result.success, isFalse);
    expect(result.errorCode, 'scheduler.invalid_input');
  });

  test('rejects empty targets', () async {
    final fixture = await _buildFixture();
    final result = await fixture.service.createDraft(
      workspaceId: fixture.workspaceId,
      contentAssetIds: [fixture.contentAssetId],
      targets: const [],
      scheduledAtIso: _futureIso,
      timezone: 'UTC',
      createdByUserId: 'user-1',
    );
    expect(result.success, isFalse);
    expect(result.errorCode, 'scheduler.invalid_input');
  });

  test('rejects past scheduled time', () async {
    final fixture = await _buildFixture();
    final result = await fixture.service.createDraft(
      workspaceId: fixture.workspaceId,
      contentAssetIds: [fixture.contentAssetId],
      targets: [_target(fixture: fixture)],
      scheduledAtIso: _pastIso,
      timezone: 'UTC',
      createdByUserId: 'user-1',
    );
    expect(result.success, isFalse);
    expect(result.errorCode, 'scheduler.past_time');
  });

  test('creates valid draft', () async {
    final fixture = await _buildFixture();
    final result = await fixture.service.createDraft(
      workspaceId: fixture.workspaceId,
      contentAssetIds: [fixture.contentAssetId],
      targets: [_target(fixture: fixture)],
      scheduledAtIso: _futureIso,
      timezone: 'UTC',
      createdByUserId: 'user-1',
    );
    expect(result.success, isTrue, reason: result.errorCode ?? result.userMessage);
    expect(result.value?.status, PublishStatus.pendingApproval);
  });

  test('approve valid draft', () async {
    final fixture = await _buildFixture();
    final draft = await fixture.service.createDraft(
      workspaceId: fixture.workspaceId,
      contentAssetIds: [fixture.contentAssetId],
      targets: [_target(fixture: fixture)],
      scheduledAtIso: _futureIso,
      timezone: 'UTC',
      createdByUserId: 'user-1',
    );
    final approved = await fixture.service.approveDraft(
      postId: draft.value!.id,
      approvedByUserId: 'user-2',
    );
    expect(approved.success, isTrue);
    expect(approved.value?.status, PublishStatus.approved);
  });

  test('schedule approved post', () async {
    final fixture = await _buildFixture();
    final draft = await fixture.service.createDraft(
      workspaceId: fixture.workspaceId,
      contentAssetIds: [fixture.contentAssetId],
      targets: [_target(fixture: fixture)],
      scheduledAtIso: _futureIso,
      timezone: 'UTC',
      createdByUserId: 'user-1',
    );
    await fixture.service.approveDraft(
      postId: draft.value!.id,
      approvedByUserId: 'user-2',
    );
    final scheduled = await fixture.service.scheduleApprovedPost(draft.value!.id);
    expect(scheduled.success, isTrue);
    expect(scheduled.value?.status, PublishStatus.scheduled);
  });

  test('block schedule before approval', () async {
    final fixture = await _buildFixture();
    final draft = await fixture.service.createDraft(
      workspaceId: fixture.workspaceId,
      contentAssetIds: [fixture.contentAssetId],
      targets: [_target(fixture: fixture)],
      scheduledAtIso: _futureIso,
      timezone: 'UTC',
      createdByUserId: 'user-1',
    );
    final scheduled = await fixture.service.scheduleApprovedPost(draft.value!.id);
    expect(scheduled.success, isFalse);
    expect(scheduled.errorCode, 'scheduler.invalid_transition');
  });

  test('cancel scheduled post', () async {
    final fixture = await _buildFixture();
    final draft = await fixture.service.createDraft(
      workspaceId: fixture.workspaceId,
      contentAssetIds: [fixture.contentAssetId],
      targets: [_target(fixture: fixture)],
      scheduledAtIso: _futureIso,
      timezone: 'UTC',
      createdByUserId: 'user-1',
    );
    await fixture.service.approveDraft(
      postId: draft.value!.id,
      approvedByUserId: 'user-2',
    );
    await fixture.service.scheduleApprovedPost(draft.value!.id);
    final canceled = await fixture.service.cancelScheduledPost(
      draft.value!.id,
      'No longer needed.',
    );
    expect(canceled.success, isTrue);
    expect(canceled.value?.status, PublishStatus.canceled);
  });

  test('search filters by query/status', () async {
    final fixture = await _buildFixture();
    final first = await fixture.service.createDraft(
      workspaceId: fixture.workspaceId,
      contentAssetIds: [fixture.contentAssetId],
      targets: [_target(fixture: fixture)],
      scheduledAtIso: _futureIso,
      timezone: 'UTC',
      createdByUserId: 'user-1',
    );
    await fixture.service.approveDraft(
      postId: first.value!.id,
      approvedByUserId: 'user-2',
    );
    await fixture.service.scheduleApprovedPost(first.value!.id);

    final result = await fixture.service.searchScheduledPosts(
      fixture.workspaceId,
      'scheduled post',
      const ScheduledPostFilters(status: PublishStatus.scheduled),
    );
    expect(result.success, isTrue);
    expect(result.value, isNotEmpty);
  });
}
