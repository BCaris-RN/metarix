import '../models/connected_account.dart';
import '../models/connector_models.dart';
import '../models/model_types.dart';
import 'connector_result.dart';

abstract class AccountConnector {
  SocialPlatform get platform;

  Future<ConnectorResult<AccountConnectionSession>> startConnection(
    AccountConnectionRequest request,
  );

  Future<ConnectorResult<ConnectedAccount>> completeConnection({
    required String state,
    required Uri callbackUri,
  });

  Future<ConnectorResult<List<ConnectedAccount>>> listAccounts();

  Future<ConnectorResult<ConnectedAccount>> getAccount(String accountId);

  Future<ConnectorResult<ConnectedAccount>> refreshAccount(String accountId);

  Future<ConnectorResult<bool>> disconnectAccount(String accountId);
}
