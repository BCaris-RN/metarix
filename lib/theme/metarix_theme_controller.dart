import 'dart:convert';

import 'package:flutter/material.dart';

import 'metarix_theme.dart';
import 'metarix_theme_config.dart';

class MetarixThemeController extends ChangeNotifier {
  MetarixThemeController({MetarixThemeConfig? initialConfig})
    : _config =
          initialConfig ??
          MetarixThemeConfig.forPreset(MetarixThemePreset.codexSignature);

  MetarixThemeConfig _config;

  MetarixThemeConfig get config => _config;
  ThemeMode get themeMode => _config.themeMode;
  MetarixThemePreset get preset => _config.preset;

  ThemeData get lightTheme => MetarixTheme.build(_config, Brightness.light);
  ThemeData get darkTheme => MetarixTheme.build(_config, Brightness.dark);

  String exportTheme() => _config.toPrettyJson();

  bool importTheme(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return false;
      _setConfig(MetarixThemeConfig.fromJson(decoded));
      return true;
    } on FormatException {
      return false;
    }
  }

  void setPreset(MetarixThemePreset preset) {
    _setConfig(MetarixThemeConfig.forPreset(preset));
  }

  void setThemeMode(ThemeMode value) {
    update(_config.copyWith(themeMode: value));
  }

  void update(MetarixThemeConfig value) {
    _setConfig(value);
  }

  void _setConfig(MetarixThemeConfig value) {
    _config = value;
    notifyListeners();
  }
}
