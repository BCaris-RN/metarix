import 'package:flutter/material.dart';

import 'report_section.dart';

class FutureStrategyPanel extends StatelessWidget {
  const FutureStrategyPanel({super.key, required this.items});

  final List<FutureStrategyItem> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ReportSection.futureStrategy.label,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.title),
                subtitle: Text(item.rationale),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
