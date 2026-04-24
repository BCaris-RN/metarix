import 'package:flutter/foundation.dart';

import '../common/release_result.dart';
import '../platforms/platform_health.dart';
import 'connected_social_account.dart';
import 'social_account_service.dart';

class SocialAccountController extends ChangeNotifier {
  SocialAccountController(this._service);

  final SocialAccountService _service;

  List<ConnectedSocialAccount> _accounts = const <ConnectedSocialAccount>[];
  bool _loading = true;
  String? _errorCode;
  String? _message;

  List<ConnectedSocialAccount> get accounts => _accounts;
  bool get isLoading => _loading;
  String? get errorCode => _errorCode;
  String? get message => _message;

  Future<void> load(String workspaceId) async {
    _loading = true;
    notifyListeners();
    final result = await _service.listConnectedAccounts(workspaceId);
    if (result.success) {
      _accounts = result.value ?? const <ConnectedSocialAccount>[];
      _errorCode = null;
      _message = null;
    } else {
      _errorCode = result.errorCode;
      _message = result.userMessage;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> save(ConnectedSocialAccount account) async {
    final result = await _service.saveAccount(account);
    _applyAccountResult(result);
  }

  Future<void> disconnect(String accountId) async {
    final result = await _service.disconnectAccount(accountId);
    if (result.success) {
      _accounts = _accounts.where((entry) => entry.accountId != accountId).toList(growable: false);
      _errorCode = null;
      _message = null;
      notifyListeners();
    } else {
      _errorCode = result.errorCode;
      _message = result.userMessage;
      notifyListeners();
    }
  }

  Future<void> markExpired(String accountId, String reason) async {
    final result = await _service.markAccountExpired(accountId, reason);
    _applyAccountResult(result);
  }

  Future<void> updateHealth(String accountId, PlatformHealth health) async {
    final result = await _service.updateHealth(accountId, health);
    _applyAccountResult(result);
  }

  void _applyAccountResult(ReleaseResult<ConnectedSocialAccount> result) {
    if (result.success && result.value != null) {
      final updated = result.value!;
      final index = _accounts.indexWhere((entry) => entry.accountId == updated.accountId);
      if (index >= 0) {
        _accounts = [
          ..._accounts.sublist(0, index),
          updated,
          ..._accounts.sublist(index + 1),
        ];
      } else {
        _accounts = [..._accounts, updated];
      }
      _errorCode = null;
      _message = null;
    } else {
      _errorCode = result.errorCode;
      _message = result.userMessage;
    }
    notifyListeners();
  }
}

