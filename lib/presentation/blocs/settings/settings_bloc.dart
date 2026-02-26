import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<SettingsLoadData>(_onLoadData);
    on<SettingsPushNotificationsChanged>(_onPushNotificationsChanged);
    on<SettingsEmailNotificationsChanged>(_onEmailNotificationsChanged);
    on<SettingsTaskRemindersChanged>(_onTaskRemindersChanged);
    on<SettingsDarkModeChanged>(_onDarkModeChanged);
    on<SettingsLanguageChanged>(_onLanguageChanged);
    on<SettingsClearCachePressed>(_onClearCache);
    on<SettingsDeleteAccountPressed>(_onDeleteAccount);
  }

  Future<void> _onLoadData(
    SettingsLoadData event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    // TODO: Load settings from local storage
    await Future.delayed(const Duration(milliseconds: 300));

    emit(state.copyWith(isLoading: false));
  }

  void _onPushNotificationsChanged(
    SettingsPushNotificationsChanged event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(pushNotifications: event.value));
    // TODO: Save to local storage
  }

  void _onEmailNotificationsChanged(
    SettingsEmailNotificationsChanged event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(emailNotifications: event.value));
  }

  void _onTaskRemindersChanged(
    SettingsTaskRemindersChanged event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(taskReminders: event.value));
  }

  void _onDarkModeChanged(
    SettingsDarkModeChanged event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(darkMode: event.value));
    // TODO: Update theme
  }

  void _onLanguageChanged(
    SettingsLanguageChanged event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(language: event.language));
    // TODO: Update locale
  }

  Future<void> _onClearCache(
    SettingsClearCachePressed event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isClearingCache: true));

    // TODO: Actually clear cache
    await Future.delayed(const Duration(milliseconds: 500));

    emit(state.copyWith(
      isClearingCache: false,
      cacheSize: 0,
    ));
  }

  Future<void> _onDeleteAccount(
    SettingsDeleteAccountPressed event,
    Emitter<SettingsState> emit,
  ) async {
    // TODO: Delete account from backend
  }
}
