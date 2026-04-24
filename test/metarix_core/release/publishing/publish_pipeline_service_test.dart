import 'package:flutter_test/flutter_test.dart';
import 'package:metarix/metarix_core/release/release.dart';
import 'package:metarix/metarix_core/release/publishing/adapters/demo_social_publisher.dart';

class _MemoryPublishJobRepository implements PublishJobRepository {
  final Map<String, PublishJob> _jobs = <String, PublishJob>{};
  final List<PublishAuditEvent> _events = <PublishAuditEvent>[];

  @override
  Future<ReleaseResult<PublishAuditEvent>> appendAuditEvent(
    PublishAuditEvent event,
  ) async {
    _events.add(event);
    return ReleaseResult<PublishAuditEvent>.success(event);
  }

  @override
  Future<ReleaseResult<void>> deleteJob(String jobId) async {
    _jobs.remove(jobId);
    return ReleaseResult<void>.success(null);
  }

  @override
  Future<ReleaseResult<PublishJob?>> getJob(String jobId) async {
    return ReleaseResult<PublishJob?>.success(_jobs[jobId]);
  }

  @override
  Future<ReleaseResult<List<PublishAuditEvent>>> listAuditEvents(String jobId) async {
    return ReleaseResult<List<PublishAuditEvent>>.success(
      _events.where((event) => event.jobId == jobId).toList(growable: false),
    );
  }

  @override
  Future<ReleaseResult<List<PublishJob>>> listDueJobs(
    String workspaceId,
    String nowIso,
  ) async {
    final now = DateTime.parse(nowIso);
    return ReleaseResult<List<PublishJob>>.success(
      _jobs.values
          .where(
            (job) =>
                job.workspaceId == workspaceId &&
                job.publishStatus == PublishStatus.scheduled &&
                DateTime.parse(job.scheduledAtIso).isBefore(now),
          )
          .toList(growable: false),
    );
  }

  @override
  Future<ReleaseResult<List<PublishJob>>> listJobs(String workspaceId) async {
    return ReleaseResult<List<PublishJob>>.success(
      _jobs.values.where((job) => job.workspaceId == workspaceId).toList(growable: false),
    );
  }

  @override
  Future<ReleaseResult<List<PublishJob>>> listJobsByStatus(
    String workspaceId,
    PublishStatus status,
  ) async {
    return ReleaseResult<List<PublishJob>>.success(
      _jobs.values
          .where((job) => job.workspaceId == workspaceId && job.publishStatus == status)
          .toList(growable: false),
    );
  }

  @override
  Future<ReleaseResult<PublishJob>> saveJob(PublishJob job) async {
    _jobs[job.id] = job;
    return ReleaseResult<PublishJob>.success(job);
  }
}

class _MemoryContentAssetRepository implements ContentAssetRepository {
  _MemoryContentAssetRepository(this.asset);

  final ContentAsset asset;

  @override
  Future<ReleaseResult<void>> deleteAsset(String assetId) async =>
      ReleaseResult<void>.success(null);

  @override
  Future<ReleaseResult<ContentAsset?>> getAsset(String assetId) async {
    return ReleaseResult<ContentAsset?>.success(
      asset.id == assetId ? asset : null,
    );
  }

  @override
  Future<ReleaseResult<List<ContentAsset>>> listAssets(String workspaceId) async {
    return ReleaseResult<List<ContentAsset>>.success([asset]);
  }

  @override
  Future<ReleaseResult<ContentAsset>> markUploadStatus(
    String assetId,
    AssetStatus status,
    String? reason,
  ) async =>
      ReleaseResult<ContentAsset>.success(asset);

  @override
  Future<ReleaseResult<ContentAsset>> saveAsset(ContentAsset asset) async =>
      ReleaseResult<ContentAsset>.success(asset);

  @override
  Future<ReleaseResult<List<ContentAsset>>> searchAssets(
    String workspaceId,
    String query,
    ContentAssetFilters filters,
  ) async =>
      ReleaseResult<List<ContentAsset>>.success(query.isEmpty ? [asset] : [asset]);

  @override
  Future<ReleaseResult<ContentAsset>> updateMetadata(
    String assetId,
    ContentMetadata metadata,
  ) async =>
      ReleaseResult<ContentAsset>.success(asset.copyWith(metadata: metadata));
}

class _MemorySocialAccountRepository implements SocialAccountRepository {
  _MemorySocialAccountRepository(this.account);

  final ConnectedSocialAccount account;

  @override
  Future<ReleaseResult<void>> disconnectAccount(String accountId) async =>
      ReleaseResult<void>.success(null);

  @override
  Future<ReleaseResult<ConnectedSocialAccount?>> getAccount(String accountId) async {
    return ReleaseResult<ConnectedSocialAccount?>.success(
      account.accountId == accountId ? account : null,
    );
  }

  @override
  Future<ReleaseResult<ConnectedSocialAccount>> markAccountExpired(
    String accountId,
    String reason,
  ) async =>
      ReleaseResult<ConnectedSocialAccount>.success(account);

  @override
  Future<ReleaseResult<List<ConnectedSocialAccount>>> listConnectedAccounts(
    String workspaceId,
  ) async =>
      ReleaseResult<List<ConnectedSocialAccount>>.success([account]);

  @override
  Future<ReleaseResult<ConnectedSocialAccount>> saveAccount(
    ConnectedSocialAccount account,
  ) async =>
      ReleaseResult<ConnectedSocialAccount>.success(account);

  @override
  Future<ReleaseResult<ConnectedSocialAccount>> updateHealth(
    String accountId,
    PlatformHealth health,
  ) async =>
      ReleaseResult<ConnectedSocialAccount>.success(account);
}

void main() {
  late _MemoryPublishJobRepository jobs;
  late PublishPipelineService service;
  late ScheduledPost demoPost;
  late ScheduledPost nonDemoPost;

  setUp(() {
    jobs = _MemoryPublishJobRepository();
    final asset = ContentAsset(
      id: 'asset-1',
      workspaceId: 'workspace-1',
      createdAtIso: '2026-04-23T00:00:00.000Z',
      updatedAtIso: '2026-04-23T00:00:00.000Z',
      localPathOrUri: 'demo://asset-1',
      filename: 'image.png',
      mimeType: 'image/png',
      fileSizeBytes: 123,
      status: AssetStatus.local,
      metadata: const ContentMetadata(
        id: 'meta-1',
        createdAtIso: '2026-04-23T00:00:00.000Z',
        updatedAtIso: '2026-04-23T00:00:00.000Z',
        title: 'Title',
        caption: 'Caption',
        description: '',
        tags: <String>[],
        hashtags: <String>[],
        altText: null,
        intendedChannel: null,
        notes: null,
      ),
    );
    final account = ConnectedSocialAccount(
      id: 'acct-demo',
      createdAtIso: '2026-04-23T00:00:00.000Z',
      updatedAtIso: '2026-04-23T00:00:00.000Z',
      platform: SocialPlatform.demo,
      accountId: 'acct-demo',
      workspaceId: 'workspace-1',
      providerAccountId: 'provider-demo',
      displayName: 'Demo',
      username: 'demo',
      profileImageUrl: null,
      scopes: const [],
      missingScopes: const [],
      tokenStatus: TokenStatus.active,
      expiresAtIso: null,
      lastHealthCheckIso: null,
      connectionStatus: ConnectionStatus.connected,
      metadata: const <String, Object?>{},
      tokenRef: 'ref-demo',
    );
    service = PublishPipelineService(
      jobs,
      _NoopScheduledPostRepository(),
      _MemoryContentAssetRepository(asset),
      _MemorySocialAccountRepository(account),
      const <SocialPlatform, SocialPublisher>{
        SocialPlatform.demo: const DemoSocialPublisher(),
      },
    );
    demoPost = ScheduledPost(
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
          platform: SocialPlatform.demo,
          connectedAccountId: 'acct-demo',
          targetDisplayName: 'Demo',
          platformMetadata: const <String, Object?>{},
        ),
      ],
      scheduledAtIso: '2026-04-23T10:00:00.000Z',
      timezone: 'UTC',
      status: PublishStatus.scheduled,
      validationErrors: const [],
      approvalStatus: 'approved',
      createdByUserId: 'user-1',
      approvedByUserId: 'user-2',
      publishedJobIds: const [],
    );
    nonDemoPost = demoPost.copyWith(
      id: 'post-2',
      targets: [
        PublishTarget(
          id: 'target-2',
          createdAtIso: '2026-04-23T00:00:00.000Z',
          updatedAtIso: '2026-04-23T00:00:00.000Z',
          platform: SocialPlatform.instagram,
          connectedAccountId: 'acct-demo',
          targetDisplayName: 'IG',
          platformMetadata: const <String, Object?>{},
        ),
      ],
    );
  });

  test('creates job from scheduled post', () async {
    final result = await service.createJobFromScheduledPost(demoPost);
    expect(result.success, isTrue);
    expect(result.value?.scheduledPostId, 'post-1');
    expect(result.value?.publishStatus, PublishStatus.scheduled);
  });

  test('blocks invalid transition', () async {
    final created = await service.createJobFromScheduledPost(demoPost);
    final failed = await service.startPublishing(created.value!.id);
    expect(failed.success, isFalse);
  });

  test('queues scheduled job', () async {
    final created = await service.createJobFromScheduledPost(demoPost);
    final queued = await service.queueScheduledJob(created.value!.id);
    expect(queued.success, isTrue);
    expect(queued.value?.publishStatus, PublishStatus.queued);
  });

  test('starts publishing queued job', () async {
    final created = await service.createJobFromScheduledPost(demoPost);
    await service.queueScheduledJob(created.value!.id);
    final started = await service.startPublishing(created.value!.id);
    expect(started.success, isTrue);
    expect(started.value?.publishStatus, PublishStatus.publishing);
  });

  test('completes publishing job', () async {
    final created = await service.createJobFromScheduledPost(demoPost);
    await service.queueScheduledJob(created.value!.id);
    await service.startPublishing(created.value!.id);
    final completed = await service.completePublishing(
      created.value!.id,
      'external-1',
    );
    expect(completed.success, isTrue);
    expect(completed.value?.publishStatus, PublishStatus.published);
  });

  test('fails publishing job', () async {
    final created = await service.createJobFromScheduledPost(demoPost);
    await service.queueScheduledJob(created.value!.id);
    final failed = await service.failPublishing(
      created.value!.id,
      'publish.live_disabled',
      'Disabled',
      false,
    );
    expect(failed.success, isTrue);
    expect(failed.value?.publishStatus, PublishStatus.failed);
  });

  test('cancels scheduled job', () async {
    final created = await service.createJobFromScheduledPost(demoPost);
    final canceled = await service.cancelJob(created.value!.id, 'Canceled');
    expect(canceled.success, isTrue);
    expect(canceled.value?.publishStatus, PublishStatus.canceled);
  });

  test('returns live-disabled for non-demo platform', () async {
    final created = await service.createJobFromScheduledPost(nonDemoPost);
    final result = await service.runLocalDueJobs('workspace-1', '2026-04-23T11:00:00.000Z');
    expect(result.success, isTrue);
    final job = await jobs.getJob(created.value!.id);
    expect(job.value?.publishStatus, PublishStatus.validationFailed);
    expect(job.value?.lastErrorCode, 'publish.live_disabled');
  });

  test('appends audit events', () async {
    final created = await service.createJobFromScheduledPost(demoPost);
    final audit = await jobs.listAuditEvents(created.value!.id);
    expect(audit.value, isNotEmpty);
  });

  test('runLocalDueJobs uses demo publisher only', () async {
    await service.createJobFromScheduledPost(demoPost);
    final result = await service.runLocalDueJobs(
      'workspace-1',
      '2026-04-23T11:00:00.000Z',
    );
    expect(result.success, isTrue);
    final job = await jobs.getJob('publish-post-1');
    expect(job.value?.publishStatus, PublishStatus.published);
  });
}

class _NoopScheduledPostRepository implements ScheduledPostRepository {
  @override
  Future<ReleaseResult<void>> deleteScheduledPost(String postId) async =>
      ReleaseResult<void>.success(null);

  @override
  Future<ReleaseResult<ScheduledPost?>> getScheduledPost(String postId) async =>
      ReleaseResult<ScheduledPost?>.success(null);

  @override
  Future<ReleaseResult<List<ScheduledPost>>> listScheduledPosts(
    String workspaceId,
  ) async =>
      ReleaseResult<List<ScheduledPost>>.success(<ScheduledPost>[]);

  @override
  Future<ReleaseResult<ScheduledPost>> saveScheduledPost(
    ScheduledPost post,
  ) async =>
      ReleaseResult<ScheduledPost>.success(post);

  @override
  Future<ReleaseResult<List<ScheduledPost>>> searchScheduledPosts(
    String workspaceId,
    String query,
    ScheduledPostFilters filters,
  ) async =>
      ReleaseResult<List<ScheduledPost>>.success(<ScheduledPost>[]);
}
