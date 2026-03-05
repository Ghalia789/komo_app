import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'injection.dart';

import 'core/theme/app_theme.dart';
import 'domain/entities/project.dart';
import 'presentation/pages/pages.dart';
import 'presentation/blocs/blocs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Already initialized (e.g. hot-restart)
  }

  configureDependencies();

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
        '/dashboard': (context) => const DashboardPage(),
        '/create-project': (context) => const CreateProjectPage(),
        '/profile': (context) => const ProfilePage(),
        '/settings': (context) => const SettingsPage(),
        '/notifications': (context) => const NotificationsPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/create-task') {
          final projectId =
              settings.arguments is String ? settings.arguments as String : '';
          return MaterialPageRoute(
            builder: (context) => CreateTaskPage(projectId: projectId),
          );
        } else if (settings.name == '/kanban') {
          if (settings.arguments is Project) {
            final project = settings.arguments as Project;
            return MaterialPageRoute(
              builder: (context) => KanbanPage(project: project),
            );
          }
        } else if (settings.name == '/task-details') {
          if (settings.arguments is String) {
            final taskId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => TaskDetailsPage(taskId: taskId),
            );
          }
        } else if (settings.name == '/style-project') {
          if (settings.arguments is CreateProjectBloc) {
            return MaterialPageRoute(
              builder: (context) => const StyleProjectPage(),
              settings: settings,
            );
          }
        }
        return null;
      },
    );
  }
}
