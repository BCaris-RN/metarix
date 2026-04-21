import 'dart:convert';

import 'package:http/http.dart' as http;

class LinkedInProfileService {
  const LinkedInProfileService({http.Client? client}) : _client = client;

  static final Uri userInfoEndpoint = Uri.parse('https://api.linkedin.com/v2/userinfo');

  final http.Client? _client;

  Future<Map<String, Object?>> loadUserInfo({
    required String accessToken,
  }) async {
    final client = _client ?? http.Client();
    final ownsClient = _client == null;
    try {
      final response = await client.get(
        userInfoEndpoint,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode != 200) {
        throw StateError(
          'LinkedIn userinfo request failed with HTTP ${response.statusCode}.',
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw StateError('LinkedIn userinfo response was malformed JSON.');
      }
      return Map<String, Object?>.from(decoded);
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }
}
