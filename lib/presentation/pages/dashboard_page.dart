import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../../injection.dart';
import '../blocs/blocs.dart';
import '../widgets/widgets.dart';

/// Maps a project color string to a [Color] for UI display.
Color _projectColor(String color) {
  switch (color) {
    case 'ocean':
      return const Color(0xFF268060);
    case 'sunset':
      return const Color(0xFFD4A017);
    case 'mono':
      return const Color(0xFF3E0C54);
    default:
      return const Color(0xFF9600BF); // purple
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardBloc(
        authRepository: locator<AuthRepository>(),
        projectRepository: locator<ProjectRepository>(),
      )..add(DashboardLoadProjects()),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<Project> _filterProjects(List<Project> projects) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return projects;

    return projects.where((project) {
      return project.name.toLowerCase().contains(query) ||
          project.description.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _showQuickMenu() async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.of(context).pushNamed('/profile');
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_none),
                title: const Text('Notifications'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.of(context).pushNamed('/notifications');
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.of(context).pushNamed('/settings');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showMoreActions() async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Refresh projects'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.read<DashboardBloc>().add(DashboardLoadProjects());
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('Create project'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.of(context).pushNamed('/create-project');
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text(
                  'Sign out',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final result = await locator<AuthRepository>().signOut();
                  result.fold(
                    (failure) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(failure.message)),
                      );
                    },
                    (_) {
                      if (!mounted) return;
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/login',
                        (route) => false,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

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
                    onPressed: _showQuickMenu,
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
                    onPressed: () => _searchFocusNode.requestFocus(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
                    onPressed: _showMoreActions,
                  ),
                ],
              ),
            ),
            
            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: (value) => setState(() => _searchQuery = value),
                        decoration: const InputDecoration(
                          hintText: 'Search projects...',
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(Icons.close, size: 18),
                        splashRadius: 18,
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

                  final filtered = _filterProjects(state.projects);
                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? 'No projects yet. Tap + to create your first project.'
                            : 'No project matches "$_searchQuery".',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final project = filtered[index];
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
          switch (index) {
            case 0:
              // Already on dashboard
              break;
            case 1:
              Navigator.of(context).pushNamed('/notifications');
              break;
            case 2:
              Navigator.of(context).pushNamed('/profile');
              break;
            case 3:
              Navigator.of(context).pushNamed('/settings');
              break;
          }
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
  final Project project;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _projectColor(project.color);
    return KomoCard(
      leftBorderColor: color,
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 110,
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
              project.summaryDescription,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            
            // PROGRESS BAR + AVATARS
            Row(
              children: [
                // Progress bar
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: project.progress,
                      backgroundColor: AppColors.background,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        color,
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
                          color: _projectColor(project.color),
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