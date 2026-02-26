import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../blocs/create_project/create_project_bloc.dart';
import '../blocs/create_project/create_project_event.dart';
import '../blocs/create_project/create_project_state.dart';
import '../widgets/widgets.dart';

/// Step 2: Pick a color palette for the project
class StyleProjectPage extends StatelessWidget {
  const StyleProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the bloc passed from the previous page
    final bloc = ModalRoute.of(context)!.settings.arguments as CreateProjectBloc;

    return BlocProvider.value(
      value: bloc,
      child: const StyleProjectView(),
    );
  }
}

class StyleProjectView extends StatelessWidget {
  const StyleProjectView({super.key});

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
                    'Style It',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Pick a vibe',
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
                _buildStepDot(isActive: false),
                const SizedBox(width: 6),
                _buildStepDot(isActive: true),
              ],
            ),
          ),
        ],
      ),
      body: BlocConsumer<CreateProjectBloc, CreateProjectState>(
        listener: (context, state) {
          if (state.isSuccess) {
            // Show success and navigate to dashboard or project
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Project created successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
            // Pop back to dashboard (pop twice to get past both create pages)
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Instructions
                      const Text(
                        'Choose a color palette for your project boards and cards.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Palette Cards
                      ...ColorPalette.palettes.map((palette) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ColorPaletteCard(
                            palette: palette,
                            projectIcon: state.selectedIcon,
                            isSelected: state.selectedPaletteId == palette.id,
                            onTap: () {
                              context
                                  .read<CreateProjectBloc>()
                                  .add(CreateProjectPaletteSelected(palette.id));
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // Create Project Button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: KomoButton(
                    text: 'Create Project',
                    icon: Icons.check,
                    isLoading: state.isLoading,
                    onPressed: state.isLoading
                        ? null
                        : () {
                            context
                                .read<CreateProjectBloc>()
                                .add(CreateProjectSubmitted());
                          },
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
