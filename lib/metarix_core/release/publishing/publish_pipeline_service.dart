import '../accounts/social_account_repository.dart';
import '../accounts/social_platform.dart';
import '../common/release_result.dart';
import '../content/content_asset.dart';
import '../content/content_asset_repository.dart';
import '../scheduler/scheduled_post.dart';
import '../scheduler/scheduled_post_repository.dart';
import '../scheduler/publish_target.dart';
import 'publish_audit_event.dart';
import 'publish_attempt.dart';
import 'publish_job.dart';
import 'publish_job_repository.dart';
import 'publish_request.dart';
import 'publish_status.dart';
import 'social_publisher.dart';

class PublishPipelineService {
  PublishPipelineService(
    this._jobRepository,
    this._scheduledPostRepository,
    this._contentAssetRepository,
    this._socialAccountRepository,
    this._publisherRegistry,
  );

  final PublishJobRepository _jobRepository;
  final ScheduledPostRepository _scheduledPostRepository;
  final ContentAssetRepository _contentAssetRepository;
  final SocialAccountRepository _socialAccountRepository;
  final Map<SocialPlatform, SocialPublisher> _publisherRegistry;

  PublishJobRepository get jobRepository => _jobRepository;

  Future<ReleaseResult<List<PublishJob>>> listJobs(String workspaceId) {
    return _jobRepository.listJobs(workspaceId);
  }

  Future<ReleaseResult<List<PublishAuditEvent>>> listAuditEvents(String jobId) {
    return _jobRepository.listAuditEvents(jobId);
  }

  Future<ReleaseResult<PublishJob?>> getJob(String jobId) {
    return _jobRepository.getJob(jobId);
  }

  Future<ReleaseResult<PublishJob>> createJobFromScheduledPost(
    ScheduledPost post,
  ) async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    if (post.targets.isEmpty || post.contentAssetIds.isEmpty) {
      return ReleaseResult<PublishJob>.failure(
        errorCode: 'publish.validation_failed',
        userMessage: 'Scheduled post is missing targets or content.',
      );
    }
    final job = PublishJob(
      id: 'publish-${post.id}',
      createdAtIso: nowIso,
      updatedAtIso: nowIso,
      workspaceId: post.workspaceId,
      scheduledPostId: post.id,
      platform: post.targets.first.platform,
      target: post.targets.first,
      publishStatus: PublishStatus.scheduled,
      contentAssetId: post.contentAssetIds.first,
      scheduledAtIso: post.scheduledAtIso,
      attempts: const <PublishAttempt>[],
      remotePostId: null,
      lastErrorCode: null,
      lastErrorMessage: null,
      retryable: false,
    );
    await _jobRepository.saveJob(job);
    await _jobRepository.appendAuditEvent(
      PublishAuditEvent(
        id: 'audit-${job.id}',
        createdAtIso: nowIso,
        updatedAtIso: nowIso,
        jobId: job.id,
        type: PublishAuditEventType.jobCreated,
        message: 'Publish job created from scheduled post ${post.id}.',
        metadata: <String, Object?>{
          'scheduledPostId': post.id,
          'platform': job.platform.name,
        },
      ),
    );
    return ReleaseResult<PublishJob>.success(job);
  }

  Future<ReleaseResult<PublishJob>> validateJob(PublishJob job) async {
    final validation = _validateLocalJob(job);
    final updated = validation.success
        ? job.copyWith(
            updatedAtIso: DateTime.now().toUtc().toIso8601String(),
            publishStatus: PublishStatus.scheduled,
          )
        : job.copyWith(
            updatedAtIso: DateTime.now().toUtc().toIso8601String(),
            publishStatus: PublishStatus.validationFailed,
            lastErrorCode: validation.errorCode,
            lastErrorMessage: validation.userMessage,
            retryable: validation.retryable,
          );
    await _jobRepository.saveJob(updated);
    await _jobRepository.appendAuditEvent(
      PublishAuditEvent(
        id: 'audit-validate-${job.id}',
        createdAtIso: DateTime.now().toUtc().toIso8601String(),
        updatedAtIso: DateTime.now().toUtc().toIso8601String(),
        jobId: job.id,
        type: PublishAuditEventType.jobValidated,
        message: validation.success ? 'Publish job validated.' : 'Publish job validation failed.',
        metadata: <String, Object?>{
          'success': validation.success,
          'errorCode': validation.errorCode,
        },
      ),
    );
    return validation.success
        ? ReleaseResult<PublishJob>.success(updated)
        : ReleaseResult<PublishJob>.failure(
            errorCode: validation.errorCode,
            userMessage: validation.userMessage,
            technicalMessage: validation.technicalMessage,
            retryable: validation.retryable,
          );
  }

  Future<ReleaseResult<PublishJob>> queueScheduledJob(String jobId) async {
    final found = await _jobRepository.getJob(jobId);
    if (!found.success || found.value == null) {
      return ReleaseResult<PublishJob>.failure(
        errorCode: 'publish.not_found',
        userMessage: 'Publish job not found.',
      );
    }
    final job = found.value!;
    if (job.publishStatus != PublishStatus.scheduled) {
      return ReleaseResult<PublishJob>.failure(
        errorCode: 'publish.invalid_transition',
        userMessage: 'Only scheduled jobs can be queued.',
      );
    }
    final queued = job.copyWith(
      updatedAtIso: DateTime.now().toUtc().toIso8601String(),
      publishStatus: PublishStatus.queued,
    );
    await _jobRepository.saveJob(queued);
    await _appendEvent(job.id, PublishAuditEventType.jobQueued, 'Publish job queued.');
    return ReleaseResult<PublishJob>.success(queued);
  }

  Future<ReleaseResult<PublishJob>> startPublishing(String jobId) async {
    final found = await _jobRepository.getJob(jobId);
    if (!found.success || found.value == null) {
      return ReleaseResult<PublishJob>.failure(
        errorCode: 'publish.not_found',
        userMessage: 'Publish job not found.',
      );
    }
    final job = found.value!;
    if (job.publishStatus != PublishStatus.queued) {
      return ReleaseResult<PublishJob>.failure(
        errorCode: 'publish.invalid_transition',
        userMessage: 'Only queued jobs can start publishing.',
      );
    }
    final publishing = job.copyWith(
      updatedAtIso: DateTime.now().toUtc().toIso8601String(),
      publishStatus: PublishStatus.publishing,
    );
    await _jobRepository.saveJob(publishing);
    await _appendEvent(job.id, PublishAuditEventType.publishStarted, 'Publish started.');
    return ReleaseResult<PublishJob>.success(publishing);
  }

  Future<ReleaseResult<PublishJob>> completePublishing(
    String jobId,
    String externalPostId,
  ) async {
    final found = await _jobRepository.getJob(jobId);
    if (!found.success || found.value == null) {
      return ReleaseResult<PublishJob>.failure(
        errorCode: 'publish.not_found',
        userMessage: 'Publish job not found.',
      );
    }
    final job = found.value!;
    if (job.publishStatus != PublishStatus.publishing) {
      return ReleaseResult<PublishJob>.failure(
        errorCode: 'publish.invalid_transition',
        userMessage: 'Only publishing jobs can complete.',
      );
    }
    final updated = job.copyWith(
      updatedAtIso: DateTime.now().toUtc().toIso8601String(),
      publishStatus: PublishStatus.published,
      remotePostId: externalPostId,
      clearLastErrorCode: true,
      clearLastErrorMessage: true,
      retryable: false,
    );
    await _jobRepository.saveJob(updated);
    await _appendEvent(
      job.id,
      PublishAuditEventType.publishSucceeded,
      'Publish completed successfully.',
      <String, Object?>{'externalPostId': externalPostId},
    );
    return ReleaseResult<PublishJob>.success(updated);
  }

  Future<ReleaseResult<PublishJob>> failPublishing(
    String jobId,
    String errorCode,
    String message,
    bool retryable,
  ) async {
    final found = await _jobRepository.getJob(jobId);
    if (!found.success || found.value == null) {
      return ReleaseResult<PublishJob>.failure(
        errorCode: 'publish.not_found',
        userMessage: 'Publish job not found.',
      );
    }
    final job = found.value!;
    final failed = job.copyWith(
      updatedAtIso: DateTime.now().toUtc().toIso8601String(),
      publishStatus: PublishStatus.failed,
      lastErrorCode: errorCode,
      lastErrorMessage: message,
      retryable: retryable,
    );
    await _jobRepository.saveJob(failed);
    await _appendEvent(
      job.id,
      PublishAuditEventType.publishFailed,
      message,
      <String, Object?>{'errorCode': errorCode, 'retryable': retryable},
    );
    return ReleaseResult<PublishJob>.success(failed);
  }

  Future<ReleaseResult<PublishJob>> cancelJob(
    String jobId,
    String reason,
  ) async {
    final found = await _jobRepository.getJob(jobId);
    if (!found.success || found.value == null) {
      return ReleaseResult<PublishJob>.failure(
        errorCode: 'publish.not_found',
        userMessage: 'Publish job not found.',
      );
    }
    final job = found.value!;
    if (job.publishStatus != PublishStatus.scheduled &&
        job.publishStatus != PublishStatus.queued) {
      return ReleaseResult<PublishJob>.failure(
        errorCode: 'publish.invalid_transition',
        userMessage: 'Only scheduled or queued jobs can be canceled.',
      );
    }
    final canceled = job.copyWith(
      updatedAtIso: DateTime.now().toUtc().toIso8601String(),
      publishStatus: PublishStatus.canceled,
      lastErrorMessage: reason,
      retryable: false,
    );
    await _jobRepository.saveJob(canceled);
    await _appendEvent(
      job.id,
      PublishAuditEventType.publishCanceled,
      reason,
    );
    return ReleaseResult<PublishJob>.success(canceled);
  }

  Future<ReleaseResult<List<PublishJob>>> runLocalDueJobs(
    String workspaceId,
    String nowIso,
  ) async {
    final due = await _jobRepository.listDueJobs(workspaceId, nowIso);
    if (!due.success) {
      return ReleaseResult<List<PublishJob>>.failure(
        errorCode: due.errorCode,
        userMessage: due.userMessage,
        technicalMessage: due.technicalMessage,
        retryable: due.retryable,
      );
    }
    final processed = <PublishJob>[];
    for (final job in due.value!) {
      final validation = await validateJob(job);
      if (!validation.success) {
        continue;
      }
      if (job.platform != SocialPlatform.demo) {
        await _appendEvent(
          job.id,
          PublishAuditEventType.unsupportedPlatform,
          'Live publishing is disabled for ${job.platform.name}.',
          <String, Object?>{'platform': job.platform.name},
        );
        await failPublishing(
          job.id,
          'publish.live_disabled',
          'Live publishing is disabled for ${job.platform.name}.',
          false,
        );
        continue;
      }
      final publisher = _publisherRegistry[job.platform];
      if (publisher == null) {
        await _appendEvent(
          job.id,
          PublishAuditEventType.missingAdapter,
          'No publisher registered for ${job.platform.name}.',
          <String, Object?>{'platform': job.platform.name},
        );
        await failPublishing(
          job.id,
          'publish.adapter_missing',
          'No publisher registered for ${job.platform.name}.',
          false,
        );
        continue;
      }
      final queued = await queueScheduledJob(job.id);
      if (!queued.success) {
        continue;
      }
      final started = await startPublishing(job.id);
      if (!started.success) {
        continue;
      }
      final publishRequest = await _buildRequest(job);
      if (publishRequest == null) {
        await failPublishing(
          job.id,
          'publish.validation_failed',
          'Unable to build publish request.',
          false,
        );
        continue;
      }
      final published = await publisher.publish(publishRequest);
      if (!published.success || published.value == null) {
        await failPublishing(
          job.id,
          published.errorCode ?? 'publish.live_disabled',
          published.userMessage ?? 'Publishing failed.',
          published.retryable,
        );
        continue;
      }
      final completed = await completePublishing(job.id, published.value!);
      if (completed.success && completed.value != null) {
        processed.add(completed.value!);
      }
    }
    return ReleaseResult<List<PublishJob>>.success(processed);
  }

  Future<ReleaseResult<PublishJob>> retryFailedJob(String jobId) async {
    final found = await _jobRepository.getJob(jobId);
    if (!found.success || found.value == null) {
      return ReleaseResult<PublishJob>.failure(
        errorCode: 'publish.not_found',
        userMessage: 'Publish job not found.',
      );
    }
    final job = found.value!;
    if (job.publishStatus != PublishStatus.failed) {
      return ReleaseResult<PublishJob>.failure(
        errorCode: 'publish.invalid_transition',
        userMessage: 'Only failed jobs can be retried.',
      );
    }
    final requeued = job.copyWith(
      updatedAtIso: DateTime.now().toUtc().toIso8601String(),
      publishStatus: PublishStatus.queued,
      clearLastErrorCode: true,
      clearLastErrorMessage: true,
    );
    await _jobRepository.saveJob(requeued);
    await _appendEvent(job.id, PublishAuditEventType.jobQueued, 'Publish job retried.');
    return ReleaseResult<PublishJob>.success(requeued);
  }

  Future<ReleaseResult<PublishJob>> validateAndPersistJob(
    PublishJob job,
  ) async {
    return validateJob(job);
  }

  ReleaseResult<void> _validateLocalJob(PublishJob job) {
    if (job.workspaceId == null || job.workspaceId!.trim().isEmpty) {
      return ReleaseResult<void>.failure(
        errorCode: 'publish.validation_failed',
        userMessage: 'Workspace is required.',
      );
    }
    if (job.contentAssetId.trim().isEmpty) {
      return ReleaseResult<void>.failure(
        errorCode: 'publish.validation_failed',
        userMessage: 'A content asset is required.',
      );
    }
    if (job.target.connectedAccountId.trim().isEmpty) {
      return ReleaseResult<void>.failure(
        errorCode: 'publish.validation_failed',
        userMessage: 'A connected account is required.',
      );
    }
    if (job.target.platform == SocialPlatform.demo) {
      return ReleaseResult<void>.success(null);
    }
    return ReleaseResult<void>.failure(
      errorCode: 'publish.live_disabled',
      userMessage: 'Live publishing is disabled for this platform.',
    );
  }

  Future<PublishRequest?> _buildRequest(PublishJob job) async {
    if (job.workspaceId == null) {
      return null;
    }
    final content = await _contentAssetRepository.getAsset(job.contentAssetId);
    final account = await _socialAccountRepository.getAccount(job.target.connectedAccountId);
    if (!content.success ||
        content.value == null ||
        !account.success ||
        account.value == null) {
      return null;
    }
    return PublishRequest(
      workspaceId: job.workspaceId!,
      scheduledPostId: job.scheduledPostId ?? job.id,
      contentAssets: <ContentAsset>[content.value!],
      connectedAccount: account.value!,
      target: job.target,
      metadata: <String, Object?>{
        'publishJobId': job.id,
      },
      dryRun: job.platform == SocialPlatform.demo,
    );
  }

  Future<void> _appendEvent(
    String jobId,
    PublishAuditEventType type,
    String message, [
    Map<String, Object?> metadata = const <String, Object?>{},
  ]) async {
    await _jobRepository.appendAuditEvent(
      PublishAuditEvent(
        id: 'audit-$jobId-${type.name}-${DateTime.now().microsecondsSinceEpoch}',
        createdAtIso: DateTime.now().toUtc().toIso8601String(),
        updatedAtIso: DateTime.now().toUtc().toIso8601String(),
        jobId: jobId,
        type: type,
        message: message,
        metadata: metadata,
      ),
    );
  }
}
