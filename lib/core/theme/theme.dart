import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

class WorkSoluteTheme {
  WorkSoluteTheme._();

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: WorkSoluteColors.primary,
      onPrimary: WorkSoluteColors.onPrimary,
      primaryContainer: WorkSoluteColors.primaryContainer,
      onPrimaryContainer: WorkSoluteColors.onPrimaryContainer,
      secondary: WorkSoluteColors.secondary,
      onSecondary: WorkSoluteColors.onSecondary,
      secondaryContainer: WorkSoluteColors.secondaryContainer,
      onSecondaryContainer: WorkSoluteColors.onSecondaryContainer,
      tertiary: WorkSoluteColors.tertiary,
      onTertiary: WorkSoluteColors.onTertiary,
      tertiaryContainer: WorkSoluteColors.tertiaryContainer,
      onTertiaryContainer: WorkSoluteColors.onTertiaryContainer,
      error: WorkSoluteColors.error,
      onError: WorkSoluteColors.onError,
      errorContainer: WorkSoluteColors.errorContainer,
      onErrorContainer: WorkSoluteColors.onErrorContainer,
      surface: WorkSoluteColors.surface,
      onSurface: WorkSoluteColors.onSurface,
      surfaceDim: WorkSoluteColors.surfaceDim,
      surfaceBright: WorkSoluteColors.surfaceBright,
      surfaceContainerLowest: WorkSoluteColors.surfaceContainerLowest,
      surfaceContainerLow: WorkSoluteColors.surfaceContainerLow,
      surfaceContainer: WorkSoluteColors.surfaceContainer,
      surfaceContainerHigh: WorkSoluteColors.surfaceContainerHigh,
      surfaceContainerHighest: WorkSoluteColors.surfaceContainerHighest,
      outline: WorkSoluteColors.outline,
      outlineVariant: WorkSoluteColors.outlineVariant,
      inverseSurface: WorkSoluteColors.inverseSurface,
      onInverseSurface: WorkSoluteColors.inverseOnSurface,
      inversePrimary: WorkSoluteColors.inversePrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: WorkSoluteColors.background,
      fontFamily: 'plusJakartaSans',
      splashFactory: InkSparkle.splashFactory,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: WorkSoluteColors.surface,
        foregroundColor: WorkSoluteColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        toolbarHeight: 56,
        titleTextStyle: WorkSoluteTypography.headlineSm(),
      ),
      cardTheme: CardThemeData(
        color: WorkSoluteColors.surfaceContainerLowest,
        elevation: 0,
        shadowColor: WorkSoluteColors.onSurface.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: WorkSoluteColors.borderSubtle, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: WorkSoluteColors.primaryContainer,
          foregroundColor: WorkSoluteColors.onPrimary,
          minimumSize: const Size(64, 52),
          elevation: 0,
          splashFactory: InkSparkle.splashFactory,
          textStyle: WorkSoluteTypography.labelLg(color: WorkSoluteColors.onPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: WorkSoluteColors.onSurface,
          backgroundColor: WorkSoluteColors.surfaceContainerLow,
          minimumSize: const Size(64, 48),
          textStyle: WorkSoluteTypography.labelMd(color: WorkSoluteColors.onSurface),
          side: const BorderSide(color: WorkSoluteColors.borderSubtle, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: WorkSoluteColors.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        hintStyle: WorkSoluteTypography.bodyMd(color: WorkSoluteColors.outline),
        labelStyle: WorkSoluteTypography.bodyMd(color: WorkSoluteColors.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WorkSoluteColors.borderSubtle, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WorkSoluteColors.borderSubtle, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WorkSoluteColors.primary, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WorkSoluteColors.error, width: 1.5),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: WorkSoluteColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
        dragHandleColor: WorkSoluteColors.outlineVariant,
        dragHandleSize: Size(36, 4),
        clipBehavior: Clip.antiAliasWithSaveLayer,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: WorkSoluteColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: WorkSoluteColors.inverseSurface,
        contentTextStyle: WorkSoluteTypography.labelMd(color: WorkSoluteColors.inverseOnSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

typedef SahayakTheme = WorkSoluteTheme;
typedef CooperativeTheme = WorkSoluteTheme;

