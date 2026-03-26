import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../injection.dart';
import '../blocs/blocs.dart';
import '../widgets/widgets.dart';

class CompleteProfileArguments {
  final String? name;
  final String? jobTitle;
  final String? company;
  final String? role;
  final String? avatarUrl;

  const CompleteProfileArguments({
    this.name,
    this.jobTitle,
    this.company,
    this.role,
    this.avatarUrl,
  });
}

class CompleteProfilePage extends StatelessWidget {
  const CompleteProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as CompleteProfileArguments?;
    return BlocProvider(
      create: (context) {
        final bloc = CompleteProfileBloc(
          authRepository: locator(),
          userRepository: locator(),
        );
        if (args != null) {
          bloc.add(CompleteProfilePrefilled(
            name: args.name,
            jobTitle: args.jobTitle,
            company: args.company,
            role: args.role,
            avatarUrl: args.avatarUrl,
          ));
        }
        return bloc;
      },
      child: const CompleteProfileView(),
    );
  }
}

class CompleteProfileView extends StatefulWidget {
  const CompleteProfileView({super.key});

  @override
  State<CompleteProfileView> createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<CompleteProfileView> {
  final List<String> _roles = const [
    'Designer',
    'Developer',
    'Manager',
    'Product Owner',
    'Other',
  ];

  late final TextEditingController _nameController;
  late final TextEditingController _jobTitleController;
  late final TextEditingController _companyController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _jobTitleController = TextEditingController();
    _companyController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _jobTitleController.dispose();
    _companyController.dispose();
    super.dispose();
  }

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
      body: BlocListener<CompleteProfileBloc, CompleteProfileState>(
        listenWhen: (prev, curr) =>
            prev.name != curr.name ||
            prev.jobTitle != curr.jobTitle ||
            prev.company != curr.company,
        listener: (_, state) {
          if (_nameController.text != state.name) {
            _nameController.text = state.name;
          }
          if (_jobTitleController.text != state.jobTitle) {
            _jobTitleController.text = state.jobTitle;
          }
          if (_companyController.text != state.company) {
            _companyController.text = state.company;
          }
        },
        child: SingleChildScrollView(
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
                          backgroundImage: _avatarImage(state.avatarPath),
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
                          onPressed: () => _pickAvatar(context),
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
                          controller: _nameController,
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
                          controller: _jobTitleController,
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
                          controller: _companyController,
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
                        previous.isSuccess != current.isSuccess ||
                        previous.errorMessage != current.errorMessage,
                      listener: (context, state) {
                        if (state.isSuccess) {
                          Navigator.of(context).pushReplacementNamed('/dashboard');
                        }
                        if (state.errorMessage != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.errorMessage!)),
                          );
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
      ),
    );
  }

  ImageProvider? _avatarImage(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) return null;
    if (avatarPath.startsWith('http')) {
      return NetworkImage(avatarPath);
    }
    return FileImage(File(avatarPath));
  }

  Future<void> _pickAvatar(BuildContext context) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );

    if (!context.mounted || image == null) return;

    context
        .read<CompleteProfileBloc>()
        .add(CompleteProfileAvatarChanged(image.path));
  }
}