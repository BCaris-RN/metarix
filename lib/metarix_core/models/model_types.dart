enum WorkspaceMode { singleUser }

extension WorkspaceModeX on WorkspaceMode {
  String get label => switch (this) {
    WorkspaceMode.singleUser => 'Single user',
  };

  static WorkspaceMode fromName(String value) =>
      WorkspaceMode.values.firstWhere((mode) => mode.name == value);
}

enum SocialPlatform { instagram, facebook, linkedin, tiktok, youtube }

extension SocialPlatformX on SocialPlatform {
  String get label => switch (this) {
    SocialPlatform.instagram => 'Instagram',
    SocialPlatform.facebook => 'Facebook',
    SocialPlatform.linkedin => 'LinkedIn',
    SocialPlatform.tiktok => 'TikTok',
    SocialPlatform.youtube => 'YouTube',
  };

  static SocialPlatform fromName(String value) =>
      SocialPlatform.values.firstWhere((platform) => platform.name == value);
}

enum ConnectionStatus { disconnected, connected, attentionRequired }

extension ConnectionStatusX on ConnectionStatus {
  String get label => switch (this) {
    ConnectionStatus.disconnected => 'Disconnected',
    ConnectionStatus.connected => 'Connected',
    ConnectionStatus.attentionRequired => 'Attention required',
  };

  static ConnectionStatus fromName(String value) =>
      ConnectionStatus.values.firstWhere((status) => status.name == value);
}

enum MediaSourceType { canva, adobe, manual }

extension MediaSourceTypeX on MediaSourceType {
  static MediaSourceType fromName(String value) =>
      MediaSourceType.values.firstWhere((source) => source.name == value);
}

enum ContentStatus { draft, approved, scheduled, published, failed, archived }

extension ContentStatusX on ContentStatus {
  String get label => switch (this) {
    ContentStatus.draft => 'Draft',
    ContentStatus.approved => 'Approved',
    ContentStatus.scheduled => 'Scheduled',
    ContentStatus.published => 'Published',
    ContentStatus.failed => 'Failed',
    ContentStatus.archived => 'Archived',
  };

  static ContentStatus fromName(String value) =>
      ContentStatus.values.firstWhere((status) => status.name == value);
}

enum PublishExecutionStatus { queued, running, succeeded, failed, canceled }

extension PublishExecutionStatusX on PublishExecutionStatus {
  String get label => switch (this) {
    PublishExecutionStatus.queued => 'Queued',
    PublishExecutionStatus.running => 'Running',
    PublishExecutionStatus.succeeded => 'Succeeded',
    PublishExecutionStatus.failed => 'Failed',
    PublishExecutionStatus.canceled => 'Canceled',
  };

  static PublishExecutionStatus fromName(String value) => PublishExecutionStatus
      .values
      .firstWhere((status) => status.name == value);
}

enum ReportCadence { weekly, monthly, custom }

extension ReportCadenceX on ReportCadence {
  static ReportCadence fromName(String value) =>
      ReportCadence.values.firstWhere((cadence) => cadence.name == value);
}

enum ReportOutputFormat { pdf, csv, json, link }

extension ReportOutputFormatX on ReportOutputFormat {
  static ReportOutputFormat fromName(String value) =>
      ReportOutputFormat.values.firstWhere((format) => format.name == value);
}

enum WatchTermCategory { brand, campaign, competitor, industry, trend }

extension WatchTermCategoryX on WatchTermCategory {
  static WatchTermCategory fromName(String value) =>
      WatchTermCategory.values.firstWhere((category) => category.name == value);
}

enum AlertEventType {
  spike,
  sentiment,
  competitor,
  publishFailure,
  syncFailure,
}

extension AlertEventTypeX on AlertEventType {
  static AlertEventType fromName(String value) =>
      AlertEventType.values.firstWhere((type) => type.name == value);
}

enum AlertSeverity { low, medium, high, critical }

extension AlertSeverityX on AlertSeverity {
  static AlertSeverity fromName(String value) =>
      AlertSeverity.values.firstWhere((severity) => severity.name == value);
}

enum SmartlinkBlockType { hero, button, text, social, spacer }

extension SmartlinkBlockTypeX on SmartlinkBlockType {
  static SmartlinkBlockType fromName(String value) =>
      SmartlinkBlockType.values.firstWhere((type) => type.name == value);
}
