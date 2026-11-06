import 'package:flutter/material.dart';

/// SkyTrack design tokens.
///
/// A restrained, aviation-grade palette: deep midnight surfaces, a single
/// violet brand ramp, and status colors with enough contrast for both themes.
class AppColors {
  AppColors._();

  // ── Surfaces ───────────────────────────────────────────────────────────────
  static const Color primaryBackground = Color(0xFF07070F);
  static const Color secondaryBackground = Color(0xFF0C0C17);
  static const Color cardBackground = Color(0xFF12121F);
  static const Color elevatedSurface = Color(0xFF191929);
  static const Color border = Color(0xFF24243A);
  static const Color borderStrong = Color(0xFF33334D);

  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentViolet = Color(0xFFA78BFA);
  static const Color accentMagenta = Color(0xFFEC4899);
  static const Color accentCyan = Color(0xFF22D3EE);

  /// Legacy aliases kept for backward compatibility.
  static const Color accentBlue = accentPurple;

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF4F2FF);
  static const Color textSecondary = Color(0xFF9A97B8);
  static const Color textTertiary = Color(0xFF6B6885);

  /// Mid-tone text that stays readable on both light and dark surfaces.
  static const Color textMuted = Color(0xFF8B88A6);
  static const Color textOnLight = Color(0xFF101426);

  // ── Status ─────────────────────────────────────────────────────────────────
  static const Color successGreen = Color(0xFF34D399);
  static const Color warningOrange = Color(0xFFFBBF24);
  static const Color errorRed = Color(0xFFF87171);
  static const Color infoBlue = Color(0xFF60A5FA);

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFC026D3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6), Color(0xFFD946EF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient trackingGlow = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA), Color(0xFF22D3EE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [primaryBackground, Color(0xFF0B0A17), secondaryBackground],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF191929), Color(0xFF111120)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x1FFFFFFF), Color(0x0AFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Helpers ────────────────────────────────────────────────────────────────
  static Color branded(Color color, {double alpha = 0.14}) =>
      color.withValues(alpha: alpha);
}
