import 'package:flutter/foundation.dart';

import '../common/release_result.dart';
import 'app_session.dart';
import 'app_session_service.dart';

class AppSessionController extends ChangeNotifier {
  AppSessionController(this._service);

  final AppSessionService _service;

  AppSession? _session;
  bool _loading = true;
  String? _errorCode;
  String? _message;

  AppSession? get session => _session;
  bool get isLoading => _loading;
  String? get errorCode => _errorCode;
  String? get message => _message;

  bool get isSignedIn => _session != null && !_session!.isExpired;
  bool get hasExpiredSession => _session != null && _session!.isExpired;

  Future<void> bootstrap() async {
    _loading = true;
    notifyListeners();
    final result = await _service.loadSession();
    if (result.success) {
      _session = result.value;
      _errorCode = null;
      _message = null;
    } else {
      _errorCode = result.errorCode;
      _message = result.userMessage;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> signInDemoWorkspace(String workspaceName) async {
    _loading = true;
    notifyListeners();
    final result = await _service.signInDemoWorkspace(workspaceName: workspaceName);
    _applyResult(result);
    _loading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _loading = true;
    notifyListeners();
    final result = await _service.logout();
    if (result.success) {
      _session = null;
      _errorCode = null;
      _message = 'Signed out.';
    } else {
      _errorCode = result.errorCode;
      _message = result.userMessage;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    final current = _session;
    if (current == null) {
      return;
    }
    final result = await _service.refreshSession(current);
    _applyResult(result);
    notifyListeners();
  }

  void _applyResult(ReleaseResult<AppSession> result) {
    if (result.success) {
      _session = result.value;
      _errorCode = null;
      _message = null;
      return;
    }
    _errorCode = result.errorCode;
    _message = result.userMessage;
  }
}

