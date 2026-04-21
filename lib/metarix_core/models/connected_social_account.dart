enum SocialConnectionStatus {
  unavailable,
  notConfigured,
  configured,
  connected,
  error,
}

class ConnectedSocialAccount {
  const ConnectedSocialAccount({
    required this.platformKey,
    required this.displayName,
    required this.accountHandle,
    required this.status,
    this.externalAccountId,
    this.profileImageUrl,
    this.authorUrn,
    this.scope,
    this.connectedAtIso,
    this.lastSyncAtIso,
    this.note,
  });

  final String platformKey; // linkedin, facebook, instagram
  final String displayName;
  final String accountHandle;
  final SocialConnectionStatus status;
  final String? externalAccountId;
  final String? profileImageUrl;
  final String? authorUrn;
  final String? scope;
  final String? connectedAtIso;
  final String? lastSyncAtIso;
  final String? note;

  ConnectedSocialAccount copyWith({
    String? platformKey,
    String? displayName,
    String? accountHandle,
    SocialConnectionStatus? status,
    String? externalAccountId,
    String? profileImageUrl,
    String? authorUrn,
    String? scope,
    String? connectedAtIso,
    String? lastSyncAtIso,
    String? note,
  }) {
    return ConnectedSocialAccount(
      platformKey: platformKey ?? this.platformKey,
      displayName: displayName ?? this.displayName,
      accountHandle: accountHandle ?? this.accountHandle,
      status: status ?? this.status,
      externalAccountId: externalAccountId ?? this.externalAccountId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      authorUrn: authorUrn ?? this.authorUrn,
      scope: scope ?? this.scope,
      connectedAtIso: connectedAtIso ?? this.connectedAtIso,
      lastSyncAtIso: lastSyncAtIso ?? this.lastSyncAtIso,
      note: note ?? this.note,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'platformKey': platformKey,
      'displayName': displayName,
      'accountHandle': accountHandle,
      'status': status.name,
      'externalAccountId': externalAccountId,
      'profileImageUrl': profileImageUrl,
      'authorUrn': authorUrn,
      'scope': scope,
      'connectedAtIso': connectedAtIso,
      'lastSyncAtIso': lastSyncAtIso,
      'note': note,
    };
  }

  factory ConnectedSocialAccount.fromJson(Map<String, Object?> json) {
    return ConnectedSocialAccount(
      platformKey: (json['platformKey'] as String?) ?? '',
      displayName: (json['displayName'] as String?) ?? '',
      accountHandle: (json['accountHandle'] as String?) ?? '',
      status: SocialConnectionStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => SocialConnectionStatus.unavailable,
      ),
      externalAccountId: json['externalAccountId'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      authorUrn: json['authorUrn'] as String?,
      scope: json['scope'] as String?,
      connectedAtIso: json['connectedAtIso'] as String?,
      lastSyncAtIso: json['lastSyncAtIso'] as String?,
      note: json['note'] as String?,
    );
  }
}
