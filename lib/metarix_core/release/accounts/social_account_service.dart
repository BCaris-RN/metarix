import '../common/release_result.dart';
import '../platforms/platform_health.dart';
import 'connected_social_account.dart';
import 'social_account_repository.dart';

class SocialAccountService {
  const SocialAccountService(this._repository);

  final SocialAccountRepository _repository;

  Future<ReleaseResult<List<ConnectedSocialAccount>>> listConnectedAccounts(
    String workspaceId,
  ) =>
      _repository.listConnectedAccounts(workspaceId);

  Future<ReleaseResult<ConnectedSocialAccount?>> getAccount(String accountId) =>
      _repository.getAccount(accountId);

  Future<ReleaseResult<ConnectedSocialAccount>> saveAccount(
    ConnectedSocialAccount account,
  ) =>
      _repository.saveAccount(account);

  Future<ReleaseResult<void>> disconnectAccount(String accountId) =>
      _repository.disconnectAccount(accountId);

  Future<ReleaseResult<ConnectedSocialAccount>> markAccountExpired(
    String accountId,
    String reason,
  ) =>
      _repository.markAccountExpired(accountId, reason);

  Future<ReleaseResult<ConnectedSocialAccount>> updateHealth(
    String accountId,
    PlatformHealth health,
  ) =>
      _repository.updateHealth(accountId, health);
}

