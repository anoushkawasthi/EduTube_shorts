import 'package:flutter/material.dart';

/// EduTube brand and semantic colors (aligned with web `globals.css` / Tailwind theme).
/// Accent uses documented brand red [#b52827], not the generic Tailwind accent-600.
abstract final class AppColors {
  // —— Primary scale (Tailwind primary.*) ——
  static const Color primary50 = Color(0xFFF7FAFC);
  static const Color primary100 = Color(0xFFE8EDF4);
  static const Color primary200 = Color(0xFFD1DCE8);
  static const Color primary300 = Color(0xFFA8B8CC);
  static const Color primary400 = Color(0xFF6B7F9E);
  /// Focus ring / outline (matches --primary-500 in CSS vars).
  static const Color primary500 = Color(0xFF4A5568);
  static const Color primary600 = Color(0xFF385A8A);
  static const Color primary700 = Color(0xFF244A76);
  /// Brand primary (dark blue) — main CTA & chrome.
  static const Color primary800 = Color(0xFF102C57);
  static const Color primary900 = Color(0xFF0A1628);

  // —— Accent (brand red) ——
  static const Color accent = Color(0xFFB52827);
  static const Color accentHover = Color(0xFF9E2221);
  static const Color accentLight = Color(0xFFE57373);
  /// Decorative blobs / gradients (lighter accent steps).
  static const Color accent400 = Color(0xFFE85C5A);
  static const Color accent500 = Color(0xFFCC3A38);

  // —— Neutrals (gray.*) ——
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF4F4F5);
  static const Color gray200 = Color(0xFFE4E4E7);
  static const Color gray300 = Color(0xFFD4D4D8);
  static const Color gray400 = Color(0xFFA1A1AA);
  static const Color gray500 = Color(0xFF71717A);
  static const Color gray600 = Color(0xFF52525B);
  static const Color gray700 = Color(0xFF3F3F46);
  static const Color gray800 = Color(0xFF27272A);
  static const Color gray900 = Color(0xFF18181B);

  // —— Semantic ——
  static const Color success = Color(0xFF38A169);
  static const Color warning = Color(0xFFD69E2E);
  static const Color error = Color(0xFFE53E3E);

  /// Loading / muted icon (toast “loading” tone from web layout).
  static const Color loadingMuted = Color(0xFF4A5568);

  /// Variants for course card left bar (primary blues; excludes slate focus token).
  static const List<Color> courseAccentBarColors = <Color>[
    primary900,
    primary800,
    primary700,
    primary600,
    primary400,
  ];
}
