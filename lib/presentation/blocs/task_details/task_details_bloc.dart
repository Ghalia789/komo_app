import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/comment_model.dart';
import '../../../data/models/subtask_model.dart';
import '../../../data/models/task_model.dart';
import '../../../domain/entities/comment.dart';
import '../../../domain/entities/subtask.dart';
import '../../../domain/entities/user.dart' as domain;
import '../../../domain/repositories/project_repository.dart';
import '../../../domain/repositories/task_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import 'task_details_event.dart';
import 'task_details_state.dart';

class TaskDetailsBloc extends Bloc<TaskDetailsEvent, TaskDetailsState> {
  final TaskRepository _taskRepository;
  final ProjectRepository _projectRepository;
  final UserRepository _userRepository;

  TaskDetailsBloc({
    required TaskRepository taskRepository,
    required ProjectRepository projectRepository,
    required UserRepository userRepository,
  })  : _taskRepository = taskRepository,
        _projectRepository = projectRepository,
        _userRepository = userRepository,
        super(const TaskDetailsState()) {
    on<TaskDetailsLoadData>(_onLoadData);
    on<TaskDetailsSubtaskToggled>(_onSubtaskToggled);
    on<TaskDetailsSubtaskAdded>(_onSubtaskAdded);
    on<TaskDetailsSubtaskRemoved>(_onSubtaskRemoved);
    on<TaskDetailsAssigneeChanged>(_onAssigneeChanged);
    on<TaskDetailsTagToggled>(_onTagToggled);
    on<TaskDetailsCommentAdded>(_onCommentAdded);
    on<TaskDetailsStatusChanged>(_onStatusChanged);
    on<TaskDetailsInvitePressed>(_onInvitePressed);
  }

  Future<void> _onLoadData(
    TaskDetailsLoadData event,
    Emitter<TaskDetailsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: () => null));

    // Load the task first (we need its projectId for members)
    final taskResult = await _taskRepository.getTask(taskId: event.taskId);

    final taskFailure = taskResult.fold((f) => f, (_) => null);
    if (taskFailure != null) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: () => taskFailure.message,
      ));
      return;
    }

    final task = taskResult.getOrElse(() => throw Exception('unreachable'));
    final taskModel = TaskModel.fromDomain(task);

    // Kick off remaining requests in parallel
    final subtasksFuture = _taskRepository.getSubtasks(taskId: event.taskId);
    final commentsFuture = _taskRepository.getComments(taskId: event.taskId);
    final currentUserFuture = _userRepository.getCurrentUserProfile();
    final membersFuture =
        _projectRepository.getProjectMembers(projectId: task.projectId);

    final subtasksResult = await subtasksFuture;
    final commentsResult = await commentsFuture;
    final currentUserResult = await currentUserFuture;
    final membersResult = await membersFuture;

    final subtasks = subtasksResult.fold(
      (_) => <SubtaskModel>[],
      (list) => list.map(SubtaskModel.fromDomain).toList(),
    );
    final comments = commentsResult.fold(
      (_) => <CommentModel>[],
      (list) => list.map(CommentModel.fromDomain).toList(),
    );
    final currentUser = currentUserResult.fold((_) => null, (u) => u);
    final members = membersResult.fold<List<domain.User>>(
      (_) => const [],
      (list) => list,
    );

    emit(state.copyWith(
      isLoading: false,
      task: taskModel,
      subtasks: subtasks,
      comments: comments,
      members: members,
      currentUserId: currentUser?.id ?? '',
      currentUserName: currentUser?.name ?? 'Me',
    ));
  }

  Future<void> _onSubtaskToggled(
    TaskDetailsSubtaskToggled event,
    Emitter<TaskDetailsState> emit,
  ) async {
    if (state.task == null) return;

    // Optimistic update
    final updatedSubtasks = state.subtasks.map((s) {
      return s.id == event.subtaskId
          ? s.copyWith(isCompleted: !s.isCompleted)
          : s;
    }).toList();
    emit(state.copyWith(subtasks: updatedSubtasks));

    // Persist to Firestore
    await _taskRepository.toggleSubtaskCompletion(
      subtaskId: event.subtaskId,
      taskId: state.task!.id,
    );
  }

  Future<void> _onSubtaskAdded(
    TaskDetailsSubtaskAdded event,
    Emitter<TaskDetailsState> emit,
  ) async {
    if (event.title.trim().isEmpty || state.task == null) return;

    final newSubtask = Subtask(
      id: '',
      taskId: state.task!.id,
      title: event.title.trim(),
      isCompleted: false,
      order: state.subtasks.length + 1,
      createdAt: DateTime.now(),
    );

    final result = await _taskRepository.createSubtask(subtask: newSubtask);
    result.fold(
      (_) {}, // silently swallow — UI already shows the field
      (created) {
        emit(state.copyWith(
          subtasks: [...state.subtasks, SubtaskModel.fromDomain(created)],
        ));
      },
    );
  }

  Future<void> _onSubtaskRemoved(
    TaskDetailsSubtaskRemoved event,
    Emitter<TaskDetailsState> emit,
  ) async {
    if (state.task == null) return;

    // Optimistic update
    emit(state.copyWith(
      subtasks: state.subtasks.where((s) => s.id != event.subtaskId).toList(),
    ));

    // Persist to Firestore
    await _taskRepository.deleteSubtask(
      subtaskId: event.subtaskId,
      taskId: state.task!.id,
    );
  }

  Future<void> _onAssigneeChanged(
    TaskDetailsAssigneeChanged event,
    Emitter<TaskDetailsState> emit,
  ) async {
    if (state.task == null) return;

    // Optimistic update
    emit(state.copyWith(
      selectedAssigneeId: () => event.assigneeId,
      selectedAssigneeName: () => event.assigneeName,
    ));

    // Persist to Firestore — update full task with new assignee fields
    final updatedTask = state.task!.toDomain().copyWith(
          assigneeId: () => event.assigneeId,
          assigneeName: () => event.assigneeName,
          updatedAt: () => DateTime.now(),
        );
    await _taskRepository.updateTask(task: updatedTask);
  }

  Future<void> _onTagToggled(
    TaskDetailsTagToggled event,
    Emitter<TaskDetailsState> emit,
  ) async {
    if (state.task == null) return;

    final updatedTags = List<String>.from(state.currentTags);
    if (updatedTags.contains(event.tag)) {
      updatedTags.remove(event.tag);
    } else {
      updatedTags.add(event.tag);
    }

    // Optimistic update
    emit(state.copyWith(selectedTags: () => updatedTags));

    // Persist to Firestore
    final updatedTask = state.task!.toDomain().copyWith(
          tags: updatedTags,
          updatedAt: () => DateTime.now(),
        );
    await _taskRepository.updateTask(task: updatedTask);
  }

  Future<void> _onCommentAdded(
    TaskDetailsCommentAdded event,
    Emitter<TaskDetailsState> emit,
  ) async {
    if (state.task == null) return;

    final comment = Comment(
      id: '',
      taskId: state.task!.id,
      authorId: state.currentUserId,
      authorName:
          state.currentUserName.isNotEmpty ? state.currentUserName : 'Me',
      authorPhotoUrl: null,
      text: event.text,
      createdAt: DateTime.now(),
    );

    final result = await _taskRepository.addComment(comment: comment);
    result.fold(
      (_) {},
      (created) {
        emit(state.copyWith(
          comments: [...state.comments, CommentModel.fromDomain(created)],
        ));
      },
    );
  }

  Future<void> _onStatusChanged(
    TaskDetailsStatusChanged event,
    Emitter<TaskDetailsState> emit,
  ) async {
    if (state.task == null) return;

    // Optimistic update — rebuild the TaskModel with the new columnId
    final updatedTaskModel = TaskModel.fromDomain(
      state.task!.toDomain().copyWith(
            columnId: event.columnId,
            updatedAt: () => DateTime.now(),
          ),
    );
    emit(state.copyWith(task: updatedTaskModel));

    // Persist to Firestore
    await _taskRepository.updateTaskStatus(
      taskId: state.task!.id,
      status: event.columnId,
    );
  }

  void _onInvitePressed(
    TaskDetailsInvitePressed event,
    Emitter<TaskDetailsState> emit,
  ) {
    // Handled by the UI layer (show invite dialog)
  }
}
