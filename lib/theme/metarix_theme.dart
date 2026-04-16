import 'package:flutter/material.dart';

import 'metarix_theme_config.dart';

class MetarixTheme {
  const MetarixTheme._();

  static ThemeData build(MetarixThemeConfig config, Brightness brightness) {
    final colors = _ResolvedThemeColors.fromConfig(config, brightness);
    final textTheme = _textTheme(config, colors);
    final cursor = config.usePointerCursors
        ? SystemMouseCursors.click
        : SystemMouseCursors.basic;

    final scheme = ColorScheme.fromSeed(
      seedColor: colors.accent,
      brightness: brightness,
      primary: colors.accent,
      onPrimary: colors.onAccent,
      secondary: colors.panelStrong,
      tertiary: colors.signal,
      surface: colors.panel,
      onSurface: colors.foreground,
      outline: colors.borderStrong,
      outlineVariant: colors.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      visualDensity: VisualDensity.compact,
      fontFamily: config.uiFontFamily,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colors.topSurface,
        foregroundColor: colors.foreground,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
        shape: Border(bottom: BorderSide(color: colors.border, width: 1)),
      ),
      cardTheme: CardThemeData(
        color: colors.panel,
        elevation: brightness == Brightness.dark ? 3 : 0,
        margin: EdgeInsets.zero,
        shadowColor: colors.shadow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: colors.border),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.panelSoft,
        selectedColor: colors.accent.withValues(alpha: 0.20),
        side: BorderSide(color: colors.border),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colors.sidebar,
        useIndicator: true,
        indicatorColor: colors.accent.withValues(alpha: 0.20),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        selectedIconTheme: IconThemeData(color: colors.accent, size: 20),
        unselectedIconTheme: IconThemeData(color: colors.muted, size: 20),
        selectedLabelTextStyle: textTheme.labelSmall?.copyWith(
          color: colors.foreground,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: textTheme.labelSmall,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.sidebar,
        indicatorColor: colors.accent.withValues(alpha: 0.20),
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelSmall),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: colors.onAccent,
          disabledBackgroundColor: colors.accent.withValues(alpha: 0.30),
          elevation: brightness == Brightness.dark ? 3 : 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ).copyWith(mouseCursor: WidgetStatePropertyAll(cursor)),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.accent,
          side: BorderSide(color: colors.borderStrong),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ).copyWith(mouseCursor: WidgetStatePropertyAll(cursor)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.accent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: textTheme.labelMedium,
        ).copyWith(mouseCursor: WidgetStatePropertyAll(cursor)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.panelSoft,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.accent, width: 1.3),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.border),
        ),
      ),
      dividerTheme: DividerThemeData(color: colors.border, thickness: 1),
    );
  }

  static TextTheme _textTheme(
    MetarixThemeConfig config,
    _ResolvedThemeColors colors,
  ) {
    return TextTheme(
      headlineSmall: TextStyle(
        color: colors.foreground,
        fontFamily: config.uiFontFamily,
        fontSize: config.uiFontSize + 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.2,
      ),
      titleLarge: TextStyle(
        color: colors.foreground,
        fontFamily: config.uiFontFamily,
        fontSize: config.uiFontSize + 8,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.2,
      ),
      titleMedium: TextStyle(
        color: colors.foreground,
        fontFamily: config.uiFontFamily,
        fontSize: config.uiFontSize + 2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.3,
      ),
      bodyMedium: TextStyle(
        color: colors.foreground,
        fontFamily: config.uiFontFamily,
        fontSize: config.uiFontSize,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.35,
      ),
      bodySmall: TextStyle(
        color: colors.muted,
        fontFamily: config.uiFontFamily,
        fontSize: config.uiFontSize - 2,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.3,
      ),
      labelMedium: TextStyle(
        color: colors.foreground,
        fontFamily: config.uiFontFamily,
        fontSize: config.uiFontSize - 1,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.2,
      ),
      labelSmall: TextStyle(
        color: colors.muted,
        fontFamily: config.uiFontFamily,
        fontSize: config.uiFontSize - 3,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.2,
      ),
    );
  }
}

class _ResolvedThemeColors {
  const _ResolvedThemeColors({
    required this.background,
    required this.topSurface,
    required this.sidebar,
    required this.panel,
    required this.panelSoft,
    required this.panelStrong,
    required this.border,
    required this.borderStrong,
    required this.accent,
    required this.signal,
    required this.foreground,
    required this.muted,
    required this.onAccent,
    required this.shadow,
  });

  factory _ResolvedThemeColors.fromConfig(
    MetarixThemeConfig config,
    Brightness brightness,
  ) {
    final background = _surfaceForMode(config.background, brightness);
    final foreground = _foregroundForMode(config.foreground, brightness);
    final accent = config.accent;
    final contrast = config.contrast.clamp(0.0, 1.0);
    final lighten = brightness == Brightness.dark ? Colors.white : Colors.black;
    final panel = Color.lerp(
      background,
      lighten,
      brightness == Brightness.dark ? 0.10 + contrast * 0.05 : 0.025,
    )!;
    final panelSoft = Color.lerp(
      background,
      lighten,
      brightness == Brightness.dark ? 0.15 + contrast * 0.06 : 0.055,
    )!;
    final panelStrong = Color.lerp(
      background,
      accent,
      brightness == Brightness.dark ? 0.24 : 0.08,
    )!;
    final border = Color.lerp(
      background,
      foreground,
      brightness == Brightness.dark
          ? 0.22 + contrast * 0.10
          : 0.13 + contrast * 0.05,
    )!;
    final borderStrong = Color.lerp(border, accent, 0.46)!;
    final sidebarBase = config.translucentSidebar
        ? panel.withValues(alpha: 0.76)
        : panel;

    return _ResolvedThemeColors(
      background: background,
      topSurface: panelSoft,
      sidebar: sidebarBase,
      panel: panel,
      panelSoft: panelSoft,
      panelStrong: panelStrong,
      border: border,
      borderStrong: borderStrong,
      accent: accent,
      signal: Color.lerp(accent, foreground, 0.25)!,
      foreground: foreground,
      muted: Color.lerp(foreground, background, 0.36)!,
      onAccent: _onColor(accent),
      shadow: brightness == Brightness.dark
          ? Colors.black.withValues(alpha: 0.45)
          : Colors.black.withValues(alpha: 0.10),
    );
  }

  final Color background;
  final Color topSurface;
  final Color sidebar;
  final Color panel;
  final Color panelSoft;
  final Color panelStrong;
  final Color border;
  final Color borderStrong;
  final Color accent;
  final Color signal;
  final Color foreground;
  final Color muted;
  final Color onAccent;
  final Color shadow;

  static Color _surfaceForMode(Color color, Brightness brightness) {
    final isDark =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark;
    if (brightness == Brightness.dark && !isDark) {
      return const Color(0xFF201236);
    }
    if (brightness == Brightness.light && isDark) {
      return const Color(0xFFF5F7F6);
    }
    return color;
  }

  static Color _foregroundForMode(Color color, Brightness brightness) {
    final isDark =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark;
    if (brightness == Brightness.dark && isDark) {
      return const Color(0xFFF6F3FF);
    }
    if (brightness == Brightness.light && !isDark) {
      return const Color(0xFF26322F);
    }
    return color;
  }

  static Color _onColor(Color color) {
    return ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : const Color(0xFF161616);
  }
}
