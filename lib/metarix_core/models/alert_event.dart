import 'model_types.dart';

class AlertEvent {
  const AlertEvent({
    required this.alertEventId,
    required this.type,
    required this.severity,
    required this.sourceRef,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  final String alertEventId;
  final AlertEventType type;
  final AlertSeverity severity;
  final String sourceRef;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  AlertEvent markRead() => copyWith(isRead: true);

  AlertEvent copyWith({
    String? alertEventId,
    AlertEventType? type,
    AlertSeverity? severity,
    String? sourceRef,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return AlertEvent(
      alertEventId: alertEventId ?? this.alertEventId,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      sourceRef: sourceRef ?? this.sourceRef,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
    'alertEventId': alertEventId,
    'type': type.name,
    'severity': severity.name,
    'sourceRef': sourceRef,
    'title': title,
    'message': message,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
  };

  factory AlertEvent.fromJson(Map<String, dynamic> json) => AlertEvent(
    alertEventId: json['alertEventId'] as String,
    type: AlertEventTypeX.fromName(json['type'] as String),
    severity: AlertSeverityX.fromName(json['severity'] as String),
    sourceRef: json['sourceRef'] as String,
    title: json['title'] as String,
    message: json['message'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    isRead: json['isRead'] as bool,
  );
}
