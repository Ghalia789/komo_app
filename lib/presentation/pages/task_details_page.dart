import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../blocs/task_details/task_details_bloc_exports.dart';
import '../blocs/create_task/create_task_state.dart';
import '../widgets/widgets.dart';

class TaskDetailsPage extends StatelessWidget {
  final String taskId;

  const TaskDetailsPage({
    super.key,
    required this.taskId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TaskDetailsBloc()..add(TaskDetailsLoadData(taskId)),
      child: const TaskDetailsView(),
    );
  }
}

class TaskDetailsView extends StatefulWidget {
  const TaskDetailsView({super.key});

  @override
  State<TaskDetailsView> createState() => _TaskDetailsViewState();
}

class _TaskDetailsViewState extends State<TaskDetailsView> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _subtaskController = TextEditingController();
  bool _isAddingSubtask = false;

  @override
  void dispose() {
    _commentController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  void _addSubtask(BuildContext context) {
    if (_subtaskController.text.trim().isEmpty) return;
    context.read<TaskDetailsBloc>().add(
          TaskDetailsSubtaskAdded(_subtaskController.text),
        );
    _subtaskController.clear();
    setState(() => _isAddingSubtask = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Task Details'),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: BlocBuilder<TaskDetailsBloc, TaskDetailsState>(
        builder: (context, state) {
          if (state.isLoading && state.task == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return Center(
              child: Text(
                state.errorMessage!,
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }

          if (state.task == null) {
            return const Center(
              child: Text('Task not found'),
            );
          }

          final task = state.task!;

          return Column(
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TASK TITLE
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // DESCRIPTION
                      if (task.description != null &&
                          task.description!.isNotEmpty) ...[
                        Text(
                          task.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ASSIGNEE SELECTOR
                      AssigneeSelector(
                        assignees: Assignee.mockAssignees,
                        selectedIds: state.currentAssigneeId != null
                            ? [state.currentAssigneeId!]
                            : [],
                        onToggle: (id) {
                          final assignee = Assignee.mockAssignees
                              .firstWhere((a) => a.id == id);
                          context.read<TaskDetailsBloc>().add(
                                TaskDetailsAssigneeChanged(
                                  id,
                                  assignee.name,
                                ),
                              );
                        },
                      ),
                      const SizedBox(height: 20),

                      // STATUS
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  _getStatusColor(task.columnId).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getStatusColor(task.columnId),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _getStatusLabel(task.columnId),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(task.columnId),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // TAGS with KomoChipSelector
                      if (task.tags.isNotEmpty)
                        KomoChipSelector<String>(
                          label: 'Tags',
                          options: CreateTaskState.availableTags,
                          selected: task.tags,
                          colorForOption: (tag) =>
                              const CreateTaskState().getTagColor(tag),
                          labelForOption: (tag) => tag,
                          onToggle: (_) {
                            // Read-only in details view
                          },
                        ),
                      const SizedBox(height: 24),

                      // SUBTASKS SECTION
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subtasks',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (state.subtasks.isNotEmpty)
                            Text(
                              state.progressText,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Subtasks list
                      if (state.subtasks.isNotEmpty)
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
                            children: state.subtasks
                                .map(
                                  (subtask) => SubtaskItem(
                                    subtask: subtask,
                                    onChanged: (_) {
                                      context.read<TaskDetailsBloc>().add(
                                            TaskDetailsSubtaskToggled(
                                                subtask.id),
                                          );
                                    },
                                    onDelete: () {
                                      context.read<TaskDetailsBloc>().add(
                                            TaskDetailsSubtaskRemoved(
                                                subtask.id),
                                          );
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                        ),

                      // Inline Add Subtask
                      const SizedBox(height: 12),
                      if (_isAddingSubtask)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _subtaskController,
                                  autofocus: true,
                                  decoration: const InputDecoration(
                                    hintText: 'Subtask title...',
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onSubmitted: (_) => _addSubtask(context),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _addSubtask(context),
                                icon: const Icon(Icons.check,
                                    color: AppColors.primary),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() => _isAddingSubtask = false);
                                  _subtaskController.clear();
                                },
                                icon: const Icon(Icons.close,
                                    color: AppColors.textHint),
                              ),
                            ],
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: () => setState(() => _isAddingSubtask = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.add,
                                    color: AppColors.primary, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Add subtask',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // COMMENTS SECTION
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Comments',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${state.comments.length}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // COMMENTS LIST
                      if (state.comments.isNotEmpty)
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
                            children: state.comments
                                .map(
                                  (comment) => CommentItem(
                                    comment: comment,
                                  ),
                                )
                                .toList(),
                          ),
                        ),

                      const SizedBox(height: 80), // Space for sticky input
                    ],
                  ),
                ),
              ),

              // STICKY COMMENT INPUT AT BOTTOM
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 48,
                        width: 48,
                        child: ElevatedButton(
                          onPressed: _commentController.text.isEmpty
                              ? null
                              : () {
                                  context.read<TaskDetailsBloc>().add(
                                        TaskDetailsCommentAdded(
                                          _commentController.text,
                                        ),
                                      );
                                  _commentController.clear();
                                  setState(() {});
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Icon(Icons.send, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getStatusColor(String columnId) {
    switch (columnId.toLowerCase()) {
      case 'done':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      case 'todo':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusLabel(String columnId) {
    switch (columnId.toLowerCase()) {
      case 'done':
        return 'Done';
      case 'in_progress':
        return 'In Progress';
      case 'todo':
        return 'To Do';
      default:
        return columnId;
    }
  }
}
