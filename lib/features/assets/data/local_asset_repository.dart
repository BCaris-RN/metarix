import '../../../data/local_metarix_gateway.dart';
import '../domain/asset_record.dart';
import '../domain/content_library_entry.dart';

class LocalAssetRepository {
  const LocalAssetRepository(this._gateway);

  final LocalMetarixGateway _gateway;

  List<AssetRecord> listAssets() => _gateway.snapshot.assetRecords;

  List<ContentLibraryEntry> listEntries() => _gateway.snapshot.contentLibraryEntries;

  Future<void> saveAsset(AssetRecord record) => _gateway.saveAssetRecord(record);

  Future<void> saveEntry(ContentLibraryEntry entry) =>
      _gateway.saveContentLibraryEntry(entry);
}
