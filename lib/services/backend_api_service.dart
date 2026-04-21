import 'dart:convert';

import 'package:http/http.dart' as http;

class BackendApiService {
  BackendApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = (baseUrl ?? const String.fromEnvironment(
          'METARIX_BACKEND_BASE_URL',
          defaultValue: 'http://localhost:3000',
        )).replaceAll(RegExp(r'/$'), '');

  final http.Client _client;
  final String _baseUrl;

  Uri _uri(String path) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$_baseUrl$normalized');
  }

  Future<Map<String, dynamic>> bootstrap({String? token}) async {
    final response = await _client.get(
      _uri('/api/bootstrap'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw StateError('Backend bootstrap failed with HTTP ${response.statusCode}.');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Backend bootstrap returned malformed JSON.');
    }
    return decoded;
  }

  Future<bool> health() async {
    try {
      final response = await _client.get(_uri('/health'));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> ping({String? token}) async {
    return health();
  }

  void dispose() {
    _client.close();
  }
}
