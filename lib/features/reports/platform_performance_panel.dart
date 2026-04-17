import 'package:flutter/material.dart';

import '../../metarix_core/models/model_types.dart';
import 'report_section.dart';

class PlatformPerformancePanel extends StatelessWidget {
  const PlatformPerformancePanel({super.key, required this.summaries});

  final List<PlatformPerformanceSummary> summaries;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ReportSection.platformPerformance.label,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...summaries.map(
              (summary) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.platform.label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Impressions ${summary.impressions}  Reach ${summary.reach}  Engagements ${summary.engagements}  Clicks ${summary.clicks}',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Period change ${summary.engagementComparison.deltaValue >= 0 ? '+' : ''}${summary.engagementComparison.deltaValue} engagements (${summary.engagementComparison.deltaPercent.toStringAsFixed(1)}%)',
                      ),
                      if (summary.topContent != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Top content ${summary.topContent!.contentId} with ${summary.topContent!.engagements} engagements',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
