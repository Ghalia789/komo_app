class SettingsState {
  final bool pushNotifications;
  final bool emailNotifications;
  final bool taskReminders;
  final bool darkMode;
  final String language;
  final int cacheSize; // in MB
  final bool isLoading;
  final bool isClearingCache;
  final String? errorMessage;

  static const List<String> availableLanguages = [
    'English',
    'Français',
    'العربية',
    'Español',
  ];

  const SettingsState({
    this.pushNotifications = true,
    this.emailNotifications = false,
    this.taskReminders = true,
    this.darkMode = false,
    this.language = 'English',
    this.cacheSize = 24,
    this.isLoading = false,
    this.isClearingCache = false,
    this.errorMessage,
  });

  SettingsState copyWith({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? taskReminders,
    bool? darkMode,
    String? language,
    int? cacheSize,
    bool? isLoading,
    bool? isClearingCache,
    String? errorMessage,
  }) {
    return SettingsState(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      taskReminders: taskReminders ?? this.taskReminders,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      cacheSize: cacheSize ?? this.cacheSize,
      isLoading: isLoading ?? this.isLoading,
      isClearingCache: isClearingCache ?? this.isClearingCache,
      errorMessage: errorMessage,
    );
  }
}
