import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../../core/backend_config.dart';
import 'linkedin_auth_session.dart';

class LinkedInAuthService {
  const LinkedInAuthService({Random? random, DateTime Function()? now})
    : _random = random,
      _now = now;

  static final Uri authorizationEndpoint = Uri.parse(
    'https://www.linkedin.com/oauth/v2/authorization',
  );

  final Random? _random;
  final DateTime Function()? _now;

  LinkedInAuthSession startAuthSession(BackendConfig config) {
    if (!config.isLinkedInConfigured) {
      throw StateError('LinkedIn runtime configuration is incomplete.');
    }

    final state = _randomToken(byteLength: 32);
    final codeVerifier = _randomToken(byteLength: 64);
    final codeChallenge = _codeChallengeFor(codeVerifier);
    final redirectUri = config.linkedinRedirectUriValue.trim();
    final authorizationUrl = authorizationEndpoint.replace(
      queryParameters: <String, String>{
        'response_type': 'code',
        'client_id': config.linkedinClientIdValue.trim(),
        'redirect_uri': redirectUri,
        'state': state,
        'scope': config.linkedInScopes.join(' '),
        'code_challenge': codeChallenge,
        'code_challenge_method': 'S256',
      },
    );

    return LinkedInAuthSession(
      platformKey: 'linkedin',
      state: state,
      codeVerifier: codeVerifier,
      codeChallenge: codeChallenge,
      redirectUri: redirectUri,
      authorizationUrl: authorizationUrl.toString(),
      startedAtIso: (_now ?? DateTime.now)().toUtc().toIso8601String(),
      status: LinkedInAuthSessionStatus.awaitingCallback,
    );
  }

  String _randomToken({required int byteLength}) {
    final random = _random ?? Random.secure();
    final bytes = List<int>.generate(byteLength, (_) => random.nextInt(256));
    return _base64UrlNoPadding(bytes);
  }

  String _codeChallengeFor(String codeVerifier) {
    final digest = sha256.convert(utf8.encode(codeVerifier));
    return _base64UrlNoPadding(digest.bytes);
  }

  String _base64UrlNoPadding(List<int> bytes) {
    return base64UrlEncode(bytes).replaceAll('=', '');
  }
}
