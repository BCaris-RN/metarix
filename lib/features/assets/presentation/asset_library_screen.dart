import 'package:flutter/material.dart';

import '../../../app/metarix_scope.dart';
import '../../shared/domain/core_models.dart';
import '../application/asset_library_controller.dart';
import '../domain/asset_record.dart';

class AssetLibraryScreen extends StatefulWidget {
  const AssetLibraryScreen({super.key});

  @override
  State<AssetLibraryScreen> createState() => _AssetLibraryScreenState();
}

class _AssetLibraryScreenState extends State<AssetLibraryScreen> {
  AssetRecordType? _typeFilter;
  SocialChannel? _channelFilter;
  String? _campaignFilter;
  final TextEditingController _tagController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final services = MetarixScope.of(context);
    final controller = services.assetLibraryController;
    final campaigns = services.gateway.snapshot.campaigns;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final assets = controller.filteredAssets(
          type: _typeFilter,
          tag: _tagController.text.isEmpty ? null : _tagController.text,
          campaignId: _campaignFilter,
          channel: _channelFilter,
        );

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Asset Library',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    DropdownButton<AssetRecordType?>(
                      value: _typeFilter,
                      items: [
                        const DropdownMenuItem<AssetRecordType?>(
                          value: null,
                          child: Text('All types'),
                        ),
                        ...AssetRecordType.values.map(
                          (type) => DropdownMenuItem<AssetRecordType?>(
                            value: type,
                            child: Text(type.label),
                          ),
                        ),
                      ],
                      onChanged: (value) => setState(() => _typeFilter = value),
                    ),
                    DropdownButton<SocialChannel?>(
                      value: _channelFilter,
                      items: [
                        const DropdownMenuItem<SocialChannel?>(
                          value: null,
                          child: Text('All channels'),
                        ),
                        ...SocialChannel.values.map(
                          (channel) => DropdownMenuItem<SocialChannel?>(
                            value: channel,
                            child: Text(channel.label),
                          ),
                        ),
                      ],
                      onChanged: (value) => setState(() => _channelFilter = value),
                    ),
                    DropdownButton<String?>(
                      value: _campaignFilter,
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All campaigns'),
                        ),
                        ...campaigns.map(
                          (campaign) => DropdownMenuItem<String?>(
                            value: campaign.id,
                            child: Text(campaign.name),
                          ),
                        ),
                      ],
                      onChanged: (value) => setState(() => _campaignFilter = value),
                    ),
                    SizedBox(
                      width: 220,
                      child: TextField(
                        controller: _tagController,
                        decoration: const InputDecoration(labelText: 'Filter by tag'),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _showAssetDialog(context, controller, null),
                      icon: const Icon(Icons.add),
                      label: const Text('New asset'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...assets.map(
              (asset) => Card(
                child: ListTile(
                  title: Text(asset.name),
                  subtitle: Text(
                    '${asset.type.label} - ${asset.tags.join(', ')}\nUsage: ${controller.usageFor(asset.id).join(', ')}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showAssetDialog(context, controller, asset),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAssetDialog(
    BuildContext context,
    AssetLibraryController controller,
    AssetRecord? existing,
  ) async {
    final services = MetarixScope.of(context);
    final nameController = TextEditingController(text: existing?.name ?? '');
    final descriptionController =
        TextEditingController(text: existing?.description ?? '');
    final tagsController =
        TextEditingController(text: existing?.tags.join(', ') ?? '');
    AssetRecordType selectedType = existing?.type ?? AssetRecordType.image;
    SocialChannel selectedChannel =
        existing == null || existing.channels.isEmpty
            ? SocialChannel.instagram
            : existing.channels.first;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'New asset' : 'Edit asset'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              DropdownButtonFormField<AssetRecordType>(
                initialValue: selectedType,
                items: AssetRecordType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedType = value;
                  }
                },
              ),
              DropdownButtonFormField<SocialChannel>(
                initialValue: selectedChannel,
                items: SocialChannel.values
                    .map(
                      (channel) => DropdownMenuItem(
                        value: channel,
                        child: Text(channel.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedChannel = value;
                  }
                },
              ),
              TextField(
                controller: tagsController,
                decoration: const InputDecoration(labelText: 'Tags'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved != true) {
      return;
    }

    await controller.saveAsset(
      AssetRecord(
        id: existing?.id ?? services.gateway.createId('asset'),
        workspaceId: services.gateway.workspace.id,
        name: nameController.text,
        type: selectedType,
        tags: tagsController.text
            .split(',')
            .map((entry) => entry.trim())
            .where((entry) => entry.isNotEmpty)
            .toList(),
        channels: [selectedChannel],
        location: existing?.location ?? 'demo://asset/${nameController.text}',
        description: descriptionController.text,
      ),
    );
  }
}
