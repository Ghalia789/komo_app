import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/project_model.dart';
import '../blocs/blocs.dart';
import '../widgets/widgets.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardBloc()..add(DashboardLoadProjects()),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // TOP BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: AppColors.textPrimary),
                    onPressed: () {},
                  ),
                  const Expanded(
                    child: Text(
                      'My Projects',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: AppColors.textPrimary),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            
            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Search projects...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // PROJECT LIST
            Expanded(
              child: BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.projects.length,
                    itemBuilder: (context, index) {
                      final project = state.projects[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ProjectCard(
                          project: project,
                          onTap: () {
                            context.read<DashboardBloc>().add(
                              DashboardProjectSelected(project.id),
                            );
                            Navigator.of(context).pushNamed('/kanban', arguments: project);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      
      // BOTTOM NAV with FAB
      bottomNavigationBar: KomoBottomNav(
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation
        },
        onFabPressed: () {
          context.read<DashboardBloc>().add(DashboardCreateProjectPressed());
          Navigator.of(context).pushNamed('/create-project');
        },
      ),
    );
  }
}

// PROJECT CARD - Uses KomoCard widget
class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return KomoCard(
      leftBorderColor: project.getColorValue(),
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Text(
              project.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            // Subtitle
            Text(
              project.description,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            
            // PROGRESS BAR + AVATARS
            Row(
              children: [
                // Progress bar
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: project.progressPercent,
                      backgroundColor: AppColors.background,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        project.getColorValue(),
                      ),
                      minHeight: 4,
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // OVERLAPPING AVATARS using KomoAvatar
                SizedBox(
                  width: 80,
                  height: 28,
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      // Avatar 3 (back)
                      Positioned(
                        right: 0,
                        child: _OverlappingAvatar(
                          color: const Color(0xFF7D627F),
                          borderColor: AppColors.surface,
                        ),
                      ),
                      // Avatar 2 (middle)
                      Positioned(
                        right: 16,
                        child: _OverlappingAvatar(
                          color: const Color(0xFFB85C6E),
                          borderColor: AppColors.surface,
                        ),
                      ),
                      // Avatar 1 (front) - project color
                      Positioned(
                        right: 32,
                        child: _OverlappingAvatar(
                          color: project.getColorValue(),
                          borderColor: AppColors.surface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// OVERLAPPING AVATAR - Simple circle for dashboard
class _OverlappingAvatar extends StatelessWidget {
  final Color color;
  final Color borderColor;

  const _OverlappingAvatar({
    required this.color,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: borderColor, width: 2),
      ),
    );
  }
}