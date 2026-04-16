import 'package:flutter/foundation.dart';

import '../../../data/local_metarix_gateway.dart';
import '../../shared/domain/core_models.dart';
import '../../../features/workflow/domain/workflow_models.dart';
import '../data/local_asset_repository.dart';
import '../domain/asset_record.dart';
import '../domain/content_library_entry.dart';

class AssetLibraryController extends ChangeNotifier {
  AssetLibraryController(this._repository, this._gateway) {
    _gateway.addListener(notifyListeners);
  }

  final LocalAssetRepository _repository;
  final LocalMetarixGateway _gateway;

  List<AssetRecord> get assets => _repository.listAssets();

  List<ContentLibraryEntry> get libraryEntries => _repository.listEntries();

  List<AssetRecord> filteredAssets({
    AssetRecordType? type,
    String? tag,
    String? campaignId,
    SocialChannel? channel,
  }) {
    return _gateway.filterAssets(
      type: type,
      tag: tag,
      campaignId: campaignId,
      channel: channel,
    );
  }

  List<String> usageFor(String assetId) => _gateway.assetUsageLabels(assetId);

  Future<void> saveAsset(AssetRecord record) => _repository.saveAsset(record);

  Future<void> saveLibraryEntry(ContentLibraryEntry entry) =>
      _repository.saveEntry(entry);

  Future<void> attachAssetsToDraft(
    PostDraft draft,
    List<AssetRecord> selectedAssets,
  ) async {
    await _gateway.updateDraft(
      draft.copyWith(
        assetRefs: selectedAssets.map((asset) => asset.toAssetRef()).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _gateway.removeListener(notifyListeners);
    super.dispose();
  }
}
