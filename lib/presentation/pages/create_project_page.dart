import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../../injection.dart';
import '../blocs/blocs.dart';
import '../widgets/widgets.dart';

/// Step 1: Enter project name, description, and select an icon
class CreateProjectPage extends StatelessWidget {
  const CreateProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateProjectBloc(
        authRepository: locator<AuthRepository>(),
        projectRepository: locator<ProjectRepository>(),
      ),
      child: const CreateProjectView(),
    );
  }
}

class CreateProjectView extends StatefulWidget {
  const CreateProjectView({super.key});

  @override
  State<CreateProjectView> createState() => _CreateProjectViewState();
}

class _CreateProjectViewState extends State<CreateProjectView> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Project',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'What are you building?',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Step Indicator Dots
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                _buildStepDot(isActive: true),
                const SizedBox(width: 6),
                _buildStepDot(isActive: false),
              ],
            ),
          ),
        ],
      ),
      body: BlocBuilder<CreateProjectBloc, CreateProjectState>(
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Preview Card
                      ProjectPreviewCard(
                        icon: state.selectedIcon,
                        name: state.name,
                        description: state.description,
                        paletteColors: state.selectedPalette.colors,
                      ),

                      const SizedBox(height: 32),

                      // Project Name Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Project Name',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            maxLength: 40,
                            onChanged: (value) {
                              context
                                  .read<CreateProjectBloc>()
                                  .add(CreateProjectNameChanged(value));
                            },
                            decoration: InputDecoration(
                              hintText: 'e.g. Sprint Launch 🚀',
                              filled: true,
                              fillColor: AppColors.surface,
                              counterText: '${state.name.length}/40',
                              counterStyle: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textHint,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              hintStyle: const TextStyle(
                                color: AppColors.textHint,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Description Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _descriptionController,
                            maxLength: 120,
                            maxLines: 3,
                            onChanged: (value) {
                              context
                                  .read<CreateProjectBloc>()
                                  .add(CreateProjectDescriptionChanged(value));
                            },
                            decoration: InputDecoration(
                              hintText: 'What\'s this project about?',
                              filled: true,
                              fillColor: AppColors.surface,
                              counterText: '${state.description.length}/120',
                              counterStyle: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textHint,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                              hintStyle: const TextStyle(
                                color: AppColors.textHint,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Due Date & Start Date Section
                      Row(
                        children: [
                          Expanded(
                            child: KomoDatePicker(
                              label: '📅 Due Date',
                              selectedDate: state.dueDate,
                              onDateSelected: (date) {
                                context
                                    .read<CreateProjectBloc>()
                                    .add(CreateProjectDueDateChanged(date));
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: KomoDatePicker(
                              label: '🏁 Start Date',
                              selectedDate: state.startDate,
                              onDateSelected: (date) {
                                context
                                    .read<CreateProjectBloc>()
                                    .add(CreateProjectStartDateChanged(date));
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Icon Picker
                      IconPicker(
                        icons: CreateProjectState.availableIcons,
                        selectedIcon: state.selectedIcon,
                        onIconSelected: (icon) {
                          context
                              .read<CreateProjectBloc>()
                              .add(CreateProjectIconSelected(icon));
                        },
                      ),
                    ],
                  ),
                ),

                // Continue Button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: KomoButton(
                    text: 'Continue',
                    icon: Icons.auto_awesome,
                    onPressed: state.isStep1Valid
                        ? () {
                            // Navigate to Style It page, passing the bloc
                            Navigator.of(context).pushNamed(
                              '/style-project',
                              arguments: context.read<CreateProjectBloc>(),
                            );
                          }
                        : null,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepDot({required bool isActive}) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.primary : AppColors.primary.withOpacity(0.3),
      ),
    );
  }
}
