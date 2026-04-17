import '../../models/connector_models.dart';
import '../../models/smartlink_page.dart';
import '../connector_result.dart';
import '../smart_link_service.dart';

class DemoSmartLinkService implements SmartLinkService {
  const DemoSmartLinkService();

  @override
  Future<ConnectorResult<SmartlinkPage>> createPage(SmartlinkPage page) async {
    return ConnectorResult.success(value: page);
  }

  @override
  Future<ConnectorResult<SmartlinkPage>> publishPage(SmartlinkPage page) async {
    return ConnectorResult.success(value: page);
  }

  @override
  Future<ConnectorResult<SmartLinkClickAttribution>> trackClick(
    String pageId,
    String blockId, {
    Uri? referrer,
  }) async {
    return ConnectorResult.success(
      value: SmartLinkClickAttribution(
        pageId: pageId,
        blockId: blockId,
        referrer: referrer,
        sourcePlatform: null,
        clickCount: 1,
        recordedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<ConnectorResult<SmartLinkStats>> getPageStats(String pageId) async {
    final now = DateTime.now();
    final page = SmartlinkPage(
      pageId: pageId,
      slug: 'demo-link',
      title: 'Demo Smart Link',
      heroText: 'Public-safe demo attribution page.',
      themeKey: 'demo',
      blocks: const [],
      updatedAt: now,
    );
    return ConnectorResult.success(
      value: SmartLinkStats(
        page: page,
        views: 240,
        clicks: 73,
        uniqueVisitors: 181,
        topSources: const {'instagram': 41, 'linkedin': 22, 'facebook': 10},
        updatedAt: now,
      ),
    );
  }
}
