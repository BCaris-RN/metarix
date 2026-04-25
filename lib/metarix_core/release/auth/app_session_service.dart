import 'auth_repository.dart';
import 'app_session.dart';
import '../common/release_result.dart';

class AppSessionService {
  const AppSessionService(this._repository);

  final AuthRepository _repository;

  Future<ReleaseResult<AppSession?>> loadSession() => _repository.loadSession();

  Future<ReleaseResult<AppSession>> signInDemoWorkspace({
    required String workspaceName,
  }) =>
      _repository.signInDemoWorkspace(workspaceName: workspaceName);

  Future<ReleaseResult<void>> persistSession(AppSession session) =>
      _repository.persistSession(session);

  Future<ReleaseResult<void>> logout() => _repository.logout();

  Future<ReleaseResult<AppSession>> refreshSession(AppSession session) =>
      _repository.refreshSession(session);
}

