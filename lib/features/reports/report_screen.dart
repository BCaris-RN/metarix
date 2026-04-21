import 'package:flutter/material.dart';

import 'analysis_panel.dart';
import 'future_strategy_panel.dart';
import 'platform_performance_panel.dart';
import 'report_controller.dart';
import 'report_section.dart';
import 'standout_results_panel.dart';
import 'success_snapshot_card.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key, required this.controller});

  final ReportController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final assembly = controller.assembly;
        return Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Reports',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  FilledButton(
                    onPressed: () =>
                        controller.exportReport(ReportExportFormat.pdf),
                    child: const Text('Export PDF'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () =>
                        controller.exportReport(ReportExportFormat.ppt),
                    child: const Text('Export PPT'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(controller.exportStatus),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: assembly.sectionOrder
                    .map((section) => Chip(label: Text(section.label)))
                    .toList(),
              ),
              const SizedBox(height: 16),
              SuccessSnapshotCard(snapshot: assembly.successSnapshot),
              const SizedBox(height: 16),
              PlatformPerformancePanel(summaries: assembly.platformSummaries),
              const SizedBox(height: 16),
              StandoutResultsPanel(results: assembly.standoutResults),
              const SizedBox(height: 16),
              AnalysisPanel(insights: assembly.analysis),
              const SizedBox(height: 16),
              FutureStrategyPanel(items: assembly.futureStrategy),
            ],
          ),
        );
      },
    );
  }
}
