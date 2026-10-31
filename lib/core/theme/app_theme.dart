import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color seedColor = Color(0xFF65C466);

  static ThemeData light() => _buildTheme(Brightness.light);

  static ThemeData dark() => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    final typography = Typography.material2021();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: brightness == Brightness.light
          ? typography.black
          : typography.white,
    );
  }
}
