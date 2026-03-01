import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../blocs/create_task/create_task_bloc.dart';
import '../blocs/create_task/create_task_event.dart';
import '../blocs/create_task/create_task_state.dart';
import '../widgets/widgets.dart';

class CreateTaskPage extends StatelessWidget {
  const CreateTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateTaskBloc(),
      child: const CreateTaskView(),
    );
  }
}

class CreateTaskView extends StatefulWidget {
  const CreateTaskView({super.key});

  @override
  State<CreateTaskView> createState() => _CreateTaskViewState();
}

class _CreateTaskViewState extends State<CreateTaskView> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subtaskController = TextEditingController();
  bool _isAddingSubtask = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subtaskController.dispose();
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
        title: const Text(
          'New Task',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: BlocConsumer<CreateTaskBloc, CreateTaskState>(
        listener: (context, state) {
          if (state.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task created successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.of(context).pop(true); // Return true to indicate success
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
                      // Task Title Field
                      _buildSectionLabel('Task Title'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        onChanged: (value) {
                          context
                              .read<CreateTaskBloc>()
                              .add(CreateTaskTitleChanged(value));
                        },
                        decoration: _inputDecoration(
                          hint: 'What needs to be done?',
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Description Field
                      _buildSectionLabel('Description'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        onChanged: (value) {
                          context
                              .read<CreateTaskBloc>()
                              .add(CreateTaskDescriptionChanged(value));
                        },
                        decoration: _inputDecoration(
                          hint: 'Add more details...',
                        ),
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
                                    .read<CreateTaskBloc>()
                                    .add(CreateTaskDueDateChanged(date));
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
                                    .read<CreateTaskBloc>()
                                    .add(CreateTaskStartDateChanged(date));
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Priority Section - using KomoChipSelector
                      KomoChipSelector<String>(
                        label: '🚩 Priority',
                        options: CreateTaskState.priorities,
                        selected: [state.priority],
                        colorForOption: (p) => state.getPriorityColor(p),
                        labelForOption: (p) => p,
                        onToggle: (priority) {
                          context
                              .read<CreateTaskBloc>()
                              .add(CreateTaskPriorityChanged(priority));
                        },
                      ),

                      const SizedBox(height: 24),

                      // Tags Section - using KomoChipSelector
                      KomoChipSelector<String>(
                        label: '🏷️ Tags',
                        options: CreateTaskState.availableTags,
                        selected: state.selectedTags,
                        colorForOption: (tag) => state.getTagColor(tag),
                        labelForOption: (tag) => tag,
                        onToggle: (tag) {
                          context
                              .read<CreateTaskBloc>()
                              .add(CreateTaskTagToggled(tag));
                        },
                      ),

                      const SizedBox(height: 24),

                      // Assign To Section
                      AssigneeSelector(
                        assignees: Assignee.mockAssignees,
                        selectedIds: state.selectedAssigneeIds,
                        onToggle: (id) {
                          context
                              .read<CreateTaskBloc>()
                              .add(CreateTaskAssigneeToggled(id));
                        },
                      ),

                      const SizedBox(height: 24),

                      // Subtasks Section
                      _buildSectionLabel('Subtasks'),
                      const SizedBox(height: 12),
                      _buildSubtasksList(context, state),
                      _buildInlineSubtaskInput(context),
                    ],
                  ),
                ),

                // Create Task Button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: KomoButton(
                    text: 'Create Task',
                    icon: Icons.check,
                    isLoading: state.isLoading,
                    onPressed: state.isLoading
                        ? null
                        : () {
                            context
                                .read<CreateTaskBloc>()
                                .add(CreateTaskSubmitted());
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

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.surface,
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
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.all(16),
      hintStyle: const TextStyle(
        color: AppColors.textHint,
        fontSize: 14,
      ),
    );
  }

  Widget _buildSubtasksList(BuildContext context, CreateTaskState state) {
    if (state.subtasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: state.subtasks.asMap().entries.map((entry) {
        final index = entry.key;
        final title = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.textHint.withOpacity(0.4),
                    width: 2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.read<CreateTaskBloc>().add(CreateTaskRemoveSubtask(index));
                },
                child: const Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInlineSubtaskInput(BuildContext context) {
    if (!_isAddingSubtask) {
      // Show "+ Add subtask" button
      return GestureDetector(
        onTap: () {
          setState(() {
            _isAddingSubtask = true;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.add,
                size: 20,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Add subtask',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show inline text field with check button
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ),
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
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                hintStyle: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 14,
                ),
              ),
              onSubmitted: (value) => _addSubtask(context),
            ),
          ),
          // Check button
          GestureDetector(
            onTap: () => _addSubtask(context),
            child: Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addSubtask(BuildContext context) {
    if (_subtaskController.text.trim().isNotEmpty) {
      context.read<CreateTaskBloc>().add(CreateTaskAddSubtask(_subtaskController.text));
      _subtaskController.clear();
    }
    setState(() {
      _isAddingSubtask = false;
    });
  }
}
