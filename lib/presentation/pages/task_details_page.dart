import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../blocs/blocs.dart';
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
  bool _isChangingAssignee = false;

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

                      // ASSIGNEE SECTION
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Assigned to',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => setState(() {
                                  _isChangingAssignee = !_isChangingAssignee;
                                }),
                                child: Text(
                                  _isChangingAssignee ? 'Done' : 'Change',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Current assignee display
                          if (!_isChangingAssignee) ...[
                            if (state.currentAssigneeName != null)
                              Row(
                                children: [
                                  KomoAvatar(
                                    name: state.currentAssigneeName!,
                                    size: 36,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    state.currentAssigneeName!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Text(
                                'No assignee',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textHint,
                                ),
                              ),
                          ] else
                            // Assignee selector when changing
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: Assignee.mockAssignees.map((assignee) {
                                final isSelected =
                                    state.currentAssigneeId == assignee.id;
                                return GestureDetector(
                                  onTap: () {
                                    context.read<TaskDetailsBloc>().add(
                                          TaskDetailsAssigneeChanged(
                                            assignee.id,
                                            assignee.name,
                                          ),
                                        );
                                    setState(
                                        () => _isChangingAssignee = false);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? assignee.color.withOpacity(0.15)
                                          : AppColors.surface,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: isSelected
                                            ? assignee.color
                                            : AppColors.textHint
                                                .withOpacity(0.3),
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: assignee.color,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              assignee.initials,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          assignee.name,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? assignee.color
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
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
                      KomoChipSelector<String>(
                        label: '🏷️ Tags',
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
