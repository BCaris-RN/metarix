enum SocialPlatform { instagram, facebook, tiktok, youtube, linkedin, demo }

extension SocialPlatformX on SocialPlatform {
  String get label => switch (this) {
        SocialPlatform.instagram => 'Instagram',
        SocialPlatform.facebook => 'Facebook',
        SocialPlatform.tiktok => 'TikTok',
        SocialPlatform.youtube => 'YouTube',
        SocialPlatform.linkedin => 'LinkedIn',
        SocialPlatform.demo => 'Demo',
      };

  static SocialPlatform fromName(String? value) {
    return SocialPlatform.values.firstWhere(
      (platform) => platform.name == value,
      orElse: () => SocialPlatform.demo,
    );
  }
}

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  expired,
  revoked,
  unhealthy,
  unsupported,
}

extension ConnectionStatusX on ConnectionStatus {
  static ConnectionStatus fromName(String? value) {
    return ConnectionStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ConnectionStatus.disconnected,
    );
  }
}


