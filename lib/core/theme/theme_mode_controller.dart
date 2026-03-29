import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Single source of truth for app-wide theme mode.
class ThemeModeController {
  ThemeModeController._();

  static final ValueNotifier<ThemeMode> notifier =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    final legacyDark = prefs.getBool('dark_mode_enabled');
    final savedTheme = prefs.getString(StorageKeys.themeMode);

    if (savedTheme == 'dark' || (savedTheme == null && legacyDark == true)) {
      notifier.value = ThemeMode.dark;
    } else {
      notifier.value = ThemeMode.light;
    }
  }

  static Future<void> setDarkMode(bool isDark) async {
    notifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.themeMode, isDark ? 'dark' : 'light');
    // Keep legacy bool for compatibility with existing settings state loading.
    await prefs.setBool('dark_mode_enabled', isDark);
  }

  static bool get isDarkMode => notifier.value == ThemeMode.dark;
}
