import 'package:flutter/material.dart';

import '../domain/asset_record.dart';

class AssetPickerPanel extends StatefulWidget {
  const AssetPickerPanel({
    required this.assets,
    required this.initialSelection,
    required this.onConfirm,
    super.key,
  });

  final List<AssetRecord> assets;
  final List<String> initialSelection;
  final ValueChanged<List<AssetRecord>> onConfirm;

  @override
  State<AssetPickerPanel> createState() => _AssetPickerPanelState();
}

class _AssetPickerPanelState extends State<AssetPickerPanel> {
  late final Set<String> _selectedIds = widget.initialSelection.toSet();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 520,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...widget.assets.map(
            (asset) => CheckboxListTile(
              value: _selectedIds.contains(asset.id),
              title: Text(asset.name),
              subtitle: Text('${asset.type.label} - ${asset.tags.join(', ')}'),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedIds.add(asset.id);
                  } else {
                    _selectedIds.remove(asset.id);
                  }
                });
              },
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () {
                widget.onConfirm(
                  widget.assets
                      .where((asset) => _selectedIds.contains(asset.id))
                      .toList(),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Attach assets'),
            ),
          ),
        ],
      ),
    );
  }
}
