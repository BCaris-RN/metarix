import 'dart:convert';

class LinkedInIdTokenClaims {
  const LinkedInIdTokenClaims({
    required this.subject,
    required this.name,
    required this.picture,
    required this.email,
    required this.rawJson,
  });

  final String? subject;
  final String? name;
  final String? picture;
  final String? email;
  final Map<String, Object?> rawJson;

  bool get hasUsableSubject => subject != null && subject!.trim().isNotEmpty;

  factory LinkedInIdTokenClaims.fromJwt(String jwt) {
    final parts = jwt.split('.');
    if (parts.length < 2) {
      throw StateError('LinkedIn ID token was not a valid JWT.');
    }
    final decoded = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final json = jsonDecode(decoded);
    if (json is! Map) {
      throw StateError('LinkedIn ID token claims were malformed.');
    }
    final map = Map<String, Object?>.from(json);
    return LinkedInIdTokenClaims(
      subject: map['sub'] as String?,
      name: map['name'] as String?,
      picture: map['picture'] as String?,
      email: map['email'] as String?,
      rawJson: map,
    );
  }
}
