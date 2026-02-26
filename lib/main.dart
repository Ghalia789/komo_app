import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/models/project_model.dart';
import 'presentation/blocs/create_project/create_project_bloc.dart';
import 'presentation/pages/complete_profile_page.dart';
import 'presentation/pages/create_project_page.dart';
import 'presentation/pages/create_task_page.dart';
import 'presentation/pages/dashboard_page.dart';
import 'presentation/pages/invite_project_page.dart';
import 'presentation/pages/kanban_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/notifications_page.dart';
import 'presentation/pages/onboarding_page.dart';
import 'presentation/pages/profile_page.dart';
import 'presentation/pages/settings_page.dart';
import 'presentation/pages/signup_page.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/style_project_page.dart';
import 'presentation/pages/task_details_page.dart';

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
        '/dashboard': (context) => const DashboardPage(),
        '/invite-project': (context) => const InviteProjectPage(),
        '/create-project': (context) => const CreateProjectPage(),
        '/create-task': (context) => const CreateTaskPage(),
        '/profile': (context) => const ProfilePage(),
        '/settings': (context) => const SettingsPage(),
        '/notifications': (context) => const NotificationsPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/kanban') {
          if (settings.arguments is ProjectModel) {
            final project = settings.arguments as ProjectModel;
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
