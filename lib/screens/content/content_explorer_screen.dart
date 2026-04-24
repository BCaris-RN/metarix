import 'package:flutter/material.dart';

import '../../app/metarix_scope.dart';
import '../../metarix_core/release/content/content_asset.dart';
import '../../metarix_core/release/content/content_metadata.dart';

class ContentExplorerScreen extends StatefulWidget {
  const ContentExplorerScreen({super.key});

  @override
  State<ContentExplorerScreen> createState() => _ContentExplorerScreenState();
}

class _ContentExplorerScreenState extends State<ContentExplorerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _hashtagsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _captionController.dispose();
    _hashtagsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = MetarixScope.of(context);
    final controller = services.contentAssetController;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final selected = controller.selectedAsset;
        _titleController.text = selected == null ? '' : selected.metadata.title;
        _captionController.text =
            selected == null ? '' : selected.metadata.caption;
        _hashtagsController.text =
            selected == null ? '' : selected.metadata.hashtags.join(', ');
        _notesController.text =
            selected == null ? '' : (selected.metadata.notes ?? '');

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Content Library',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            const Text('Local/demo content library'),
            const SizedBox(height: 16),
            if (controller.errorMessage != null)
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(controller.errorMessage!),
                ),
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: controller.isLoading ? null : controller.createDemoAsset,
                  icon: const Icon(Icons.add),
                  label: const Text('Create demo asset'),
                ),
                SizedBox(
                  width: 280,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(labelText: 'Search assets'),
                    onChanged: (value) {
                      controller.updateFilters(
                        controller.filters.copyWith(query: value),
                      );
                    },
                  ),
                ),
                DropdownButton<AssetStatus?>(
                  value: controller.filters.status,
                  items: const [
                    DropdownMenuItem<AssetStatus?>(
                      value: null,
                      child: Text('All statuses'),
                    ),
                    DropdownMenuItem<AssetStatus?>(
                      value: AssetStatus.local,
                      child: Text('Local'),
                    ),
                    DropdownMenuItem<AssetStatus?>(
                      value: AssetStatus.uploading,
                      child: Text('Uploading'),
                    ),
                    DropdownMenuItem<AssetStatus?>(
                      value: AssetStatus.uploaded,
                      child: Text('Uploaded'),
                    ),
                    DropdownMenuItem<AssetStatus?>(
                      value: AssetStatus.failed,
                      child: Text('Failed'),
                    ),
                    DropdownMenuItem<AssetStatus?>(
                      value: AssetStatus.archived,
                      child: Text('Archived'),
                    ),
                  ],
                  onChanged: (value) {
                    controller.updateFilters(
                      controller.filters.copyWith(status: value),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (controller.assets.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No assets yet. Create a demo asset to get started.'),
                ),
              )
            else
              ...controller.assets.map(
                (asset) => Card(
                  child: ListTile(
                    selected: selected?.id == asset.id,
                    onTap: () => controller.selectAsset(asset),
                    title: Text(asset.fileName),
                    subtitle: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Badge(label: asset.status.name),
                        _Badge(label: asset.mimeType),
                        ...asset.platformTargets.map((target) => _Badge(label: target)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => controller.deleteAsset(asset.id),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            if (selected != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Selected asset', style: Theme.of(context).textTheme.titleLarge),
                      Text('Filename: ${selected.fileName}'),
                      Text('Mime type: ${selected.mimeType}'),
                      Text('Status: ${selected.status.name}'),
                      Text('Preview: ${selected.previewUrl ?? 'n/a'}'),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                      ),
                      TextField(
                        controller: _captionController,
                        decoration: const InputDecoration(labelText: 'Caption'),
                        maxLines: 3,
                      ),
                      TextField(
                        controller: _hashtagsController,
                        decoration: const InputDecoration(labelText: 'Hashtags'),
                      ),
                      TextField(
                        controller: _notesController,
                        decoration: const InputDecoration(labelText: 'Notes'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        children: [
                          FilledButton(
                            onPressed: () {
                              final nowIso = DateTime.now().toUtc().toIso8601String();
                              controller.updateMetadata(
                                selected.id,
                                ContentMetadata(
                                  id: selected.metadata.id,
                                  createdAtIso: selected.metadata.createdAtIso,
                                  updatedAtIso: nowIso,
                                  title: _titleController.text,
                                  caption: _captionController.text,
                                  description: selected.metadata.description,
                                  tags: selected.metadata.tags,
                                  hashtags: _hashtagsController.text
                                      .split(',')
                                      .map((value) => value.trim())
                                      .where((value) => value.isNotEmpty)
                                      .toList(),
                                  altText: selected.metadata.altText,
                                  intendedChannel: selected.metadata.intendedChannel,
                                  notes: _notesController.text,
                                ),
                              );
                            },
                            child: const Text('Save metadata'),
                          ),
                          OutlinedButton(
                            onPressed: () => controller.markUploadStatus(
                              selected.id,
                              AssetStatus.uploaded,
                              'Marked uploaded in local demo.',
                            ),
                            child: const Text('Mark uploaded'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
}
