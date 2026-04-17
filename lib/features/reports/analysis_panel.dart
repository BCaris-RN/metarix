import 'package:flutter/material.dart';

import 'report_section.dart';

class AnalysisPanel extends StatelessWidget {
  const AnalysisPanel({super.key, required this.insights});

  final List<AnalysisInsight> insights;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ReportSection.analysis.label,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...insights.map(
              (insight) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(insight.body),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
