import '../common/release_result.dart';
import '../platforms/platform_health.dart';
import 'connected_social_account.dart';

abstract class SocialAccountRepository {
  Future<ReleaseResult<List<ConnectedSocialAccount>>> listConnectedAccounts(
    String workspaceId,
  );

  Future<ReleaseResult<ConnectedSocialAccount?>> getAccount(String accountId);

  Future<ReleaseResult<ConnectedSocialAccount>> saveAccount(
    ConnectedSocialAccount account,
  );

  Future<ReleaseResult<void>> disconnectAccount(String accountId);

  Future<ReleaseResult<ConnectedSocialAccount>> markAccountExpired(
    String accountId,
    String reason,
  );

  Future<ReleaseResult<ConnectedSocialAccount>> updateHealth(
    String accountId,
    PlatformHealth health,
  );
}

