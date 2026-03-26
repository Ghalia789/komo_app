import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/repositories/project_repository.dart';
import '../../../domain/repositories/task_repository.dart';
import 'create_task_event.dart';
import 'create_task_state.dart';

class CreateTaskBloc extends Bloc<CreateTaskEvent, CreateTaskState> {
  CreateTaskBloc({
    required TaskRepository taskRepository,
    required String projectId,
    String currentUserId = '',
    ProjectRepository? projectRepository,
  })  : _taskRepository = taskRepository,
        _projectId = projectId,
        _currentUserId = currentUserId,
        _projectRepository = projectRepository,
        super(const CreateTaskState()) {
    on<CreateTaskProjectMembersLoaded>(_onProjectMembersLoaded);
    on<CreateTaskTitleChanged>(_onTitleChanged);
    on<CreateTaskDescriptionChanged>(_onDescriptionChanged);
    on<CreateTaskPriorityChanged>(_onPriorityChanged);
    on<CreateTaskTagToggled>(_onTagToggled);
    on<CreateTaskAssigneeToggled>(_onAssigneeToggled);
    on<CreateTaskAddSubtask>(_onAddSubtask);
    on<CreateTaskRemoveSubtask>(_onRemoveSubtask);
    on<CreateTaskDueDateChanged>(_onDueDateChanged);
    on<CreateTaskStartDateChanged>(_onStartDateChanged);
    on<CreateTaskSubmitted>(_onSubmitted);
    on<CreateTaskReset>(_onReset);

    // Auto-load project members if repository provided
    if (_projectRepository != null && _projectId.isNotEmpty) {
      add(CreateTaskProjectMembersLoaded());
    }
  }

  final TaskRepository _taskRepository;
  final ProjectRepository? _projectRepository;
  final String _projectId;
  // ignore: unused_field
  final String _currentUserId;

  Future<void> _onProjectMembersLoaded(
    CreateTaskProjectMembersLoaded event,
    Emitter<CreateTaskState> emit,
  ) async {
    if (_projectRepository == null || _projectId.isEmpty) return;
    final result = await _projectRepository.getProjectMembers(projectId: _projectId);
    result.fold(
      (_) {},
      (members) => emit(state.copyWith(members: members)),
    );
  }

  TaskPriority _parsePriority(String p) {
    switch (p.toLowerCase()) {
      case 'low':
        return TaskPriority.low;
      case 'high':
        return TaskPriority.high;
      case 'urgent':
        return TaskPriority.urgent;
      default:
        return TaskPriority.medium;
    }
  }

  void _onTitleChanged(
    CreateTaskTitleChanged event,
    Emitter<CreateTaskState> emit,
  ) {
    emit(state.copyWith(
      title: event.title,
      errorMessage: () => null,
    ));
  }

  void _onDescriptionChanged(
    CreateTaskDescriptionChanged event,
    Emitter<CreateTaskState> emit,
  ) {
    emit(state.copyWith(description: event.description));
  }

  void _onPriorityChanged(
    CreateTaskPriorityChanged event,
    Emitter<CreateTaskState> emit,
  ) {
    emit(state.copyWith(priority: event.priority));
  }

  void _onTagToggled(
    CreateTaskTagToggled event,
    Emitter<CreateTaskState> emit,
  ) {
    final currentTags = List<String>.from(state.selectedTags);
    if (currentTags.contains(event.tag)) {
      currentTags.remove(event.tag);
    } else {
      currentTags.add(event.tag);
    }
    emit(state.copyWith(selectedTags: currentTags));
  }

  void _onAssigneeToggled(
    CreateTaskAssigneeToggled event,
    Emitter<CreateTaskState> emit,
  ) {
    final currentAssignees = List<String>.from(state.selectedAssigneeIds);
    if (currentAssignees.contains(event.assigneeId)) {
      currentAssignees.remove(event.assigneeId);
    } else {
      currentAssignees.add(event.assigneeId);
    }
    emit(state.copyWith(selectedAssigneeIds: currentAssignees));
  }

  void _onAddSubtask(
    CreateTaskAddSubtask event,
    Emitter<CreateTaskState> emit,
  ) {
    if (event.title.trim().isEmpty) return;
    final subtasks = List<String>.from(state.subtasks)..add(event.title.trim());
    emit(state.copyWith(subtasks: subtasks));
  }

  void _onRemoveSubtask(
    CreateTaskRemoveSubtask event,
    Emitter<CreateTaskState> emit,
  ) {
    final subtasks = List<String>.from(state.subtasks)..removeAt(event.index);
    emit(state.copyWith(subtasks: subtasks));
  }

  void _onDueDateChanged(
    CreateTaskDueDateChanged event,
    Emitter<CreateTaskState> emit,
  ) {
    emit(state.copyWith(dueDate: () => event.dueDate));
  }

  void _onStartDateChanged(
    CreateTaskStartDateChanged event,
    Emitter<CreateTaskState> emit,
  ) {
    emit(state.copyWith(startDate: () => event.startDate));
  }

  Future<void> _onSubmitted(
    CreateTaskSubmitted event,
    Emitter<CreateTaskState> emit,
  ) async {
    if (state.title.trim().isEmpty) {
      emit(state.copyWith(
        errorMessage: () => 'Task title is required',
      ));
      return;
    }

    if (_projectId.isEmpty) {
      emit(state.copyWith(
        errorMessage: () => 'No project selected',
      ));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: () => null));

    final assigneeId = state.selectedAssigneeIds.isNotEmpty
        ? state.selectedAssigneeIds.first
        : null;

    final now = DateTime.now();
    final task = Task(
      id: '',
      projectId: _projectId,
      title: state.title.trim(),
      description:
          state.description.trim().isNotEmpty ? state.description.trim() : null,
      columnId: 'todo',
      tags: state.selectedTags,
      priority: _parsePriority(state.priority),
      dueDate: state.dueDate,
      startDate: state.startDate,
      assigneeId: assigneeId,
      order: DateTime.now().millisecondsSinceEpoch,
      createdAt: now,
    );

    final result = await _taskRepository.createTask(task: task);
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: () => failure.message,
      )),
      (_) => emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
      )),
    );
  }

  void _onReset(
    CreateTaskReset event,
    Emitter<CreateTaskState> emit,
  ) {
    emit(const CreateTaskState());
  }
}
