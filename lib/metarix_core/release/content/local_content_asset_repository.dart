import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../common/release_result.dart';
import 'content_asset.dart';
import 'content_asset_filters.dart';
import 'content_asset_repository.dart';
import 'content_metadata.dart';

class LocalContentAssetRepository implements ContentAssetRepository {
  LocalContentAssetRepository._(this._preferences);

  static const String _assetsKey = 'metarix.release.content.assets.v1';

  final SharedPreferences _preferences;

  static Future<LocalContentAssetRepository> create() async {
    final preferences = await SharedPreferences.getInstance();
    return LocalContentAssetRepository._(preferences);
  }

  @override
  Future<ReleaseResult<List<ContentAsset>>> listAssets(String workspaceId) async {
    try {
      return ReleaseResult<List<ContentAsset>>.success(
        _load().where((asset) => asset.workspaceId == workspaceId).toList(growable: false),
      );
    } catch (error) {
      return ReleaseResult<List<ContentAsset>>.failure(
        errorCode: 'content.storage_failed',
        userMessage: 'Unable to load content assets.',
        technicalMessage: '$error',
        retryable: true,
      );
    }
  }

  @override
  Future<ReleaseResult<ContentAsset?>> getAsset(String assetId) async {
    try {
      ContentAsset? asset;
      for (final entry in _load()) {
        if (entry.id == assetId) {
          asset = entry;
          break;
        }
      }
      return ReleaseResult<ContentAsset?>.success(asset);
    } catch (error) {
      return ReleaseResult<ContentAsset?>.failure(
        errorCode: 'content.storage_failed',
        userMessage: 'Unable to load content asset.',
        technicalMessage: '$error',
        retryable: true,
      );
    }
  }

  @override
  Future<ReleaseResult<ContentAsset>> saveAsset(ContentAsset asset) async {
    try {
      final items = _load();
      final index = items.indexWhere((entry) => entry.id == asset.id);
      if (index >= 0) {
        items[index] = asset;
      } else {
        items.add(asset);
      }
      await _persist(items);
      return ReleaseResult<ContentAsset>.success(asset);
    } catch (error) {
      return ReleaseResult<ContentAsset>.failure(
        errorCode: 'content.storage_failed',
        userMessage: 'Unable to save content asset.',
        technicalMessage: '$error',
        retryable: true,
      );
    }
  }

  @override
  Future<ReleaseResult<ContentAsset>> updateMetadata(
    String assetId,
    ContentMetadata metadata,
  ) async {
    final found = await getAsset(assetId);
    if (!found.success || found.value == null) {
      return ReleaseResult<ContentAsset>.failure(
        errorCode: 'content.not_found',
        userMessage: 'Asset not found.',
      );
    }
    final updated = found.value!.copyWith(
      updatedAtIso: DateTime.now().toUtc().toIso8601String(),
      metadata: metadata,
    );
    return saveAsset(updated);
  }

  @override
  Future<ReleaseResult<ContentAsset>> markUploadStatus(
    String assetId,
    AssetStatus status,
    String? reason,
  ) async {
    final found = await getAsset(assetId);
    if (!found.success || found.value == null) {
      return ReleaseResult<ContentAsset>.failure(
        errorCode: 'content.not_found',
        userMessage: 'Asset not found.',
      );
    }
    final updated = found.value!.copyWith(
      status: status,
      updatedAtIso: DateTime.now().toUtc().toIso8601String(),
      note: reason ?? found.value!.note,
    );
    return saveAsset(updated);
  }

  @override
  Future<ReleaseResult<void>> deleteAsset(String assetId) async {
    try {
      final items = _load()..removeWhere((entry) => entry.id == assetId);
      await _persist(items);
      return ReleaseResult<void>.success(null);
    } catch (error) {
      return ReleaseResult<void>.failure(
        errorCode: 'content.storage_failed',
        userMessage: 'Unable to delete content asset.',
        technicalMessage: '$error',
        retryable: true,
      );
    }
  }

  @override
  Future<ReleaseResult<List<ContentAsset>>> searchAssets(
    String workspaceId,
    String query,
    ContentAssetFilters filters,
  ) async {
    final normalized = query.trim().toLowerCase();
    final assets = await listAssets(workspaceId);
    if (!assets.success) {
      return ReleaseResult<List<ContentAsset>>.failure(
        errorCode: assets.errorCode,
        userMessage: assets.userMessage,
        technicalMessage: assets.technicalMessage,
        retryable: assets.retryable,
      );
    }
    final filtered = assets.value!
        .where((asset) {
          final matchesQuery = normalized.isEmpty ||
              asset.filename.toLowerCase().contains(normalized) ||
              (asset.note ?? '').toLowerCase().contains(normalized) ||
              asset.intendedPlatforms.any(
                (target) => target.toLowerCase().contains(normalized),
              ) ||
              asset.metadata.title.toLowerCase().contains(normalized) ||
              asset.metadata.caption.toLowerCase().contains(normalized);
          final matchesStatus = filters.status == null || asset.status == filters.status;
          final matchesTargets = filters.platformTargets.isEmpty ||
              asset.intendedPlatforms.any(filters.platformTargets.contains);
          return matchesQuery && matchesStatus && matchesTargets;
        })
        .toList(growable: false);
    return ReleaseResult<List<ContentAsset>>.success(filtered);
  }

  List<ContentAsset> _load() {
    final encoded = _preferences.getString(_assetsKey);
    if (encoded == null || encoded.isEmpty) {
      return <ContentAsset>[];
    }
    final decoded = jsonDecode(encoded) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map((item) => ContentAsset.fromJson(item))
        .toList(growable: true);
  }

  Future<void> _persist(List<ContentAsset> items) async {
    await _preferences.setString(
      _assetsKey,
      jsonEncode(items.map((entry) => entry.toJson()).toList()),
    );
  }
}
