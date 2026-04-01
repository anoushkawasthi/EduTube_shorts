import 'package:flutter/material.dart';
import 'package:edutube_shorts/pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color primaryBlue = Color(0xFF1F3A70);
  static const Color navyBlue = Color(0xFF0B2E4A);
  static const Color scaffoldBg = Color(0xFFF5F7FA);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thapar EduTube',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: primaryBlue,
        scaffoldBackgroundColor: scaffoldBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          brightness: Brightness.light,
          surface: scaffoldBg,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      home: const HomePage(),
    );
  }
}
