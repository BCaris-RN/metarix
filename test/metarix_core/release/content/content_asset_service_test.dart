import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:metarix/metarix_core/release/release.dart';

Future<ContentAssetService> _buildService() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final repository = await LocalContentAssetRepository.create();
  return ContentAssetService(repository, const PlatformCapabilityService());
}

ContentAsset _asset({
  required String id,
  required String workspaceId,
  required String filename,
  required String mimeType,
  required ContentMetadata metadata,
}) {
  final nowIso = '2026-04-23T00:00:00.000Z';
  return ContentAsset(
    id: id,
    workspaceId: workspaceId,
    createdAtIso: nowIso,
    updatedAtIso: nowIso,
    localPathOrUri: 'demo://$filename',
    filename: filename,
    mimeType: mimeType,
    fileSizeBytes: 1024,
    status: AssetStatus.local,
    metadata: metadata,
    intendedPlatforms: const <String>['instagram'],
    thumbnailUrl: null,
    remoteUrl: null,
    width: null,
    height: null,
    durationSeconds: null,
    campaignId: null,
    note: null,
  );
}

void main() {
  test('rejects empty workspaceId', () async {
    final service = await _buildService();
    final result = await service.listAssets('');
    expect(result.success, isFalse);
    expect(result.errorCode, 'content.invalid_input');
  });

  test('rejects empty filename', () async {
    final service = await _buildService();
    final result = await service.saveAsset(
      _asset(
        id: 'asset-1',
        workspaceId: 'workspace-1',
        filename: '',
        mimeType: 'image/jpeg',
        metadata: ContentMetadata(
          id: 'metadata-1',
          createdAtIso: '2026-04-23T00:00:00.000Z',
          updatedAtIso: '2026-04-23T00:00:00.000Z',
          title: 'Title',
          caption: 'Caption',
          description: 'Description',
          tags: const <String>[],
          hashtags: const <String>[],
          altText: null,
          intendedChannel: 'instagram',
          notes: null,
        ),
      ),
    );
    expect(result.success, isFalse);
    expect(result.errorCode, 'content.invalid_input');
  });

  test('rejects unsupported mime type', () async {
    final service = await _buildService();
    final result = await service.saveAsset(
      _asset(
        id: 'asset-1',
        workspaceId: 'workspace-1',
        filename: 'bad.txt',
        mimeType: 'text/plain',
        metadata: ContentMetadata(
          id: 'metadata-1',
          createdAtIso: '2026-04-23T00:00:00.000Z',
          updatedAtIso: '2026-04-23T00:00:00.000Z',
          title: 'Title',
          caption: 'Caption',
          description: 'Description',
          tags: const <String>[],
          hashtags: const <String>[],
          altText: null,
          intendedChannel: 'instagram',
          notes: null,
        ),
      ),
    );
    expect(result.success, isFalse);
    expect(result.errorCode, 'content.unsupported_mime');
  });

  test('creates demo asset', () async {
    final service = await _buildService();
    final result = await service.createDemoAsset(
      workspaceId: 'workspace-1',
      filename: 'demo-image.jpg',
      mimeType: 'image/jpeg',
      platformTargets: const <String>['instagram'],
      previewUrl: 'demo://preview/demo-image.jpg',
      sizeBytes: 2048,
    );
    expect(result.success, isTrue);
    expect(result.value?.workspaceId, 'workspace-1');
    expect(result.value?.metadata.title, 'demo-image.jpg');
  });

  test('metadata update persists', () async {
    final service = await _buildService();
    final saveResult = await service.saveAsset(
      _asset(
        id: 'asset-1',
        workspaceId: 'workspace-1',
        filename: 'image.jpg',
        mimeType: 'image/jpeg',
        metadata: ContentMetadata(
          id: 'metadata-1',
          createdAtIso: '2026-04-23T00:00:00.000Z',
          updatedAtIso: '2026-04-23T00:00:00.000Z',
          title: 'Title',
          caption: 'Caption',
          description: 'Description',
          tags: const <String>[],
          hashtags: const <String>[],
          altText: null,
          intendedChannel: 'instagram',
          notes: null,
        ),
      ),
    );
    expect(saveResult.success, isTrue);

    final metadata = ContentMetadata(
      id: 'metadata-1',
      createdAtIso: '2026-04-23T00:00:00.000Z',
      updatedAtIso: '2026-04-23T01:00:00.000Z',
      title: 'Updated title',
      caption: 'Updated caption',
      description: 'Description',
      tags: const <String>['tag1'],
      hashtags: const <String>['#tag1'],
      altText: 'alt',
      intendedChannel: 'instagram',
      notes: 'updated',
    );
    final updateResult = await service.updateMetadata('asset-1', metadata);
    expect(updateResult.success, isTrue);
    expect(updateResult.value?.metadata.title, 'Updated title');
    expect(updateResult.value?.metadata.notes, 'updated');
  });

  test('search filters by query', () async {
    final service = await _buildService();
    await service.createDemoAsset(
      workspaceId: 'workspace-1',
      filename: 'summer-launch.jpg',
      mimeType: 'image/jpeg',
      platformTargets: const <String>['instagram'],
      note: 'summer launch hero',
    );
    await service.createDemoAsset(
      workspaceId: 'workspace-1',
      filename: 'winter-release.jpg',
      mimeType: 'image/jpeg',
      platformTargets: const <String>['facebook'],
      note: 'winter release',
    );

    final allAssets = await service.listAssets('workspace-1');
    expect(allAssets.success, isTrue);
    expect(allAssets.value, isNotNull);
    expect(allAssets.value!.length, 2);

    final result = await service.searchAssets(
      'workspace-1',
      'summer launch hero',
      const ContentAssetFilters(),
    );
    expect(result.success, isTrue);
    expect(result.value, isNotNull);
    expect(result.value!.length, 1);
    expect(result.value!.first.filename, 'summer-launch.jpg');
  });

  test('delete removes asset', () async {
    final service = await _buildService();
    await service.createDemoAsset(
      workspaceId: 'workspace-1',
      filename: 'delete-me.jpg',
      mimeType: 'image/jpeg',
      platformTargets: const <String>['instagram'],
    );
    final assets = await service.searchAssets(
      'workspace-1',
      '',
      const ContentAssetFilters(),
    );
    final assetId = assets.value!.first.id;

    final deleteResult = await service.deleteAsset(assetId);
    expect(deleteResult.success, isTrue);

    final afterDelete = await service.getAsset(assetId);
    expect(afterDelete.success, isTrue);
    expect(afterDelete.value, isNull);
  });

  test('optional preview fields do not crash', () async {
    final service = await _buildService();
    final result = await service.saveAsset(
      _asset(
        id: 'asset-optional',
        workspaceId: 'workspace-1',
        filename: 'optional.jpg',
        mimeType: 'image/jpeg',
        metadata: ContentMetadata(
          id: 'metadata-optional',
          createdAtIso: '2026-04-23T00:00:00.000Z',
          updatedAtIso: '2026-04-23T00:00:00.000Z',
          title: 'Optional',
          caption: 'Caption',
          description: 'Description',
          tags: const <String>[],
          hashtags: const <String>[],
          altText: null,
          intendedChannel: null,
          notes: null,
        ),
      ),
    );
    expect(result.success, isTrue);
    expect(result.value?.previewUrl, isNull);
    expect(result.value?.thumbnailUrl, isNull);
  });
}
