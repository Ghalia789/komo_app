import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/kanban_column_model.dart';
import '../../../data/models/task_model.dart';
import '../../../domain/repositories/task_repository.dart';
import 'kanban_event.dart';
import 'kanban_state.dart';

class KanbanBloc extends Bloc<KanbanEvent, KanbanState> {
  KanbanBloc({required TaskRepository taskRepository})
      : _taskRepository = taskRepository,
        super(const KanbanState()) {
    on<KanbanLoadData>(_onLoadData);
    on<KanbanToggleView>(_onToggleView);
    on<KanbanTaskTapped>(_onTaskTapped);
    on<KanbanInvitePressed>(_onInvitePressed);
  }

  final TaskRepository _taskRepository;

  Future<void> _onLoadData(
    KanbanLoadData event,
    Emitter<KanbanState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: () => null));

    final result = await _taskRepository.getTasks(projectId: event.projectId);
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: () => failure.message,
      )),
      (tasks) {
        final taskModels = tasks.map(TaskModel.fromDomain).toList();
        // Derive column counts from loaded tasks
        final columns = [
          KanbanColumnModel(
            id: 'todo',
            title: 'À faire',
            taskCount: tasks.where((t) => t.columnId == 'todo').length,
          ),
          KanbanColumnModel(
            id: 'in_progress',
            title: 'En cours',
            taskCount: tasks.where((t) => t.columnId == 'in_progress').length,
          ),
          KanbanColumnModel(
            id: 'done',
            title: 'Terminé',
            taskCount: tasks.where((t) => t.columnId == 'done').length,
          ),
        ];
        emit(state.copyWith(
          isLoading: false,
          columns: columns,
          tasks: taskModels,
        ));
      },
    );
  }

  void _onToggleView(
      KanbanToggleView event, Emitter<KanbanState> emit) {
    emit(state.copyWith(isBoardView: event.isBoardView));
  }

  void _onTaskTapped(KanbanTaskTapped event, Emitter<KanbanState> emit) {
    // Navigation handled in UI
  }

  void _onInvitePressed(KanbanInvitePressed event, Emitter<KanbanState> emit) {
    // Show invite dialog in UI
  }
}
