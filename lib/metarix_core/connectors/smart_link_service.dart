import '../models/connector_models.dart';
import '../models/smartlink_page.dart';
import 'connector_result.dart';

abstract class SmartLinkService {
  Future<ConnectorResult<SmartlinkPage>> createPage(SmartlinkPage page);

  Future<ConnectorResult<SmartlinkPage>> publishPage(SmartlinkPage page);

  Future<ConnectorResult<SmartLinkClickAttribution>> trackClick(
    String pageId,
    String blockId, {
    Uri? referrer,
  });

  Future<ConnectorResult<SmartLinkStats>> getPageStats(String pageId);
}
