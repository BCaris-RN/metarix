import '../accounts/social_platform.dart';
import '../common/release_helpers.dart';
import '../content/content_asset.dart';
import '../publishing/publish_status.dart';
import 'publish_target.dart';

class ScheduledPost {
  const ScheduledPost({
    required this.id,
    required this.createdAtIso,
    required this.updatedAtIso,
    required this.workspaceId,
    required this.contentAssetIds,
    required this.targets,
    required this.scheduledAtIso,
    required this.timezone,
    required this.status,
    required this.validationErrors,
    required this.approvalStatus,
    required this.createdByUserId,
    required this.publishedJobIds,
    this.approvedByUserId,
    this.asset,
    this.title,
    this.caption,
    this.platform,
    this.target,
    this.publishStatus,
    this.contentAssetId,
    this.approvalState,
    this.validationMessage,
  });

  final String id;
  final String createdAtIso;
  final String updatedAtIso;
  final String workspaceId;
  final List<String> contentAssetIds;
  final List<PublishTarget> targets;
  final String scheduledAtIso;
  final String timezone;
  final PublishStatus status;
  final List<String> validationErrors;
  final String approvalStatus;
  final String createdByUserId;
  final String? approvedByUserId;
  final List<String> publishedJobIds;
  final ContentAsset? asset;

  // Compatibility aliases for older release-layer call sites.
  final String? title;
  final String? caption;
  final SocialPlatform? platform;
  final PublishTarget? target;
  final PublishStatus? publishStatus;
  final String? contentAssetId;
  final String? approvalState;
  final String? validationMessage;

  ScheduledPost copyWith({
    String? id,
    String? createdAtIso,
    String? updatedAtIso,
    String? workspaceId,
    List<String>? contentAssetIds,
    List<PublishTarget>? targets,
    String? scheduledAtIso,
    String? timezone,
    PublishStatus? status,
    List<String>? validationErrors,
    String? approvalStatus,
    String? createdByUserId,
    String? approvedByUserId,
    bool clearApprovedByUserId = false,
    List<String>? publishedJobIds,
    ContentAsset? asset,
    bool clearAsset = false,
    String? title,
    bool clearTitle = false,
    String? caption,
    bool clearCaption = false,
    SocialPlatform? platform,
    PublishTarget? target,
    PublishStatus? publishStatus,
    String? contentAssetId,
    String? approvalState,
    bool clearApprovalState = false,
    String? validationMessage,
    bool clearValidationMessage = false,
  }) {
    return ScheduledPost(
      id: id ?? this.id,
      createdAtIso: createdAtIso ?? this.createdAtIso,
      updatedAtIso: updatedAtIso ?? this.updatedAtIso,
      workspaceId: workspaceId ?? this.workspaceId,
      contentAssetIds: contentAssetIds ?? this.contentAssetIds,
      targets: targets ?? this.targets,
      scheduledAtIso: scheduledAtIso ?? this.scheduledAtIso,
      timezone: timezone ?? this.timezone,
      status: status ?? this.status,
      validationErrors: validationErrors ?? this.validationErrors,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      approvedByUserId: clearApprovedByUserId
          ? null
          : approvedByUserId ?? this.approvedByUserId,
      publishedJobIds: publishedJobIds ?? this.publishedJobIds,
      asset: clearAsset ? null : asset ?? this.asset,
      title: clearTitle ? null : title ?? this.title,
      caption: clearCaption ? null : caption ?? this.caption,
      platform: platform ?? this.platform,
      target: target ?? this.target,
      publishStatus: publishStatus ?? this.publishStatus,
      contentAssetId: contentAssetId ?? this.contentAssetId,
      approvalState: clearApprovalState ? null : approvalState ?? this.approvalState,
      validationMessage: clearValidationMessage
          ? null
          : validationMessage ?? this.validationMessage,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'createdAtIso': createdAtIso,
        'updatedAtIso': updatedAtIso,
        'workspaceId': workspaceId,
        'contentAssetIds': contentAssetIds,
        'targets': targets.map((entry) => entry.toJson()).toList(),
        'scheduledAtIso': scheduledAtIso,
        'timezone': timezone,
        'status': status.name,
        'validationErrors': validationErrors,
        'approvalStatus': approvalStatus,
        'createdByUserId': createdByUserId,
        'approvedByUserId': approvedByUserId,
        'publishedJobIds': publishedJobIds,
        'asset': asset?.toJson(),
        'title': title,
        'caption': caption,
        'platform': platform?.name,
        'target': target?.toJson(),
        'publishStatus': publishStatus?.name,
        'contentAssetId': contentAssetId,
        'approvalState': approvalState,
        'validationMessage': validationMessage,
      };

  factory ScheduledPost.fromJson(Map<String, Object?> json) {
    final targetsJson = json['targets'];
    final targetJson = json['target'];
    final assetJson = json['asset'];
    final contentAssetIds = stringListFromJson(
      json['contentAssetIds'] ?? (json['contentAssetId'] == null ? null : [json['contentAssetId']]),
    );
    return ScheduledPost(
      id: stringOrFallback(json['id'], 'scheduled-local'),
      createdAtIso: isoOrNow(json['createdAtIso']),
      updatedAtIso: isoOrNow(json['updatedAtIso']),
      workspaceId: stringOrFallback(json['workspaceId'], 'workspace-local'),
      contentAssetIds: contentAssetIds,
      targets: targetsJson is List
          ? targetsJson
              .whereType<Map>()
              .map((item) => PublishTarget.fromJson(item.cast<String, Object?>()))
              .toList(growable: false)
          : targetJson is Map
              ? <PublishTarget>[PublishTarget.fromJson(targetJson.cast<String, Object?>())]
              : const <PublishTarget>[],
      scheduledAtIso: stringOrFallback(
        json['scheduledAtIso'],
        DateTime.now().toUtc().toIso8601String(),
      ),
      timezone: stringOrFallback(json['timezone'], 'UTC'),
      status: PublishStatusX.fromName(json['status'] as String? ?? json['publishStatus'] as String?),
      validationErrors: stringListFromJson(json['validationErrors']),
      approvalStatus: stringOrFallback(json['approvalStatus'], json['approvalState'] as String? ?? 'draft'),
      createdByUserId: stringOrFallback(json['createdByUserId'], 'user-local'),
      approvedByUserId: json['approvedByUserId'] as String?,
      publishedJobIds: stringListFromJson(json['publishedJobIds']),
      asset: assetJson is Map
          ? ContentAsset.fromJson(assetJson.cast<String, Object?>())
          : null,
      title: json['title'] as String?,
      caption: json['caption'] as String?,
      platform: SocialPlatformX.fromName(json['platform'] as String?),
      target: targetJson is Map
          ? PublishTarget.fromJson(targetJson.cast<String, Object?>())
          : null,
      publishStatus: PublishStatusX.fromName(json['publishStatus'] as String?),
      contentAssetId: json['contentAssetId'] as String?,
      approvalState: json['approvalState'] as String?,
      validationMessage: json['validationMessage'] as String?,
    );
  }
}
