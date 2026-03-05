import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../injection.dart';
import '../blocs/blocs.dart';
import '../widgets/widgets.dart';

// ENTRY POINT: Provides BLoC to the page
class InviteProjectPage extends StatelessWidget {
  final String projectId;

  const InviteProjectPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InviteProjectBloc(
        projectRepository: locator<ProjectRepository>(),
        userRepository: locator<UserRepository>(),
      )..add(InviteProjectLoaded(projectId)),
      child: const InviteProjectView(),
    );
  }
}

// UI WIDGET: Builds the actual screen
class InviteProjectView extends StatefulWidget {
  const InviteProjectView({super.key});

  @override
  State<InviteProjectView> createState() => _InviteProjectViewState();
}

class _InviteProjectViewState extends State<InviteProjectView> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Invite to Project'),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Show menu options
            },
          ),
        ],
      ),
      body: BlocConsumer<InviteProjectBloc, InviteProjectState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.success,
              ),
            );
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }

          // Clear email field when invite is sent
          if (state.isInviteSent) {
            _emailController.clear();
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.projectTitle.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // PROJECT INFO CARD
                ProjectInfoCard(
                  title: state.projectTitle,
                  description: state.projectDescription,
                ),

                const SizedBox(height: 32),

                // INVITE PEOPLE SECTION
                const Text(
                  'Invite People',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                // EMAIL INPUT WITH INVITE BUTTON
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          context.read<InviteProjectBloc>().add(
                                InviteEmailChanged(value),
                              );
                        },
                        decoration: InputDecoration(
                          hintText: 'email@example.com',
                          filled: true,
                          fillColor: AppColors.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          errorText: state.emailError,
                          errorStyle: const TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: state.isLoading || !state.isValid
                            ? null
                            : () {
                                context.read<InviteProjectBloc>().add(
                                      InviteSubmitted(),
                                    );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(0, 52),
                        ),
                        child: state.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Invite',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // PENDING INVITES SECTION
                if (state.pendingInvites.isNotEmpty) ...[
                  const Text(
                    'Pending Invites',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: state.pendingInvites
                          .map(
                            (invite) => PendingInviteItem(
                              email: invite.email,
                              onResend: () {
                                context.read<InviteProjectBloc>().add(
                                      InviteResend(invite.email),
                                    );
                              },
                              onRemove: () {
                                context.read<InviteProjectBloc>().add(
                                      InviteRemove(invite.email),
                                    );
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // TEAM MEMBERS SECTION
                const Text(
                  'Team Members',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: state.teamMembers
                        .map(
                          (member) => TeamMemberItem(
                            name: member.name,
                            email: member.email,
                            role: member.role,
                            imageUrl: member.imageUrl,
                            onMenuTap: member.role != 'Owner'
                                ? () {
                                    context.read<InviteProjectBloc>().add(
                                          TeamMemberMenuTapped(member.email),
                                        );
                                  }
                                : null,
                          ),
                        )
                        .toList(),
                  ),
                ),

                const SizedBox(height: 32),

                // LEAVE PROJECT BUTTON
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      _showLeaveProjectDialog(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Leave Project',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLeaveProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave Project'),
        content: const Text(
          'Are you sure you want to leave this project? You will need to be invited again to rejoin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<InviteProjectBloc>().add(LeaveProjectPressed());
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}