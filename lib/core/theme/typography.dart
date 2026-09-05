import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Cooperative Craft Typography Scale
/// Defined in cooperative_craft/DESIGN.md
class SahayakTypography {
  SahayakTypography._();

  static TextStyle _baseStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    double letterSpacing = 0,
    Color color = SahayakColors.onSurface,
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
  static TextStyle displayHero({Color color = SahayakColors.onSurface}) =>
      _baseStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 44,
        letterSpacing: -0.72,
        color: color,
      );

  // Display Hero Mobile (28px / 36px, 700)
  static TextStyle displayHeroMobile({Color color = SahayakColors.onSurface}) =>
      _baseStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 36,
        letterSpacing: -0.28,
        color: color,
      );

  // Headline Large (24px / 32px, 700)
  static TextStyle headlineLg({Color color = SahayakColors.onSurface}) =>
      _baseStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 32,
        letterSpacing: -0.24,
        color: color,
      );

  // Headline Medium (20px / 28px, 600)
  static TextStyle headlineMd({Color color = SahayakColors.onSurface}) =>
      _baseStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28,
        letterSpacing: 0,
        color: color,
      );

  // Headline Small (18px / 24px, 600)
  static TextStyle headlineSm({Color color = SahayakColors.onSurface}) =>
      _baseStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 24,
        letterSpacing: 0,
        color: color,
      );

  // Body Large (16px / 24px, 400)
  static TextStyle bodyLg({Color color = SahayakColors.onSurface}) =>
      _baseStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24,
        letterSpacing: 0,
        color: color,
      );

  // Body Medium (15px / 22px, 400)
  static TextStyle bodyMd({Color color = SahayakColors.onSurface}) =>
      _baseStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 22,
        letterSpacing: 0,
        color: color,
      );

  // Body Small (13px / 18px, 400)
  static TextStyle bodySm({Color color = SahayakColors.onSurfaceVariant}) =>
      _baseStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 18,
        letterSpacing: 0.13,
        color: color,
      );

  // Label Large (16px / 20px, 600)
  static TextStyle labelLg({Color color = SahayakColors.onSurface}) =>
      _baseStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 20,
        letterSpacing: 0.16,
        color: color,
      );

  // Label Medium (14px / 18px, 600)
  static TextStyle labelMd({Color color = SahayakColors.onSurface}) =>
      _baseStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 18,
        letterSpacing: 0.14,
        color: color,
      );

  // Label Small (12px / 16px, 600)
  static TextStyle labelSm({Color color = SahayakColors.onSurface}) =>
      _baseStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16,
        letterSpacing: 0.24,
        color: color,
      );

  // Caption (11px / 14px, 500)
  static TextStyle caption({Color color = SahayakColors.onSurfaceVariant}) =>
      _baseStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 14,
        letterSpacing: 0.22,
        color: color,
      );
}

class CooperativeTypography {
  CooperativeTypography._();

  static TextStyle get displayHero => SahayakTypography.displayHero();
  static TextStyle get displayHeroMobile => SahayakTypography.displayHeroMobile();
  static TextStyle get headlineLg => SahayakTypography.headlineLg();
  static TextStyle get headlineMd => SahayakTypography.headlineMd();
  static TextStyle get headlineSm => SahayakTypography.headlineSm();
  static TextStyle get bodyLg => SahayakTypography.bodyLg();
  static TextStyle get bodyMd => SahayakTypography.bodyMd();
  static TextStyle get bodySm => SahayakTypography.bodySm();
  static TextStyle get labelLg => SahayakTypography.labelLg();
  static TextStyle get labelMd => SahayakTypography.labelMd();
  static TextStyle get labelSm => SahayakTypography.labelSm();
  static TextStyle get caption => SahayakTypography.caption();
}
