enum LinkedInAuthSessionStatus { started, awaitingCallback, expired, failed }

class LinkedInAuthSession {
  const LinkedInAuthSession({
    required this.platformKey,
    required this.state,
    required this.codeVerifier,
    required this.codeChallenge,
    required this.redirectUri,
    required this.authorizationUrl,
    required this.startedAtIso,
    required this.status,
  });

  final String platformKey;
  final String state;
  final String codeVerifier;
  final String codeChallenge;
  final String redirectUri;
  final String authorizationUrl;
  final String startedAtIso;
  final LinkedInAuthSessionStatus status;

  LinkedInAuthSession copyWith({
    String? platformKey,
    String? state,
    String? codeVerifier,
    String? codeChallenge,
    String? redirectUri,
    String? authorizationUrl,
    String? startedAtIso,
    LinkedInAuthSessionStatus? status,
  }) {
    return LinkedInAuthSession(
      platformKey: platformKey ?? this.platformKey,
      state: state ?? this.state,
      codeVerifier: codeVerifier ?? this.codeVerifier,
      codeChallenge: codeChallenge ?? this.codeChallenge,
      redirectUri: redirectUri ?? this.redirectUri,
      authorizationUrl: authorizationUrl ?? this.authorizationUrl,
      startedAtIso: startedAtIso ?? this.startedAtIso,
      status: status ?? this.status,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'platformKey': platformKey,
      'state': state,
      'codeVerifier': codeVerifier,
      'codeChallenge': codeChallenge,
      'redirectUri': redirectUri,
      'authorizationUrl': authorizationUrl,
      'startedAtIso': startedAtIso,
      'status': status.name,
    };
  }

  factory LinkedInAuthSession.fromJson(Map<String, Object?> json) {
    return LinkedInAuthSession(
      platformKey: (json['platformKey'] as String?) ?? 'linkedin',
      state: (json['state'] as String?) ?? '',
      codeVerifier: (json['codeVerifier'] as String?) ?? '',
      codeChallenge: (json['codeChallenge'] as String?) ?? '',
      redirectUri: (json['redirectUri'] as String?) ?? '',
      authorizationUrl: (json['authorizationUrl'] as String?) ?? '',
      startedAtIso: (json['startedAtIso'] as String?) ?? '',
      status: LinkedInAuthSessionStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => LinkedInAuthSessionStatus.failed,
      ),
    );
  }
}
