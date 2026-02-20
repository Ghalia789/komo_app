import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

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
      //home: const SplashPage(), // We'll create this
    );
  }
}