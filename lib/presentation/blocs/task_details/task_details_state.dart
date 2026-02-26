import '../../../data/models/comment_model.dart';
import '../../../data/models/subtask_model.dart';
import '../../../data/models/task_model.dart';

class TaskDetailsState {
  final TaskModel? task;
  final List<SubtaskModel> subtasks;
  final List<CommentModel> comments;
  final String? selectedAssigneeId;
  final String? selectedAssigneeName;
  final List<String>? selectedTags;
  final bool isLoading;
  final String? errorMessage;

  TaskDetailsState({
    this.task,
    this.subtasks = const [],
    this.comments = const [],
    this.selectedAssigneeId,
    this.selectedAssigneeName,
    this.selectedTags,
    this.isLoading = false,
    this.errorMessage,
  });

  // Effective assignee (selected or from task)
  String? get currentAssigneeId => selectedAssigneeId ?? task?.assigneeId;
  String? get currentAssigneeName => selectedAssigneeName ?? task?.assigneeName;

  // Effective tags (selected or from task)
  List<String> get currentTags => selectedTags ?? task?.tags ?? [];

  int get completedSubtasks => subtasks.where((s) => s.isCompleted).length;
  int get totalSubtasks => subtasks.length;
  String get progressText => '$completedSubtasks/$totalSubtasks';

  TaskDetailsState copyWith({
    TaskModel? task,
    List<SubtaskModel>? subtasks,
    List<CommentModel>? comments,
    String? selectedAssigneeId,
    String? selectedAssigneeName,
    List<String>? selectedTags,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TaskDetailsState(
      task: task ?? this.task,
      subtasks: subtasks ?? this.subtasks,
      comments: comments ?? this.comments,
      selectedAssigneeId: selectedAssigneeId ?? this.selectedAssigneeId,
      selectedAssigneeName: selectedAssigneeName ?? this.selectedAssigneeName,
      selectedTags: selectedTags ?? this.selectedTags,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
