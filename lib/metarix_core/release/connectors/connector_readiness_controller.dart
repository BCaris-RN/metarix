import 'package:flutter/foundation.dart';

import '../common/release_result.dart';
import 'backend_connector_client.dart';
import 'provider_connection_summary.dart';
import 'provider_status.dart';

class ConnectorReadinessController extends ChangeNotifier {
  ConnectorReadinessController(this._client);

  final BackendConnectorClient _client;

  List<ProviderStatus> providerStatuses = <ProviderStatus>[];
  Map<String, ProviderConnectionSummary> connectionSummaries =
      <String, ProviderConnectionSummary>{};
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    final statusesResult = await _client.getProviderStatuses();
    if (statusesResult.success) {
      providerStatuses = statusesResult.value ?? <ProviderStatus>[];
    } else {
      errorMessage = statusesResult.userMessage;
    }
    isLoading = false;
    notifyListeners();
  }

  Future<ReleaseResult<String>> getLoginUrl(
    String provider,
    String workspaceId,
  ) async {
    return _client.getLoginUrl(provider, workspaceId);
  }

  Future<ReleaseResult<ProviderConnectionSummary>> getConnection(
    String provider,
    String workspaceId,
  ) async {
    return _client.getConnection(provider, workspaceId);
  }

  Future<ReleaseResult<void>> disconnect(
    String provider,
    String workspaceId,
  ) async {
    return _client.disconnect(provider, workspaceId);
  }

  Future<void> refreshWorkspace(String workspaceId) async {
    final summaries = <String, ProviderConnectionSummary>{};
    for (final status in providerStatuses) {
      final result = await _client.getConnection(status.provider, workspaceId);
      if (result.success && result.value != null) {
        summaries[status.provider] = result.value!;
      }
    }
    connectionSummaries = summaries;
    notifyListeners();
  }
}
