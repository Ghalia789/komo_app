import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../blocs/blocs.dart';
import '../widgets/widgets.dart';

class CompleteProfilePage extends StatelessWidget {
  const CompleteProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CompleteProfileBloc(),
      child: const CompleteProfileView(),
    );
  }
}

class CompleteProfileView extends StatelessWidget {
  const CompleteProfileView({super.key});

  final List<String> _roles = const [
    'Designer',
    'Developer',
    'Manager',
    'Product Owner',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Complete your profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // AVATAR
            Center(
              child: Stack(
                children: [
                  BlocBuilder<CompleteProfileBloc, CompleteProfileState>(
                    builder: (context, state) {
                      return CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        backgroundImage: state.avatarPath != null
                            ? NetworkImage(state.avatarPath!)
                            : null,
                        child: state.avatarPath == null
                            ? const Icon(
                                Icons.person_outline,
                                size: 60,
                                color: AppColors.textSecondary,
                              )
                            : null,
                      );
                    },
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                        onPressed: () {
                          // TODO: Image picker
                          context.read<CompleteProfileBloc>().add(
                            CompleteProfileAvatarChanged(null),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // WHITE CARD
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // FULL NAME
                  BlocBuilder<CompleteProfileBloc, CompleteProfileState>(
                    buildWhen: (previous, current) => 
                      previous.name != current.name ||
                      previous.nameError != current.nameError,
                    builder: (context, state) {
                      return KomoTextField(
                        label: 'Full Name',
                        hint: 'John Doe',
                        errorText: state.nameError,
                        onChanged: (value) {
                          context.read<CompleteProfileBloc>().add(
                            CompleteProfileNameChanged(value),
                          );
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // JOB TITLE
                  BlocBuilder<CompleteProfileBloc, CompleteProfileState>(
                    buildWhen: (previous, current) => 
                      previous.jobTitle != current.jobTitle,
                    builder: (context, state) {
                      return KomoTextField(
                        label: 'Job Title',
                        hint: 'Product Designer',
                        onChanged: (value) {
                          context.read<CompleteProfileBloc>().add(
                            CompleteProfileJobTitleChanged(value),
                          );
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // COMPANY (Optional)
                  BlocBuilder<CompleteProfileBloc, CompleteProfileState>(
                    buildWhen: (previous, current) => 
                      previous.company != current.company,
                    builder: (context, state) {
                      return KomoTextField(
                        label: 'Company (Optional)',
                        hint: 'Acme Inc.',
                        onChanged: (value) {
                          context.read<CompleteProfileBloc>().add(
                            CompleteProfileCompanyChanged(value),
                          );
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // ROLE DROPDOWN
                  BlocBuilder<CompleteProfileBloc, CompleteProfileState>(
                    buildWhen: (previous, current) => 
                      previous.role != current.role,
                    builder: (context, state) {
                      return KomoDropdown<String>(
                        label: 'What best describes you?',
                        hint: 'Role',
                        value: state.role.isEmpty ? null : state.role,
                        items: _roles,
                        itemLabel: (role) => role,
                        onChanged: (value) {
                          if (value != null) {
                            context.read<CompleteProfileBloc>().add(
                              CompleteProfileRoleChanged(value),
                            );
                          }
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // SAVE BUTTON
                  BlocConsumer<CompleteProfileBloc, CompleteProfileState>(
                    listenWhen: (previous, current) => 
                      previous.isSuccess != current.isSuccess,
                    listener: (context, state) {
                      if (state.isSuccess) {
                        Navigator.of(context).pushReplacementNamed('/dashboard');
                      }
                    },
                    builder: (context, state) {
                      return KomoButton(
                        text: state.isLoading ? 'Saving...' : 'Save',
                        isLoading: state.isLoading,
                        onPressed: state.isLoading || !state.isValid
                            ? null
                            : () {
                                context.read<CompleteProfileBloc>().add(
                                  CompleteProfileSubmitted(),
                                );
                              },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}