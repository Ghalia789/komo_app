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
    on<TaskDetailsSubtaskAdded>(_onSubtaskAdded);
    on<TaskDetailsSubtaskRemoved>(_onSubtaskRemoved);
    on<TaskDetailsAssigneeChanged>(_onAssigneeChanged);
    on<TaskDetailsTagToggled>(_onTagToggled);
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

  void _onSubtaskAdded(
    TaskDetailsSubtaskAdded event,
    Emitter<TaskDetailsState> emit,
  ) {
    if (event.title.trim().isEmpty) return;
    
    final newSubtask = SubtaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      taskId: state.task?.id ?? '',
      title: event.title.trim(),
      isCompleted: false,
      order: state.subtasks.length + 1,
      createdAt: DateTime.now(),
    );
    
    final updatedSubtasks = [...state.subtasks, newSubtask];
    emit(state.copyWith(subtasks: updatedSubtasks));
  }

  void _onSubtaskRemoved(
    TaskDetailsSubtaskRemoved event,
    Emitter<TaskDetailsState> emit,
  ) {
    final updatedSubtasks = state.subtasks
        .where((s) => s.id != event.subtaskId)
        .toList();
    emit(state.copyWith(subtasks: updatedSubtasks));
  }

  void _onAssigneeChanged(
    TaskDetailsAssigneeChanged event,
    Emitter<TaskDetailsState> emit,
  ) {
    if (state.task == null) return;
    // In a real app, this would update the backend
    // For now we just update local state
    emit(state.copyWith(
      selectedAssigneeId: () => event.assigneeId,
      selectedAssigneeName: () => event.assigneeName,
    ));
  }

  void _onTagToggled(
    TaskDetailsTagToggled event,
    Emitter<TaskDetailsState> emit,
  ) {
    final currentTags = List<String>.from(state.currentTags);
    if (currentTags.contains(event.tag)) {
      currentTags.remove(event.tag);
    } else {
      currentTags.add(event.tag);
    }
    emit(state.copyWith(selectedTags: () => currentTags));
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
