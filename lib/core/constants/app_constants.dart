/// Application-wide constants

// ==================== Route Constants ====================

class RouteConstants {
  RouteConstants._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String completeProfile = '/complete-profile';
  static const String dashboard = '/dashboard';
  static const String kanban = '/kanban';
  static const String taskDetails = '/task-details';
  static const String createProject = '/create-project';
  static const String styleProject = '/style-project';
  static const String createTask = '/create-task';
  static const String inviteProject = '/invite-project';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
}

// ==================== Asset Constants ====================

class AssetConstants {
  AssetConstants._();

  // Base paths
  static const String _imagesPath = 'assets/images';
  static const String _iconsPath = 'assets/icons';
  static const String animationsPath = 'assets/animations';
  static const String fontsPath = 'assets/fonts';
  
  // Logo
  static const String komoLogoMini = '$_imagesPath/KOMO_LOGO_MINI.png';
  
  // Onboarding images
  static const String handWithClipboard = '$_imagesPath/hand_with_clipboard.png';
  static const String collaborating = '$_imagesPath/collaborating.png';
  static const String lightbulb = '$_imagesPath/lightbulb.png';
  
  // Placeholders (add if needed)
  static const String avatarPlaceholder = '$_imagesPath/avatar_placeholder.png';
  
  // Icons (add if needed)
  static const String iconGoogle = '$_iconsPath/google.svg';
}

// ==================== Storage Keys ====================

class StorageKeys {
  StorageKeys._();

  // Auth (Firebase handles tokens internally)
  static const String userId = 'user_id';
  static const String isLoggedIn = 'is_logged_in';
  static const String isFirstLaunch = 'is_first_launch';
  
  // User preferences
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String notificationsEnabled = 'notifications_enabled';
  
  // Cache
  static const String cachedUser = 'cached_user';
  static const String cachedProjects = 'cached_projects';
  static const String cacheTimestamp = 'cache_timestamp';
}

// ==================== App Constants ====================

class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Komo';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache duration (in hours)
  static const int cacheDuration = 24;
  
  // Input limits
  static const int maxEmailLength = 255;
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int maxNameLength = 100;
  static const int maxProjectNameLength = 100;
  static const int maxProjectDescriptionLength = 500;
  static const int maxTaskTitleLength = 200;
  static const int maxTaskDescriptionLength = 2000;
  static const int maxCommentLength = 1000;
  
  // Date formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayTimeFormat = 'h:mm a';
  static const String displayDateTimeFormat = 'MMM dd, yyyy h:mm a';
  
  // Animation durations (in milliseconds)
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 350;
  static const int longAnimationDuration = 500;
  
  // Debounce duration (in milliseconds)
  static const int searchDebounceDuration = 300;
  static const int inputDebounceDuration = 500;
}

// ==================== Firebase Constants ====================

class FirebaseConstants {
  FirebaseConstants._();

  // Collections
  static const String usersCollection = 'users';
  static const String projectsCollection = 'projects';
  static const String tasksCollection = 'tasks';
  static const String subtasksCollection = 'subtasks';
  static const String commentsCollection = 'comments';
  static const String notificationsCollection = 'notifications';
  static const String invitationsCollection = 'invitations';
  
  // Storage paths
  static const String profileImagesPath = 'profile_images';
  static const String projectImagesPath = 'project_images';
  static const String taskAttachmentsPath = 'task_attachments';
}

// ==================== Error Messages ====================

class ErrorMessages {
  ErrorMessages._();

  // Generic
  static const String somethingWentWrong = 'Something went wrong. Please try again.';
  static const String noInternetConnection = 'No internet connection. Please check your network.';
  static const String serverError = 'Server error. Please try again later.';
  static const String timeout = 'Request timed out. Please try again.';
  
  // Auth
  static const String invalidCredentials = 'Invalid email or password.';
  static const String emailAlreadyInUse = 'This email is already registered.';
  static const String weakPassword = 'Password is too weak.';
  static const String userNotFound = 'No account found with this email.';
  static const String sessionExpired = 'Your session has expired. Please login again.';
  static const String accountDisabled = 'This account has been disabled.';
  
  // Validation
  static const String invalidEmail = 'Please enter a valid email address.';
  static const String passwordTooShort = 'Password must be at least 8 characters.';
  static const String passwordsDoNotMatch = 'Passwords do not match.';
  static const String fieldRequired = 'This field is required.';
  
  // Permission
  static const String permissionDenied = 'You do not have permission to perform this action.';
  static const String notFound = 'The requested resource was not found.';
}

// ==================== Success Messages ====================

class SuccessMessages {
  SuccessMessages._();

  static const String loginSuccess = 'Login successful!';
  static const String signupSuccess = 'Account created successfully!';
  static const String logoutSuccess = 'Logged out successfully.';
  static const String profileUpdated = 'Profile updated successfully.';
  static const String projectCreated = 'Project created successfully.';
  static const String projectUpdated = 'Project updated successfully.';
  static const String projectDeleted = 'Project deleted successfully.';
  static const String taskCreated = 'Task created successfully.';
  static const String taskUpdated = 'Task updated successfully.';
  static const String taskDeleted = 'Task deleted successfully.';
  static const String inviteSent = 'Invitation sent successfully.';
  static const String passwordResetSent = 'Password reset email sent.';
}
