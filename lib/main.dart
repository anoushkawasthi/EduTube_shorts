import 'package:flutter/material.dart';
import 'package:edutube_shorts/pages/home_page.dart';
import 'package:edutube_shorts/theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thapar EduTube',
      theme: buildEduTubeTheme(),
      home: const HomePage(),
    );
  }
}
