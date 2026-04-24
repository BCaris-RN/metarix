import '../common/release_helpers.dart';

enum PublishAuditEventType {
  jobCreated,
  jobValidated,
  jobQueued,
  publishStarted,
  publishSucceeded,
  publishFailed,
  publishCanceled,
  unsupportedPlatform,
  missingAdapter,
}

extension PublishAuditEventTypeX on PublishAuditEventType {
  static PublishAuditEventType fromName(String? value) {
    return PublishAuditEventType.values.firstWhere(
      (eventType) => eventType.name == value,
      orElse: () => PublishAuditEventType.jobCreated,
    );
  }
}

class PublishAuditEvent {
  const PublishAuditEvent({
    required this.id,
    required this.createdAtIso,
    required this.updatedAtIso,
    required this.jobId,
    required this.type,
    required this.message,
    required this.metadata,
  });

  final String id;
  final String createdAtIso;
  final String updatedAtIso;
  final String jobId;
  final PublishAuditEventType type;
  final String message;
  final Map<String, Object?> metadata;

  PublishAuditEvent copyWith({
    String? id,
    String? createdAtIso,
    String? updatedAtIso,
    String? jobId,
    PublishAuditEventType? type,
    String? message,
    Map<String, Object?>? metadata,
  }) {
    return PublishAuditEvent(
      id: id ?? this.id,
      createdAtIso: createdAtIso ?? this.createdAtIso,
      updatedAtIso: updatedAtIso ?? this.updatedAtIso,
      jobId: jobId ?? this.jobId,
      type: type ?? this.type,
      message: message ?? this.message,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'createdAtIso': createdAtIso,
        'updatedAtIso': updatedAtIso,
        'jobId': jobId,
        'type': type.name,
        'message': message,
        'metadata': metadata,
      };

  factory PublishAuditEvent.fromJson(Map<String, Object?> json) {
    return PublishAuditEvent(
      id: stringOrFallback(json['id'], 'publish-audit-local'),
      createdAtIso: isoOrNow(json['createdAtIso']),
      updatedAtIso: isoOrNow(json['updatedAtIso']),
      jobId: stringOrFallback(json['jobId'], 'publish-local'),
      type: PublishAuditEventTypeX.fromName(json['type'] as String?),
      message: stringOrEmpty(json['message']),
      metadata: (json['metadata'] as Map?)?.cast<String, Object?>() ??
          <String, Object?>{},
    );
  }
}
