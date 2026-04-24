import '../common/release_result.dart';
import '../accounts/social_platform.dart';
import '../platforms/platform_capability_service.dart';
import 'content_asset.dart';
import 'content_asset_filters.dart';
import 'content_asset_repository.dart';
import 'content_metadata.dart';

class ContentAssetService {
  ContentAssetService(this._repository, this._capabilities);

  final ContentAssetRepository _repository;
  final PlatformCapabilityService _capabilities;

  static const Set<String> supportedMimeTypes = <String>{
    'image/jpeg',
    'image/png',
    'image/webp',
    'video/mp4',
    'video/quicktime',
  };

  Future<ReleaseResult<List<ContentAsset>>> listAssets(String workspaceId) async {
    if (workspaceId.trim().isEmpty) {
      return ReleaseResult<List<ContentAsset>>.failure(
        errorCode: 'content.invalid_input',
        userMessage: 'Workspace is required.',
        retryable: false,
      );
    }
    return _repository.listAssets(workspaceId);
  }

  Future<ReleaseResult<ContentAsset?>> getAsset(String assetId) async {
    if (assetId.trim().isEmpty) {
      return ReleaseResult<ContentAsset?>.failure(
        errorCode: 'content.invalid_input',
        userMessage: 'Asset id is required.',
        retryable: false,
      );
    }
    return _repository.getAsset(assetId);
  }

  Future<ReleaseResult<ContentAsset>> saveAsset(ContentAsset asset) async {
    final validation = _validateAsset(asset);
    if (!validation.success) {
      return ReleaseResult<ContentAsset>.failure(
        errorCode: validation.errorCode,
        userMessage: validation.userMessage,
        technicalMessage: validation.technicalMessage,
        retryable: validation.retryable,
      );
    }
    return _repository.saveAsset(asset);
  }

  Future<ReleaseResult<ContentAsset>> updateMetadata(
    String assetId,
    ContentMetadata metadata,
  ) async {
    if (assetId.trim().isEmpty) {
      return ReleaseResult<ContentAsset>.failure(
        errorCode: 'content.invalid_input',
        userMessage: 'Asset id is required.',
        retryable: false,
      );
    }
    final metadataValidation = _validateMetadata(metadata);
    if (!metadataValidation.success) {
      return ReleaseResult<ContentAsset>.failure(
        errorCode: metadataValidation.errorCode,
        userMessage: metadataValidation.userMessage,
        technicalMessage: metadataValidation.technicalMessage,
        retryable: metadataValidation.retryable,
      );
    }
    return _repository.updateMetadata(assetId, metadata);
  }

  Future<ReleaseResult<ContentAsset>> markUploadStatus(
    String assetId,
    AssetStatus status,
    String? reason,
  ) async {
    return _repository.markUploadStatus(assetId, status, reason);
  }

  Future<ReleaseResult<void>> deleteAsset(String assetId) async {
    if (assetId.trim().isEmpty) {
      return ReleaseResult<void>.failure(
        errorCode: 'content.invalid_input',
        userMessage: 'Asset id is required.',
        retryable: false,
      );
    }
    return _repository.deleteAsset(assetId);
  }

  Future<ReleaseResult<List<ContentAsset>>> searchAssets(
    String workspaceId,
    String query,
    ContentAssetFilters filters,
  ) async {
    if (workspaceId.trim().isEmpty) {
      return ReleaseResult<List<ContentAsset>>.failure(
        errorCode: 'content.invalid_input',
        userMessage: 'Workspace is required.',
        retryable: false,
      );
    }
    return _repository.searchAssets(workspaceId, query, filters);
  }

  Future<ReleaseResult<ContentAsset>> createDemoAsset({
    required String workspaceId,
    required String filename,
    required String mimeType,
    List<String> platformTargets = const <String>[],
    String? note,
    String? previewUrl,
    int? sizeBytes,
  }) async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final uniqueSuffix = DateTime.now().toUtc().microsecondsSinceEpoch;
    final metadata = ContentMetadata(
      id: 'metadata-$filename-$uniqueSuffix',
      createdAtIso: nowIso,
      updatedAtIso: nowIso,
      title: filename,
      caption: '',
      description: '',
      tags: const <String>[],
      hashtags: const <String>[],
      altText: null,
      intendedChannel: platformTargets.isEmpty ? null : platformTargets.first,
      notes: note,
    );
    final asset = ContentAsset(
      id: 'asset-$filename-$uniqueSuffix',
      workspaceId: workspaceId,
      createdAtIso: nowIso,
      updatedAtIso: nowIso,
      localPathOrUri: 'demo://$filename',
      filename: filename,
      mimeType: mimeType,
      fileSizeBytes: sizeBytes ?? 0,
      status: AssetStatus.local,
      remoteUrl: null,
      width: null,
      height: null,
      durationSeconds: null,
      thumbnailUrl: previewUrl,
      campaignId: null,
      intendedPlatforms: platformTargets,
      metadata: metadata,
      note: note ?? 'Demo asset',
    );
    return saveAsset(asset);
  }

  ReleaseResult<void> _validateAsset(ContentAsset asset) {
    if (asset.workspaceId.trim().isEmpty) {
      return ReleaseResult<void>.failure(
        errorCode: 'content.invalid_input',
        userMessage: 'Workspace is required.',
        retryable: false,
      );
    }
    if (asset.fileName.trim().isEmpty) {
      return ReleaseResult<void>.failure(
        errorCode: 'content.invalid_input',
        userMessage: 'Filename is required.',
        retryable: false,
      );
    }
    if (!supportedMimeTypes.contains(asset.mimeType.trim().toLowerCase())) {
      return ReleaseResult<void>.failure(
        errorCode: 'content.unsupported_mime',
        userMessage: 'Unsupported media type.',
        retryable: false,
      );
    }
    final metadataValidation = _validateMetadata(asset.metadata);
    if (!metadataValidation.success) {
      return ReleaseResult<void>.failure(
        errorCode: metadataValidation.errorCode,
        userMessage: metadataValidation.userMessage,
        technicalMessage: metadataValidation.technicalMessage,
        retryable: metadataValidation.retryable,
      );
    }
    return ReleaseResult<void>.success(null);
  }

  ReleaseResult<void> _validateMetadata(ContentMetadata metadata) {
    if (metadata.id.trim().isEmpty) {
      return ReleaseResult<void>.failure(
        errorCode: 'content.invalid_input',
        userMessage: 'Metadata id is required.',
        retryable: false,
      );
    }
    if (metadata.caption.trim().length > 2200) {
      return ReleaseResult<void>.failure(
        errorCode: 'content.caption_too_long',
        userMessage: 'Caption is too long.',
        retryable: false,
      );
    }
    if (metadata.title.trim().length > 200) {
      return ReleaseResult<void>.failure(
        errorCode: 'content.title_too_long',
        userMessage: 'Title is too long.',
        retryable: false,
      );
    }
    final target = metadata.intendedChannel;
    if (target != null) {
      final platform = SocialPlatformX.fromName(target);
      final manifest = _capabilities.manifestFor(platform);
      if (manifest.unsupportedReason != null && manifest.canConnect == false) {
        return ReleaseResult<void>.failure(
          errorCode: 'content.unsupported_platform_capability',
          userMessage: manifest.unsupportedReason,
          retryable: false,
        );
      }
    }
    return ReleaseResult<void>.success(null);
  }
}
