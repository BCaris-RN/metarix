import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/backend_config.dart';

class SupabaseRestService {
  const SupabaseRestService(this._config);

  final BackendConfig _config;

  bool get isConfigured => _config.isRemoteEnabled;

  Uri _tableUri(String table, [Map<String, String>? query]) {
    final uri = Uri.parse('${_config.supabaseUrl}/rest/v1/$table');
    if (query == null || query.isEmpty) {
      return uri;
    }
    return uri.replace(queryParameters: query);
  }

  Map<String, String> get _headers => {
        'apikey': _config.supabaseAnonKey,
        'Authorization': 'Bearer ${_config.supabaseAnonKey}',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
      };

  Future<List<Map<String, dynamic>>> list(
    String table, {
    Map<String, String>? query,
  }) async {
    final response = await http.get(_tableUri(table, query), headers: _headers);
    return _decodeList(response.body);
  }

  Future<Map<String, dynamic>?> single(
    String table, {
    Map<String, String>? query,
  }) async {
    final response = await http.get(_tableUri(table, query), headers: _headers);
    final list = _decodeList(response.body);
    return list.isEmpty ? null : list.first;
  }

  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> payload,
  ) async {
    final response = await http.post(
      _tableUri(table),
      headers: _headers,
      body: jsonEncode(payload),
    );
    return _decodeList(response.body).first;
  }

  Future<Map<String, dynamic>> upsert(
    String table,
    Map<String, dynamic> payload,
  ) async {
    final response = await http.post(
      _tableUri(table),
      headers: {
        ..._headers,
        'Prefer': 'resolution=merge-duplicates,return=representation',
      },
      body: jsonEncode(payload),
    );
    return _decodeList(response.body).first;
  }

  List<Map<String, dynamic>> _decodeList(String body) {
    final decoded = jsonDecode(body) as List<dynamic>;
    return decoded
        .map((entry) => Map<String, dynamic>.from(entry as Map))
        .toList();
  }
}
