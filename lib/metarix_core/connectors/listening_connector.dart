import '../models/connector_models.dart';
import '../models/model_types.dart';
import 'connector_result.dart';

abstract class ListeningConnector {
  SocialPlatform get platform;

  Future<ConnectorResult<List<ListeningMentionRecord>>> runWatchQuery(
    String watchTermId,
  );

  Future<ConnectorResult<List<ListeningMentionRecord>>> syncMentions({
    String? accountId,
  });

  Future<ConnectorResult<ListeningSpikeSignal>> detectSpike(String watchTermId);
}
