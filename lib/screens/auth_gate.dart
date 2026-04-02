import 'package:flutter/material.dart';
import 'package:edutube_shorts/pages/home_page.dart';
import 'package:edutube_shorts/screens/login_screen.dart';
import 'package:edutube_shorts/screens/onboarding_screen.dart';
import 'package:edutube_shorts/services/auth_service.dart';

class AppEntryScreen extends StatelessWidget {
  const AppEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.instance.hasSeenOnboarding(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const _AuthLoadingScaffold();
        }

        final seenOnboarding = snapshot.data ?? false;
        if (!seenOnboarding) {
          return const OnboardingScreen();
        }
        return const AuthGate();
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.instance.isLoggedIn(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const _AuthLoadingScaffold();
        }

        final loggedIn = snapshot.data ?? false;
        if (loggedIn) return const HomePage();
        return const LoginScreen();
      },
    );
  }
}

class _AuthLoadingScaffold extends StatelessWidget {
  const _AuthLoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}
