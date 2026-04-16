import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'metarix_snapshot.dart';

class LocalStorageAdapter {
  LocalStorageAdapter._(this._preferences);

  static const _snapshotKey = 'metarix.snapshot.v1';

  final SharedPreferences _preferences;

  static Future<LocalStorageAdapter> create() async {
    final preferences = await SharedPreferences.getInstance();
    return LocalStorageAdapter._(preferences);
  }

  Future<MetarixSnapshot?> loadSnapshot() async {
    final encoded = _preferences.getString(_snapshotKey);
    if (encoded == null || encoded.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(encoded) as Map<String, dynamic>;
    return MetarixSnapshot.fromJson(decoded);
  }

  Future<void> saveSnapshot(MetarixSnapshot snapshot) async {
    final encoded = jsonEncode(snapshot.toJson());
    await _preferences.setString(_snapshotKey, encoded);
  }

  Future<void> clear() async {
    await _preferences.remove(_snapshotKey);
  }
}
