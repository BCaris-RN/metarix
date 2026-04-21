class LinkedInAuthRecord {
  const LinkedInAuthRecord({
    required this.platformKey,
    required this.accessToken,
    required this.tokenType,
    required this.scope,
    required this.persistedAtIso,
    this.idToken,
    this.refreshToken,
    this.expiresAtIso,
    this.externalAccountId,
  });

  final String platformKey;
  final String accessToken;
  final String tokenType;
  final String? idToken;
  final String? refreshToken;
  final String? expiresAtIso;
  final String? scope;
  final String persistedAtIso;
  final String? externalAccountId;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'platformKey': platformKey,
      'accessToken': accessToken,
      'idToken': idToken,
      'refreshToken': refreshToken,
      'tokenType': tokenType,
      'scope': scope,
      'expiresAtIso': expiresAtIso,
      'persistedAtIso': persistedAtIso,
      'externalAccountId': externalAccountId,
    };
  }

  factory LinkedInAuthRecord.fromJson(Map<String, Object?> json) {
    return LinkedInAuthRecord(
      platformKey: (json['platformKey'] as String?) ?? 'linkedin',
      accessToken: (json['accessToken'] as String?) ?? '',
      idToken: json['idToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      tokenType: (json['tokenType'] as String?) ?? '',
      scope: json['scope'] as String?,
      expiresAtIso: json['expiresAtIso'] as String?,
      persistedAtIso: (json['persistedAtIso'] as String?) ?? '',
      externalAccountId: json['externalAccountId'] as String?,
    );
  }
}
