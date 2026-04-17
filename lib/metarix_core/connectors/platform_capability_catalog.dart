import '../models/model_types.dart';
import 'connector_capability.dart';

class PlatformCapabilityProfile {
  const PlatformCapabilityProfile({
    required this.platform,
    required this.capabilities,
    required this.supportedPublishFormats,
    required this.notes,
    required this.officialReferenceUrls,
  });

  final SocialPlatform platform;
  final Set<ConnectorCapability> capabilities;
  final List<String> supportedPublishFormats;
  final String notes;
  final List<String> officialReferenceUrls;

  bool supports(ConnectorCapability capability) =>
      capabilities.contains(capability);
}

class PlatformCapabilityCatalog {
  const PlatformCapabilityCatalog._();

  static const List<PlatformCapabilityProfile> profiles = [
    PlatformCapabilityProfile(
      platform: SocialPlatform.instagram,
      capabilities: {
        ConnectorCapability.canPublishNow,
        ConnectorCapability.canReadAccountMetrics,
        ConnectorCapability.canReadPostMetrics,
        ConnectorCapability.canReadComments,
        ConnectorCapability.canReplyToComments,
        ConnectorCapability.canRunNativeListening,
        ConnectorCapability.hasQuotaSensitiveUpload,
        ConnectorCapability.notes,
      },
      supportedPublishFormats: [
        'single image',
        'single video',
        'reel',
        'carousel',
      ],
      notes:
          'Content publishing supports images, videos, reels, and carousel-style media for eligible professional accounts. Comment and mention handling is available through platform APIs; broad listening remains constrained.',
      officialReferenceUrls: [
        'https://developers.facebook.com/docs/instagram-platform/instagram-graph-api/content-publishing/',
        'https://developers.facebook.com/docs/instagram-platform/instagram-graph-api/reference/ig-media/comments/',
      ],
    ),
    PlatformCapabilityProfile(
      platform: SocialPlatform.facebook,
      capabilities: {
        ConnectorCapability.canPublishNow,
        ConnectorCapability.canScheduleViaConnector,
        ConnectorCapability.canReadAccountMetrics,
        ConnectorCapability.canReadPostMetrics,
        ConnectorCapability.canReadComments,
        ConnectorCapability.canReplyToComments,
        ConnectorCapability.canReadMessages,
        ConnectorCapability.hasQuotaSensitiveUpload,
        ConnectorCapability.notes,
      },
      supportedPublishFormats: [
        'page post',
        'link post',
        'photo post',
        'video post',
      ],
      notes:
          'Page connectors can publish and schedule Page posts, read Page and post insights, and manage comments when the app has the required Page permissions.',
      officialReferenceUrls: [
        'https://developers.facebook.com/docs/pages-api/posts/',
        'https://developers.facebook.com/docs/graph-api/reference/page/feed/',
      ],
    ),
    PlatformCapabilityProfile(
      platform: SocialPlatform.linkedin,
      capabilities: {
        ConnectorCapability.canPublishNow,
        ConnectorCapability.canReadAccountMetrics,
        ConnectorCapability.canReadPostMetrics,
        ConnectorCapability.canReadComments,
        ConnectorCapability.canReplyToComments,
        ConnectorCapability.hasQuotaSensitiveUpload,
        ConnectorCapability.notes,
      },
      supportedPublishFormats: [
        'text post',
        'article link',
        'image post',
        'video post',
        'document post',
      ],
      notes:
          'Organic post APIs support multiple content types. Scheduling is kept in MetaRix unless a future official connector surface provides native scheduling guarantees.',
      officialReferenceUrls: [
        'https://learn.microsoft.com/en-us/linkedin/marketing/community-management/shares/posts-api?tabs=http&view=li-lms-2024-08',
      ],
    ),
    PlatformCapabilityProfile(
      platform: SocialPlatform.tiktok,
      capabilities: {
        ConnectorCapability.canPublishNow,
        ConnectorCapability.canScheduleViaConnector,
        ConnectorCapability.canRunNativeListening,
        ConnectorCapability.requiresMediaUploadHostVerification,
        ConnectorCapability.hasQuotaSensitiveUpload,
        ConnectorCapability.notes,
      },
      supportedPublishFormats: [
        'draft upload',
        'direct video post',
        'direct photo post',
      ],
      notes:
          'Content Posting APIs support draft and direct posting flows. Pull-from-url media workflows require verified media URLs; native listening depends on restricted research-oriented access.',
      officialReferenceUrls: [
        'https://developers.tiktok.com/doc/content-posting-api-get-started/',
        'https://developers.tiktok.com/products/content-posting-api',
        'https://developers.tiktok.com/products/research-api/',
      ],
    ),
    PlatformCapabilityProfile(
      platform: SocialPlatform.youtube,
      capabilities: {
        ConnectorCapability.canPublishNow,
        ConnectorCapability.canScheduleViaConnector,
        ConnectorCapability.canReadAccountMetrics,
        ConnectorCapability.canReadPostMetrics,
        ConnectorCapability.canReadComments,
        ConnectorCapability.canReplyToComments,
        ConnectorCapability.hasQuotaSensitiveUpload,
        ConnectorCapability.notes,
      },
      supportedPublishFormats: ['video upload', 'scheduled video publish'],
      notes:
          'Data API upload and comment workflows pair with Analytics API reporting. Uploads are quota-sensitive and should be treated as bounded jobs.',
      officialReferenceUrls: [
        'https://developers.google.com/youtube/v3/docs/videos/insert',
        'https://developers.google.com/youtube/v3/docs/comments',
        'https://developers.google.com/youtube/analytics/data_model',
      ],
    ),
  ];

  static PlatformCapabilityProfile forPlatform(SocialPlatform platform) {
    return profiles.firstWhere((profile) => profile.platform == platform);
  }
}
