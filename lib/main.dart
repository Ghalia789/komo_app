import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'firebase_options.dart';
import 'injection.dart';

import 'core/constants/app_constants.dart';
import 'core/services/push_notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';
import 'domain/entities/project.dart';
import 'presentation/pages/pages.dart';
import 'presentation/blocs/blocs.dart';
import 'presentation/widgets/auth/email_verification_guard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Already initialized (e.g. hot-restart)
  }

  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider: kDebugMode
          ? AndroidProvider.debug
          : AndroidProvider.playIntegrity,
      appleProvider: kDebugMode
          ? AppleProvider.debug
          : AppleProvider.deviceCheck,
    );
  } catch (_) {
    // Keep app startup resilient if App Check is not fully configured yet.
  }

  configureDependencies();
  await ThemeModeController.initialize();
  await PushNotificationService.initialize();

  runApp(const KomoApp());
}

class KomoApp extends StatelessWidget {
  const KomoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeModeController.notifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'KOMO',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          debugShowCheckedModeBanner: false,
          routes: {
            '/': (context) => const SplashPage(),
            '/onboarding': (context) => const OnboardingPage(),
            '/login': (context) => const LoginPage(),
            '/signup': (context) => const SignupPage(),
            '/complete-profile': (context) => const CompleteProfilePage(),
            '/dashboard': (context) => const EmailVerificationGuard(
                  child: DashboardPage(),
                ),
            '/create-project': (context) => const EmailVerificationGuard(
                  child: CreateProjectPage(),
                ),
            '/profile': (context) => const EmailVerificationGuard(
                  child: ProfilePage(),
                ),
            '/settings': (context) => const EmailVerificationGuard(
                  child: SettingsPage(),
                ),
            '/notifications': (context) => const EmailVerificationGuard(
                  child: NotificationsPage(),
                ),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/create-task') {
              final projectId =
                  settings.arguments is String ? settings.arguments as String : '';
              return MaterialPageRoute(
                builder: (context) => EmailVerificationGuard(
                  child: CreateTaskPage(projectId: projectId),
                ),
              );
            } else if (settings.name == '/kanban') {
              if (settings.arguments is Project) {
                final project = settings.arguments as Project;
                return MaterialPageRoute(
                  builder: (context) => EmailVerificationGuard(
                    child: KanbanPage(project: project),
                  ),
                );
              }
            } else if (settings.name == '/task-details') {
              if (settings.arguments is String) {
                final taskId = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (context) => EmailVerificationGuard(
                    child: TaskDetailsPage(taskId: taskId),
                  ),
                );
              }
            } else if (settings.name == '/style-project') {
              if (settings.arguments is CreateProjectBloc) {
                return MaterialPageRoute(
                  builder: (context) => const EmailVerificationGuard(
                    child: StyleProjectPage(),
                  ),
                  settings: settings,
                );
              }
            } else if (settings.name == RouteConstants.resetPassword) {
              final email = settings.arguments is String ? settings.arguments as String : '';
              return MaterialPageRoute(
                builder: (context) => ResetPasswordPage(email: email),
              );
            }
            return null;
          },
        );
      },
    );
  }
}
