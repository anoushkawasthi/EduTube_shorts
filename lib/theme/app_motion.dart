import 'package:flutter/material.dart';

/// Durations matching web `--transition-*` (ms).
abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
  /// Buttons / interactive (~ `duration-200`).
  static const Duration interaction = Duration(milliseconds: 200);
}

/// Easing: cubic-bezier(0.4, 0, 0.2, 1) — Material [Curves.easeInOutCubicEmphasized] is close;
/// standard ease in out cubic matches Tailwind’s default transition curve.
abstract final class AppCurves {
  static const Curve standard = Curves.easeInOutCubic;
}
