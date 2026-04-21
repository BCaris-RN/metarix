import 'package:flutter/foundation.dart';

import '../shared/domain/core_models.dart';
import '../shared/domain/signal_summary.dart';
import 'domain/report_models.dart';
import '../../metarix_core/models/model_types.dart';
import 'report_section.dart';

enum ReportExportFormat { pdf, ppt, json }

class ReportController extends ChangeNotifier {
  ReportController({required ReportSnapshot snapshot}) : _snapshot = snapshot {
    _rebuildAssembly();
  }

  final ReportSnapshot _snapshot;
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
    final activePeriodId = _snapshot.activePeriodId;
    final signalSummary = _snapshot.signalSummaryFor(activePeriodId);
    final engagement = signalSummary.engagement;
    final sortedSignals =
        _snapshot.channelPerformance
            .where((entry) => entry.reportPeriodId == activePeriodId)
            .toList()
          ..sort(
            (left, right) => right.engagements.compareTo(left.engagements),
          );
    final comparisonPeriodId =
        _snapshot.comparisonPeriods[activePeriodId] ?? activePeriodId;
    final comparisonByChannel = {
      for (final record in _snapshot.channelPerformance.where(
        (entry) => entry.reportPeriodId == comparisonPeriodId,
      ))
        record.channel: record,
    };
    final topContentByChannel = <String, TopContentUnitSummary>{
      for (final entry in signalSummary.topContentUnits)
        entry.channelLabel: entry,
    };
    final totalEngagements = engagement?.totalEngagements ?? 0;
    final previousEngagements = engagement == null
        ? 0
        : totalEngagements - engagement.comparisonDelta;

    _assembly = ReportAssembly(
      sectionOrder: const [
        ReportSection.successSnapshot,
        ReportSection.platformPerformance,
        ReportSection.standoutResults,
        ReportSection.analysis,
        ReportSection.futureStrategy,
      ],
      successSnapshot: SuccessSnapshot(
        headline: engagement == null
            ? 'No reporting signal available.'
            : '${engagement.topChannelLabel} led the current signal window with ${engagement.totalEngagements} engagements.',
        totalImpressions: engagement?.totalImpressions ?? 0,
        totalReach: engagement?.totalReach ?? 0,
        totalEngagements: totalEngagements,
        totalClicks: engagement?.totalClicks ?? 0,
        totalFollowerDelta: 0,
        engagementComparison: _comparison(
          totalEngagements,
          previousEngagements,
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
              topContent: _topContentFor(
                entry.channel,
                topContentByChannel,
                entry.impressions,
              ),
              engagementComparison: _comparison(
                entry.engagements,
                comparisonByChannel[entry.channel]?.engagements ?? 0,
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

  TopPerformingContent? _topContentFor(
    SocialChannel channel,
    Map<String, TopContentUnitSummary> topContentByChannel,
    int impressions,
  ) {
    final topContent = topContentByChannel[channel.label];
    if (topContent == null) {
      return null;
    }
    return TopPerformingContent(
      contentId: topContent.title,
      engagements: topContent.engagements,
      impressions: impressions,
      clicks: topContent.clicks,
    );
  }

  PeriodComparison _comparison(int currentValue, int previousValue) {
    final deltaValue = currentValue - previousValue;
    final deltaPercent = previousValue == 0
        ? 0.0
        : (deltaValue / previousValue) * 100;
    return PeriodComparison(
      currentValue: currentValue,
      previousValue: previousValue,
      deltaValue: deltaValue,
      deltaPercent: deltaPercent,
    );
  }
}
