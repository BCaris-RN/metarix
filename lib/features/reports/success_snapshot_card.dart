import 'package:flutter/material.dart';

import 'report_section.dart';

class SuccessSnapshotCard extends StatelessWidget {
  const SuccessSnapshotCard({super.key, required this.snapshot});

  final SuccessSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ReportSection.successSnapshot.label,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              snapshot.headline,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricTile(
                  label: 'Impressions',
                  value: snapshot.totalImpressions,
                ),
                _MetricTile(label: 'Reach', value: snapshot.totalReach),
                _MetricTile(
                  label: 'Engagements',
                  value: snapshot.totalEngagements,
                ),
                _MetricTile(label: 'Clicks', value: snapshot.totalClicks),
                _MetricTile(
                  label: 'Follower Delta',
                  value: snapshot.totalFollowerDelta,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Period comparison: ${snapshot.engagementComparison.deltaValue >= 0 ? '+' : ''}${snapshot.engagementComparison.deltaValue} engagements (${snapshot.engagementComparison.deltaPercent.toStringAsFixed(1)}%).',
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          Text('$value', style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}
