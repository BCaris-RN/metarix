enum CommentType {
  note,
  reviewNote,
  systemNote,
}

extension CommentTypeX on CommentType {
  String get label => switch (this) {
        CommentType.note => 'Note',
        CommentType.reviewNote => 'Review note',
        CommentType.systemNote => 'System note',
      };

  static CommentType fromName(String value) => switch (value) {
        'review_note' => CommentType.reviewNote,
        'system_note' => CommentType.systemNote,
        _ => CommentType.note,
      };

  String get storageName => switch (this) {
        CommentType.reviewNote => 'review_note',
        CommentType.systemNote => 'system_note',
        _ => name,
      };
}

class CommentRecord {
  const CommentRecord({
    required this.id,
    required this.objectType,
    required this.objectId,
    required this.authorUserId,
    required this.authorName,
    required this.type,
    required this.text,
    required this.mentions,
    required this.assignmentLabel,
    required this.createdAt,
  });

  final String id;
  final String objectType;
  final String objectId;
  final String authorUserId;
  final String authorName;
  final CommentType type;
  final String text;
  final List<String> mentions;
  final String? assignmentLabel;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'objectType': objectType,
        'objectId': objectId,
        'authorUserId': authorUserId,
        'authorName': authorName,
        'type': type.storageName,
        'text': text,
        'mentions': mentions,
        'assignmentLabel': assignmentLabel,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CommentRecord.fromJson(Map<String, dynamic> json) => CommentRecord(
        id: json['id'] as String,
        objectType: json['objectType'] as String,
        objectId: json['objectId'] as String,
        authorUserId: json['authorUserId'] as String,
        authorName: json['authorName'] as String,
        type: CommentTypeX.fromName(json['type'] as String),
        text: json['text'] as String,
        mentions: (json['mentions'] as List<dynamic>).cast<String>().toList(),
        assignmentLabel: json['assignmentLabel'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
