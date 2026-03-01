import 'package:flutter_bloc/flutter_bloc.dart';
import 'create_task_event.dart';
import 'create_task_state.dart';

class CreateTaskBloc extends Bloc<CreateTaskEvent, CreateTaskState> {
  CreateTaskBloc() : super(const CreateTaskState()) {
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

    emit(state.copyWith(isLoading: true));

    // TODO: Save task to backend
    await Future.delayed(const Duration(milliseconds: 600));

    emit(state.copyWith(
      isLoading: false,
      isSuccess: true,
    ));
  }

  void _onReset(
    CreateTaskReset event,
    Emitter<CreateTaskState> emit,
  ) {
    emit(const CreateTaskState());
  }
}
