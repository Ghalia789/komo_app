import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/project_model.dart';
import '../blocs/kanban/kanban_bloc_exports.dart';
import '../widgets/widgets.dart';

class KanbanPage extends StatelessWidget {
  final ProjectModel project;

  const KanbanPage({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => KanbanBloc()..add(KanbanLoadData()),
      child: KanbanView(project: project),
    );
  }
}

class KanbanView extends StatelessWidget {
  final ProjectModel project;

  const KanbanView({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          project.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          // Invite button
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/invite-project');
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Invite',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // List/Board Toggle
          BlocBuilder<KanbanBloc, KanbanState>(
            builder: (context, state) {
              return Container(
                margin: const EdgeInsets.all(16),
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // List button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          context.read<KanbanBloc>().add(KanbanToggleView(false));
                        },
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: !state.isBoardView
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'List',
                            style: TextStyle(
                              color: !state.isBoardView
                                  ? AppColors.primary
                                  : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Board button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          context.read<KanbanBloc>().add(KanbanToggleView(true));
                        },
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: state.isBoardView
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Board',
                            style: TextStyle(
                              color: state.isBoardView
                                  ? AppColors.primary
                                  : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Content
          Expanded(
            child: BlocBuilder<KanbanBloc, KanbanState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.isBoardView) {
                  return _buildBoardView(context, state);
                } else {
                  return _buildListView(context, state);
                }
              },
            ),
          ),
        ],
      ),
      
      // Bottom Nav
      bottomNavigationBar: KomoBottomNav(
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation
        },
        onFabPressed: () {
          // Create new task
          Navigator.of(context).pushNamed('/create-task');
        },
      ),
    );
  }

  // Board view with horizontal scrollable columns
  Widget _buildBoardView(BuildContext context, KanbanState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: state.columns.map((column) {
          final columnTasks = state.getTasksForColumn(column.id);
          
          return Container(
            width: 240,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Column header
                Row(
                  children: [
                    Text(
                      column.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${columnTasks.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Task list
                Expanded(
                  child: ListView.builder(
                    itemCount: columnTasks.length,
                    itemBuilder: (context, index) {
                      return TaskCard(
                        task: columnTasks[index],
                        onTap: () {
                          context.read<KanbanBloc>().add(
                            KanbanTaskTapped(columnTasks[index].id),
                          );
                          Navigator.of(context).pushNamed(
                            '/task-details',
                            arguments: columnTasks[index].id,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // List view (all tasks in one column)
  Widget _buildListView(BuildContext context, KanbanState state) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: state.tasks.length,
      itemBuilder: (context, index) {
        return TaskCard(
          task: state.tasks[index],
          onTap: () {
            context.read<KanbanBloc>().add(
              KanbanTaskTapped(state.tasks[index].id),
            );
            Navigator.of(context).pushNamed(
              '/task-details',
              arguments: state.tasks[index].id,
            );
          },
        );
      },
    );
  }
}
