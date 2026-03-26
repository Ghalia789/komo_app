import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final bool pushNotifications;
  final bool emailNotifications;
  final bool taskReminders;
  final bool darkMode;
  final String language;
  final int cacheSize; // in MB
  final bool isLoading;
  final bool isClearingCache;
  final bool accountDeleted;
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
    this.accountDeleted = false,
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
    bool? accountDeleted,
    String? Function()? errorMessage,
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
      accountDeleted: accountDeleted ?? this.accountDeleted,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        pushNotifications,
        emailNotifications,
        taskReminders,
        darkMode,
        language,
        cacheSize,
        isLoading,
        isClearingCache,
    accountDeleted,
        errorMessage,
      ];
}
