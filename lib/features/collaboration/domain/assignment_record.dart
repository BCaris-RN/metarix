import '../../admin/domain/admin_models.dart';

class AssignmentRecord {
  const AssignmentRecord({
    required this.id,
    required this.objectType,
    required this.objectId,
    required this.label,
    required this.assigneeUserId,
    required this.assigneeRole,
    required this.createdAt,
  });

  final String id;
  final String objectType;
  final String objectId;
  final String label;
  final String? assigneeUserId;
  final UserRole? assigneeRole;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'objectType': objectType,
        'objectId': objectId,
        'label': label,
        'assigneeUserId': assigneeUserId,
        'assigneeRole': assigneeRole?.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AssignmentRecord.fromJson(Map<String, dynamic> json) =>
      AssignmentRecord(
        id: json['id'] as String,
        objectType: json['objectType'] as String,
        objectId: json['objectId'] as String,
        label: json['label'] as String,
        assigneeUserId: json['assigneeUserId'] as String?,
        assigneeRole: json['assigneeRole'] == null
            ? null
            : UserRoleX.fromName(json['assigneeRole'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
