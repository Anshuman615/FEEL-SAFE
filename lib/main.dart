import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/profile_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const FeelSafeApp());
}

class FeelSafeApp extends StatelessWidget {
  const FeelSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feel Safe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _StartupGate(),
    );
  }
}

/// Decides whether to show onboarding (first launch) or go straight home.
class _StartupGate extends StatelessWidget {
  const _StartupGate();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ProfileService().loadProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final hasProfile = snapshot.data != null;
        return hasProfile ? const HomeScreen() : const OnboardingScreen();
      },
    );
  }
}
