import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../common/release_result.dart';
import 'app_session.dart';
import 'auth_repository.dart';

class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository._(this._preferences);

  static const String _sessionKey = 'metarix.release.session.v1';

  final SharedPreferences _preferences;

  static Future<LocalAuthRepository> create() async {
    final preferences = await SharedPreferences.getInstance();
    return LocalAuthRepository._(preferences);
  }

  @override
  Future<ReleaseResult<AppSession?>> loadSession() async {
    try {
      final encoded = _preferences.getString(_sessionKey);
      if (encoded == null || encoded.isEmpty) {
        return ReleaseResult<AppSession?>.success(null);
      }
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      return ReleaseResult<AppSession?>.success(AppSession.fromJson(decoded));
    } catch (error) {
      return ReleaseResult<AppSession?>.failure(
        errorCode: 'auth.storage_failed',
        userMessage: 'Unable to load saved session.',
        technicalMessage: '$error',
        retryable: true,
      );
    }
  }

  @override
  Future<ReleaseResult<AppSession>> signInDemoWorkspace({
    required String workspaceName,
  }) async {
    final now = DateTime.now().toUtc();
    final session = AppSession(
      sessionId: 'session-${now.microsecondsSinceEpoch}',
      userId: 'user-demo',
      workspaceId: 'workspace-demo',
      workspaceName: workspaceName.trim().isEmpty ? 'Demo Workspace' : workspaceName.trim(),
      role: 'owner',
      accessTokenPreview: 'demo...${now.millisecond}',
      createdAtIso: now.toIso8601String(),
      updatedAtIso: now.toIso8601String(),
      expiresAtIso: now.add(const Duration(hours: 8)).toIso8601String(),
    );

    final persisted = await persistSession(session);
    if (!persisted.success) {
      return ReleaseResult<AppSession>.failure(
        errorCode: persisted.errorCode,
        userMessage: persisted.userMessage,
        technicalMessage: persisted.technicalMessage,
        retryable: persisted.retryable,
      );
    }
    return ReleaseResult<AppSession>.success(session);
  }

  @override
  Future<ReleaseResult<void>> persistSession(AppSession session) async {
    try {
      await _preferences.setString(_sessionKey, jsonEncode(session.toJson()));
      return ReleaseResult<void>.success(null);
    } catch (error) {
      return ReleaseResult<void>.failure(
        errorCode: 'auth.storage_failed',
        userMessage: 'Unable to save session.',
        technicalMessage: '$error',
        retryable: true,
      );
    }
  }

  @override
  Future<ReleaseResult<void>> logout() async {
    try {
      await _preferences.remove(_sessionKey);
      return ReleaseResult<void>.success(null);
    } catch (error) {
      return ReleaseResult<void>.failure(
        errorCode: 'auth.storage_failed',
        userMessage: 'Unable to clear session.',
        technicalMessage: '$error',
        retryable: true,
      );
    }
  }

  @override
  Future<ReleaseResult<AppSession>> refreshSession(AppSession session) async {
    if (session.isExpired) {
      return ReleaseResult<AppSession>.failure(
        errorCode: 'auth.expired',
        userMessage: 'Your session has expired.',
        technicalMessage: 'Session expired at ${session.expiresAtIso}',
        retryable: true,
      );
    }
    final refreshed = session.copyWith(
      updatedAtIso: DateTime.now().toUtc().toIso8601String(),
    );
    final persisted = await persistSession(refreshed);
    if (!persisted.success) {
      return ReleaseResult<AppSession>.failure(
        errorCode: persisted.errorCode,
        userMessage: persisted.userMessage,
        technicalMessage: persisted.technicalMessage,
        retryable: persisted.retryable,
      );
    }
    return ReleaseResult<AppSession>.success(refreshed);
  }
}
