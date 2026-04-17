import 'package:flutter/foundation.dart';

import '../../metarix_core/models/metric_snapshot.dart';
import '../../metarix_core/models/model_types.dart';
import 'report_assembly_service.dart';
import 'report_section.dart';

enum ReportExportFormat { pdf, ppt, json }

class ReportController extends ChangeNotifier {
  ReportController({
    ReportAssemblyService? assemblyService,
    List<MetricSnapshot>? currentMetrics,
    List<MetricSnapshot>? previousMetrics,
    List<String>? notableInsights,
  }) : _assemblyService = assemblyService ?? const ReportAssemblyService(),
       _currentMetrics = List<MetricSnapshot>.from(
         currentMetrics ?? _demoCurrentMetrics,
       ),
       _previousMetrics = List<MetricSnapshot>.from(
         previousMetrics ?? _demoPreviousMetrics,
       ),
       _notableInsights = List<String>.from(notableInsights ?? _demoInsights) {
    _rebuildAssembly();
  }

  final ReportAssemblyService _assemblyService;
  List<MetricSnapshot> _currentMetrics;
  List<MetricSnapshot> _previousMetrics;
  List<String> _notableInsights;
  late ReportAssembly _assembly;
  String _exportStatus = 'Export not started.';

  ReportAssembly get assembly => _assembly;

  String get exportStatus => _exportStatus;

  void updateMetrics({
    required List<MetricSnapshot> currentMetrics,
    required List<MetricSnapshot> previousMetrics,
    required List<String> notableInsights,
  }) {
    _currentMetrics = List<MetricSnapshot>.from(currentMetrics);
    _previousMetrics = List<MetricSnapshot>.from(previousMetrics);
    _notableInsights = List<String>.from(notableInsights);
    _rebuildAssembly();
    notifyListeners();
  }

  Future<void> exportReport(ReportExportFormat format) async {
    _exportStatus =
        '${format.name.toUpperCase()} export is stubbed for now. Use the report schema and UI as the source of truth.';
    notifyListeners();
  }

  void _rebuildAssembly() {
    _assembly = _assemblyService.assemble(
      currentMetrics: _currentMetrics,
      previousMetrics: _previousMetrics,
      notableInsights: _notableInsights,
    );
  }

  static final List<MetricSnapshot> _demoCurrentMetrics = [
    MetricSnapshot(
      snapshotId: 'curr-ig-1',
      platform: SocialPlatform.instagram,
      accountId: 'acct-ig',
      contentId: 'content-ig-launch',
      periodStart: DateTime.utc(2026, 4, 1),
      periodEnd: DateTime.utc(2026, 4, 15),
      impressions: 18000,
      reach: 12000,
      engagements: 1450,
      clicks: 210,
      followerDelta: 42,
      videoViews: 5200,
      saves: 90,
      shares: 40,
      comments: 34,
      likes: 1286,
    ),
    MetricSnapshot(
      snapshotId: 'curr-li-1',
      platform: SocialPlatform.linkedin,
      accountId: 'acct-li',
      contentId: 'content-li-essay',
      periodStart: DateTime.utc(2026, 4, 1),
      periodEnd: DateTime.utc(2026, 4, 15),
      impressions: 9600,
      reach: 7100,
      engagements: 860,
      clicks: 265,
      followerDelta: 25,
      videoViews: 0,
      saves: 24,
      shares: 33,
      comments: 49,
      likes: 754,
    ),
    MetricSnapshot(
      snapshotId: 'curr-tt-1',
      platform: SocialPlatform.tiktok,
      accountId: 'acct-tt',
      contentId: 'content-tt-pulse',
      periodStart: DateTime.utc(2026, 4, 1),
      periodEnd: DateTime.utc(2026, 4, 15),
      impressions: 22100,
      reach: 17050,
      engagements: 1320,
      clicks: 118,
      followerDelta: 67,
      videoViews: 14040,
      saves: 61,
      shares: 77,
      comments: 48,
      likes: 1134,
    ),
  ];

  static final List<MetricSnapshot> _demoPreviousMetrics = [
    MetricSnapshot(
      snapshotId: 'prev-ig-1',
      platform: SocialPlatform.instagram,
      accountId: 'acct-ig',
      contentId: 'content-ig-older',
      periodStart: DateTime.utc(2026, 3, 16),
      periodEnd: DateTime.utc(2026, 3, 31),
      impressions: 15000,
      reach: 10100,
      engagements: 1210,
      clicks: 180,
      followerDelta: 31,
      videoViews: 4300,
      saves: 71,
      shares: 32,
      comments: 25,
      likes: 1082,
    ),
    MetricSnapshot(
      snapshotId: 'prev-li-1',
      platform: SocialPlatform.linkedin,
      accountId: 'acct-li',
      contentId: 'content-li-older',
      periodStart: DateTime.utc(2026, 3, 16),
      periodEnd: DateTime.utc(2026, 3, 31),
      impressions: 8800,
      reach: 6450,
      engagements: 740,
      clicks: 230,
      followerDelta: 20,
      videoViews: 0,
      saves: 16,
      shares: 28,
      comments: 39,
      likes: 657,
    ),
    MetricSnapshot(
      snapshotId: 'prev-tt-1',
      platform: SocialPlatform.tiktok,
      accountId: 'acct-tt',
      contentId: 'content-tt-older',
      periodStart: DateTime.utc(2026, 3, 16),
      periodEnd: DateTime.utc(2026, 3, 31),
      impressions: 19050,
      reach: 15020,
      engagements: 1110,
      clicks: 96,
      followerDelta: 49,
      videoViews: 12200,
      saves: 54,
      shares: 59,
      comments: 35,
      likes: 962,
    ),
  ];

  static const List<String> _demoInsights = [
    'Carousel explainers converted especially well on LinkedIn when the first card led with an opinion.',
    'Short-form edits on TikTok created the strongest follower lift when the hook landed in the first two seconds.',
  ];
}
