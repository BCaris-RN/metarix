import '../accounts/social_platform.dart';
import '../common/release_helpers.dart';

class PlatformCapability {
  const PlatformCapability({
    required this.id,
    required this.createdAtIso,
    required this.updatedAtIso,
    required this.platform,
    required this.canConnectAccount,
    required this.canSchedulePost,
    required this.canAutoPublish,
    required this.supportsMediaUpload,
    required this.supportsVideo,
    required this.supportsMultiAccount,
    required this.note,
  });

  final String id;
  final String createdAtIso;
  final String updatedAtIso;
  final SocialPlatform platform;
  final bool canConnectAccount;
  final bool canSchedulePost;
  final bool canAutoPublish;
  final bool supportsMediaUpload;
  final bool supportsVideo;
  final bool supportsMultiAccount;
  final String? note;

  PlatformCapability copyWith({
    String? id,
    String? createdAtIso,
    String? updatedAtIso,
    SocialPlatform? platform,
    bool? canConnectAccount,
    bool? canSchedulePost,
    bool? canAutoPublish,
    bool? supportsMediaUpload,
    bool? supportsVideo,
    bool? supportsMultiAccount,
    String? note,
    bool clearNote = false,
  }) {
    return PlatformCapability(
      id: id ?? this.id,
      createdAtIso: createdAtIso ?? this.createdAtIso,
      updatedAtIso: updatedAtIso ?? this.updatedAtIso,
      platform: platform ?? this.platform,
      canConnectAccount: canConnectAccount ?? this.canConnectAccount,
      canSchedulePost: canSchedulePost ?? this.canSchedulePost,
      canAutoPublish: canAutoPublish ?? this.canAutoPublish,
      supportsMediaUpload: supportsMediaUpload ?? this.supportsMediaUpload,
      supportsVideo: supportsVideo ?? this.supportsVideo,
      supportsMultiAccount: supportsMultiAccount ?? this.supportsMultiAccount,
      note: clearNote ? null : note ?? this.note,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'createdAtIso': createdAtIso,
        'updatedAtIso': updatedAtIso,
        'platform': platform.name,
        'canConnectAccount': canConnectAccount,
        'canSchedulePost': canSchedulePost,
        'canAutoPublish': canAutoPublish,
        'supportsMediaUpload': supportsMediaUpload,
        'supportsVideo': supportsVideo,
        'supportsMultiAccount': supportsMultiAccount,
        'note': note,
      };

  factory PlatformCapability.fromJson(Map<String, Object?> json) {
    return PlatformCapability(
      id: stringOrFallback(json['id'], 'capability-local'),
      createdAtIso: isoOrNow(json['createdAtIso']),
      updatedAtIso: isoOrNow(json['updatedAtIso']),
      platform: SocialPlatformX.fromName(json['platform'] as String?),
      canConnectAccount: json['canConnectAccount'] == true,
      canSchedulePost: json['canSchedulePost'] == true,
      canAutoPublish: json['canAutoPublish'] == true,
      supportsMediaUpload: json['supportsMediaUpload'] == true,
      supportsVideo: json['supportsVideo'] == true,
      supportsMultiAccount: json['supportsMultiAccount'] == true,
      note: json['note'] as String?,
    );
  }
}


