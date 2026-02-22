import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'presentation/pages/complete_profile_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/onboarding_page.dart';
import 'presentation/pages/signup_page.dart';
import 'presentation/pages/splash_page.dart';

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
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const SplashPage(),
        '/onboarding': (context) => const OnboardingPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(), 
        '/complete-profile': (context) => const CompleteProfilePage(),
        //'/dashboard': (context) => const DashboardPage(), // Create later
      },
    );
  }
}
