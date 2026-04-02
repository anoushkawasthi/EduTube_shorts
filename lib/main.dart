import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edutube_shorts/screens/auth_gate.dart';
import 'package:edutube_shorts/services/theme_service.dart';
import 'package:edutube_shorts/services/user_profile_service.dart';
import 'package:edutube_shorts/services/video_state_service.dart';
import 'package:edutube_shorts/utils/video_prefetch_service.dart';
import 'package:edutube_shorts/utils/design_tokens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await VideoStateService.instance.load();
  await UserProfileService.instance.load();
  await ThemeService.instance.load();
  // Kick off global prefetch in background immediately after first frame.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    VideoPrefetchService.prefetchAppWide();
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final _lightText = GoogleFonts.poppinsTextTheme(
    ThemeData(brightness: Brightness.light).textTheme,
  );
  static final _darkText = GoogleFonts.poppinsTextTheme(
    ThemeData(brightness: Brightness.dark).textTheme,
  );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'Thapar EduTube',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeService.instance.themeMode,
          theme: _buildTheme(Brightness.light, _lightText),
          darkTheme: _buildTheme(Brightness.dark, _darkText),
          home: const AppEntryScreen(),
        );
      },
    );
  }

  static ThemeData _buildTheme(Brightness brightness, TextTheme textTheme) {
    final isDark = brightness == Brightness.dark;
    final ext = isDark ? AppColorsExtension.dark : AppColorsExtension.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: AppColors.primary800,
      scaffoldBackgroundColor: ext.scaffoldBg,
      textTheme: textTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary800,
        brightness: brightness,
        surface: ext.cardBg,
        error: AppColors.error,
      ),
      extensions: [ext],
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary800,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: ext.cardBg,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: ext.cardBg,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: ext.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        backgroundColor: isDark ? const Color(0xFF30363D) : AppColors.gray900,
        contentTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary800,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg)),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: ext.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.primary800, width: 2),
        ),
      ),
    );
  }
}
