import '../../../data/models/comment_model.dart';
import '../../../data/models/subtask_model.dart';
import '../../../data/models/task_model.dart';

class TaskDetailsState {
  final TaskModel? task;
  final List<SubtaskModel> subtasks;
  final List<CommentModel> comments;
  final bool isLoading;
  final String? errorMessage;

  TaskDetailsState({
    this.task,
    this.subtasks = const [],
    this.comments = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  int get completedSubtasks => subtasks.where((s) => s.isCompleted).length;
  int get totalSubtasks => subtasks.length;
  String get progressText => '$completedSubtasks/$totalSubtasks';

  TaskDetailsState copyWith({
    TaskModel? task,
    List<SubtaskModel>? subtasks,
    List<CommentModel>? comments,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TaskDetailsState(
      task: task ?? this.task,
      subtasks: subtasks ?? this.subtasks,
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
