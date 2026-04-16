import 'package:flutter/material.dart';

class PublishBoundaryPanel extends StatelessWidget {
  const PublishBoundaryPanel({
    required this.eligibleCount,
    required this.deniedCount,
    required this.denialReasonsCount,
    super.key,
  });

  final int eligibleCount;
  final int deniedCount;
  final int denialReasonsCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Publish boundary', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text('Eligible drafts: $eligibleCount'),
            Text('Denied drafts: $deniedCount'),
            Text('Blocked reasons logged: $denialReasonsCount'),
          ],
        ),
      ),
    );
  }
}
