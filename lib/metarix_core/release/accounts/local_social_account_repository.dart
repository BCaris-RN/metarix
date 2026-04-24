import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../common/release_result.dart';
import '../platforms/platform_health.dart';
import 'connected_social_account.dart';
import 'social_platform.dart';
import 'social_account_repository.dart';

class LocalSocialAccountRepository implements SocialAccountRepository {
  LocalSocialAccountRepository._(this._preferences);

  static const String _storageKey = 'metarix.release.social_accounts.v1';

  final SharedPreferences _preferences;

  static Future<LocalSocialAccountRepository> create() async {
    final preferences = await SharedPreferences.getInstance();
    return LocalSocialAccountRepository._(preferences);
  }

  @override
  Future<ReleaseResult<List<ConnectedSocialAccount>>> listConnectedAccounts(
    String workspaceId,
  ) async {
    try {
      return ReleaseResult<List<ConnectedSocialAccount>>.success(
        _load().where((entry) => entry.workspaceId == workspaceId).toList(growable: false),
      );
    } catch (error) {
      return ReleaseResult<List<ConnectedSocialAccount>>.failure(
        errorCode: 'release.storage_failed',
        userMessage: 'Unable to load connected accounts.',
        technicalMessage: '$error',
        retryable: true,
      );
    }
  }

  @override
  Future<ReleaseResult<ConnectedSocialAccount?>> getAccount(String accountId) async {
    try {
      final account = _load().cast<ConnectedSocialAccount?>().firstWhere(
            (entry) => entry?.accountId == accountId,
            orElse: () => null,
          );
      return ReleaseResult<ConnectedSocialAccount?>.success(account);
    } catch (error) {
      return ReleaseResult<ConnectedSocialAccount?>.failure(
        errorCode: 'release.storage_failed',
        userMessage: 'Unable to load connected account.',
        technicalMessage: '$error',
        retryable: true,
      );
    }
  }

  @override
  Future<ReleaseResult<ConnectedSocialAccount>> saveAccount(
    ConnectedSocialAccount account,
  ) async {
    try {
      final items = _load();
      final index = items.indexWhere((entry) => entry.accountId == account.accountId);
      if (index >= 0) {
        items[index] = account;
      } else {
        items.add(account);
      }
      await _persist(items);
      return ReleaseResult<ConnectedSocialAccount>.success(account);
    } catch (error) {
      return ReleaseResult<ConnectedSocialAccount>.failure(
        errorCode: 'release.storage_failed',
        userMessage: 'Unable to save connected account.',
        technicalMessage: '$error',
        retryable: true,
      );
    }
  }

  @override
  Future<ReleaseResult<void>> disconnectAccount(String accountId) async {
    try {
      final items = _load()..removeWhere((entry) => entry.accountId == accountId);
      await _persist(items);
      return ReleaseResult<void>.success(null);
    } catch (error) {
      return ReleaseResult<void>.failure(
        errorCode: 'release.storage_failed',
        userMessage: 'Unable to disconnect account.',
        technicalMessage: '$error',
        retryable: true,
      );
    }
  }

  @override
  Future<ReleaseResult<ConnectedSocialAccount>> markAccountExpired(
    String accountId,
    String reason,
  ) async {
    final found = await getAccount(accountId);
    if (!found.success || found.value == null) {
      return ReleaseResult<ConnectedSocialAccount>.failure(
        errorCode: 'release.not_found',
        userMessage: 'Account not found.',
        technicalMessage: reason,
        retryable: false,
      );
    }
    final updated = found.value!.copyWith(
      connectionStatus: ConnectionStatus.expired,
      note: reason,
      updatedAtIso: DateTime.now().toUtc().toIso8601String(),
    );
    return saveAccount(updated);
  }

  @override
  Future<ReleaseResult<ConnectedSocialAccount>> updateHealth(
    String accountId,
    PlatformHealth health,
  ) async {
    final found = await getAccount(accountId);
    if (!found.success || found.value == null) {
      return ReleaseResult<ConnectedSocialAccount>.failure(
        errorCode: 'release.not_found',
        userMessage: 'Account not found.',
      );
    }
    final updated = found.value!.copyWith(
      connectionStatus: health.connectionStatus,
      lastHealthCheckIso: health.lastCheckedAtIso,
      updatedAtIso: DateTime.now().toUtc().toIso8601String(),
      metadata: <String, Object?>{
        ...found.value!.metadata,
        'health': health.toJson(),
      },
    );
    return saveAccount(updated);
  }

  List<ConnectedSocialAccount> _load() {
    final encoded = _preferences.getString(_storageKey);
    if (encoded == null || encoded.isEmpty) {
      return <ConnectedSocialAccount>[];
    }
    final decoded = jsonDecode(encoded) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map((item) => ConnectedSocialAccount.fromJson(item))
        .toList(growable: true);
  }

  Future<void> _persist(List<ConnectedSocialAccount> items) async {
    await _preferences.setString(
      _storageKey,
      jsonEncode(items.map((entry) => entry.toJson()).toList()),
    );
  }
}
