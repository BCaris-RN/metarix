import '../../models/connected_account.dart';
import '../../models/connector_models.dart';
import '../../models/model_types.dart';
import '../account_connector.dart';
import '../connector_result.dart';

class DemoAccountConnector implements AccountConnector {
  const DemoAccountConnector(this.platform);

  @override
  final SocialPlatform platform;

  @override
  Future<ConnectorResult<AccountConnectionSession>> startConnection(
    AccountConnectionRequest request,
  ) async {
    final session = AccountConnectionSession(
      platform: platform,
      authorizationUrl: Uri.parse(
        'https://demo.metarix.local/oauth/${platform.name}?state=${request.state}',
      ),
      state: request.state,
      expiresAt: DateTime.now().add(const Duration(minutes: 10)),
    );
    return ConnectorResult.success(value: session);
  }

  @override
  Future<ConnectorResult<ConnectedAccount>> completeConnection({
    required String state,
    required Uri callbackUri,
  }) async {
    return ConnectorResult.success(value: _account());
  }

  @override
  Future<ConnectorResult<bool>> disconnectAccount(String accountId) async {
    return const ConnectorResult.success(value: true);
  }

  @override
  Future<ConnectorResult<ConnectedAccount>> getAccount(String accountId) async {
    return ConnectorResult.success(value: _account(accountId: accountId));
  }

  @override
  Future<ConnectorResult<List<ConnectedAccount>>> listAccounts() async {
    return ConnectorResult.success(value: [_account()]);
  }

  @override
  Future<ConnectorResult<ConnectedAccount>> refreshAccount(
    String accountId,
  ) async {
    return ConnectorResult.success(value: _account(accountId: accountId));
  }

  ConnectedAccount _account({String? accountId}) {
    return ConnectedAccount(
      accountId: accountId ?? 'demo-${platform.name}-account',
      platform: platform,
      handle: '@metarix_${platform.name}',
      displayName: 'MetaRix ${platform.label}',
      connectionStatus: ConnectionStatus.connected,
      scopes: const ['demo.read', 'demo.write'],
      isLocalOnly: true,
      lastSyncAt: DateTime.now(),
    );
  }
}
