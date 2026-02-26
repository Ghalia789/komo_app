abstract class SettingsEvent {}

class SettingsLoadData extends SettingsEvent {}

class SettingsPushNotificationsChanged extends SettingsEvent {
  final bool value;
  SettingsPushNotificationsChanged(this.value);
}

class SettingsEmailNotificationsChanged extends SettingsEvent {
  final bool value;
  SettingsEmailNotificationsChanged(this.value);
}

class SettingsTaskRemindersChanged extends SettingsEvent {
  final bool value;
  SettingsTaskRemindersChanged(this.value);
}

class SettingsDarkModeChanged extends SettingsEvent {
  final bool value;
  SettingsDarkModeChanged(this.value);
}

class SettingsLanguageChanged extends SettingsEvent {
  final String language;
  SettingsLanguageChanged(this.language);
}

class SettingsClearCachePressed extends SettingsEvent {}

class SettingsDeleteAccountPressed extends SettingsEvent {}
