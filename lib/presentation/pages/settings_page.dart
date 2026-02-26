import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../blocs/settings/settings_bloc_exports.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc()..add(SettingsLoadData()),
      child: const SettingsView(),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NOTIFICATIONS SECTION
                _buildSectionTitle('Notifications'),
                const SizedBox(height: 12),
                _buildSettingsCard([
                  _buildSwitchTile(
                    icon: Icons.notifications_outlined,
                    title: 'Push Notifications',
                    subtitle: 'Receive push notifications',
                    value: state.pushNotifications,
                    onChanged: (val) => context
                        .read<SettingsBloc>()
                        .add(SettingsPushNotificationsChanged(val)),
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: Icons.email_outlined,
                    title: 'Email Notifications',
                    subtitle: 'Receive email updates',
                    value: state.emailNotifications,
                    onChanged: (val) => context
                        .read<SettingsBloc>()
                        .add(SettingsEmailNotificationsChanged(val)),
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: Icons.alarm_outlined,
                    title: 'Task Reminders',
                    subtitle: 'Get reminded before deadlines',
                    value: state.taskReminders,
                    onChanged: (val) => context
                        .read<SettingsBloc>()
                        .add(SettingsTaskRemindersChanged(val)),
                  ),
                ]),

                const SizedBox(height: 28),

                // APPEARANCE SECTION
                _buildSectionTitle('Appearance'),
                const SizedBox(height: 12),
                _buildSettingsCard([
                  _buildSwitchTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    subtitle: 'Switch to dark theme',
                    value: state.darkMode,
                    onChanged: (val) => context
                        .read<SettingsBloc>()
                        .add(SettingsDarkModeChanged(val)),
                  ),
                  _buildDivider(),
                  _buildSelectTile(
                    context: context,
                    icon: Icons.language_outlined,
                    title: 'Language',
                    value: state.language,
                    onTap: () => _showLanguagePicker(context, state),
                  ),
                ]),

                const SizedBox(height: 28),

                // PRIVACY SECTION
                _buildSectionTitle('Privacy & Security'),
                const SizedBox(height: 12),
                _buildSettingsCard([
                  _buildActionTile(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildActionTile(
                    icon: Icons.fingerprint,
                    title: 'Biometric Login',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildActionTile(
                    icon: Icons.security_outlined,
                    title: 'Two-Factor Authentication',
                    onTap: () {},
                  ),
                ]),

                const SizedBox(height: 28),

                // DATA SECTION
                _buildSectionTitle('Data'),
                const SizedBox(height: 12),
                _buildSettingsCard([
                  _buildActionTile(
                    icon: Icons.download_outlined,
                    title: 'Export Data',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildActionTile(
                    icon: Icons.delete_outline,
                    title: 'Clear Cache',
                    subtitle: '${state.cacheSize} MB',
                    onTap: () => _showClearCacheDialog(context, state),
                  ),
                  _buildDivider(),
                  _buildActionTile(
                    icon: Icons.delete_forever_outlined,
                    title: 'Delete Account',
                    titleColor: AppColors.error,
                    onTap: () => _showDeleteAccountDialog(context),
                  ),
                ]),

                const SizedBox(height: 28),

                // APP INFO
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Komo v1.0.0',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textHint,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Made with 💜 by ITBS Team',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      color: AppColors.background,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: AppColors.textHint,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (titleColor ?? AppColors.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: titleColor ?? AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: titleColor ?? AppColors.textPrimary,
                  ),
                ),
              ),
              if (subtitle != null) ...[
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Icon(
                Icons.chevron_right,
                color: AppColors.textHint,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, SettingsState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textHint.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Language',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ...SettingsState.availableLanguages.map((lang) => ListTile(
                    title: Text(lang),
                    trailing: state.language == lang
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      context
                          .read<SettingsBloc>()
                          .add(SettingsLanguageChanged(lang));
                      Navigator.pop(bottomSheetContext);
                    },
                  )),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showClearCacheDialog(BuildContext context, SettingsState state) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Cache'),
        content:
            Text('This will clear ${state.cacheSize} MB of cached data. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<SettingsBloc>().add(SettingsClearCachePressed());
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action is irreversible. All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<SettingsBloc>().add(SettingsDeleteAccountPressed());
              Navigator.pop(dialogContext);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
