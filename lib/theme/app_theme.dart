import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';

/// Full app theme: Poppins body (1.6 line height), Montserrat for titles / app chrome titles.
ThemeData buildEduTubeTheme() {
  const seed = AppColors.primary800;

  final colorScheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
    primary: AppColors.primary800,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primary50,
    onPrimaryContainer: AppColors.primary900,
    secondary: AppColors.accent,
    onSecondary: Colors.white,
    surface: Colors.white,
    onSurface: AppColors.gray900,
    error: AppColors.error,
    onError: Colors.white,
  ).copyWith(
    surfaceContainerHighest: AppColors.gray100,
    outline: AppColors.gray300,
  );

  final baseText = TextTheme(
    displayLarge: GoogleFonts.montserrat(
      fontWeight: FontWeight.bold,
      color: AppColors.gray900,
      height: 1.25,
    ),
    displayMedium: GoogleFonts.montserrat(
      fontWeight: FontWeight.bold,
      color: AppColors.gray900,
      height: 1.3,
    ),
    headlineMedium: GoogleFonts.montserrat(
      fontWeight: FontWeight.bold,
      color: AppColors.gray900,
      height: 1.35,
    ),
    titleLarge: GoogleFonts.montserrat(
      fontWeight: FontWeight.w600,
      color: AppColors.gray900,
      height: 1.4,
    ),
    titleMedium: GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      color: AppColors.gray900,
      height: 1.45,
    ),
    bodyLarge: GoogleFonts.poppins(
      color: AppColors.gray900,
      height: 1.6,
    ),
    bodyMedium: GoogleFonts.poppins(
      color: AppColors.gray900,
      height: 1.6,
    ),
    bodySmall: GoogleFonts.poppins(
      color: AppColors.gray600,
      height: 1.5,
      fontSize: 13,
    ),
    labelLarge: GoogleFonts.poppins(
      fontWeight: FontWeight.w500,
      color: AppColors.gray900,
      height: 1.4,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.gray50,
    primaryColor: AppColors.primary800,
    focusColor: AppColors.primary500.withValues(alpha: 0.18),
    highlightColor: AppColors.primary500.withValues(alpha: 0.08),
    splashColor: AppColors.primary800.withValues(alpha: 0.12),
    dividerColor: AppColors.gray200,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textTheme: baseText,
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.primary800,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.montserrat(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.primary800,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.gray300,
        disabledForegroundColor: AppColors.gray500,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm + 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return AppColors.primary700.withValues(alpha: 0.92);
          }
          if (states.contains(WidgetState.hovered)) {
            return AppColors.primary700.withValues(alpha: 0.15);
          }
          return null;
        }),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary800,
        side: const BorderSide(color: AppColors.primary700, width: 1.5),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm + 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary800,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.white,
      contentTextStyle: GoogleFonts.poppins(
        color: AppColors.gray900,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md + 1),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      elevation: 8,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.loadingMuted,
    ),
    iconTheme: const IconThemeData(color: AppColors.primary800),
    listTileTheme: ListTileThemeData(
      iconColor: AppColors.primary800,
      textColor: AppColors.gray900,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.gray800,
      titleTextStyle: GoogleFonts.montserrat(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: GoogleFonts.poppins(
        color: Colors.white70,
        height: 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
    ),
  );
}
