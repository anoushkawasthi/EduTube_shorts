import 'package:flutter/material.dart';
import 'package:edutube_shorts/pages/home_page.dart';
import 'package:edutube_shorts/screens/login_screen.dart';
import 'package:edutube_shorts/screens/onboarding_screen.dart';
import 'package:edutube_shorts/screens/profile_setup_screen.dart';
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

  Future<({bool loggedIn, bool profileComplete})> _loadAuthState() async {
    final loggedIn = await AuthService.instance.isLoggedIn();
    final profileComplete =
        loggedIn ? await AuthService.instance.isProfileComplete() : false;
    return (loggedIn: loggedIn, profileComplete: profileComplete);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<({bool loggedIn, bool profileComplete})>(
      future: _loadAuthState(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const _AuthLoadingScaffold();
        }

        final state = snapshot.data!;
        if (!state.loggedIn) return const LoginScreen();
        if (!state.profileComplete) return const ProfileSetupScreen();
        return const HomePage();
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
