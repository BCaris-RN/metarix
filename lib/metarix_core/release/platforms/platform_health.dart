import '../accounts/social_platform.dart';
import '../common/release_helpers.dart';

class PlatformHealth {
  const PlatformHealth({
    required this.id,
    required this.createdAtIso,
    required this.updatedAtIso,
    required this.platform,
    required this.connectionStatus,
    required this.isHealthy,
    required this.lastCheckedAtIso,
    required this.lastErrorCode,
    required this.lastErrorMessage,
    required this.retryable,
  });

  final String id;
  final String createdAtIso;
  final String updatedAtIso;
  final SocialPlatform platform;
  final ConnectionStatus connectionStatus;
  final bool isHealthy;
  final String? lastCheckedAtIso;
  final String? lastErrorCode;
  final String? lastErrorMessage;
  final bool retryable;

  PlatformHealth copyWith({
    String? id,
    String? createdAtIso,
    String? updatedAtIso,
    SocialPlatform? platform,
    ConnectionStatus? connectionStatus,
    bool? isHealthy,
    String? lastCheckedAtIso,
    bool clearLastCheckedAtIso = false,
    String? lastErrorCode,
    bool clearLastErrorCode = false,
    String? lastErrorMessage,
    bool clearLastErrorMessage = false,
    bool? retryable,
  }) {
    return PlatformHealth(
      id: id ?? this.id,
      createdAtIso: createdAtIso ?? this.createdAtIso,
      updatedAtIso: updatedAtIso ?? this.updatedAtIso,
      platform: platform ?? this.platform,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      isHealthy: isHealthy ?? this.isHealthy,
      lastCheckedAtIso: clearLastCheckedAtIso
          ? null
          : lastCheckedAtIso ?? this.lastCheckedAtIso,
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
        'connectionStatus': connectionStatus.name,
        'isHealthy': isHealthy,
        'lastCheckedAtIso': lastCheckedAtIso,
        'lastErrorCode': lastErrorCode,
        'lastErrorMessage': lastErrorMessage,
        'retryable': retryable,
      };

  factory PlatformHealth.fromJson(Map<String, Object?> json) {
    return PlatformHealth(
      id: stringOrFallback(json['id'], 'health-local'),
      createdAtIso: isoOrNow(json['createdAtIso']),
      updatedAtIso: isoOrNow(json['updatedAtIso']),
      platform: SocialPlatformX.fromName(json['platform'] as String?),
      connectionStatus:
          ConnectionStatusX.fromName(json['connectionStatus'] as String?),
      isHealthy: json['isHealthy'] == true,
      lastCheckedAtIso: json['lastCheckedAtIso'] as String?,
      lastErrorCode: json['lastErrorCode'] as String?,
      lastErrorMessage: json['lastErrorMessage'] as String?,
      retryable: json['retryable'] == true,
    );
  }
}


