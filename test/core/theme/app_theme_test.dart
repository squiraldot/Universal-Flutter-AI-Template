import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_app/core/theme/app_theme.dart';
import 'package:universal_app/core/theme/app_tokens.dart';

void main() {
  group('AppTheme', () {
    test('light theme uses Material 3 and the shared brand seed', () {
      final theme = AppTheme.light();
      final expected = ColorScheme.fromSeed(
        seedColor: AppTheme.seedColor,
        brightness: Brightness.light,
      );

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, expected.primary);
      expect(theme.textTheme.titleLarge, isNotNull);
    });

    test('dark theme uses Material 3 and the shared brand seed', () {
      final theme = AppTheme.dark();
      final expected = ColorScheme.fromSeed(
        seedColor: AppTheme.seedColor,
        brightness: Brightness.dark,
      );

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, expected.primary);
      expect(theme.textTheme.titleLarge, isNotNull);
    });
  });

  test('spacing, radius and motion tokens expose the shared scales', () {
    expect(AppSpacing.xs, 4);
    expect(AppSpacing.sm, 8);
    expect(AppSpacing.md, 16);
    expect(AppSpacing.lg, 24);
    expect(AppSpacing.xl, 32);
    expect(AppRadii.sm, 8);
    expect(AppRadii.md, 12);
    expect(AppRadii.lg, 16);
    expect(AppMotion.fast, const Duration(milliseconds: 150));
    expect(AppMotion.normal, const Duration(milliseconds: 250));
    expect(AppMotion.slow, const Duration(milliseconds: 350));
  });
}
