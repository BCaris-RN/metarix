import 'dart:convert';

import 'package:http/http.dart' as http;

import '../common/release_result.dart';
import 'provider_connection_summary.dart';
import 'provider_status.dart';

abstract class BackendConnectorClient {
  Future<ReleaseResult<List<ProviderStatus>>> getProviderStatuses();
  Future<ReleaseResult<ProviderStatus>> getProviderStatus(String provider);
  Future<ReleaseResult<String>> getLoginUrl(String provider, String workspaceId);
  Future<ReleaseResult<ProviderConnectionSummary>> getConnection(
    String provider,
    String workspaceId,
  );
  Future<ReleaseResult<void>> disconnect(String provider, String workspaceId);
}

class HttpBackendConnectorClient implements BackendConnectorClient {
  HttpBackendConnectorClient({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Uri _uri(String path, [Map<String, String>? queryParameters]) {
    return Uri.parse('$baseUrl$path').replace(queryParameters: queryParameters);
  }

  @override
  Future<ReleaseResult<List<ProviderStatus>>> getProviderStatuses() async {
    final response = await _client.get(_uri('/api/providers/status'));
    final body = jsonDecode(response.body) as Map<String, Object?>;
    final items = (body['providers'] as List? ?? const [])
        .whereType<Map<String, Object?>>()
        .map(ProviderStatus.fromJson)
        .toList(growable: false);
    return ReleaseResult<List<ProviderStatus>>.success(items);
  }

  @override
  Future<ReleaseResult<ProviderStatus>> getProviderStatus(String provider) async {
    final response = await _client.get(_uri('/api/providers/$provider/status'));
    final body = jsonDecode(response.body) as Map<String, Object?>;
    return ReleaseResult<ProviderStatus>.success(
      ProviderStatus.fromJson(
        (body['provider'] as Map<String, Object?>?) ?? const <String, Object?>{},
      ),
    );
  }

  @override
  Future<ReleaseResult<String>> getLoginUrl(
    String provider,
    String workspaceId,
  ) async {
    final response = await _client.get(
      _uri('/api/oauth/$provider/login-url', {'workspaceId': workspaceId}),
    );
    final body = jsonDecode(response.body) as Map<String, Object?>;
    if (body['ok'] == true) {
      return ReleaseResult<String>.success(body['loginUrl'] as String? ?? '');
    }
    return ReleaseResult<String>.failure(
      errorCode: body['errorCode'] as String?,
      userMessage: body['message'] as String?,
    );
  }

  @override
  Future<ReleaseResult<ProviderConnectionSummary>> getConnection(
    String provider,
    String workspaceId,
  ) async {
    final response = await _client.get(
      _uri('/api/oauth/$provider/connection', {'workspaceId': workspaceId}),
    );
    final body = jsonDecode(response.body) as Map<String, Object?>;
    if (body['ok'] == true) {
      return ReleaseResult<ProviderConnectionSummary>.success(
        ProviderConnectionSummary.fromJson(body),
      );
    }
    return ReleaseResult<ProviderConnectionSummary>.failure(
      errorCode: body['errorCode'] as String?,
      userMessage: body['message'] as String?,
    );
  }

  @override
  Future<ReleaseResult<void>> disconnect(
    String provider,
    String workspaceId,
  ) async {
    final response = await _client.delete(
      _uri('/api/oauth/$provider/connection', {'workspaceId': workspaceId}),
    );
    final body = jsonDecode(response.body) as Map<String, Object?>;
    if (body['ok'] == true) {
      return ReleaseResult<void>.success(null);
    }
    return ReleaseResult<void>.failure(
      errorCode: body['errorCode'] as String?,
      userMessage: body['message'] as String?,
    );
  }
}
