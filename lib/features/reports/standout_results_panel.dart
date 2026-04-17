import 'package:flutter/material.dart';

import 'report_section.dart';

class StandoutResultsPanel extends StatelessWidget {
  const StandoutResultsPanel({super.key, required this.results});

  final List<StandoutResultItem> results;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ReportSection.standoutResults.label,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...results.map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.title),
                subtitle: Text(item.summary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
