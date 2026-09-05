import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

class SahayakTheme {
  SahayakTheme._();

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: SahayakColors.primary,
      onPrimary: SahayakColors.onPrimary,
      primaryContainer: SahayakColors.primaryContainer,
      onPrimaryContainer: SahayakColors.onPrimaryContainer,
      secondary: SahayakColors.secondary,
      onSecondary: SahayakColors.onSecondary,
      secondaryContainer: SahayakColors.secondaryContainer,
      onSecondaryContainer: SahayakColors.onSecondaryContainer,
      tertiary: SahayakColors.tertiary,
      onTertiary: SahayakColors.onTertiary,
      tertiaryContainer: SahayakColors.tertiaryContainer,
      onTertiaryContainer: SahayakColors.onTertiaryContainer,
      error: SahayakColors.error,
      onError: SahayakColors.onError,
      errorContainer: SahayakColors.errorContainer,
      onErrorContainer: SahayakColors.onErrorContainer,
      surface: SahayakColors.surface,
      onSurface: SahayakColors.onSurface,
      surfaceDim: SahayakColors.surfaceDim,
      surfaceBright: SahayakColors.surfaceBright,
      surfaceContainerLowest: SahayakColors.surfaceContainerLowest,
      surfaceContainerLow: SahayakColors.surfaceContainerLow,
      surfaceContainer: SahayakColors.surfaceContainer,
      surfaceContainerHigh: SahayakColors.surfaceContainerHigh,
      surfaceContainerHighest: SahayakColors.surfaceContainerHighest,
      outline: SahayakColors.outline,
      outlineVariant: SahayakColors.outlineVariant,
      inverseSurface: SahayakColors.inverseSurface,
      onInverseSurface: SahayakColors.inverseOnSurface,
      inversePrimary: SahayakColors.inversePrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: SahayakColors.background,
      fontFamily: 'plusJakartaSans',
      appBarTheme: AppBarTheme(
        backgroundColor: SahayakColors.surface.withValues(alpha: 0.9),
        foregroundColor: SahayakColors.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: SahayakTypography.headlineSm(),
      ),
      cardTheme: CardThemeData(
        color: SahayakColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: SahayakColors.borderSubtle, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SahayakColors.primaryContainer,
          foregroundColor: SahayakColors.onPrimary,
          minimumSize: const Size(64, 48),
          elevation: 0,
          textStyle: SahayakTypography.labelLg(color: SahayakColors.onPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SahayakColors.onSurface,
          backgroundColor: SahayakColors.surfaceContainerLow,
          minimumSize: const Size(64, 48),
          textStyle: SahayakTypography.labelMd(color: SahayakColors.onSurface),
          side: const BorderSide(color: SahayakColors.borderSubtle, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SahayakColors.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: SahayakTypography.bodyMd(color: SahayakColors.outline),
        labelStyle: SahayakTypography.bodyMd(color: SahayakColors.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SahayakColors.borderSubtle, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SahayakColors.borderSubtle, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SahayakColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SahayakColors.error, width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: SahayakColors.inverseSurface,
        contentTextStyle: SahayakTypography.labelMd(color: SahayakColors.inverseOnSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

typedef CooperativeTheme = SahayakTheme;

