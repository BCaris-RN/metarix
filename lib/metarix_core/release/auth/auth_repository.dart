import '../common/release_result.dart';
import 'app_session.dart';

abstract class AuthRepository {
  Future<ReleaseResult<AppSession?>> loadSession();

  Future<ReleaseResult<AppSession>> signInDemoWorkspace({
    required String workspaceName,
  });

  Future<ReleaseResult<void>> persistSession(AppSession session);

  Future<ReleaseResult<void>> logout();

  Future<ReleaseResult<AppSession>> refreshSession(AppSession session);
}

