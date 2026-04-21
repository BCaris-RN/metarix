import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:metarix/data/local_storage_adapter.dart';
import 'package:metarix/data/sample_data_pack.dart';
import 'package:metarix/metarix_core/models/connected_social_account.dart';
import 'package:metarix/metarix_core/models/connector_runtime_state.dart';
import 'package:metarix/metarix_core/models/linkedin_auth_record.dart';
import 'package:metarix/services/linkedin/linkedin_auth_session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'snapshot round-trips connected accounts and connector runtime state',
    () async {
      SharedPreferences.setMockInitialValues({});
      final adapter = await LocalStorageAdapter.create();
      final snapshot = SampleDataPack.initialSnapshot().copyWith(
        connectedAccounts: const [
          ConnectedSocialAccount(
            platformKey: 'linkedin',
            displayName: 'Northstar LinkedIn',
            accountHandle: '@northstar',
            status: SocialConnectionStatus.connected,
            externalAccountId: 'linkedin-account-1',
            connectedAtIso: '2026-04-18T10:00:00.000Z',
            lastSyncAtIso: '2026-04-18T10:30:00.000Z',
            note: 'Connected for live cutover prep.',
          ),
        ],
        connectorRuntimeStates: const [
          ConnectorRuntimeState(
            platformKey: 'linkedin',
            availability: ConnectorAvailabilityState.connected,
            clientIdPresent: true,
            redirectUriPresent: true,
            secretPresent: false,
            note: 'LinkedIn connector is configured and connected.',
          ),
        ],
        pendingLinkedInAuthSession: const LinkedInAuthSession(
          platformKey: 'linkedin',
          state: 'state-1',
          codeVerifier: 'verifier-1',
          codeChallenge: 'challenge-1',
          redirectUri: 'http://127.0.0.1:8787/linkedin/callback',
          authorizationUrl:
              'https://www.linkedin.com/oauth/v2/authorization?state=state-1',
          startedAtIso: '2026-04-18T10:00:00.000Z',
          status: LinkedInAuthSessionStatus.awaitingCallback,
        ),
        linkedInAuthRecords: const [
          LinkedInAuthRecord(
            platformKey: 'linkedin',
            accessToken: 'token-1',
            idToken: 'id-token-1',
            refreshToken: 'refresh-1',
            tokenType: 'Bearer',
            scope: 'openid profile',
            expiresAtIso: '2026-04-18T11:00:00.000Z',
            persistedAtIso: '2026-04-18T10:00:00.000Z',
            externalAccountId: 'account-1',
          ),
        ],
      );

      await adapter.saveSnapshot(snapshot);
      final loaded = await adapter.loadSnapshot();

      expect(loaded, isNotNull);
      expect(loaded!.connectedAccounts, hasLength(1));
      expect(
        loaded.connectedAccounts.single.externalAccountId,
        'linkedin-account-1',
      );
      expect(loaded.connectorRuntimeStates, hasLength(1));
      expect(
        loaded.connectorRuntimeStates.single.availability,
        ConnectorAvailabilityState.connected,
      );
      expect(loaded.pendingLinkedInAuthSession, isNotNull);
      expect(loaded.pendingLinkedInAuthSession!.state, 'state-1');
      expect(
        loaded.pendingLinkedInAuthSession!.status,
        LinkedInAuthSessionStatus.awaitingCallback,
      );
      expect(loaded.linkedInAuthRecords, hasLength(1));
      expect(loaded.linkedInAuthRecords.single.accessToken, 'token-1');
      expect(loaded.linkedInAuthRecords.single.idToken, 'id-token-1');
    },
  );
}
