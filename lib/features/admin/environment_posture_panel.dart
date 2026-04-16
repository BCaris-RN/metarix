import 'package:flutter/material.dart';

class EnvironmentPosturePanel extends StatelessWidget {
  const EnvironmentPosturePanel({
    required this.environmentLabel,
    required this.dangerousActionsDisabled,
    required this.allowIncompleteFeatures,
    super.key,
  });

  final String environmentLabel;
  final bool dangerousActionsDisabled;
  final bool allowIncompleteFeatures;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Environment posture', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text('Environment: $environmentLabel'),
            Text('Dangerous actions disabled: ${dangerousActionsDisabled ? 'Yes' : 'No'}'),
            Text('Incomplete features allowed: ${allowIncompleteFeatures ? 'Yes' : 'No'}'),
          ],
        ),
      ),
    );
  }
}
