import '../common/release_helpers.dart';
import 'social_platform.dart';

enum TokenStatus { active, expiring, expired, revoked, missing }

extension TokenStatusX on TokenStatus {
  static TokenStatus fromName(String? value) {
    return TokenStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => TokenStatus.missing,
    );
  }
}

class ConnectedSocialAccount {
  const ConnectedSocialAccount({
    required this.id,
    required this.createdAtIso,
    required this.updatedAtIso,
    required this.platform,
    required this.accountId,
    required this.workspaceId,
    required this.providerAccountId,
    required this.displayName,
    required this.username,
    required this.profileImageUrl,
    required this.scopes,
    required this.missingScopes,
    required this.tokenStatus,
    required this.expiresAtIso,
    required this.lastHealthCheckIso,
    required this.connectionStatus,
    required this.metadata,
    required this.tokenRef,
    this.note,
    String? accountHandle,
    String? externalAccountId,
    bool? isLocalOnly,
    String? lastSyncAtIso,
    String? tokenExpiresAtIso,
  });

  final String id;
  final String createdAtIso;
  final String updatedAtIso;
  final SocialPlatform platform;
  final String accountId;
  final String workspaceId;
  final String providerAccountId;
  final String displayName;
  final String username;
  final String? profileImageUrl;
  final List<String> scopes;
  final List<String> missingScopes;
  final TokenStatus tokenStatus;
  final String? expiresAtIso;
  final String? lastHealthCheckIso;
  final ConnectionStatus connectionStatus;
  final Map<String, Object?> metadata;
  final String tokenRef;
  final String? note;

  ConnectedSocialAccount copyWith({
    String? id,
    String? createdAtIso,
    String? updatedAtIso,
    SocialPlatform? platform,
    String? accountId,
    String? workspaceId,
    String? providerAccountId,
    String? displayName,
    String? username,
    String? profileImageUrl,
    bool clearProfileImageUrl = false,
    List<String>? scopes,
    List<String>? missingScopes,
    TokenStatus? tokenStatus,
    String? expiresAtIso,
    bool clearExpiresAtIso = false,
    String? lastHealthCheckIso,
    bool clearLastHealthCheckIso = false,
    ConnectionStatus? connectionStatus,
    Map<String, Object?>? metadata,
    String? tokenRef,
    String? note,
    bool clearNote = false,
  }) {
    return ConnectedSocialAccount(
      id: id ?? this.id,
      createdAtIso: createdAtIso ?? this.createdAtIso,
      updatedAtIso: updatedAtIso ?? this.updatedAtIso,
      platform: platform ?? this.platform,
      accountId: accountId ?? this.accountId,
      workspaceId: workspaceId ?? this.workspaceId,
      providerAccountId: providerAccountId ?? this.providerAccountId,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      profileImageUrl: clearProfileImageUrl
          ? null
          : profileImageUrl ?? this.profileImageUrl,
      scopes: scopes ?? this.scopes,
      missingScopes: missingScopes ?? this.missingScopes,
      tokenStatus: tokenStatus ?? this.tokenStatus,
      expiresAtIso: clearExpiresAtIso ? null : expiresAtIso ?? this.expiresAtIso,
      lastHealthCheckIso: clearLastHealthCheckIso
          ? null
          : lastHealthCheckIso ?? this.lastHealthCheckIso,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      metadata: metadata ?? this.metadata,
      tokenRef: tokenRef ?? this.tokenRef,
      note: clearNote ? null : note ?? this.note,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'createdAtIso': createdAtIso,
        'updatedAtIso': updatedAtIso,
        'platform': platform.name,
        'accountId': accountId,
        'workspaceId': workspaceId,
        'providerAccountId': providerAccountId,
        'displayName': displayName,
        'username': username,
        'profileImageUrl': profileImageUrl,
        'scopes': scopes,
        'missingScopes': missingScopes,
        'tokenStatus': tokenStatus.name,
        'expiresAtIso': expiresAtIso,
        'lastHealthCheckIso': lastHealthCheckIso,
        'connectionStatus': connectionStatus.name,
        'metadata': metadata,
        'tokenRef': tokenRef,
        'note': note,
      };

  factory ConnectedSocialAccount.fromJson(Map<String, Object?> json) {
    return ConnectedSocialAccount(
      id: stringOrFallback(json['id'], 'account-local'),
      createdAtIso: isoOrNow(json['createdAtIso']),
      updatedAtIso: isoOrNow(json['updatedAtIso']),
      platform: SocialPlatformX.fromName(json['platform'] as String?),
      accountId: stringOrFallback(json['accountId'], 'account-local'),
      workspaceId: stringOrFallback(json['workspaceId'], 'workspace-local'),
      providerAccountId: stringOrFallback(
        json['providerAccountId'],
        'provider-local',
      ),
      displayName: stringOrEmpty(json['displayName']),
      username: stringOrEmpty(json['username']),
      profileImageUrl: json['profileImageUrl'] as String?,
      scopes: stringListFromJson(json['scopes']),
      missingScopes: stringListFromJson(json['missingScopes']),
      tokenStatus: TokenStatusX.fromName(json['tokenStatus'] as String?),
      expiresAtIso: json['expiresAtIso'] as String?,
      lastHealthCheckIso: json['lastHealthCheckIso'] as String?,
      connectionStatus:
          ConnectionStatusX.fromName(json['connectionStatus'] as String?),
      metadata: (json['metadata'] as Map?)?.cast<String, Object?>() ??
          <String, Object?>{},
      tokenRef: stringOrFallback(json['tokenRef'], 'ref-local'),
      note: json['note'] as String?,
    );
  }
}
