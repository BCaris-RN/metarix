import 'package:flutter/material.dart';

import '../domain/export_artifact.dart';

class ExportActionsPanel extends StatelessWidget {
  const ExportActionsPanel({
    required this.title,
    required this.actions,
    required this.artifacts,
    super.key,
  });

  final String title;
  final List<Widget> actions;
  final List<ExportArtifact> artifacts;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(spacing: 12, runSpacing: 12, children: actions),
            const SizedBox(height: 12),
            if (artifacts.isEmpty)
              const Text('No exports generated yet.')
            else
              ...artifacts.map(
                (artifact) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(artifact.fileName),
                  subtitle: Text('${artifact.type.label} • ${artifact.posture}'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
