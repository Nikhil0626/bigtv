import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/core/theme/spacing.dart';
import 'package:chotanews/core/theme/typography.dart';
import 'package:chotanews/core/theme/app_theme.dart';
import 'package:chotanews/core/theme/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('Core Theme & Tokens Tests', () {
    test('AppColorTokens defines valid colors', () {
      expect(AppColorTokens.primaryRed, isNotNull);
      expect(AppColorTokens.darkRed, isNotNull);
      expect(AppColorTokens.lightBackground, isNotNull);
      expect(AppColorTokens.darkBackground, isNotNull);
      expect(AppColorTokens.success, equals(const Color(0xFF10B981)));
      expect(AppColorTokens.warning, equals(const Color(0xFFF59E0B)));
      expect(AppColorTokens.error, equals(const Color(0xFFEF4444)));
      expect(AppColorTokens.info, equals(const Color(0xFF3B82F6)));
    });

    test('AppSpacing provides consistent spacing and edge insets', () {
      expect(AppSpacing.xs, equals(4.0));
      expect(AppSpacing.sm, equals(8.0));
      expect(AppSpacing.md, equals(16.0));
      expect(AppSpacing.lg, equals(24.0));
      expect(AppSpacing.xl, equals(32.0));
      expect(AppSpacing.xxl, equals(48.0));
      expect(AppSpacing.xxxl, equals(64.0));

      expect(AppSpacing.edgeInsetsAllXs, equals(const EdgeInsets.all(4.0)));
      expect(AppSpacing.edgeInsetsAllSm, equals(const EdgeInsets.all(8.0)));
      expect(AppSpacing.edgeInsetsAllMd, equals(const EdgeInsets.all(16.0)));
      expect(AppSpacing.edgeInsetsAllLg, equals(const EdgeInsets.all(24.0)));
      expect(AppSpacing.edgeInsetsAllXl, equals(const EdgeInsets.all(32.0)));
      expect(AppSpacing.edgeInsetsHorizontalMd, equals(const EdgeInsets.symmetric(horizontal: 16.0)));
      expect(AppSpacing.edgeInsetsVerticalMd, equals(const EdgeInsets.symmetric(vertical: 16.0)));
    });

    test('AppTypography provides text themes', () {
      final theme = AppTypography.textTheme;
      expect(theme, isNotNull);
      expect(theme.headlineLarge, isNotNull);
      expect(theme.bodyLarge, isNotNull);

      final teluguTheme = AppTypography.teluguTextTheme;
      expect(teluguTheme, isNotNull);
    });

    test('AppTheme creates light and dark themes', () {
      final lightTheme = AppTheme.lightTheme;
      final darkTheme = AppTheme.darkTheme;

      expect(lightTheme.brightness, equals(Brightness.light));
      expect(darkTheme.brightness, equals(Brightness.dark));
    });

    test('ThemeProvider manages theme modes correctly', () async {
      SharedPreferences.setMockInitialValues({'theme_pref': 'dark'});
      final provider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(provider.themeMode, equals(ThemeMode.dark));
      expect(provider.isDarkMode, isTrue);

      await provider.setThemeMode(ThemeMode.light);
      expect(provider.themeMode, equals(ThemeMode.light));
      expect(provider.isDarkMode, isFalse);

      await provider.setThemeMode(ThemeMode.system);
      expect(provider.themeMode, equals(ThemeMode.system));
    });
  });
}
