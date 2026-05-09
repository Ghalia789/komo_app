import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../core/services/push_notification_service.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository,
        super(const SettingsState()) {
    on<SettingsLoadData>(_onLoadData);
    on<SettingsPushNotificationsChanged>(_onPushNotificationsChanged);
    on<SettingsEmailNotificationsChanged>(_onEmailNotificationsChanged);
    on<SettingsTaskRemindersChanged>(_onTaskRemindersChanged);
    on<SettingsDarkModeChanged>(_onDarkModeChanged);
    on<SettingsLanguageChanged>(_onLanguageChanged);
    on<SettingsClearCachePressed>(_onClearCache);
    on<SettingsDeleteAccountRequested>(_onDeleteAccount);
  }

  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  static const String _emailNotificationsKey = 'email_notifications_enabled';
  static const String _taskRemindersKey = 'task_reminders_enabled';
  static const String _darkModeKey = 'dark_mode_enabled';

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> _onLoadData(
    SettingsLoadData event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      accountDeleted: false,
      errorMessage: () => null,
    ));

    final prefs = await SharedPreferences.getInstance();
    final pushNotifications =
        prefs.getBool(StorageKeys.notificationsEnabled) ?? state.pushNotifications;
    final emailNotifications =
        prefs.getBool(_emailNotificationsKey) ?? state.emailNotifications;
    final taskReminders =
        prefs.getBool(_taskRemindersKey) ?? state.taskReminders;
    final darkMode =
      (prefs.getString(StorageKeys.themeMode) == 'dark') ||
        (prefs.getBool(_darkModeKey) ?? state.darkMode);
    final language = prefs.getString(StorageKeys.language) ?? state.language;

    final cacheSize = _estimateCacheSizeMb(prefs);

    emit(state.copyWith(
      isLoading: false,
      pushNotifications: pushNotifications,
      emailNotifications: emailNotifications,
      taskReminders: taskReminders,
      darkMode: darkMode,
      language: language,
      cacheSize: cacheSize,
    ));
  }

  void _onPushNotificationsChanged(
    SettingsPushNotificationsChanged event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(pushNotifications: event.value));
    _saveBool(StorageKeys.notificationsEnabled, event.value);
    PushNotificationService.setPushEnabled(event.value);
  }

  void _onEmailNotificationsChanged(
    SettingsEmailNotificationsChanged event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(emailNotifications: event.value));
    _saveBool(_emailNotificationsKey, event.value);
  }

  void _onTaskRemindersChanged(
    SettingsTaskRemindersChanged event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(taskReminders: event.value));
    _saveBool(_taskRemindersKey, event.value);
  }

  void _onDarkModeChanged(
    SettingsDarkModeChanged event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(darkMode: event.value));
    _saveBool(_darkModeKey, event.value);
    _saveString(StorageKeys.themeMode, event.value ? 'dark' : 'light');
  }

  void _onLanguageChanged(
    SettingsLanguageChanged event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(language: event.language));
    _saveString(StorageKeys.language, event.language);
  }

  Future<void> _onClearCache(
    SettingsClearCachePressed event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isClearingCache: true));

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.cachedUser);
    await prefs.remove(StorageKeys.cachedProjects);
    await prefs.remove(StorageKeys.cacheTimestamp);

    emit(state.copyWith(
      isClearingCache: false,
      cacheSize: 0,
    ));
  }

  Future<void> _onDeleteAccount(
    SettingsDeleteAccountRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: () => null));

    final currentUserResult = await _authRepository.getCurrentUser();
    await currentUserResult.fold(
      (failure) async {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: () => failure.message,
        ));
      },
      (user) async {
        final deleteResult = event.mode == AccountDeleteMode.archive
            ? await _userRepository.softDeleteAccount(userId: user.id)
            : await _userRepository.hardDeleteAccount(userId: user.id);

        await deleteResult.fold(
          (failure) async {
            emit(state.copyWith(
              isLoading: false,
              errorMessage: () => failure.message,
            ));
          },
          (_) async {
            await _authRepository.signOut();
            emit(state.copyWith(
              isLoading: false,
              accountDeleted: true,
            ));
          },
        );
      },
    );
  }

  int _estimateCacheSizeMb(SharedPreferences prefs) {
    final keys = [
      StorageKeys.cachedUser,
      StorageKeys.cachedProjects,
      StorageKeys.cacheTimestamp,
    ];
    var totalChars = 0;
    for (final key in keys) {
      final value = prefs.get(key);
      if (value is String) totalChars += value.length;
      if (value is List<String>) {
        totalChars += value.join('').length;
      }
    }

    // Rough estimate (UTF-16 chars in memory) converted to MB.
    final bytes = totalChars * 2;
    final mb = (bytes / (1024 * 1024)).ceil();
    return mb <= 0 ? 0 : mb;
  }
}
