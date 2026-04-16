import '../../shared/domain/core_models.dart';
import '../../workflow/domain/workflow_models.dart';

enum PublishPosture {
  notReady,
  readyForReview,
  approved,
  scheduled,
  publishEligible,
  publishDenied,
}

extension PublishPostureX on PublishPosture {
  String get label => switch (this) {
        PublishPosture.notReady => 'Not ready',
        PublishPosture.readyForReview => 'Ready for review',
        PublishPosture.approved => 'Approved',
        PublishPosture.scheduled => 'Scheduled',
        PublishPosture.publishEligible => 'Publish eligible',
        PublishPosture.publishDenied => 'Publish denied',
      };
}

class ScheduleRecord {
  const ScheduleRecord({
    required this.id,
    required this.draftId,
    required this.channel,
    required this.scheduledAt,
    required this.denialReasons,
  });

  final String id;
  final String draftId;
  final SocialChannel channel;
  final DateTime scheduledAt;
  final List<DenialReason> denialReasons;

  ScheduleRecord copyWith({
    String? id,
    String? draftId,
    SocialChannel? channel,
    DateTime? scheduledAt,
    List<DenialReason>? denialReasons,
  }) {
    return ScheduleRecord(
      id: id ?? this.id,
      draftId: draftId ?? this.draftId,
      channel: channel ?? this.channel,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      denialReasons: denialReasons ?? this.denialReasons,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'draftId': draftId,
        'channel': channel.name,
        'scheduledAt': scheduledAt.toIso8601String(),
        'denialReasons':
            denialReasons.map((reason) => reason.toJson()).toList(),
      };

  factory ScheduleRecord.fromJson(Map<String, dynamic> json) => ScheduleRecord(
        id: json['id'] as String,
        draftId: json['draftId'] as String,
        channel: SocialChannelX.fromName(json['channel'] as String),
        scheduledAt: DateTime.parse(json['scheduledAt'] as String),
        denialReasons: (json['denialReasons'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(DenialReason.fromJson)
            .toList(),
      );
}
