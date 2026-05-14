import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../injection.dart';
import '../blocs/profile/profile_bloc_exports.dart';
import '../widgets/widgets.dart';
import 'complete_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        authRepository: locator(),
        userRepository: locator(),
      )..add(ProfileLoadData()),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  static final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.logoutSuccess) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // PROFILE HEADER
                _buildProfileHeader(context, state),
                const SizedBox(height: 32),

                // STATS ROW
                _buildStatsRow(state),
                const SizedBox(height: 32),

                // PROFILE OPTIONS
                _buildSection(
                  title: 'Account',
                  children: [
                    _buildOptionTile(
                      icon: Icons.person_outline,
                      title: 'Edit Profile',
                      onTap: () {
                        final state = context.read<ProfileBloc>().state;
                        Navigator.pushNamed(
                          context,
                          RouteConstants.completeProfile,
                          arguments: CompleteProfileArguments(
                            name: state.name.isNotEmpty ? state.name : null,
                            jobTitle: state.jobTitle.isNotEmpty ? state.jobTitle : null,
                            company: state.company.isNotEmpty ? state.company : null,
                            role: state.role.isNotEmpty ? state.role : null,
                            avatarUrl: state.avatarUrl,
                          ),
                        );
                      },
                    ),
                    _buildOptionTile(
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      onTap: () => _sendPasswordResetCode(context, state),
                    ),
                    _buildOptionTile(
                      icon: Icons.verified_outlined,
                      title: 'Resend Verification Email',
                      onTap: () => _resendVerificationEmail(context),
                    ),
                    _buildOptionTile(
                      icon: Icons.email_outlined,
                      title: 'Email Preferences',
                      onTap: () => Navigator.pushNamed(context, RouteConstants.settings),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _buildSection(
                  title: 'Workspace',
                  children: [
                    _buildOptionTile(
                      icon: Icons.people_outline,
                      title: 'Team Members',
                      subtitle: '${state.teamMembersCount} members',
                      onTap: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        RouteConstants.dashboard,
                        (route) => false,
                      ),
                    ),
                    _buildOptionTile(
                      icon: Icons.folder_outlined,
                      title: 'My Projects',
                      subtitle: '${state.activeProjectsCount} active projects',
                      onTap: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        RouteConstants.dashboard,
                        (route) => false,
                      ),
                    ),
                    _buildOptionTile(
                      icon: Icons.archive_outlined,
                      title: 'Archived Tasks',
                      onTap: () => _showInfo(context, 'Archived tasks are coming soon.'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _buildSection(
                  title: 'Support',
                  children: [
                    _buildOptionTile(
                      icon: Icons.help_outline,
                      title: 'Help Center',
                      onTap: () => _showHelpCenter(context),
                    ),
                    _buildOptionTile(
                      icon: Icons.feedback_outlined,
                      title: 'Send Feedback',
                      onTap: () => _copySupportEmail(context),
                    ),
                    _buildOptionTile(
                      icon: Icons.info_outline,
                      title: 'About Komo',
                      onTap: () => _showAboutKomo(context),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // LOGOUT BUTTON
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<ProfileBloc>().add(ProfileLogoutPressed());
                    },
                    icon: const Icon(Icons.logout, color: AppColors.error),
                    label: const Text(
                      'Log Out',
                      style: TextStyle(color: AppColors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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

  Widget _buildProfileHeader(BuildContext context, ProfileState state) {
    return Column(
      children: [
        // Avatar
        Stack(
          children: [
            KomoAvatar(
              name: state.name,
              imageUrl: state.avatarUrl,
              size: 100,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  _pickAvatar(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Name
        Text(
          state.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        // Role
        Text(
          state.role,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        // Email
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.email_outlined,
              size: 14,
              color: AppColors.textHint,
            ),
            const SizedBox(width: 6),
            Text(
              state.email,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickAvatar(BuildContext context) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );

    if (!context.mounted || image == null) return;

    context.read<ProfileBloc>().add(ProfileAvatarChanged(image.path));
  }

  Future<void> _sendPasswordResetCode(
    BuildContext context,
    ProfileState state,
  ) async {
    final email = state.email.trim();
    if (email.isEmpty) {
      _showInfo(context, 'No email found on your profile.');
      return;
    }

    final authRepository = locator<AuthRepository>();
    final result = await authRepository.sendPasswordResetCode(email: email);
    result.fold(
      (failure) => _showInfo(context, failure.message),
      (_) => _showInfo(context, 'Reset code sent to $email'),
    );
  }

  Future<void> _resendVerificationEmail(BuildContext context) async {
    final authRepository = locator<AuthRepository>();

    final verifiedResult = await authRepository.isCurrentUserEmailVerified(
      reload: true,
    );

    final alreadyVerified = verifiedResult.fold(
      (_) => false,
      (isVerified) => isVerified,
    );
    if (alreadyVerified) {
      _showInfo(context, 'Your email is already verified.');
      return;
    }

    final sendResult = await authRepository.sendEmailVerification();
    sendResult.fold(
      (failure) => _showInfo(context, failure.message),
      (_) => _showInfo(context, 'Verification email sent. Please check your inbox.'),
    );
  }

  Future<void> _copySupportEmail(BuildContext context) async {
    const supportEmail = 'support@komo.app';
    await Clipboard.setData(const ClipboardData(text: supportEmail));
    _showInfo(context, 'Support email copied: $supportEmail');
  }

  void _showHelpCenter(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Help Center'),
        content: const Text(
          'For account or workspace help, contact support@komo.app.\n\n'
          'Tip: You can also reset your password directly from Profile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutKomo(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationLegalese: 'KOMO collaborative workspace app.',
    );
  }

  void _showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildStatsRow(ProfileState state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('${state.tasksDone}', 'Tasks Done'),
          _buildDivider(),
          _buildStatItem('${state.projectsCount}', 'Projects'),
          _buildDivider(),
          _buildStatItem('${state.onTimePercentage}%', 'On Time'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppColors.textHint.withOpacity(0.2),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    String? subtitle,
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
}
