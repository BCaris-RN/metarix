import '../accounts/social_platform.dart';
import '../common/release_helpers.dart';
import '../scheduler/publish_target.dart';
import 'publish_attempt.dart';
import 'publish_status.dart';

class PublishJob {
  const PublishJob({
    required this.id,
    required this.createdAtIso,
    required this.updatedAtIso,
    required this.platform,
    required this.target,
    required this.publishStatus,
    required this.contentAssetId,
    required this.scheduledAtIso,
    required this.attempts,
    required this.remotePostId,
    required this.lastErrorCode,
    required this.lastErrorMessage,
    required this.retryable,
  });

  final String id;
  final String createdAtIso;
  final String updatedAtIso;
  final SocialPlatform platform;
  final PublishTarget target;
  final PublishStatus publishStatus;
  final String contentAssetId;
  final String scheduledAtIso;
  final List<PublishAttempt> attempts;
  final String? remotePostId;
  final String? lastErrorCode;
  final String? lastErrorMessage;
  final bool retryable;

  PublishJob copyWith({
    String? id,
    String? createdAtIso,
    String? updatedAtIso,
    SocialPlatform? platform,
    PublishTarget? target,
    PublishStatus? publishStatus,
    String? contentAssetId,
    String? scheduledAtIso,
    List<PublishAttempt>? attempts,
    String? remotePostId,
    bool clearRemotePostId = false,
    String? lastErrorCode,
    bool clearLastErrorCode = false,
    String? lastErrorMessage,
    bool clearLastErrorMessage = false,
    bool? retryable,
  }) {
    return PublishJob(
      id: id ?? this.id,
      createdAtIso: createdAtIso ?? this.createdAtIso,
      updatedAtIso: updatedAtIso ?? this.updatedAtIso,
      platform: platform ?? this.platform,
      target: target ?? this.target,
      publishStatus: publishStatus ?? this.publishStatus,
      contentAssetId: contentAssetId ?? this.contentAssetId,
      scheduledAtIso: scheduledAtIso ?? this.scheduledAtIso,
      attempts: attempts ?? this.attempts,
      remotePostId: clearRemotePostId ? null : remotePostId ?? this.remotePostId,
      lastErrorCode: clearLastErrorCode ? null : lastErrorCode ?? this.lastErrorCode,
      lastErrorMessage: clearLastErrorMessage
          ? null
          : lastErrorMessage ?? this.lastErrorMessage,
      retryable: retryable ?? this.retryable,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'createdAtIso': createdAtIso,
        'updatedAtIso': updatedAtIso,
        'platform': platform.name,
        'target': target.toJson(),
        'publishStatus': publishStatus.name,
        'contentAssetId': contentAssetId,
        'scheduledAtIso': scheduledAtIso,
        'attempts': attempts.map((attempt) => attempt.toJson()).toList(),
        'remotePostId': remotePostId,
        'lastErrorCode': lastErrorCode,
        'lastErrorMessage': lastErrorMessage,
        'retryable': retryable,
      };

  factory PublishJob.fromJson(Map<String, Object?> json) {
    final targetJson = json['target'];
    final attemptsJson = json['attempts'];
    return PublishJob(
      id: stringOrFallback(json['id'], 'publish-local'),
      createdAtIso: isoOrNow(json['createdAtIso']),
      updatedAtIso: isoOrNow(json['updatedAtIso']),
      platform: SocialPlatformX.fromName(json['platform'] as String?),
      target: targetJson is Map<String, Object?>
          ? PublishTarget.fromJson(targetJson)
          : PublishTarget.fromJson(const <String, Object?>{}),
      publishStatus: PublishStatusX.fromName(json['publishStatus'] as String?),
      contentAssetId: stringOrEmpty(json['contentAssetId']),
      scheduledAtIso: stringOrFallback(json['scheduledAtIso'], isoOrNow(null)),
      attempts: attemptsJson is List
          ? attemptsJson
              .whereType<Map<String, Object?>>()
              .map(PublishAttempt.fromJson)
              .toList(growable: false)
          : const <PublishAttempt>[],
      remotePostId: json['remotePostId'] as String?,
      lastErrorCode: json['lastErrorCode'] as String?,
      lastErrorMessage: json['lastErrorMessage'] as String?,
      retryable: json['retryable'] == true,
    );
  }
}


