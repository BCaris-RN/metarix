// Chunk 6 — Fix unavailable LinkedIn connector imports + conversation connector
// File: lib/metarix_core/connectors/unavailable/unavailable_linkedin_connectors.dart

import '../../models/connected_account.dart';
import '../../models/connector_models.dart';
import '../../models/content_item.dart';
import '../../models/metric_snapshot.dart';
import '../../models/model_types.dart';
import '../account_connector.dart';
import '../analytics_connector.dart';
import '../connector_result.dart';
import '../conversation_connector.dart';
import '../listening_connector.dart';
import '../publish_connector.dart';

const String _linkedinUnavailableMessage =
    'LinkedIn is not configured or cut over yet. '
    'This path is intentionally unavailable until real connector setup is complete.';

class UnavailableLinkedInAccountConnector implements AccountConnector {
  const UnavailableLinkedInAccountConnector();

  @override
  SocialPlatform get platform => SocialPlatform.linkedin;

  @override
  Future<ConnectorResult<AccountConnectionSession>> startConnection(
    AccountConnectionRequest request,
  ) async {
    return const ConnectorResult<AccountConnectionSession>.failure(
      error: _linkedinUnavailableMessage,
    );
  }

  @override
  Future<ConnectorResult<ConnectedAccount>> completeConnection({
    required String state,
    required Uri callbackUri,
  }) async {
    return const ConnectorResult<ConnectedAccount>.failure(
      error: _linkedinUnavailableMessage,
    );
  }

  @override
  Future<ConnectorResult<List<ConnectedAccount>>> listAccounts() async {
    return const ConnectorResult<List<ConnectedAccount>>.success(
      value: <ConnectedAccount>[],
      message: _linkedinUnavailableMessage,
    );
  }

  @override
  Future<ConnectorResult<ConnectedAccount>> getAccount(String accountId) async {
    return const ConnectorResult<ConnectedAccount>.failure(
      error: _linkedinUnavailableMessage,
    );
  }

  @override
  Future<ConnectorResult<ConnectedAccount>> refreshAccount(
    String accountId,
  ) async {
    return const ConnectorResult<ConnectedAccount>.failure(
      error: _linkedinUnavailableMessage,
    );
  }

  @override
  Future<ConnectorResult<bool>> disconnectAccount(String accountId) async {
    return const ConnectorResult<bool>.failure(
      error: _linkedinUnavailableMessage,
    );
  }
}

class UnavailableLinkedInAnalyticsConnector implements AnalyticsConnector {
  const UnavailableLinkedInAnalyticsConnector();

  @override
  SocialPlatform get platform => SocialPlatform.linkedin;

  @override
  Future<ConnectorResult<List<MetricSnapshot>>> syncAccountMetrics(
    String accountId, {
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    return const ConnectorResult<List<MetricSnapshot>>.failure(
      error: _linkedinUnavailableMessage,
    );
  }

  @override
  Future<ConnectorResult<List<MetricSnapshot>>> syncPostMetrics(
    String contentId, {
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    return const ConnectorResult<List<MetricSnapshot>>.failure(
      error: _linkedinUnavailableMessage,
    );
  }

  @override
  Future<ConnectorResult<AccountAnalyticsSummary>> getAccountSummary(
    String accountId,
  ) async {
    return const ConnectorResult<AccountAnalyticsSummary>.failure(
      error: _linkedinUnavailableMessage,
    );
  }
}

class UnavailableLinkedInPublishConnector implements PublishConnector {
  const UnavailableLinkedInPublishConnector();

  @override
  SocialPlatform get platform => SocialPlatform.linkedin;

  @override
  Future<ConnectorResult<PublishValidation>> validatePost(
    ContentItem content,
  ) async {
    return ConnectorResult<PublishValidation>.success(
      value: PublishValidation(
        content: content,
        isValid: false,
        errors: const <String>[_linkedinUnavailableMessage],
        warnings: const <String>[],
      ),
      message: _linkedinUnavailableMessage,
    );
  }

  @override
  Future<ConnectorResult<PublishReceipt>> schedulePost(
    ContentItem content, {
    required String accountId,
  }) async {
    return const ConnectorResult<PublishReceipt>.failure(
      error: _linkedinUnavailableMessage,
    );
  }

  @override
  Future<ConnectorResult<PublishReceipt>> publishNow(
    ContentItem content, {
    required String accountId,
  }) async {
    return const ConnectorResult<PublishReceipt>.failure(
      error: _linkedinUnavailableMessage,
    );
  }

  @override
  Future<ConnectorResult<PublishReceipt>> getPublishStatus(
    String publishJobId,
  ) async {
    return const ConnectorResult<PublishReceipt>.failure(
      error: _linkedinUnavailableMessage,
    );
  }
}

class UnavailableLinkedInListeningConnector implements ListeningConnector {
  const UnavailableLinkedInListeningConnector();

  @override
  SocialPlatform get platform => SocialPlatform.linkedin;

  @override
  Future<ConnectorResult<List<ListeningMentionRecord>>> runWatchQuery(
    String watchTermId,
  ) async {
    return const ConnectorResult<List<ListeningMentionRecord>>.failure(
      error: _linkedinUnavailableMessage,
    );
  }

  @override
  Future<ConnectorResult<List<ListeningMentionRecord>>> syncMentions({
    String? accountId,
  }) async {
    return const ConnectorResult<List<ListeningMentionRecord>>.failure(
      error: _linkedinUnavailableMessage,
    );
  }

  @override
  Future<ConnectorResult<ListeningSpikeSignal>> detectSpike(
    String watchTermId,
  ) async {
    return const ConnectorResult<ListeningSpikeSignal>.failure(
      error: _linkedinUnavailableMessage,
    );
  }
}

class UnavailableLinkedInConversationConnector
    implements ConversationConnector {
  const UnavailableLinkedInConversationConnector();

  @override
  SocialPlatform get platform => SocialPlatform.linkedin;

  @override
  Future<ConnectorResult<List<ConversationThread>>> syncThreads({
    required String accountId,
  }) async {
    return const ConnectorResult<List<ConversationThread>>.failure(
      error: _linkedinUnavailableMessage,
    );
  }

  @override
  Future<ConnectorResult<List<ConversationMessage>>> syncComments({
    required String threadId,
  }) async {
    return const ConnectorResult<List<ConversationMessage>>.failure(
      error: _linkedinUnavailableMessage,
    );
  }

  @override
  Future<ConnectorResult<ConversationMessage>> replyToComment({
    required String threadId,
    required String commentId,
    required String message,
  }) async {
    return const ConnectorResult<ConversationMessage>.failure(
      error: _linkedinUnavailableMessage,
    );
  }

  @override
  Future<ConnectorResult<ConversationThread>> markHandled(
    String threadId,
  ) async {
    return const ConnectorResult<ConversationThread>.failure(
      error: _linkedinUnavailableMessage,
    );
  }
}
