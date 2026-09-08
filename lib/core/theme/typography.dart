import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Cooperative Craft Typography Scale
/// Defined in cooperative_craft/DESIGN.md
class WorkSoluteTypography {
  WorkSoluteTypography._();

  static TextStyle _baseStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    double letterSpacing = 0,
    Color color = WorkSoluteColors.onSurface,
  }) {
    try {
      return GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height / fontSize,
        letterSpacing: letterSpacing,
        color: color,
      );
    } catch (_) {
      return TextStyle(
        fontFamily: 'sans-serif',
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height / fontSize,
        letterSpacing: letterSpacing,
        color: color,
      );
    }
  }

  // Display Hero (36px / 44px, 700)
  static TextStyle displayHero({Color color = WorkSoluteColors.onSurface}) =>
      _baseStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 44,
        letterSpacing: -0.72,
        color: color,
      );

  // Display Hero Mobile (28px / 36px, 700)
  static TextStyle displayHeroMobile({Color color = WorkSoluteColors.onSurface}) =>
      _baseStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 36,
        letterSpacing: -0.28,
        color: color,
      );

  // Headline Large (24px / 32px, 700)
  static TextStyle headlineLg({Color color = WorkSoluteColors.onSurface}) =>
      _baseStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 32,
        letterSpacing: -0.24,
        color: color,
      );

  // Headline Medium (20px / 28px, 600)
  static TextStyle headlineMd({Color color = WorkSoluteColors.onSurface}) =>
      _baseStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28,
        letterSpacing: 0,
        color: color,
      );

  // Headline Small (18px / 24px, 600)
  static TextStyle headlineSm({Color color = WorkSoluteColors.onSurface}) =>
      _baseStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 24,
        letterSpacing: 0,
        color: color,
      );

  // Body Large (16px / 24px, 400)
  static TextStyle bodyLg({Color color = WorkSoluteColors.onSurface}) =>
      _baseStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24,
        letterSpacing: 0,
        color: color,
      );

  // Body Medium (15px / 22px, 400)
  static TextStyle bodyMd({Color color = WorkSoluteColors.onSurface}) =>
      _baseStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 22,
        letterSpacing: 0,
        color: color,
      );

  // Body Small (13px / 18px, 400)
  static TextStyle bodySm({Color color = WorkSoluteColors.onSurfaceVariant}) =>
      _baseStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 18,
        letterSpacing: 0.13,
        color: color,
      );

  // Label Large (16px / 20px, 600)
  static TextStyle labelLg({Color color = WorkSoluteColors.onSurface}) =>
      _baseStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 20,
        letterSpacing: 0.16,
        color: color,
      );

  // Label Medium (14px / 18px, 600)
  static TextStyle labelMd({Color color = WorkSoluteColors.onSurface}) =>
      _baseStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 18,
        letterSpacing: 0.14,
        color: color,
      );

  // Label Small (12px / 16px, 600)
  static TextStyle labelSm({Color color = WorkSoluteColors.onSurface}) =>
      _baseStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16,
        letterSpacing: 0.24,
        color: color,
      );

  // Title Medium (18px / 24px, 600) -> Alias for headlineSm
  static TextStyle titleMedium({Color color = WorkSoluteColors.onSurface}) => headlineSm(color: color);

  // Body Medium (15px / 22px, 400) -> Alias for bodyMd
  static TextStyle bodyMedium({Color color = WorkSoluteColors.onSurface}) => bodyMd(color: color);

  // Label Medium (14px / 18px, 600) -> Alias for labelMd
  static TextStyle labelMedium({Color color = WorkSoluteColors.onSurface}) => labelMd(color: color);

  // Caption (11px / 14px, 500)
  static TextStyle caption({Color color = WorkSoluteColors.onSurfaceVariant}) =>
      _baseStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 14,
        letterSpacing: 0.22,
        color: color,
      );
}

typedef SahayakTypography = WorkSoluteTypography;

class CooperativeTypography {
  CooperativeTypography._();

  static TextStyle get displayHero => WorkSoluteTypography.displayHero();
  static TextStyle get displayHeroMobile => WorkSoluteTypography.displayHeroMobile();
  static TextStyle get headlineLg => WorkSoluteTypography.headlineLg();
  static TextStyle get headlineMd => WorkSoluteTypography.headlineMd();
  static TextStyle get headlineMedium => WorkSoluteTypography.headlineMd();
  static TextStyle get headlineSm => WorkSoluteTypography.headlineSm();
  static TextStyle get titleMedium => WorkSoluteTypography.headlineSm();
  static TextStyle get bodyLg => WorkSoluteTypography.bodyLg();
  static TextStyle get bodyMd => WorkSoluteTypography.bodyMd();
  static TextStyle get bodyMedium => WorkSoluteTypography.bodyMd();
  static TextStyle get bodySm => WorkSoluteTypography.bodySm();
  static TextStyle get bodySmall => WorkSoluteTypography.bodySm();
  static TextStyle get labelLg => WorkSoluteTypography.labelLg();
  static TextStyle get labelMd => WorkSoluteTypography.labelMd();
  static TextStyle get labelMedium => WorkSoluteTypography.labelMd();
  static TextStyle get labelSm => WorkSoluteTypography.labelSm();
  static TextStyle get labelSmall => WorkSoluteTypography.labelSm();
  static TextStyle get caption => WorkSoluteTypography.caption();
}
