import 'package:flutter/material.dart';
import 'package:komo_app/presentation/pages/login_page.dart';
import 'package:komo_app/presentation/pages/onboarding_page.dart';
import 'package:komo_app/presentation/pages/splash_page.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/signup_page.dart';

void main() {
  runApp(const KomoApp());
}

class KomoApp extends StatelessWidget {
  const KomoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KOMO',
      theme: AppTheme.lightTheme,
      routes: {
        '/': (context) => const SplashPage(),
        '/onboarding': (context) => const OnboardingPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(), 
        //'/dashboard': (context) => const DashboardPage(), // Create later
      },
    );
  }
}
