import 'package:flutter/material.dart';

/// Dynamic color palette. The `static const` fields never change between
/// themes; the getters below them track [isDark] (kept in sync by
/// `ThemeCubit`) so existing call sites (`AppColors.textPrimary`, etc.)
/// automatically follow the active theme without being rewritten.
class AppColors {
  static bool isDark = true;

  static Color get background =>
      isDark ? const Color(0xFF0E0E12) : const Color(0xFFF7F7FA);
  static Color get surface =>
      isDark ? const Color(0xFF1A1A22) : const Color(0xFFFFFFFF);
  static Color get surfaceAlt =>
      isDark ? const Color(0xFF24242E) : const Color(0xFFEEEEF3);
  static const primary = Color(0xFF7C5CFC);
  static Color get primarySoft =>
      isDark ? const Color(0xFF2A2440) : const Color(0xFFECE7FE);
  static const accent = Color(0xFFB9FF66);
  static Color get textPrimary =>
      isDark ? const Color(0xFFF4F4F6) : const Color(0xFF16161C);
  static Color get textSecondary =>
      isDark ? const Color(0xFF9A9AA8) : const Color(0xFF62626E);
  static Color get border =>
      isDark ? const Color(0xFF2E2E3A) : const Color(0xFFE1E1E9);
  static const success = Color(0xFF4ADE80);
  static const danger = Color(0xFFF87171);
}

class AppRadius {
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 22.0;
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

class AppTheme {
  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    background: const Color(0xFF0E0E12),
    surface: const Color(0xFF1A1A22),
    surfaceAlt: const Color(0xFF24242E),
    primarySoft: const Color(0xFF2A2440),
    textPrimary: const Color(0xFFF4F4F6),
    textSecondary: const Color(0xFF9A9AA8),
    border: const Color(0xFF2E2E3A),
  );

  static ThemeData get light => _build(
    brightness: Brightness.light,
    background: const Color(0xFFF7F7FA),
    surface: const Color(0xFFFFFFFF),
    surfaceAlt: const Color(0xFFEEEEF3),
    primarySoft: const Color(0xFFECE7FE),
    textPrimary: const Color(0xFF16161C),
    textSecondary: const Color(0xFF62626E),
    border: const Color(0xFFE1E1E9),
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceAlt,
    required Color primarySoft,
    required Color textPrimary,
    required Color textSecondary,
    required Color border,
  }) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: brightness == Brightness.dark
          ? ColorScheme.dark(
              primary: AppColors.primary,
              surface: surface,
              onPrimary: Colors.white,
              onSurface: textPrimary,
              error: AppColors.danger,
            )
          : ColorScheme.light(
              primary: AppColors.primary,
              surface: surface,
              onPrimary: Colors.white,
              onSurface: textPrimary,
              error: AppColors.danger,
            ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        hintStyle: TextStyle(color: textSecondary),
        labelStyle: TextStyle(color: textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: surfaceAlt,
        labelStyle: TextStyle(color: textSecondary),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceAlt,
        contentTextStyle: TextStyle(color: textPrimary),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
