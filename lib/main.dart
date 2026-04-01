import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edutube_shorts/pages/home_page.dart';
import 'package:edutube_shorts/services/user_profile_service.dart';
import 'package:edutube_shorts/services/video_state_service.dart';
import 'package:edutube_shorts/utils/video_prefetch_service.dart';
import 'package:edutube_shorts/utils/design_tokens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await VideoStateService.instance.load();
  await UserProfileService.instance.load();
  // Kick off global prefetch in background immediately after first frame.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    VideoPrefetchService.prefetchAppWide();
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = GoogleFonts.poppinsTextTheme(
      Theme.of(context).textTheme,
    );

    return MaterialApp(
      title: 'Thapar EduTube',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: AppColors.primary800,
        scaffoldBackgroundColor: AppColors.scaffoldBg,
        textTheme: baseTextTheme,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary800,
          brightness: Brightness.light,
          surface: AppColors.scaffoldBg,
          error: AppColors.error,
        ),
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
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg)),
          backgroundColor: AppColors.gray900,
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
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(color: AppColors.primary800, width: 2),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}
