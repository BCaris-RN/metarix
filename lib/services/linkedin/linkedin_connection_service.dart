import '../../core/backend_config.dart';
import '../../data/local_metarix_gateway.dart';
import '../../metarix_core/models/connected_social_account.dart';
import '../../metarix_core/models/linkedin_auth_record.dart';
import 'linkedin_callback_result.dart';
import 'linkedin_id_token_claims.dart';
import 'linkedin_profile_service.dart';
import 'linkedin_token_exchange_service.dart';

class LinkedInConnectionService {
  LinkedInConnectionService(
    this._gateway,
    this._tokenExchangeService, {
    LinkedInProfileService? profileService,
    DateTime Function()? now,
  }) : _profileService = profileService ?? const LinkedInProfileService(),
       _now = now;

  final LocalMetarixGateway _gateway;
  final LinkedInTokenExchangeService _tokenExchangeService;
  final LinkedInProfileService _profileService;
  final DateTime Function()? _now;

  LinkedInCallbackResult parseCallbackUrl(String callbackUrl) {
    return LinkedInCallbackResult.fromUri(Uri.parse(callbackUrl.trim()));
  }

  Future<void> completeFromCallbackUrl({
    required BackendConfig config,
    required String callbackUrl,
  }) async {
    final pending = _gateway.pendingLinkedInAuthSession;
    if (pending == null) {
      throw StateError('No pending LinkedIn auth session exists.');
    }

    final callback = parseCallbackUrl(callbackUrl);
    if (callback.hasError) {
      throw StateError(
        callback.errorDescription?.isNotEmpty ?? false
            ? callback.errorDescription!
            : callback.error!,
      );
    }
    if (!callback.hasCode) {
      throw StateError('LinkedIn callback did not contain an authorization code.');
    }
    if (callback.state == null || callback.state != pending.state) {
      throw StateError('LinkedIn callback state did not match the pending auth session.');
    }

    final tokenResponse = await _tokenExchangeService.exchangeAuthorizationCode(
      config: config,
      session: pending,
      code: callback.code!,
    );
    final connectedAt = (_now ?? DateTime.now)().toUtc().toIso8601String();
    final idTokenClaims = tokenResponse.idToken == null
        ? null
        : LinkedInIdTokenClaims.fromJwt(tokenResponse.idToken!);
    final identity = await _buildIdentity(
      accessToken: tokenResponse.accessToken,
      idTokenClaims: idTokenClaims,
      scope: tokenResponse.scope,
    );
    final account = ConnectedSocialAccount(
      platformKey: 'linkedin',
      displayName: identity.displayName,
      accountHandle: identity.accountHandle,
      status: SocialConnectionStatus.connected,
      externalAccountId: identity.externalAccountId,
      profileImageUrl: identity.profileImageUrl,
      authorUrn: identity.authorUrn,
      scope: tokenResponse.scope,
      connectedAtIso: connectedAt,
      lastSyncAtIso: connectedAt,
      note: identity.note,
    );
    final authRecord = LinkedInAuthRecord(
      platformKey: 'linkedin',
      accessToken: tokenResponse.accessToken,
      idToken: tokenResponse.idToken,
      refreshToken: tokenResponse.refreshToken,
      tokenType: tokenResponse.tokenType,
      scope: tokenResponse.scope,
      expiresAtIso: tokenResponse.expiresIn == null
          ? null
          : (_now ?? DateTime.now)()
              .toUtc()
              .add(Duration(seconds: tokenResponse.expiresIn!))
              .toIso8601String(),
      persistedAtIso: connectedAt,
      externalAccountId: account.externalAccountId,
    );

    await _gateway.saveConnectedSocialAccount(account);
    await _gateway.saveLinkedInAuthRecord(authRecord);
    await _gateway.saveConnectorRuntimeState(
      config.linkedInRuntimeState(connected: true),
    );
    await _gateway.clearPendingLinkedInAuthSession();
  }

  Future<_LinkedInIdentity> _buildIdentity({
    required String accessToken,
    required LinkedInIdTokenClaims? idTokenClaims,
    required String? scope,
  }) async {
    final subject = idTokenClaims?.subject?.trim();
    final displayNameFromToken = idTokenClaims?.name?.trim();
    final profileImageFromToken = idTokenClaims?.picture?.trim();
    final emailFromToken = idTokenClaims?.email?.trim();
    final hasTokenIdentity = subject != null && subject.isNotEmpty;
    if (hasTokenIdentity && displayNameFromToken != null && displayNameFromToken.isNotEmpty) {
      return _LinkedInIdentity(
        externalAccountId: subject,
        authorUrn: 'urn:li:person:$subject',
        displayName: displayNameFromToken,
        accountHandle: emailFromToken != null && emailFromToken.isNotEmpty
            ? emailFromToken
            : 'linkedin-member',
        profileImageUrl: profileImageFromToken,
        note: 'Profile hydrated from ID token.',
      );
    }

    final userInfo = await _profileService.loadUserInfo(accessToken: accessToken);
    final externalAccountId = (userInfo['sub'] as String?)?.trim();
    if (externalAccountId == null || externalAccountId.isEmpty) {
      throw StateError('LinkedIn identity hydration failed to produce a member identifier.');
    }
    final displayName = (userInfo['name'] as String?)?.trim();
    if (displayName == null || displayName.isEmpty) {
      throw StateError('LinkedIn identity hydration did not return a display name.');
    }
    final picture = (userInfo['picture'] as String?)?.trim();
    final email = (userInfo['email'] as String?)?.trim();
    return _LinkedInIdentity(
      externalAccountId: externalAccountId,
      authorUrn: 'urn:li:person:$externalAccountId',
      displayName: displayName,
      accountHandle: email != null && email.isNotEmpty ? email : 'linkedin-member',
      profileImageUrl: picture,
      note: 'Profile hydrated from userinfo.',
    );
  }
}

class _LinkedInIdentity {
  const _LinkedInIdentity({
    required this.externalAccountId,
    required this.authorUrn,
    required this.displayName,
    required this.accountHandle,
    required this.profileImageUrl,
    required this.note,
  });

  final String externalAccountId;
  final String authorUrn;
  final String displayName;
  final String accountHandle;
  final String? profileImageUrl;
  final String note;
}
