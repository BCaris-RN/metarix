import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:metarix/core/backend_config.dart';
import 'package:metarix/data/local_metarix_gateway.dart';
import 'package:metarix/metarix_core/models/connected_social_account.dart';
import 'package:metarix/metarix_core/models/connector_runtime_state.dart';
import 'package:metarix/services/linkedin/linkedin_auth_service.dart';
import 'package:metarix/services/linkedin/linkedin_connection_service.dart';
import 'package:metarix/services/linkedin/linkedin_profile_service.dart';
import 'package:metarix/services/linkedin/linkedin_token_exchange_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('callback completion persists connected account and clears pending auth', () async {
    SharedPreferences.setMockInitialValues({});
    final gateway = await LocalMetarixGateway.bootstrap();
    final config = const BackendConfig(
      mode: BackendMode.demo,
      supabaseUrl: '',
      supabaseAnonKey: '',
      linkedinClientIdValue: 'client-123',
      linkedinClientSecretValue: 'secret-456',
      linkedinRedirectUriValue: 'http://127.0.0.1:8787/linkedin/callback',
      linkedinScopesValue: 'openid profile w_member_social',
    );
    final authService = LinkedInAuthService(
      random: _FixedRandom(),
      now: () => DateTime.utc(2026, 4, 18, 18),
    );
    final pendingSession = authService.startAuthSession(config);
    await gateway.savePendingLinkedInAuthSession(pendingSession);

    final tokenService = LinkedInTokenExchangeService(
      client: MockClient((request) async {
        expect(
          request.url.toString(),
          'https://www.linkedin.com/oauth/v2/accessToken',
        );
        return http.Response(
          '{"access_token":"access-1","token_type":"Bearer","expires_in":3600,"scope":"openid profile"}',
          200,
        );
      }),
    );
    final profileService = LinkedInProfileService(
      client: MockClient((request) async {
        return http.Response(
          '{"sub":"member-123","name":"Northstar Operator","picture":"https://example.com/profile.jpg","email":"operator@example.com"}',
          200,
        );
      }),
    );
    final connectionService = LinkedInConnectionService(
      gateway,
      tokenService,
      profileService: profileService,
    );

    await connectionService.completeFromCallbackUrl(
      config: config,
      callbackUrl:
          'http://127.0.0.1:8787/linkedin/callback?code=code-1&state=${pendingSession.state}',
    );

    final connected = gateway.connectedAccountFor('linkedin');
    expect(connected, isNotNull);
    expect(connected!.status, SocialConnectionStatus.connected);
    expect(
      gateway.connectorRuntimeStateFor('linkedin')?.availability,
      ConnectorAvailabilityState.connected,
    );
    expect(gateway.pendingLinkedInAuthSession, isNull);
    expect(gateway.linkedInAuthRecords, hasLength(1));
    expect(gateway.linkedInAuthRecords.single.accessToken, 'access-1');
  });

  test('callback completion hydrates identity from the id token first', () async {
    SharedPreferences.setMockInitialValues({});
    final gateway = await LocalMetarixGateway.bootstrap();
    final config = const BackendConfig(
      mode: BackendMode.demo,
      supabaseUrl: '',
      supabaseAnonKey: '',
      linkedinClientIdValue: 'client-123',
      linkedinClientSecretValue: 'secret-456',
      linkedinRedirectUriValue: 'http://127.0.0.1:8787/linkedin/callback',
      linkedinScopesValue: 'openid profile w_member_social',
    );
    final authService = LinkedInAuthService(
      random: _FixedRandom(),
      now: () => DateTime.utc(2026, 4, 18, 18),
    );
    final pendingSession = authService.startAuthSession(config);
    await gateway.savePendingLinkedInAuthSession(pendingSession);

    final tokenService = LinkedInTokenExchangeService(
      client: MockClient((request) async {
        return http.Response(
          '{"access_token":"access-1","token_type":"Bearer","expires_in":3600,"scope":"openid profile","id_token":"${_buildIdToken()}"}',
          200,
        );
      }),
    );
    final profileService = LinkedInProfileService(
      client: MockClient((request) async {
        fail('userinfo should not be called when the id token has identity claims');
      }),
    );
    final connectionService = LinkedInConnectionService(
      gateway,
      tokenService,
      profileService: profileService,
    );

    await connectionService.completeFromCallbackUrl(
      config: config,
      callbackUrl:
          'http://127.0.0.1:8787/linkedin/callback?code=code-1&state=${pendingSession.state}',
    );

    final connected = gateway.connectedAccountFor('linkedin');
    expect(connected, isNotNull);
    expect(connected!.externalAccountId, 'member-123');
    expect(connected.displayName, 'Northstar Operator');
    expect(connected.authorUrn, 'urn:li:person:member-123');
    expect(connected.profileImageUrl, 'https://example.com/profile.jpg');
    expect(connected.note, 'Profile hydrated from ID token.');
  });

  test('callback completion falls back to userinfo when id token lacks a name', () async {
    SharedPreferences.setMockInitialValues({});
    final gateway = await LocalMetarixGateway.bootstrap();
    final config = const BackendConfig(
      mode: BackendMode.demo,
      supabaseUrl: '',
      supabaseAnonKey: '',
      linkedinClientIdValue: 'client-123',
      linkedinClientSecretValue: 'secret-456',
      linkedinRedirectUriValue: 'http://127.0.0.1:8787/linkedin/callback',
      linkedinScopesValue: 'openid profile w_member_social',
    );
    final authService = LinkedInAuthService(
      random: _FixedRandom(),
      now: () => DateTime.utc(2026, 4, 18, 18),
    );
    final pendingSession = authService.startAuthSession(config);
    await gateway.savePendingLinkedInAuthSession(pendingSession);

    final tokenService = LinkedInTokenExchangeService(
      client: MockClient((request) async {
        return http.Response(
          '{"access_token":"access-1","token_type":"Bearer","expires_in":3600,"scope":"openid profile"}',
          200,
        );
      }),
    );
    final profileService = LinkedInProfileService(
      client: MockClient((request) async {
        expect(request.url.toString(), 'https://api.linkedin.com/v2/userinfo');
        return http.Response(
          '{"sub":"member-456","name":"Hydrated Operator","picture":"https://example.com/userinfo.jpg","email":"operator@example.com"}',
          200,
        );
      }),
    );
    final connectionService = LinkedInConnectionService(
      gateway,
      tokenService,
      profileService: profileService,
    );

    await connectionService.completeFromCallbackUrl(
      config: config,
      callbackUrl:
          'http://127.0.0.1:8787/linkedin/callback?code=code-1&state=${pendingSession.state}',
    );

    final connected = gateway.connectedAccountFor('linkedin');
    expect(connected, isNotNull);
    expect(connected!.externalAccountId, 'member-456');
    expect(connected.displayName, 'Hydrated Operator');
    expect(connected.authorUrn, 'urn:li:person:member-456');
    expect(connected.profileImageUrl, 'https://example.com/userinfo.jpg');
    expect(connected.note, 'Profile hydrated from userinfo.');
  });

  test('callback completion fails closed on state mismatch', () async {
    SharedPreferences.setMockInitialValues({});
    final gateway = await LocalMetarixGateway.bootstrap();
    final config = const BackendConfig(
      mode: BackendMode.demo,
      supabaseUrl: '',
      supabaseAnonKey: '',
      linkedinClientIdValue: 'client-123',
      linkedinClientSecretValue: 'secret-456',
      linkedinRedirectUriValue: 'http://127.0.0.1:8787/linkedin/callback',
      linkedinScopesValue: 'openid profile w_member_social',
    );
    final authService = LinkedInAuthService(
      random: _FixedRandom(),
      now: () => DateTime.utc(2026, 4, 18, 18),
    );
    final pendingSession = authService.startAuthSession(config);
    await gateway.savePendingLinkedInAuthSession(pendingSession);

    final tokenService = LinkedInTokenExchangeService(
      client: MockClient((request) async {
        fail('token exchange should not be reached on state mismatch');
      }),
    );
    final connectionService = LinkedInConnectionService(gateway, tokenService);

    expect(
      () => connectionService.completeFromCallbackUrl(
        config: config,
        callbackUrl:
            'http://127.0.0.1:8787/linkedin/callback?code=code-1&state=wrong-state',
      ),
      throwsStateError,
    );
    expect(gateway.connectedAccountFor('linkedin'), isNull);
    expect(gateway.pendingLinkedInAuthSession, isNotNull);
  });
}

class _FixedRandom implements Random {
  int _value = 0;

  @override
  bool nextBool() => nextInt(2) == 1;

  @override
  double nextDouble() => nextInt(1 << 30) / (1 << 30);

  @override
  int nextInt(int max) {
    _value = (_value + 73) % max;
    return _value;
  }
}

String _buildIdToken() {
  String encodePart(Map<String, Object?> json) {
    return base64Url
        .encode(utf8.encode(jsonEncode(json)))
        .replaceAll('=', '');
  }

  return [
    encodePart({'alg': 'none', 'typ': 'JWT'}),
    encodePart({
      'sub': 'member-123',
      'name': 'Northstar Operator',
      'picture': 'https://example.com/profile.jpg',
      'email': 'operator@example.com',
    }),
    '',
  ].join('.');
}
