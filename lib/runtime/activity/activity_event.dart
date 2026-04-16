import 'activity_event_type.dart';

class ActivityEvent {
  const ActivityEvent({
    required this.id,
    required this.workspaceId,
    required this.objectType,
    required this.objectId,
    required this.objectLabel,
    required this.eventType,
    required this.eventClass,
    required this.actorUserId,
    required this.actorName,
    required this.reason,
    required this.occurredAt,
    this.detail,
  });

  final String id;
  final String workspaceId;
  final ActivityObjectType objectType;
  final String objectId;
  final String objectLabel;
  final ActivityEventType eventType;
  final ActivityEventClass eventClass;
  final String actorUserId;
  final String actorName;
  final String reason;
  final String? detail;
  final DateTime occurredAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'workspaceId': workspaceId,
        'objectType': objectType.name,
        'objectId': objectId,
        'objectLabel': objectLabel,
        'eventType': eventType.name,
        'eventClass': eventClass.name,
        'actorUserId': actorUserId,
        'actorName': actorName,
        'reason': reason,
        'detail': detail,
        'occurredAt': occurredAt.toIso8601String(),
      };

  factory ActivityEvent.fromJson(Map<String, dynamic> json) => ActivityEvent(
        id: json['id'] as String,
        workspaceId: json['workspaceId'] as String,
        objectType: ActivityObjectTypeX.fromName(json['objectType'] as String),
        objectId: json['objectId'] as String,
        objectLabel: json['objectLabel'] as String,
        eventType: ActivityEventTypeX.fromName(json['eventType'] as String),
        eventClass: ActivityEventClassX.fromName(json['eventClass'] as String),
        actorUserId: json['actorUserId'] as String,
        actorName: json['actorName'] as String,
        reason: json['reason'] as String,
        detail: json['detail'] as String?,
        occurredAt: DateTime.parse(json['occurredAt'] as String),
      );
}
