import '../../models/connector_models.dart';
import '../../models/model_types.dart';
import '../connector_result.dart';
import '../listening_connector.dart';

class DemoListeningConnector implements ListeningConnector {
  const DemoListeningConnector(this.platform);

  @override
  final SocialPlatform platform;

  @override
  Future<ConnectorResult<List<ListeningMentionRecord>>> runWatchQuery(
    String watchTermId,
  ) async {
    return ConnectorResult.success(value: [_mention(watchTermId)]);
  }

  @override
  Future<ConnectorResult<List<ListeningMentionRecord>>> syncMentions({
    String? accountId,
  }) async {
    return ConnectorResult.success(value: [_mention('demo-watch-term')]);
  }

  @override
  Future<ConnectorResult<ListeningSpikeSignal>> detectSpike(
    String watchTermId,
  ) async {
    return ConnectorResult.success(
      value: ListeningSpikeSignal(
        watchTermId: watchTermId,
        platform: platform,
        baselineMentions: 12,
        currentMentions: 19 + platform.index,
        percentChange: 0.58 + platform.index * 0.03,
        detectedAt: DateTime.now(),
      ),
    );
  }

  ListeningMentionRecord _mention(String watchTermId) {
    return ListeningMentionRecord(
      mentionId: 'demo-${platform.name}-$watchTermId',
      platform: platform,
      watchTermId: watchTermId,
      authorHandle: '@market_voice',
      text: 'Demo mention for ${platform.label}.',
      sentimentLabel: 'positive',
      sourceUrl: Uri.parse('https://demo.metarix.local/${platform.name}'),
      observedAt: DateTime.now().subtract(const Duration(hours: 1)),
    );
  }
}
