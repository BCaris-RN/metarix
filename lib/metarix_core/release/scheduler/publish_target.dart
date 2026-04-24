import '../accounts/social_platform.dart';
import '../common/release_helpers.dart';

class PublishTarget {
  const PublishTarget({
    required this.id,
    required this.createdAtIso,
    required this.updatedAtIso,
    required this.platform,
    required this.connectedAccountId,
    required this.targetDisplayName,
    this.platformAssetId,
    this.targetPageOrChannelId,
    required this.platformMetadata,
    this.accountHandle,
    this.accountId,
    this.channelLabel,
    this.isPrimary = false,
    this.note,
  });

  final String id;
  final String createdAtIso;
  final String updatedAtIso;
  final SocialPlatform platform;
  final String connectedAccountId;
  final String targetDisplayName;
  final String? platformAssetId;
  final String? targetPageOrChannelId;
  final Map<String, Object?> platformMetadata;

  // Compatibility aliases for older release-layer call sites.
  final String? accountHandle;
  final String? accountId;
  final String? channelLabel;
  final bool isPrimary;
  final String? note;

  PublishTarget copyWith({
    String? id,
    String? createdAtIso,
    String? updatedAtIso,
    SocialPlatform? platform,
    String? connectedAccountId,
    String? targetDisplayName,
    String? platformAssetId,
    bool clearPlatformAssetId = false,
    String? targetPageOrChannelId,
    bool clearTargetPageOrChannelId = false,
    Map<String, Object?>? platformMetadata,
    String? accountHandle,
    String? accountId,
    String? channelLabel,
    bool? isPrimary,
    String? note,
    bool clearNote = false,
  }) {
    return PublishTarget(
      id: id ?? this.id,
      createdAtIso: createdAtIso ?? this.createdAtIso,
      updatedAtIso: updatedAtIso ?? this.updatedAtIso,
      platform: platform ?? this.platform,
      connectedAccountId: connectedAccountId ?? this.connectedAccountId,
      targetDisplayName: targetDisplayName ?? this.targetDisplayName,
      platformAssetId: clearPlatformAssetId
          ? null
          : platformAssetId ?? this.platformAssetId,
      targetPageOrChannelId: clearTargetPageOrChannelId
          ? null
          : targetPageOrChannelId ?? this.targetPageOrChannelId,
      platformMetadata: platformMetadata ?? this.platformMetadata,
      accountHandle: accountHandle ?? this.accountHandle,
      accountId: accountId ?? this.accountId,
      channelLabel: channelLabel ?? this.channelLabel,
      isPrimary: isPrimary ?? this.isPrimary,
      note: clearNote ? null : note ?? this.note,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'createdAtIso': createdAtIso,
        'updatedAtIso': updatedAtIso,
        'platform': platform.name,
        'connectedAccountId': connectedAccountId,
        'targetDisplayName': targetDisplayName,
        'platformAssetId': platformAssetId,
        'targetPageOrChannelId': targetPageOrChannelId,
        'platformMetadata': platformMetadata,
        'accountHandle': accountHandle,
        'accountId': accountId,
        'channelLabel': channelLabel,
        'isPrimary': isPrimary,
        'note': note,
      };

  factory PublishTarget.fromJson(Map<String, Object?> json) {
    return PublishTarget(
      id: stringOrFallback(json['id'], 'target-local'),
      createdAtIso: isoOrNow(json['createdAtIso']),
      updatedAtIso: isoOrNow(json['updatedAtIso']),
      platform: SocialPlatformX.fromName(json['platform'] as String?),
      connectedAccountId: stringOrFallback(
        json['connectedAccountId'] ?? json['accountId'],
        'account-local',
      ),
      targetDisplayName: stringOrFallback(
        json['targetDisplayName'] ?? json['accountHandle'],
        'Target',
      ),
      platformAssetId: json['platformAssetId'] as String?,
      targetPageOrChannelId: json['targetPageOrChannelId'] as String?,
      platformMetadata: (json['platformMetadata'] as Map?)?.cast<String, Object?>() ??
          <String, Object?>{},
      accountHandle: json['accountHandle'] as String?,
      accountId: json['accountId'] as String?,
      channelLabel: json['channelLabel'] as String?,
      isPrimary: json['isPrimary'] == true,
      note: json['note'] as String?,
    );
  }
}
