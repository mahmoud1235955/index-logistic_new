import 'package:flutter/material.dart';

import 'app_tokens.dart';

abstract final class IndexTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppTokens.navy,
      primary: AppTokens.navy,
      secondary: AppTokens.green,
      surface: AppTokens.white,
      error: AppTokens.danger,
    );
    final text = Typography.material2021().black;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppTokens.canvas,
      fontFamily: null, // Use platform Arabic fallbacks and Latin system fonts.
      textTheme: text.copyWith(
        displaySmall: text.displaySmall?.copyWith(fontSize: 40, height: 1.22, fontWeight: FontWeight.w700, color: AppTokens.ink),
        headlineMedium: text.headlineMedium?.copyWith(fontSize: 26, height: 1.3, fontWeight: FontWeight.w700, color: AppTokens.ink),
        titleLarge: text.titleLarge?.copyWith(fontSize: 18, height: 1.45, fontWeight: FontWeight.w700, color: AppTokens.ink),
        titleMedium: text.titleMedium?.copyWith(fontSize: 15, height: 1.5, fontWeight: FontWeight.w600, color: AppTokens.ink),
        bodyLarge: text.bodyLarge?.copyWith(fontSize: 15, height: 1.7, color: AppTokens.ink),
        bodyMedium: text.bodyMedium?.copyWith(fontSize: 13, height: 1.65, color: AppTokens.muted),
        labelLarge: text.labelLarge?.copyWith(fontSize: 13, height: 1.4, fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(backgroundColor: AppTokens.white, foregroundColor: AppTokens.ink, elevation: 0),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTokens.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: const TextStyle(color: AppTokens.muted, fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTokens.radiusSm), borderSide: const BorderSide(color: AppTokens.line)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTokens.radiusSm), borderSide: const BorderSide(color: AppTokens.line)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTokens.radiusSm), borderSide: const BorderSide(color: AppTokens.blue, width: 1.5)),
      ),
      cardTheme: CardThemeData(color: AppTokens.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd), side: const BorderSide(color: AppTokens.line))),
      dividerColor: AppTokens.line,
    );
  }
}
