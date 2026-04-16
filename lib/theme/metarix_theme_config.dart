import 'dart:convert';

import 'package:flutter/material.dart';

enum MetarixThemePreset { codexSignature, metarixLight, titanium }

extension MetarixThemePresetLabel on MetarixThemePreset {
  String get label {
    return switch (this) {
      MetarixThemePreset.codexSignature => 'Codex Signature',
      MetarixThemePreset.metarixLight => 'MetaRix Light',
      MetarixThemePreset.titanium => 'Titanium',
    };
  }
}

class MetarixThemeConfig {
  const MetarixThemeConfig({
    required this.themeMode,
    required this.preset,
    required this.accent,
    required this.background,
    required this.foreground,
    required this.uiFontFamily,
    required this.codeFontFamily,
    required this.translucentSidebar,
    required this.usePointerCursors,
    required this.contrast,
    required this.uiFontSize,
    required this.codeFontSize,
  });

  final ThemeMode themeMode;
  final MetarixThemePreset preset;
  final Color accent;
  final Color background;
  final Color foreground;
  final String uiFontFamily;
  final String codeFontFamily;
  final bool translucentSidebar;
  final bool usePointerCursors;
  final double contrast;
  final double uiFontSize;
  final double codeFontSize;

  static MetarixThemeConfig forPreset(MetarixThemePreset preset) {
    return switch (preset) {
      MetarixThemePreset.codexSignature => const MetarixThemeConfig(
        themeMode: ThemeMode.dark,
        preset: MetarixThemePreset.codexSignature,
        accent: Color(0xFFD2F21A),
        background: Color(0xFF201236),
        foreground: Color(0xFFF6F3FF),
        uiFontFamily: 'Segoe UI',
        codeFontFamily: 'Cascadia Code',
        translucentSidebar: true,
        usePointerCursors: true,
        contrast: 0.72,
        uiFontSize: 14,
        codeFontSize: 13,
      ),
      MetarixThemePreset.metarixLight => const MetarixThemeConfig(
        themeMode: ThemeMode.light,
        preset: MetarixThemePreset.metarixLight,
        accent: Color(0xFF006B5F),
        background: Color(0xFFF5F7F6),
        foreground: Color(0xFF26322F),
        uiFontFamily: 'Segoe UI',
        codeFontFamily: 'Cascadia Code',
        translucentSidebar: false,
        usePointerCursors: true,
        contrast: 0.48,
        uiFontSize: 14,
        codeFontSize: 13,
      ),
      MetarixThemePreset.titanium => const MetarixThemeConfig(
        themeMode: ThemeMode.system,
        preset: MetarixThemePreset.titanium,
        accent: Color(0xFF5F6772),
        background: Color(0xFFF1F1F0),
        foreground: Color(0xFF1D1F22),
        uiFontFamily: 'Segoe UI',
        codeFontFamily: 'Consolas',
        translucentSidebar: false,
        usePointerCursors: true,
        contrast: 0.58,
        uiFontSize: 14,
        codeFontSize: 13,
      ),
    };
  }

  MetarixThemeConfig copyWith({
    ThemeMode? themeMode,
    MetarixThemePreset? preset,
    Color? accent,
    Color? background,
    Color? foreground,
    String? uiFontFamily,
    String? codeFontFamily,
    bool? translucentSidebar,
    bool? usePointerCursors,
    double? contrast,
    double? uiFontSize,
    double? codeFontSize,
  }) {
    return MetarixThemeConfig(
      themeMode: themeMode ?? this.themeMode,
      preset: preset ?? this.preset,
      accent: accent ?? this.accent,
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      uiFontFamily: uiFontFamily ?? this.uiFontFamily,
      codeFontFamily: codeFontFamily ?? this.codeFontFamily,
      translucentSidebar: translucentSidebar ?? this.translucentSidebar,
      usePointerCursors: usePointerCursors ?? this.usePointerCursors,
      contrast: contrast ?? this.contrast,
      uiFontSize: uiFontSize ?? this.uiFontSize,
      codeFontSize: codeFontSize ?? this.codeFontSize,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'themeMode': themeMode.name,
      'preset': preset.name,
      'accent': formatThemeColor(accent),
      'background': formatThemeColor(background),
      'foreground': formatThemeColor(foreground),
      'uiFontFamily': uiFontFamily,
      'codeFontFamily': codeFontFamily,
      'translucentSidebar': translucentSidebar,
      'usePointerCursors': usePointerCursors,
      'contrast': contrast,
      'uiFontSize': uiFontSize,
      'codeFontSize': codeFontSize,
    };
  }

  String toPrettyJson() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  factory MetarixThemeConfig.fromJson(Map<String, dynamic> json) {
    final preset = MetarixThemePreset.values.firstWhere(
      (value) => value.name == json['preset'],
      orElse: () => MetarixThemePreset.codexSignature,
    );
    final fallback = MetarixThemeConfig.forPreset(preset);
    return fallback.copyWith(
      themeMode: ThemeMode.values.firstWhere(
        (value) => value.name == json['themeMode'],
        orElse: () => fallback.themeMode,
      ),
      accent: parseThemeColor(json['accent'] as String?) ?? fallback.accent,
      background:
          parseThemeColor(json['background'] as String?) ?? fallback.background,
      foreground:
          parseThemeColor(json['foreground'] as String?) ?? fallback.foreground,
      uiFontFamily: json['uiFontFamily'] as String? ?? fallback.uiFontFamily,
      codeFontFamily:
          json['codeFontFamily'] as String? ?? fallback.codeFontFamily,
      translucentSidebar:
          json['translucentSidebar'] as bool? ?? fallback.translucentSidebar,
      usePointerCursors:
          json['usePointerCursors'] as bool? ?? fallback.usePointerCursors,
      contrast: (json['contrast'] as num?)?.toDouble() ?? fallback.contrast,
      uiFontSize:
          (json['uiFontSize'] as num?)?.toDouble() ?? fallback.uiFontSize,
      codeFontSize:
          (json['codeFontSize'] as num?)?.toDouble() ?? fallback.codeFontSize,
    );
  }
}

String formatThemeColor(Color color) {
  final value = color.toARGB32().toRadixString(16).padLeft(8, '0');
  return '#${value.substring(2).toUpperCase()}';
}

Color? parseThemeColor(String? raw) {
  if (raw == null) return null;
  final normalized = raw.trim().replaceFirst('#', '').toUpperCase();
  if (!RegExp(r'^[0-9A-F]{6}$').hasMatch(normalized)) return null;
  return Color(int.parse('FF$normalized', radix: 16));
}
