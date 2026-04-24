import '../accounts/social_platform.dart';

class PlatformCapabilityManifest {
  const PlatformCapabilityManifest({
    required this.platform,
    required this.canConnect,
    required this.canUploadMedia,
    required this.canPublishNow,
    required this.canSchedule,
    required this.supportsImages,
    required this.supportsVideo,
    required this.supportsMultiAccount,
    required this.requiresBusinessAccount,
    required this.requiredScopes,
    required this.unsupportedReason,
  });

  final SocialPlatform platform;
  final bool canConnect;
  final bool canUploadMedia;
  final bool canPublishNow;
  final bool canSchedule;
  final bool supportsImages;
  final bool supportsVideo;
  final bool supportsMultiAccount;
  final bool requiresBusinessAccount;
  final List<String> requiredScopes;
  final String? unsupportedReason;
}

class PlatformCapabilityService {
  const PlatformCapabilityService();

  PlatformCapabilityManifest manifestFor(SocialPlatform platform) {
    return switch (platform) {
      SocialPlatform.instagram => const PlatformCapabilityManifest(
          platform: SocialPlatform.instagram,
          canConnect: true,
          canUploadMedia: true,
          canPublishNow: false,
          canSchedule: true,
          supportsImages: true,
          supportsVideo: true,
          supportsMultiAccount: false,
          requiresBusinessAccount: true,
          requiredScopes: <String>['instagram_business_content_publish'],
          unsupportedReason:
              'Instagram publishing is gated by Meta/IG Business or Creator flow.',
        ),
      SocialPlatform.facebook => const PlatformCapabilityManifest(
          platform: SocialPlatform.facebook,
          canConnect: true,
          canUploadMedia: true,
          canPublishNow: false,
          canSchedule: true,
          supportsImages: true,
          supportsVideo: true,
          supportsMultiAccount: true,
          requiresBusinessAccount: false,
          requiredScopes: <String>['pages_manage_posts'],
          unsupportedReason:
              'Facebook publishing is gated by Page connection and permissions.',
        ),
      SocialPlatform.tiktok => const PlatformCapabilityManifest(
          platform: SocialPlatform.tiktok,
          canConnect: true,
          canUploadMedia: true,
          canPublishNow: false,
          canSchedule: true,
          supportsImages: false,
          supportsVideo: true,
          supportsMultiAccount: true,
          requiresBusinessAccount: false,
          requiredScopes: <String>['video.publish'],
          unsupportedReason:
              'TikTok direct publish is gated by approved Content Posting API scopes.',
        ),
      SocialPlatform.youtube => const PlatformCapabilityManifest(
          platform: SocialPlatform.youtube,
          canConnect: true,
          canUploadMedia: true,
          canPublishNow: false,
          canSchedule: true,
          supportsImages: false,
          supportsVideo: true,
          supportsMultiAccount: true,
          requiresBusinessAccount: false,
          requiredScopes: <String>['youtube.upload'],
          unsupportedReason:
              'YouTube upload is gated by Google OAuth and quota.',
        ),
      SocialPlatform.linkedin => const PlatformCapabilityManifest(
          platform: SocialPlatform.linkedin,
          canConnect: true,
          canUploadMedia: true,
          canPublishNow: false,
          canSchedule: true,
          supportsImages: true,
          supportsVideo: true,
          supportsMultiAccount: true,
          requiresBusinessAccount: false,
          requiredScopes: <String>['w_member_social'],
          unsupportedReason: 'LinkedIn publish remains gated in release mode.',
        ),
      SocialPlatform.demo => const PlatformCapabilityManifest(
          platform: SocialPlatform.demo,
          canConnect: true,
          canUploadMedia: true,
          canPublishNow: true,
          canSchedule: true,
          supportsImages: true,
          supportsVideo: true,
          supportsMultiAccount: true,
          requiresBusinessAccount: false,
          requiredScopes: <String>[],
          unsupportedReason: null,
        ),
    };
  }
}

