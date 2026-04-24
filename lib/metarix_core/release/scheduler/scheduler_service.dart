import '../accounts/connected_social_account.dart';
import '../accounts/social_platform.dart';
import '../accounts/social_account_repository.dart';
import '../common/release_result.dart';
import '../content/content_asset_repository.dart';
import '../platforms/platform_capability_service.dart';
import '../publishing/publish_status.dart';
import 'publish_target.dart';
import 'scheduled_post.dart';
import 'scheduled_post_filters.dart';
import 'scheduled_post_repository.dart';

class SchedulerService {
  SchedulerService(
    this._repository,
    this._contentRepository,
    this._accountRepository,
    this._capabilities,
  );

  final ScheduledPostRepository _repository;
  final ContentAssetRepository _contentRepository;
  final SocialAccountRepository _accountRepository;
  final PlatformCapabilityService _capabilities;

  Future<ReleaseResult<ScheduledPost>> createDraft({
    required String workspaceId,
    required List<String> contentAssetIds,
    required List<PublishTarget> targets,
    required String scheduledAtIso,
    required String timezone,
    required String createdByUserId,
  }) async {
    final validation = await _validateDraftInput(
      workspaceId: workspaceId,
      contentAssetIds: contentAssetIds,
      targets: targets,
      scheduledAtIso: scheduledAtIso,
      timezone: timezone,
      createdByUserId: createdByUserId,
    );
    if (!validation.success) {
      return ReleaseResult<ScheduledPost>.failure(
        errorCode: validation.errorCode,
        userMessage: validation.userMessage,
        technicalMessage: validation.technicalMessage,
        retryable: validation.retryable,
      );
    }
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final post = ScheduledPost(
      id: 'scheduled-$nowIso-${contentAssetIds.first}',
      createdAtIso: nowIso,
      updatedAtIso: nowIso,
      workspaceId: workspaceId,
      contentAssetIds: contentAssetIds,
      targets: targets,
      scheduledAtIso: DateTime.parse(scheduledAtIso).toUtc().toIso8601String(),
      timezone: timezone,
      status: PublishStatus.pendingApproval,
      validationErrors: const <String>[],
      approvalStatus: 'pendingApproval',
      createdByUserId: createdByUserId,
      publishedJobIds: const <String>[],
      title: _defaultTitle(contentAssetIds),
      caption: '',
      platform: targets.first.platform,
      target: targets.first,
      publishStatus: PublishStatus.pendingApproval,
      contentAssetId: contentAssetIds.first,
      validationMessage: null,
    );
    final saved = await _repository.saveScheduledPost(post);
    if (!saved.success) {
      return ReleaseResult<ScheduledPost>.failure(
        errorCode: saved.errorCode,
        userMessage: saved.userMessage,
        technicalMessage: saved.technicalMessage,
        retryable: saved.retryable,
      );
    }
    return saved;
  }

  Future<ReleaseResult<ScheduledPost>> validateDraft(ScheduledPost post) async {
    final validation = await _validateDraftPost(post);
    if (!validation.success) {
      final updated = post.copyWith(
        status: PublishStatus.validationFailed,
        publishStatus: PublishStatus.validationFailed,
        approvalStatus: 'validationFailed',
        validationErrors: <String>[validation.userMessage ?? 'Validation failed.'],
        validationMessage: validation.userMessage,
        updatedAtIso: DateTime.now().toUtc().toIso8601String(),
      );
      await _repository.saveScheduledPost(updated);
      return ReleaseResult<ScheduledPost>.failure(
        errorCode: validation.errorCode,
        userMessage: validation.userMessage,
        technicalMessage: validation.technicalMessage,
        retryable: validation.retryable,
      );
    }
    final updated = post.copyWith(
      status: PublishStatus.pendingApproval,
      publishStatus: PublishStatus.pendingApproval,
      approvalStatus: 'pendingApproval',
      validationErrors: const <String>[],
      validationMessage: null,
      updatedAtIso: DateTime.now().toUtc().toIso8601String(),
    );
    return _repository.saveScheduledPost(updated);
  }

  Future<ReleaseResult<ScheduledPost>> approveDraft({
    required String postId,
    required String approvedByUserId,
  }) async {
    final found = await _repository.getScheduledPost(postId);
    if (!found.success || found.value == null) {
      return ReleaseResult<ScheduledPost>.failure(
        errorCode: 'scheduler.not_found',
        userMessage: 'Scheduled post not found.',
      );
    }
    final post = found.value!;
    if (post.status != PublishStatus.pendingApproval &&
        post.status != PublishStatus.validationFailed &&
        post.status != PublishStatus.draft) {
      return ReleaseResult<ScheduledPost>.failure(
        errorCode: 'scheduler.invalid_transition',
        userMessage: 'Only draft or pending approval posts can be approved.',
        retryable: false,
      );
    }
    if (post.validationErrors.isNotEmpty) {
      return ReleaseResult<ScheduledPost>.failure(
        errorCode: 'scheduler.validation_failed',
        userMessage: 'Resolve validation errors before approval.',
        retryable: false,
      );
    }
    final updated = post.copyWith(
      status: PublishStatus.approved,
      publishStatus: PublishStatus.approved,
      approvalStatus: 'approved',
      approvedByUserId: approvedByUserId,
      updatedAtIso: DateTime.now().toUtc().toIso8601String(),
    );
    return _repository.saveScheduledPost(updated);
  }

  Future<ReleaseResult<ScheduledPost>> scheduleApprovedPost(String postId) async {
    final found = await _repository.getScheduledPost(postId);
    if (!found.success || found.value == null) {
      return ReleaseResult<ScheduledPost>.failure(
        errorCode: 'scheduler.not_found',
        userMessage: 'Scheduled post not found.',
      );
    }
    final post = found.value!;
    if (post.status != PublishStatus.approved) {
      return ReleaseResult<ScheduledPost>.failure(
        errorCode: 'scheduler.invalid_transition',
        userMessage: 'Only approved posts can be scheduled.',
        retryable: false,
      );
    }
    final updated = post.copyWith(
      status: PublishStatus.scheduled,
      publishStatus: PublishStatus.scheduled,
      approvalStatus: 'scheduled',
      updatedAtIso: DateTime.now().toUtc().toIso8601String(),
    );
    return _repository.saveScheduledPost(updated);
  }

  Future<ReleaseResult<ScheduledPost>> cancelScheduledPost(
    String postId,
    String reason,
  ) async {
    final found = await _repository.getScheduledPost(postId);
    if (!found.success || found.value == null) {
      return ReleaseResult<ScheduledPost>.failure(
        errorCode: 'scheduler.not_found',
        userMessage: 'Scheduled post not found.',
      );
    }
    final post = found.value!;
    if (post.status != PublishStatus.scheduled) {
      return ReleaseResult<ScheduledPost>.failure(
        errorCode: 'scheduler.invalid_transition',
        userMessage: 'Only scheduled posts can be canceled.',
        retryable: false,
      );
    }
    final updated = post.copyWith(
      status: PublishStatus.canceled,
      publishStatus: PublishStatus.canceled,
      approvalStatus: 'canceled',
      validationMessage: reason,
      updatedAtIso: DateTime.now().toUtc().toIso8601String(),
    );
    return _repository.saveScheduledPost(updated);
  }

  Future<ReleaseResult<List<ScheduledPost>>> listUpcoming(String workspaceId) =>
      _repository.listScheduledPosts(workspaceId);

  Future<ReleaseResult<List<ScheduledPost>>> searchScheduledPosts(
    String workspaceId,
    String query,
    ScheduledPostFilters filters,
  ) =>
      _repository.searchScheduledPosts(workspaceId, query, filters);

  Future<ReleaseResult<void>> _validateDraftInput({
    required String workspaceId,
    required List<String> contentAssetIds,
    required List<PublishTarget> targets,
    required String scheduledAtIso,
    required String timezone,
    required String createdByUserId,
  }) async {
    if (workspaceId.trim().isEmpty) {
      return ReleaseResult<void>.failure(
        errorCode: 'scheduler.invalid_input',
        userMessage: 'Workspace is required.',
        retryable: false,
      );
    }
    if (createdByUserId.trim().isEmpty) {
      return ReleaseResult<void>.failure(
        errorCode: 'scheduler.invalid_input',
        userMessage: 'Creator is required.',
        retryable: false,
      );
    }
    if (contentAssetIds.isEmpty) {
      return ReleaseResult<void>.failure(
        errorCode: 'scheduler.invalid_input',
        userMessage: 'At least one content asset is required.',
        retryable: false,
      );
    }
    if (targets.isEmpty) {
      return ReleaseResult<void>.failure(
        errorCode: 'scheduler.invalid_input',
        userMessage: 'At least one publish target is required.',
        retryable: false,
      );
    }
    if (timezone.trim().isEmpty) {
      return ReleaseResult<void>.failure(
        errorCode: 'scheduler.invalid_input',
        userMessage: 'Timezone is required.',
        retryable: false,
      );
    }
    final parsed = DateTime.tryParse(scheduledAtIso);
    if (parsed == null) {
      return ReleaseResult<void>.failure(
        errorCode: 'scheduler.invalid_input',
        userMessage: 'Scheduled time must be a valid ISO datetime.',
        retryable: false,
      );
    }
    if (parsed.isBefore(DateTime.now().toUtc())) {
      return ReleaseResult<void>.failure(
        errorCode: 'scheduler.past_time',
        userMessage: 'Scheduled time cannot be in the past.',
        retryable: false,
      );
    }
    final accounts = await _accountRepository.listConnectedAccounts(workspaceId);
    if (!accounts.success) {
      return ReleaseResult<void>.failure(
        errorCode: accounts.errorCode,
        userMessage: accounts.userMessage,
        technicalMessage: accounts.technicalMessage,
        retryable: accounts.retryable,
      );
    }
    final content = await _contentRepository.listAssets(workspaceId);
    if (!content.success) {
      return ReleaseResult<void>.failure(
        errorCode: content.errorCode,
        userMessage: content.userMessage,
        technicalMessage: content.technicalMessage,
        retryable: content.retryable,
      );
    }
    final accountById = {
      for (final account in accounts.value ?? const <ConnectedSocialAccount>[])
        account.accountId: account,
    };
    final assetIds = (content.value ?? const <dynamic>[]).map((asset) => asset.id).toSet();
    if (contentAssetIds.any((assetId) => !assetIds.contains(assetId))) {
      return ReleaseResult<void>.failure(
        errorCode: 'scheduler.invalid_input',
        userMessage: 'One or more content assets do not exist.',
        retryable: false,
      );
    }
    for (final target in targets) {
      if (target.connectedAccountId.trim().isEmpty) {
        return ReleaseResult<void>.failure(
          errorCode: 'scheduler.invalid_input',
          userMessage: 'Each target must include a connected account id.',
          retryable: false,
        );
      }
      if (target.platform == SocialPlatform.demo) {
        continue;
      }
      final account = accountById[target.connectedAccountId];
      if (account == null) {
        return ReleaseResult<void>.failure(
          errorCode: 'scheduler.missing_account',
          userMessage: 'Target account is not connected.',
          retryable: false,
        );
      }
      final manifest = _capabilities.manifestFor(target.platform);
      if (!manifest.canSchedule) {
        return ReleaseResult<void>.failure(
          errorCode: 'scheduler.unsupported_platform',
          userMessage: manifest.unsupportedReason ?? 'Unsupported platform.',
          retryable: false,
        );
      }
      if (manifest.requiredScopes.isNotEmpty &&
          account.missingScopes.isNotEmpty &&
          account.missingScopes.any(manifest.requiredScopes.contains)) {
        return ReleaseResult<void>.failure(
          errorCode: 'scheduler.permission_missing',
          userMessage: 'Missing required scopes for ${target.platform.name}.',
          retryable: false,
        );
      }
    }
    return ReleaseResult<void>.success(null);
  }

  Future<ReleaseResult<void>> _validateDraftPost(ScheduledPost post) async {
    return _validateDraftInput(
      workspaceId: post.workspaceId,
      contentAssetIds: post.contentAssetIds,
      targets: post.targets,
      scheduledAtIso: post.scheduledAtIso,
      timezone: post.timezone,
      createdByUserId: post.createdByUserId,
    );
  }

  String _defaultTitle(List<String> contentAssetIds) =>
      contentAssetIds.isEmpty ? 'Scheduled post' : 'Scheduled post ${contentAssetIds.first}';
}
