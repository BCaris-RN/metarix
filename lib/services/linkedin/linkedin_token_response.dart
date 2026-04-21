class LinkedInTokenResponse {
  const LinkedInTokenResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.scope,
    required this.refreshToken,
    required this.idToken,
    required this.rawJson,
  });

  final String accessToken;
  final String tokenType;
  final int? expiresIn;
  final String? scope;
  final String? refreshToken;
  final String? idToken;
  final Map<String, Object?> rawJson;

  factory LinkedInTokenResponse.fromJson(Map<String, Object?> json) {
    return LinkedInTokenResponse(
      accessToken: (json['access_token'] as String?) ?? '',
      tokenType: (json['token_type'] as String?) ?? '',
      expiresIn: (json['expires_in'] as num?)?.toInt(),
      scope: json['scope'] as String?,
      refreshToken: json['refresh_token'] as String?,
      idToken: json['id_token'] as String?,
      rawJson: json,
    );
  }
}
