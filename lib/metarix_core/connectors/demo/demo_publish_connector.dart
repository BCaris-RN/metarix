import '../../models/content_item.dart';
import '../../models/connector_models.dart';
import '../../models/model_types.dart';
import '../connector_result.dart';
import '../publish_connector.dart';

class DemoPublishConnector implements PublishConnector {
  const DemoPublishConnector(this.platform);

  @override
  final SocialPlatform platform;

  @override
  Future<ConnectorResult<PublishValidation>> validatePost(
    ContentItem content,
  ) async {
    return ConnectorResult.success(
      value: PublishValidation(
        content: content,
        isValid: true,
        errors: const [],
        warnings: content.targetPlatforms.contains(platform)
            ? const []
            : ['Content item does not target ${platform.label}.'],
      ),
    );
  }

  @override
  Future<ConnectorResult<PublishReceipt>> schedulePost(
    ContentItem content, {
    required String accountId,
  }) async {
    return ConnectorResult.success(
      value: _receipt(
        content: content,
        accountId: accountId,
        status: PublishExecutionStatus.queued,
        remoteId: 'demo-job-${content.contentId}',
        message: 'Demo schedule queued.',
      ),
    );
  }

  @override
  Future<ConnectorResult<PublishReceipt>> publishNow(
    ContentItem content, {
    required String accountId,
  }) async {
    return ConnectorResult.success(
      value: _receipt(
        content: content,
        accountId: accountId,
        status: PublishExecutionStatus.succeeded,
        remoteId: 'demo-post-${content.contentId}',
        message: 'Demo publish completed.',
      ),
    );
  }

  @override
  Future<ConnectorResult<PublishReceipt>> getPublishStatus(
    String publishJobId,
  ) async {
    return ConnectorResult.success(
      value: PublishReceipt(
        platform: platform,
        accountId: 'demo-${platform.name}-account',
        contentId: publishJobId.replaceFirst('demo-job-', ''),
        status: PublishExecutionStatus.queued,
        remoteId: publishJobId,
        message: 'Demo publish job is queued.',
        checkedAt: DateTime.now(),
      ),
    );
  }

  PublishReceipt _receipt({
    required ContentItem content,
    required String accountId,
    required PublishExecutionStatus status,
    required String remoteId,
    required String message,
  }) {
    return PublishReceipt(
      platform: platform,
      accountId: accountId,
      contentId: content.contentId,
      status: status,
      remoteId: remoteId,
      message: message,
      checkedAt: DateTime.now(),
    );
  }
}
