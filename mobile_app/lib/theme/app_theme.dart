import 'package:flutter/material.dart';

class AppTheme {
  static const bgMain = Color(0xFF0A0E27);
  static const bgCard = Color(0xFF151934);
  static const accentPrimary = Color(0xFF00FFA3);
  static const accentSecondary = Color(0xFFFF3D71);
  static const accentYellow = Color(0xFFFFD600);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF8B92B2);
  static const border = Color(0xFF2A2F4F);

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgMain,
      colorScheme: const ColorScheme.dark(
        primary: accentPrimary,
        secondary: accentSecondary,
        surface: bgCard,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgCard,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: border),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
      ),
    );
  }
}
