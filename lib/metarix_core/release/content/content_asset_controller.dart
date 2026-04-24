import 'package:flutter/foundation.dart';

import '../common/release_result.dart';
import 'content_asset.dart';
import 'content_asset_filters.dart';
import 'content_asset_service.dart';
import 'content_metadata.dart';

class ContentAssetController extends ChangeNotifier {
  ContentAssetController(this._service);

  final ContentAssetService _service;

  List<ContentAsset> _assets = const <ContentAsset>[];
  ContentAsset? _selectedAsset;
  bool _loading = false;
  String? _errorMessage;
  ContentAssetFilters _filters = const ContentAssetFilters();
  String? _workspaceId;

  List<ContentAsset> get assets => _assets;
  ContentAsset? get selectedAsset => _selectedAsset;
  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;
  ContentAssetFilters get filters => _filters;

  Future<void> loadAssets(String workspaceId) async {
    _workspaceId = workspaceId;
    _loading = true;
    notifyListeners();
    final result = await _service.listAssets(workspaceId);
    _applyListResult(result);
    _loading = false;
    notifyListeners();
  }

  Future<void> createDemoAsset() async {
    final workspaceId = _workspaceId;
    if (workspaceId == null) {
      _errorMessage = 'Workspace not loaded.';
      notifyListeners();
      return;
    }
    _loading = true;
    notifyListeners();
    final result = await _service.createDemoAsset(
      workspaceId: workspaceId,
      filename: 'demo-image.jpg',
      mimeType: 'image/jpeg',
      platformTargets: const <String>['instagram', 'facebook'],
      note: 'Demo asset created locally.',
      previewUrl: 'demo://preview/demo-image.jpg',
      sizeBytes: 1024,
    );
    if (result.success) {
      await loadAssets(workspaceId);
      _selectedAsset = result.value;
      _errorMessage = null;
    } else {
      _errorMessage = result.userMessage ?? 'Unable to create demo asset.';
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> saveAsset(ContentAsset asset) async {
    final result = await _service.saveAsset(asset);
    if (result.success && _workspaceId != null) {
      await loadAssets(_workspaceId!);
      _selectedAsset = result.value;
      _errorMessage = null;
    } else {
      _errorMessage = result.userMessage ?? 'Unable to save asset.';
      notifyListeners();
    }
  }

  Future<void> updateMetadata(String assetId, ContentMetadata metadata) async {
    final result = await _service.updateMetadata(assetId, metadata);
    if (result.success && _workspaceId != null) {
      await loadAssets(_workspaceId!);
      _selectedAsset = result.value;
      _errorMessage = null;
    } else {
      _errorMessage = result.userMessage ?? 'Unable to update metadata.';
      notifyListeners();
    }
  }

  Future<void> deleteAsset(String assetId) async {
    final result = await _service.deleteAsset(assetId);
    if (result.success && _workspaceId != null) {
      await loadAssets(_workspaceId!);
      if (_selectedAsset?.id == assetId) {
        _selectedAsset = null;
      }
      _errorMessage = null;
    } else {
      _errorMessage = result.userMessage ?? 'Unable to delete asset.';
      notifyListeners();
    }
  }

  Future<void> markUploadStatus(
    String assetId,
    AssetStatus status,
    String? reason,
  ) async {
    final result = await _service.markUploadStatus(assetId, status, reason);
    if (result.success && _workspaceId != null) {
      await loadAssets(_workspaceId!);
      _selectedAsset = result.value;
      _errorMessage = null;
    } else {
      _errorMessage = result.userMessage ?? 'Unable to update asset status.';
      notifyListeners();
    }
  }

  Future<void> searchAssets() async {
    final workspaceId = _workspaceId;
    if (workspaceId == null) {
      _errorMessage = 'Workspace not loaded.';
      notifyListeners();
      return;
    }
    _loading = true;
    notifyListeners();
    final result = await _service.searchAssets(
      workspaceId,
      _filters.query,
      _filters,
    );
    _applyListResult(result);
    _loading = false;
    notifyListeners();
  }

  Future<void> selectAsset(ContentAsset? asset) async {
    _selectedAsset = asset;
    notifyListeners();
  }

  Future<void> updateFilters(ContentAssetFilters filters) async {
    _filters = filters;
    await searchAssets();
  }

  void clearSelection() {
    _selectedAsset = null;
    notifyListeners();
  }

  void _applyListResult(ReleaseResult<List<ContentAsset>> result) {
    if (result.success) {
      _assets = result.value ?? const <ContentAsset>[];
      _errorMessage = null;
    } else {
      _errorMessage = result.userMessage ?? 'Unable to load assets.';
    }
  }
}
