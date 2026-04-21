import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/backend_config.dart';
import 'linkedin_auth_session.dart';
import 'linkedin_token_response.dart';

class LinkedInTokenExchangeService {
  const LinkedInTokenExchangeService({http.Client? client})
    : _client = client;

  static final Uri tokenEndpoint = Uri.parse(
    'https://www.linkedin.com/oauth/v2/accessToken',
  );

  final http.Client? _client;

  Future<LinkedInTokenResponse> exchangeAuthorizationCode({
    required BackendConfig config,
    required LinkedInAuthSession session,
    required String code,
  }) async {
    final client = _client ?? http.Client();
    final ownsClient = _client == null;
    try {
      final response = await client.post(
        tokenEndpoint,
        headers: const {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': config.linkedinRedirectUriValue.trim(),
          'client_id': config.linkedinClientIdValue.trim(),
          'code_verifier': session.codeVerifier,
        },
      );

      if (response.statusCode != 200) {
        throw StateError(
          'LinkedIn token exchange failed with HTTP ${response.statusCode}.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw StateError('LinkedIn token exchange returned malformed JSON.');
      }

      final json = Map<String, Object?>.from(decoded);
      final token = LinkedInTokenResponse.fromJson(json);
      if (token.accessToken.isEmpty) {
        throw StateError('LinkedIn token exchange did not return an access token.');
      }
      return token;
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  Uri buildTokenRequestUri(BackendConfig config) => tokenEndpoint;
}
