enum ActivityEventType {
  created,
  updated,
  reviewed,
  approved,
  denied,
  scheduled,
  published,
  reportGenerated,
  listeningAlert,
  recommendationCreated,
}

extension ActivityEventTypeX on ActivityEventType {
  String get label => switch (this) {
        ActivityEventType.created => 'Created',
        ActivityEventType.updated => 'Updated',
        ActivityEventType.reviewed => 'Reviewed',
        ActivityEventType.approved => 'Approved',
        ActivityEventType.denied => 'Denied',
        ActivityEventType.scheduled => 'Scheduled',
        ActivityEventType.published => 'Published',
        ActivityEventType.reportGenerated => 'Report generated',
        ActivityEventType.listeningAlert => 'Listening alert',
        ActivityEventType.recommendationCreated => 'Recommendation created',
      };

  static ActivityEventType fromName(String value) =>
      ActivityEventType.values.firstWhere((type) => type.name == value);
}

enum ActivityEventClass {
  normalAction,
  denial,
  systemAction,
  recommendation,
}

extension ActivityEventClassX on ActivityEventClass {
  String get label => switch (this) {
        ActivityEventClass.normalAction => 'Action',
        ActivityEventClass.denial => 'Denial',
        ActivityEventClass.systemAction => 'System',
        ActivityEventClass.recommendation => 'Recommendation',
      };

  static ActivityEventClass fromName(String value) =>
      ActivityEventClass.values.firstWhere((type) => type.name == value);
}

enum ActivityObjectType {
  campaign,
  draft,
  approval,
  schedule,
  report,
  listeningQuery,
  mention,
}

extension ActivityObjectTypeX on ActivityObjectType {
  String get label => switch (this) {
        ActivityObjectType.campaign => 'Campaign',
        ActivityObjectType.draft => 'Draft',
        ActivityObjectType.approval => 'Approval',
        ActivityObjectType.schedule => 'Schedule',
        ActivityObjectType.report => 'Report',
        ActivityObjectType.listeningQuery => 'Listening query',
        ActivityObjectType.mention => 'Mention',
      };

  static ActivityObjectType fromName(String value) =>
      ActivityObjectType.values.firstWhere((type) => type.name == value);
}
