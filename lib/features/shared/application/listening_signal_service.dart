import '../../../data/local_metarix_gateway.dart';
import '../../listening/domain/listening_models.dart';
import '../../shared/domain/signal_summary.dart';

class ListeningSignalService {
  const ListeningSignalService(this._gateway);

  final LocalMetarixGateway _gateway;

  SignalSummary workspaceSignal() {
    return signalForQuery(null);
  }

  SignalSummary signalForQuery(String? queryId) {
    final query = queryId == null
        ? null
        : _gateway.snapshot.listeningQueries.firstWhere(
            (entry) => entry.id == queryId,
          );
    final mentions = query == null
        ? _gateway.snapshot.mentions
        : _gateway.snapshot.mentions
              .where((entry) => entry.queryId == query.id)
              .toList();
    final spikes = query == null
        ? _gateway.snapshot.spikes
        : _gateway.snapshot.spikes
              .where((entry) => entry.queryId == query.id)
              .toList();
    final competitorWatch = query == null || query.targetCompetitors.isEmpty
        ? _gateway.snapshot.competitorWatch
        : _gateway.snapshot.competitorWatch
              .where(
                (entry) =>
                    query.targetCompetitors.contains(entry.competitorName),
              )
              .toList();

    return SignalSummary(
      scopeId: query?.id ?? 'workspace-listening',
      scopeLabel: query?.name ?? 'Workspace listening',
      mentionWatch: MentionWatchSummary(
        mentionCount: mentions.length,
        spikeCount: spikes.length,
        actionQueueCount: mentions
            .where((entry) => entry.recommendedAction != InsightAction.observe)
            .length,
        competitorWatchCount: competitorWatch.length,
        topWatchLabel: _topWatchLabel(spikes, competitorWatch, mentions),
      ),
      sentimentBucket: _sentimentBucket(
        workspaceScope: query == null,
        mentions: mentions,
      ),
    );
  }

  StatusBucketSummary _sentimentBucket({
    required bool workspaceScope,
    required List<Mention> mentions,
  }) {
    final counts = workspaceScope
        ? <String, int>{
            'Positive': _gateway.snapshot.sentimentSummary.positive,
            'Mixed': _gateway.snapshot.sentimentSummary.mixed,
            'Negative': _gateway.snapshot.sentimentSummary.negative,
          }
        : <String, int>{'Positive': 0, 'Mixed': 0, 'Negative': 0};

    if (!workspaceScope) {
      for (final mention in mentions) {
        final label = _normalizeSentimentLabel(mention.sentimentLabel);
        counts[label] = (counts[label] ?? 0) + 1;
      }
    }

    final ordered = counts.entries.toList()
      ..sort((left, right) => right.value.compareTo(left.value));
    final leader = ordered.first;
    return StatusBucketSummary(
      label: leader.key,
      count: leader.value,
      description:
          '${leader.value} listening records are in the ${leader.key.toLowerCase()} bucket.',
    );
  }

  String _topWatchLabel(
    List<SpikeEvent> spikes,
    List<CompetitorWatchEntry> competitorWatch,
    List<Mention> mentions,
  ) {
    if (spikes.isNotEmpty) {
      return spikes.first.headline;
    }
    if (competitorWatch.isNotEmpty) {
      final ordered = List<CompetitorWatchEntry>.from(
        competitorWatch,
      )..sort((left, right) => right.shareOfVoice.compareTo(left.shareOfVoice));
      return ordered.first.competitorName;
    }
    if (mentions.isNotEmpty) {
      return mentions.first.source;
    }
    return 'No active watch signal';
  }

  String _normalizeSentimentLabel(String value) {
    switch (value.toLowerCase()) {
      case 'positive':
        return 'Positive';
      case 'negative':
        return 'Negative';
      default:
        return 'Mixed';
    }
  }
}
