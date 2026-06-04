import 'package:flutter/material.dart';
import 'color_tokens.dart';
import 'typography.dart';
import 'spacing.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColorTokens.primaryRed,
        onPrimary: Colors.white,
        secondary: AppColorTokens.darkRed,
        onSecondary: Colors.white,
        error: AppColorTokens.error,
        onError: Colors.white,
        background: AppColorTokens.lightBackground,
        onBackground: AppColorTokens.lightTextPrimary,
        surface: AppColorTokens.lightSurface,
        onSurface: AppColorTokens.lightTextPrimary,
        outline: AppColorTokens.lightBorder,
      ),
      scaffoldBackgroundColor: AppColorTokens.lightBackground,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColorTokens.lightTextPrimary,
        displayColor: AppColorTokens.lightTextPrimary,
      ),
      iconTheme: const IconThemeData(color: AppColorTokens.lightIcon),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColorTokens.lightSurface,
        foregroundColor: AppColorTokens.lightTextPrimary,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColorTokens.lightIcon),
      ),
      cardTheme: CardThemeData(
        color: AppColorTokens.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
          side: const BorderSide(color: AppColorTokens.lightBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorTokens.primaryRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.sm)),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColorTokens.primaryRed,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorTokens.lightCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: const BorderSide(color: AppColorTokens.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: const BorderSide(color: AppColorTokens.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: const BorderSide(color: AppColorTokens.primaryRed),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColorTokens.darkPrimaryRed,
        onPrimary: Colors.white,
        secondary: AppColorTokens.primaryRed,
        onSecondary: Colors.white,
        error: AppColorTokens.error,
        onError: Colors.white,
        background: AppColorTokens.darkBackground,
        onBackground: AppColorTokens.darkTextPrimary,
        surface: AppColorTokens.darkSurface,
        onSurface: AppColorTokens.darkTextPrimary,
        outline: AppColorTokens.darkBorder,
      ),
      scaffoldBackgroundColor: AppColorTokens.darkBackground,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColorTokens.darkTextPrimary,
        displayColor: AppColorTokens.darkTextPrimary,
      ),
      iconTheme: const IconThemeData(color: AppColorTokens.darkIcon),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColorTokens.darkSurface,
        foregroundColor: AppColorTokens.darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColorTokens.darkIcon),
      ),
      cardTheme: CardThemeData(
        color: AppColorTokens.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
          side: const BorderSide(color: AppColorTokens.darkBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorTokens.darkPrimaryRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.sm)),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColorTokens.darkPrimaryRed,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorTokens.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: const BorderSide(color: AppColorTokens.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: const BorderSide(color: AppColorTokens.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: const BorderSide(color: AppColorTokens.darkPrimaryRed),
        ),
      ),
    );
  }
}
