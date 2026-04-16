import 'package:flutter/material.dart';

import '../domain/share_of_voice_snapshot.dart';

class ShareOfVoicePanel extends StatelessWidget {
  const ShareOfVoicePanel({
    required this.snapshot,
    super.key,
  });

  final ShareOfVoiceSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Share of voice', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (snapshot == null)
              const Text('No share-of-voice snapshot available.')
            else ...[
              Text(snapshot!.label),
              const SizedBox(height: 8),
              ...snapshot!.shareByEntity.entries.map(
                (entry) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(entry.key),
                  trailing: Text('${(entry.value * 100).toStringAsFixed(0)}%'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
