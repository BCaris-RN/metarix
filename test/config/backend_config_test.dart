import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:metarix/core/backend_config.dart';
import 'package:metarix/metarix_core/models/connector_runtime_state.dart';
import 'package:metarix/services/linkedin/linkedin_auth_service.dart';

void main() {
  test(
    'linkedin runtime configuration defaults to not configured when env is empty',
    () {
      expect(BackendConfig.linkedinConfigured, isFalse);

      final runtimeState = BackendConfig.linkedinRuntimeState();

      expect(runtimeState.platformKey, 'linkedin');
      expect(
        runtimeState.availability,
        ConnectorAvailabilityState.notConfigured,
      );
      expect(runtimeState.clientIdPresent, isFalse);
      expect(runtimeState.redirectUriPresent, isFalse);
    },
  );

  test('linkedin auth service builds an awaiting-callback PKCE launch URL', () {
    const config = BackendConfig(
      mode: BackendMode.demo,
      supabaseUrl: '',
      supabaseAnonKey: '',
      linkedinClientIdValue: 'client-123',
      linkedinRedirectUriValue: 'http://127.0.0.1:8787/linkedin/callback',
      linkedinScopesValue: 'openid profile w_member_social',
    );
    final service = LinkedInAuthService(
      random: Random(7),
      now: () => DateTime.utc(2026, 4, 18, 18),
    );

    final session = service.startAuthSession(config);
    final authorizationUri = Uri.parse(session.authorizationUrl);

    expect(config.isLinkedInConfigured, isTrue);
    expect(session.platformKey, 'linkedin');
    expect(session.state, isNotEmpty);
    expect(session.codeVerifier, isNotEmpty);
    expect(session.codeChallenge, isNotEmpty);
    expect(session.codeVerifier, isNot(session.codeChallenge));
    expect(session.redirectUri, config.linkedinRedirectUriValue);
    expect(session.status.name, 'awaitingCallback');
    expect(authorizationUri.host, 'www.linkedin.com');
    expect(authorizationUri.path, '/oauth/v2/authorization');
    expect(authorizationUri.queryParameters['client_id'], 'client-123');
    expect(authorizationUri.queryParameters['response_type'], 'code');
    expect(authorizationUri.queryParameters['code_challenge_method'], 'S256');
    expect(
      authorizationUri.queryParameters['redirect_uri'],
      config.linkedinRedirectUriValue,
    );
  });
}
