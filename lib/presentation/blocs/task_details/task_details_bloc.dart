import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/comment_model.dart';
import '../../../data/models/subtask_model.dart';
import '../../../data/models/task_model.dart';
import 'task_details_event.dart';
import 'task_details_state.dart';

class TaskDetailsBloc extends Bloc<TaskDetailsEvent, TaskDetailsState> {
  TaskDetailsBloc() : super(TaskDetailsState()) {
    on<TaskDetailsLoadData>(_onLoadData);
    on<TaskDetailsSubtaskToggled>(_onSubtaskToggled);
    on<TaskDetailsCommentAdded>(_onCommentAdded);
    on<TaskDetailsInvitePressed>(_onInvitePressed);
  }

  Future<void> _onLoadData(
    TaskDetailsLoadData event,
    Emitter<TaskDetailsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    // TODO: Load from Firebase/API
    await Future.delayed(const Duration(milliseconds: 500));

    // Find the task from mock data
    final task = TaskModel.getMockTasks().firstWhere(
      (t) => t.id == event.taskId,
      orElse: () => TaskModel.getMockTasks().first,
    );

    emit(state.copyWith(
      isLoading: false,
      task: task,
      subtasks: SubtaskModel.getMockSubtasks(),
      comments: CommentModel.getMockComments(),
    ));
  }

  void _onSubtaskToggled(
    TaskDetailsSubtaskToggled event,
    Emitter<TaskDetailsState> emit,
  ) {
    final updatedSubtasks = state.subtasks.map((subtask) {
      if (subtask.id == event.subtaskId) {
        return subtask.copyWith(isCompleted: !subtask.isCompleted);
      }
      return subtask;
    }).toList();

    emit(state.copyWith(subtasks: updatedSubtasks));
  }

  void _onCommentAdded(
    TaskDetailsCommentAdded event,
    Emitter<TaskDetailsState> emit,
  ) {
    final newComment = CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorName: 'You', // TODO: Get from current user
      authorPhotoUrl: null,
      text: event.text,
      createdAt: DateTime.now(),
    );

    final updatedComments = [...state.comments, newComment];
    emit(state.copyWith(comments: updatedComments));
  }

  void _onInvitePressed(
    TaskDetailsInvitePressed event,
    Emitter<TaskDetailsState> emit,
  ) {
    // Show invite dialog in UI
  }
}
