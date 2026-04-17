import '../../shared/domain/core_models.dart';
import '../../workflow/domain/workflow_models.dart';

enum PublishRecordStatus {
  draft,
  scheduled,
  queued,
  published,
  failed,
  blocked,
}

extension PublishRecordStatusX on PublishRecordStatus {
  String get label => switch (this) {
    PublishRecordStatus.draft => 'Draft',
    PublishRecordStatus.scheduled => 'Scheduled',
    PublishRecordStatus.queued => 'Queued',
    PublishRecordStatus.published => 'Published',
    PublishRecordStatus.failed => 'Failed',
    PublishRecordStatus.blocked => 'Blocked',
  };

  static PublishRecordStatus fromName(String value) =>
      PublishRecordStatus.values.firstWhere((status) => status.name == value);
}

class ScheduledPostRecord {
  const ScheduledPostRecord({
    required this.id,
    required this.draftId,
    required this.campaignId,
    required this.campaignName,
    required this.title,
    required this.channel,
    required this.status,
    required this.scheduledAt,
    required this.queuedAt,
    required this.publishedAt,
    required this.updatedAt,
    required this.lastError,
    required this.denialReasons,
  });

  final String id;
  final String draftId;
  final String campaignId;
  final String campaignName;
  final String title;
  final SocialChannel channel;
  final PublishRecordStatus status;
  final DateTime? scheduledAt;
  final DateTime? queuedAt;
  final DateTime? publishedAt;
  final DateTime updatedAt;
  final String? lastError;
  final List<DenialReason> denialReasons;

  ScheduledPostRecord copyWith({
    String? id,
    String? draftId,
    String? campaignId,
    String? campaignName,
    String? title,
    SocialChannel? channel,
    PublishRecordStatus? status,
    DateTime? scheduledAt,
    bool clearScheduledAt = false,
    DateTime? queuedAt,
    bool clearQueuedAt = false,
    DateTime? publishedAt,
    bool clearPublishedAt = false,
    DateTime? updatedAt,
    String? lastError,
    bool clearLastError = false,
    List<DenialReason>? denialReasons,
  }) {
    return ScheduledPostRecord(
      id: id ?? this.id,
      draftId: draftId ?? this.draftId,
      campaignId: campaignId ?? this.campaignId,
      campaignName: campaignName ?? this.campaignName,
      title: title ?? this.title,
      channel: channel ?? this.channel,
      status: status ?? this.status,
      scheduledAt: clearScheduledAt ? null : scheduledAt ?? this.scheduledAt,
      queuedAt: clearQueuedAt ? null : queuedAt ?? this.queuedAt,
      publishedAt: clearPublishedAt ? null : publishedAt ?? this.publishedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastError: clearLastError ? null : lastError ?? this.lastError,
      denialReasons: denialReasons ?? this.denialReasons,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'draftId': draftId,
    'campaignId': campaignId,
    'campaignName': campaignName,
    'title': title,
    'channel': channel.name,
    'status': status.name,
    'scheduledAt': scheduledAt?.toIso8601String(),
    'queuedAt': queuedAt?.toIso8601String(),
    'publishedAt': publishedAt?.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'lastError': lastError,
    'denialReasons': denialReasons.map((reason) => reason.toJson()).toList(),
  };

  factory ScheduledPostRecord.fromJson(Map<String, dynamic> json) =>
      ScheduledPostRecord(
        id: json['id'] as String,
        draftId: json['draftId'] as String,
        campaignId: json['campaignId'] as String,
        campaignName: json['campaignName'] as String,
        title: json['title'] as String,
        channel: SocialChannelX.fromName(json['channel'] as String),
        status: PublishRecordStatusX.fromName(json['status'] as String),
        scheduledAt: json['scheduledAt'] == null
            ? null
            : DateTime.parse(json['scheduledAt'] as String),
        queuedAt: json['queuedAt'] == null
            ? null
            : DateTime.parse(json['queuedAt'] as String),
        publishedAt: json['publishedAt'] == null
            ? null
            : DateTime.parse(json['publishedAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        lastError: json['lastError'] as String?,
        denialReasons: (json['denialReasons'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(DenialReason.fromJson)
            .toList(),
      );
}
