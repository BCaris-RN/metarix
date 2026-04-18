import 'package:flutter/foundation.dart';

import '../../data/metarix_snapshot.dart';
import '../../data/sample_data_pack.dart';
import '../../features/shared/domain/core_models.dart';
import '../../metarix_core/models/model_types.dart';
import 'report_section.dart';

enum ReportExportFormat { pdf, ppt, json }

class ReportController extends ChangeNotifier {
  ReportController({MetarixSnapshot? snapshot})
    : _snapshot = snapshot ?? SampleDataPack.initialSnapshot() {
    _rebuildAssembly();
  }

  final MetarixSnapshot _snapshot;
  late ReportAssembly _assembly;
  String _exportStatus = 'Export not started.';

  ReportAssembly get assembly => _assembly;

  String get exportStatus => _exportStatus;

  Future<void> exportReport(ReportExportFormat format) async {
    _exportStatus =
        '${format.name.toUpperCase()} export is stubbed for now. Use the report schema and UI as the source of truth.';
    notifyListeners();
  }

  void _rebuildAssembly() {
    final sortedSignals = List.of(_snapshot.channelPerformance)
      ..sort((left, right) => right.engagements.compareTo(left.engagements));
    final strongest = sortedSignals.isEmpty ? null : sortedSignals.first;
    final totalImpressions = _snapshot.channelPerformance.fold<int>(
      0,
      (sum, entry) => sum + entry.impressions,
    );
    final totalReach = _snapshot.channelPerformance.fold<int>(
      0,
      (sum, entry) => sum + entry.reach,
    );
    final totalEngagements = _snapshot.channelPerformance.fold<int>(
      0,
      (sum, entry) => sum + entry.engagements,
    );
    final totalClicks = _snapshot.channelPerformance.fold<int>(
      0,
      (sum, entry) => sum + entry.clicks,
    );

    _assembly = ReportAssembly(
      sectionOrder: const [
        ReportSection.successSnapshot,
        ReportSection.platformPerformance,
        ReportSection.standoutResults,
        ReportSection.analysis,
        ReportSection.futureStrategy,
      ],
      successSnapshot: SuccessSnapshot(
        headline: strongest == null
            ? 'No reporting signal available.'
            : '${strongest.channel.label} led the current signal window with ${strongest.engagements} engagements.',
        totalImpressions: totalImpressions,
        totalReach: totalReach,
        totalEngagements: totalEngagements,
        totalClicks: totalClicks,
        totalFollowerDelta: 0,
        engagementComparison: PeriodComparison(
          currentValue: totalEngagements,
          previousValue: 0,
          deltaValue: totalEngagements,
          deltaPercent: 0,
        ),
      ),
      platformSummaries: sortedSignals
          .map(
            (entry) => PlatformPerformanceSummary(
              platform: _platformForChannel(entry.channel),
              impressions: entry.impressions,
              reach: entry.reach,
              engagements: entry.engagements,
              clicks: entry.clicks,
              followerDelta: 0,
              videoViews: 0,
              topContent: TopPerformingContent(
                contentId: _contentTitleForChannel(entry.channel),
                engagements: entry.engagements,
                impressions: entry.impressions,
                clicks: entry.clicks,
              ),
              engagementComparison: PeriodComparison(
                currentValue: entry.engagements,
                previousValue: 0,
                deltaValue: entry.engagements,
                deltaPercent: 0,
              ),
            ),
          )
          .toList(),
      standoutResults: _snapshot.standoutResults
          .map(
            (entry) => StandoutResultItem(
              title: entry.headline,
              summary: entry.detail,
            ),
          )
          .toList(),
      analysis: [
        AnalysisInsight(
          title: 'Signal summary',
          body: _snapshot.successSnapshot,
        ),
        ..._snapshot.takeaways.map(
          (entry) =>
              AnalysisInsight(title: entry.title, body: entry.whatWeLearned),
        ),
      ],
      futureStrategy: _snapshot.futureActions
          .map(
            (entry) => FutureStrategyItem(
              title: entry.title,
              rationale: entry.rationale,
            ),
          )
          .toList(),
      exportMessage:
          'PDF and PPT export are stubbed until live export wiring is added.',
    );
  }

  SocialPlatform _platformForChannel(SocialChannel channel) {
    if (channel == SocialChannel.instagram) {
      return SocialPlatform.instagram;
    }
    if (channel == SocialChannel.facebook) {
      return SocialPlatform.facebook;
    }
    if (channel == SocialChannel.linkedin || channel == SocialChannel.x) {
      return SocialPlatform.linkedin;
    }
    if (channel == SocialChannel.youtube) {
      return SocialPlatform.youtube;
    }
    return SocialPlatform.tiktok;
  }

  String _contentTitleForChannel(SocialChannel channel) {
    final scheduled = _snapshot.scheduledPosts.where(
      (entry) => entry.channel == channel,
    );
    if (scheduled.isNotEmpty) {
      return scheduled.first.title;
    }
    final draft = _snapshot.drafts.where(
      (entry) => entry.targetNetwork == channel,
    );
    if (draft.isNotEmpty) {
      return draft.first.title;
    }
    return '${channel.label} content unit';
  }
}
