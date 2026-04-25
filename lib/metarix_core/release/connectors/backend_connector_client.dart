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

  Map<String, Object?>? _decodeObject(String body) {
    if (body.trim().isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, Object?> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ReleaseResult<List<ProviderStatus>>> getProviderStatuses() async {
    final response = await _client.get(_uri('/api/providers/status'));
    if (response.statusCode != 200) {
      return ReleaseResult<List<ProviderStatus>>.failure(
        errorCode: 'backend.unavailable',
        userMessage: 'Backend readiness is unavailable.',
        technicalMessage: 'HTTP ${response.statusCode} from /api/providers/status.',
        retryable: true,
      );
    }
    final body = _decodeObject(response.body);
    if (body == null) {
      return ReleaseResult<List<ProviderStatus>>.failure(
        errorCode: 'backend.malformed_response',
        userMessage: 'Backend readiness is unavailable.',
        technicalMessage: 'Provider status response was empty or malformed.',
        retryable: true,
      );
    }
    final items = (body['providers'] as List? ?? const [])
        .whereType<Map<String, Object?>>()
        .map(ProviderStatus.fromJson)
        .toList(growable: false);
    return ReleaseResult<List<ProviderStatus>>.success(items);
  }

  @override
  Future<ReleaseResult<ProviderStatus>> getProviderStatus(String provider) async {
    final response = await _client.get(_uri('/api/providers/$provider/status'));
    if (response.statusCode != 200) {
      return ReleaseResult<ProviderStatus>.failure(
        errorCode: 'backend.unavailable',
        userMessage: 'Backend readiness is unavailable.',
        technicalMessage: 'HTTP ${response.statusCode} from /api/providers/$provider/status.',
        retryable: true,
      );
    }
    final body = _decodeObject(response.body);
    if (body == null) {
      return ReleaseResult<ProviderStatus>.failure(
        errorCode: 'backend.malformed_response',
        userMessage: 'Backend readiness is unavailable.',
        technicalMessage: 'Provider status response was empty or malformed.',
        retryable: true,
      );
    }
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
    final body = _decodeObject(response.body);
    if (response.statusCode != 200 || body == null) {
      return ReleaseResult<String>.failure(
        errorCode: 'backend.unavailable',
        userMessage: 'Backend readiness is unavailable.',
        technicalMessage: response.statusCode == 200
            ? 'Login URL response was empty or malformed.'
            : 'HTTP ${response.statusCode} from login-url endpoint.',
        retryable: true,
      );
    }
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
    if (response.statusCode != 200) {
      return ReleaseResult<ProviderConnectionSummary>.failure(
        errorCode: 'backend.unavailable',
        userMessage: 'Backend readiness is unavailable.',
        technicalMessage: 'HTTP ${response.statusCode} from connection endpoint.',
        retryable: true,
      );
    }
    final body = _decodeObject(response.body);
    if (body == null) {
      return ReleaseResult<ProviderConnectionSummary>.failure(
        errorCode: 'backend.malformed_response',
        userMessage: 'Backend readiness is unavailable.',
        technicalMessage: 'Connection response was empty or malformed.',
        retryable: true,
      );
    }
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
    if (response.statusCode != 200) {
      return ReleaseResult<void>.failure(
        errorCode: 'backend.unavailable',
        userMessage: 'Backend readiness is unavailable.',
        technicalMessage: 'HTTP ${response.statusCode} from disconnect endpoint.',
        retryable: true,
      );
    }
    final body = _decodeObject(response.body);
    if (body == null) {
      return ReleaseResult<void>.failure(
        errorCode: 'backend.malformed_response',
        userMessage: 'Backend readiness is unavailable.',
        technicalMessage: 'Disconnect response was empty or malformed.',
        retryable: true,
      );
    }
    if (body['ok'] == true) {
      return ReleaseResult<void>.success(null);
    }
    return ReleaseResult<void>.failure(
      errorCode: body['errorCode'] as String?,
      userMessage: body['message'] as String?,
    );
  }
}
