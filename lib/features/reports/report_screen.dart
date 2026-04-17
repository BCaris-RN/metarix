import 'package:flutter/material.dart';

import 'analysis_panel.dart';
import 'future_strategy_panel.dart';
import 'platform_performance_panel.dart';
import 'report_controller.dart';
import 'report_section.dart';
import 'standout_results_panel.dart';
import 'success_snapshot_card.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key, this.controller});

  final ReportController? controller;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late final ReportController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? ReportController();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final assembly = _controller.assembly;
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
                        _controller.exportReport(ReportExportFormat.pdf),
                    child: const Text('Export PDF'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () =>
                        _controller.exportReport(ReportExportFormat.ppt),
                    child: const Text('Export PPT'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(_controller.exportStatus),
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
