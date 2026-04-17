import 'package:flutter_test/flutter_test.dart';

import 'package:metarix/metarix_core/connectors/connector_capability.dart';
import 'package:metarix/metarix_core/connectors/platform_capability_catalog.dart';
import 'package:metarix/metarix_core/models/model_types.dart';

void main() {
  test(
    'instagram catalog includes publishing, metrics, comments, and mentions',
    () {
      final profile = PlatformCapabilityCatalog.forPlatform(
        SocialPlatform.instagram,
      );

      expect(profile.supports(ConnectorCapability.canPublishNow), isTrue);
      expect(
        profile.supports(ConnectorCapability.canReadAccountMetrics),
        isTrue,
      );
      expect(profile.supports(ConnectorCapability.canReadPostMetrics), isTrue);
      expect(profile.supports(ConnectorCapability.canReadComments), isTrue);
      expect(profile.supports(ConnectorCapability.canReplyToComments), isTrue);
      expect(
        profile.supports(ConnectorCapability.canRunNativeListening),
        isTrue,
      );
      expect(profile.supportedPublishFormats, contains('reel'));
      expect(profile.supportedPublishFormats, contains('carousel'));
    },
  );

  test('tiktok catalog models draft and direct posting constraints', () {
    final profile = PlatformCapabilityCatalog.forPlatform(
      SocialPlatform.tiktok,
    );

    expect(profile.supports(ConnectorCapability.canPublishNow), isTrue);
    expect(
      profile.supports(ConnectorCapability.requiresMediaUploadHostVerification),
      isTrue,
    );
    expect(
      profile.supports(ConnectorCapability.hasQuotaSensitiveUpload),
      isTrue,
    );
    expect(profile.supportedPublishFormats, contains('draft upload'));
    expect(profile.supportedPublishFormats, contains('direct video post'));
  });

  test('youtube catalog includes upload, analytics, and comments', () {
    final profile = PlatformCapabilityCatalog.forPlatform(
      SocialPlatform.youtube,
    );

    expect(profile.supports(ConnectorCapability.canPublishNow), isTrue);
    expect(
      profile.supports(ConnectorCapability.canScheduleViaConnector),
      isTrue,
    );
    expect(profile.supports(ConnectorCapability.canReadPostMetrics), isTrue);
    expect(profile.supports(ConnectorCapability.canReadComments), isTrue);
    expect(profile.supports(ConnectorCapability.canReplyToComments), isTrue);
    expect(profile.supportedPublishFormats, contains('video upload'));
  });
}
