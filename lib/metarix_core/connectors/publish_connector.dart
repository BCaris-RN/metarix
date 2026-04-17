import '../models/content_item.dart';
import '../models/connector_models.dart';
import '../models/model_types.dart';
import 'connector_result.dart';

abstract class PublishConnector {
  SocialPlatform get platform;

  Future<ConnectorResult<PublishValidation>> validatePost(ContentItem content);

  Future<ConnectorResult<PublishReceipt>> schedulePost(
    ContentItem content, {
    required String accountId,
  });

  Future<ConnectorResult<PublishReceipt>> publishNow(
    ContentItem content, {
    required String accountId,
  });

  Future<ConnectorResult<PublishReceipt>> getPublishStatus(String publishJobId);
}
