import '../common/release_result.dart';
import 'content_asset.dart';
import 'content_asset_filters.dart';
import 'content_metadata.dart';

abstract class ContentAssetRepository {
  Future<ReleaseResult<List<ContentAsset>>> listAssets(String workspaceId);

  Future<ReleaseResult<ContentAsset?>> getAsset(String assetId);

  Future<ReleaseResult<ContentAsset>> saveAsset(ContentAsset asset);

  Future<ReleaseResult<ContentAsset>> updateMetadata(
    String assetId,
    ContentMetadata metadata,
  );

  Future<ReleaseResult<ContentAsset>> markUploadStatus(
    String assetId,
    AssetStatus status,
    String? reason,
  );

  Future<ReleaseResult<void>> deleteAsset(String assetId);

  Future<ReleaseResult<List<ContentAsset>>> searchAssets(
    String workspaceId,
    String query,
    ContentAssetFilters filters,
  );
}

