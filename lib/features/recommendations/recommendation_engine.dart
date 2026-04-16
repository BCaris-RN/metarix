import '../listening/domain/listening_models.dart';
import '../planning/domain/planning_models.dart';
import '../reports/domain/metric_family.dart';
import '../reports/domain/normalized_metric_record.dart';
import '../strategy/domain/strategy_models.dart';
import '../workflow/domain/workflow_models.dart';
import 'domain/recommendation_model.dart';

class RecommendationEngine {
  const RecommendationEngine();

  List<RecommendationInsight> generate({
    required String reportPeriodId,
    required List<NormalizedMetricRecord> metrics,
    required List<Campaign> campaigns,
    required List<PostDraft> drafts,
    required List<ContentPillar> pillars,
    required List<Mention> mentions,
    required List<SpikeEvent> spikes,
  }) {
    final reportMetrics =
        metrics.where((entry) => entry.reportPeriodId == reportPeriodId).toList();
    if (reportMetrics.isEmpty) {
      return const [];
    }

    final metricsByChannel = <String, List<NormalizedMetricRecord>>{};
    for (final metric in reportMetrics) {
      metricsByChannel.putIfAbsent(metric.channel.name, () => []).add(metric);
    }

    final bestChannelEntry = metricsByChannel.entries.reduce((left, right) {
      double score(List<NormalizedMetricRecord> records) {
        final engagement = _metricValue(records, MetricFamily.engagement);
        final reach = _metricValue(records, MetricFamily.reach);
        return reach == 0 ? 0 : engagement / reach;
      }

      return score(left.value) >= score(right.value) ? left : right;
    });

    final underperformingChannelEntry =
        metricsByChannel.entries.reduce((left, right) {
      double score(List<NormalizedMetricRecord> records) {
        final clicks = _metricValue(records, MetricFamily.clicks);
        final impressions = _metricValue(records, MetricFamily.impressions);
        return impressions == 0 ? 0 : clicks / impressions;
      }

      return score(left.value) <= score(right.value) ? left : right;
    });

    final cadenceDraft = drafts
        .where(
          (draft) =>
              draft.targetNetwork.name == bestChannelEntry.key &&
              draft.plannedPublishAt != null,
        )
        .fold<PostDraft?>(null, (best, draft) {
      if (best == null || draft.plannedPublishAt!.hour < best.plannedPublishAt!.hour) {
        return draft;
      }
      return best;
    });

    final pillarCampaignCounts = <String, int>{};
    for (final campaign in campaigns) {
      pillarCampaignCounts.update(
        campaign.contentPillarId,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    String? bestPillarId;
    if (pillarCampaignCounts.isNotEmpty) {
      bestPillarId = pillarCampaignCounts.entries.reduce(
        (left, right) => left.value >= right.value ? left : right,
      ).key;
    }
    ContentPillar? bestPillar;
    for (final pillar in pillars) {
      if (pillar.id == bestPillarId) {
        bestPillar = pillar;
      }
    }

    final criticalSpike = spikes.fold<SpikeEvent?>(
      null,
      (best, spike) =>
          best == null || spike.mentionCount > best.mentionCount ? spike : best,
    );

    return [
      RecommendationInsight(
        id: 'rec-$reportPeriodId-cadence',
        reportPeriodId: reportPeriodId,
        type: RecommendationType.cadenceAdjustment,
        title: 'Favor ${bestChannelEntry.key} early-day posting windows',
        rationale:
            'The strongest engagement-to-reach ratio came from ${bestChannelEntry.key}, and the highest-performing scheduled draft on that channel was planned around ${cadenceDraft?.plannedPublishAt?.hour ?? 10}:00.',
        sourceReferences: [
          'engagement/reach ratio on ${bestChannelEntry.key}',
          if (cadenceDraft != null) cadenceDraft.title,
        ],
        assignedTo: 'Strategy team',
      ),
      RecommendationInsight(
        id: 'rec-$reportPeriodId-pillar',
        reportPeriodId: reportPeriodId,
        type: RecommendationType.contentShift,
        title: 'Increase ${bestPillar?.name ?? 'proof-led'} content emphasis',
        rationale:
            'Current campaign mix and click volume indicate the ${bestPillar?.name ?? 'leading'} pillar has the clearest commercial pull for this period.',
        sourceReferences: [
          if (bestPillar != null) bestPillar.name,
          '${campaigns.length} active campaigns linked to pillar performance',
        ],
        assignedTo: 'Content team',
      ),
      RecommendationInsight(
        id: 'rec-$reportPeriodId-channel',
        reportPeriodId: reportPeriodId,
        type: RecommendationType.channelFocus,
        title: 'Address ${underperformingChannelEntry.key} underperformance',
        rationale:
            '${underperformingChannelEntry.key} delivered the weakest click-through efficiency, and listening signals show ${criticalSpike?.headline ?? 'a competitor spike'} that can be converted into a response plan.',
        sourceReferences: [
          'click/impression ratio on ${underperformingChannelEntry.key}',
          if (criticalSpike != null) criticalSpike.headline,
          if (mentions.isNotEmpty) mentions.first.excerpt,
        ],
        assignedTo: 'Analytics team',
      ),
    ];
  }

  double _metricValue(
    List<NormalizedMetricRecord> records,
    MetricFamily family,
  ) {
    return records
        .where((entry) => entry.family == family)
        .fold<double>(0, (sum, entry) => sum + entry.value);
  }
}
