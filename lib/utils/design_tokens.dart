import 'package:flutter/material.dart';

/// Centralized design tokens aligned with the EduTube website design system.
/// Source: globals.css, tailwind.config.mjs
abstract final class AppColors {
  // ── Primary scale ──
  static const primary50 = Color(0xFFF7FAFC);
  static const primary100 = Color(0xFFEDF2F7);
  static const primary200 = Color(0xFFE2E8F0);
  static const primary300 = Color(0xFFCBD5E0);
  static const primary400 = Color(0xFFA0AEC0);
  static const primary500 = Color(0xFF4A5568);
  static const primary600 = Color(0xFF2D3748);
  static const primary700 = Color(0xFF1A365D);
  static const primary800 = Color(0xFF102C57); // Brand primary
  static const primary900 = Color(0xFF0A1628);

  // ── Accent (red) ──
  static const accent500 = Color(0xFFEF4444);
  static const accent600 = Color(0xFFB52827); // Brand accent

  // ── Grays (neutral scale) ──
  static const gray50 = Color(0xFFFAFAFA);
  static const gray100 = Color(0xFFF5F5F5);
  static const gray200 = Color(0xFFE5E5E5);
  static const gray300 = Color(0xFFD4D4D4);
  static const gray400 = Color(0xFFA3A3A3);
  static const gray500 = Color(0xFF737373);
  static const gray600 = Color(0xFF525252);
  static const gray700 = Color(0xFF404040);
  static const gray800 = Color(0xFF262626);
  static const gray900 = Color(0xFF171717);

  // ── Semantic ──
  static const success = Color(0xFF38A169);
  static const warning = Color(0xFFD69E2E);
  static const error = Color(0xFFE53E3E);

  // ── Convenience aliases ──
  static const scaffoldBg = gray50;
  static const textPrimary = gray900;
  static const textSecondary = gray500;
  static const textMuted = gray400;
  static const border = gray200;
  static const divider = Color(0xFFE2E8F0);
  static const cardBg = Colors.white;
}

abstract final class AppRadius {
  static const sm = 6.0;
  static const md = 8.0;
  static const lg = 12.0;
  static const xl = 16.0;
  static const xxl = 20.0;
  static const xxxl = 24.0;
}

abstract final class AppShadows {
  static final card = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];
  static final cardHover = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 15,
      offset: const Offset(0, 4),
    ),
  ];
}

abstract final class AppDurations {
  static const fast = Duration(milliseconds: 150);
  static const base = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 350);
}

abstract final class AppCurves {
  static const standard = Cubic(0.4, 0, 0.2, 1);
}

// ── Theme-adaptive colors via ThemeExtension ──

@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.scaffoldBg,
    required this.cardBg,
    required this.surface,
    required this.heading,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textHint,
    required this.border,
    required this.divider,
  });

  final Color scaffoldBg;
  final Color cardBg;
  final Color surface;
  final Color heading;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textHint;
  final Color border;
  final Color divider;

  // ── Light preset ──
  static const light = AppColorsExtension(
    scaffoldBg: AppColors.scaffoldBg,
    cardBg: Color(0xFFFFFFFF),
    surface: AppColors.gray50,
    heading: AppColors.primary900,
    textPrimary: AppColors.gray900,
    textSecondary: AppColors.gray500,
    textMuted: AppColors.gray400,
    textHint: AppColors.gray300,
    border: AppColors.border,
    divider: AppColors.divider,
  );

  // ── Dark preset (navy-tinted) ──
  static const dark = AppColorsExtension(
    scaffoldBg: Color(0xFF0D1117),
    cardBg: Color(0xFF161B22),
    surface: Color(0xFF21262D),
    heading: Color(0xFFE6EDF3),
    textPrimary: Color(0xFFC9D1D9),
    textSecondary: Color(0xFF8B949E),
    textMuted: Color(0xFF6E7681),
    textHint: Color(0xFF484F58),
    border: Color(0xFF30363D),
    divider: Color(0xFF21262D),
  );

  @override
  AppColorsExtension copyWith({
    Color? scaffoldBg,
    Color? cardBg,
    Color? surface,
    Color? heading,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textHint,
    Color? border,
    Color? divider,
  }) {
    return AppColorsExtension(
      scaffoldBg: scaffoldBg ?? this.scaffoldBg,
      cardBg: cardBg ?? this.cardBg,
      surface: surface ?? this.surface,
      heading: heading ?? this.heading,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textHint: textHint ?? this.textHint,
      border: border ?? this.border,
      divider: divider ?? this.divider,
    );
  }

  @override
  AppColorsExtension lerp(AppColorsExtension? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      scaffoldBg: Color.lerp(scaffoldBg, other.scaffoldBg, t)!,
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      heading: Color.lerp(heading, other.heading, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
    );
  }
}

/// Quick access to the adaptive color tokens from any widget.
extension AppThemeX on BuildContext {
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>()!;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
