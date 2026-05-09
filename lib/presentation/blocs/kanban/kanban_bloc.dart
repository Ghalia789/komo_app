import 'dart:async';

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
    on<KanbanStreamUpdated>(_onStreamUpdated);
    on<KanbanStreamFailed>(_onStreamFailed);
    on<KanbanToggleView>(_onToggleView);
    on<KanbanTaskTapped>(_onTaskTapped);
    on<KanbanInvitePressed>(_onInvitePressed);
  }

  final TaskRepository _taskRepository;
  StreamSubscription? _tasksSub;

  Future<void> _onLoadData(
    KanbanLoadData event,
    Emitter<KanbanState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: () => null));

    await _tasksSub?.cancel();
    _tasksSub = _taskRepository.watchTasks(projectId: event.projectId).listen(
      (result) {
        result.fold(
          (failure) => add(KanbanStreamFailed(failure.message)),
          (tasks) => add(KanbanStreamUpdated(tasks)),
        );
      },
      onError: (error) {
        add(KanbanStreamFailed(error.toString()));
      },
    );
  }

  void _onStreamUpdated(
    KanbanStreamUpdated event,
    Emitter<KanbanState> emit,
  ) {
    final taskModels = event.tasks.map(TaskModel.fromDomain).toList();
    final columns = [
      KanbanColumnModel(
        id: 'todo',
        title: 'À faire',
        taskCount: event.tasks.where((t) => t.columnId == 'todo').length,
      ),
      KanbanColumnModel(
        id: 'in_progress',
        title: 'En cours',
        taskCount: event.tasks.where((t) => t.columnId == 'in_progress').length,
      ),
      KanbanColumnModel(
        id: 'done',
        title: 'Terminé',
        taskCount: event.tasks.where((t) => t.columnId == 'done').length,
      ),
    ];

    emit(state.copyWith(
      isLoading: false,
      columns: columns,
      tasks: taskModels,
      errorMessage: () => null,
    ));
  }

  void _onStreamFailed(
    KanbanStreamFailed event,
    Emitter<KanbanState> emit,
  ) {
    emit(state.copyWith(
      isLoading: false,
      errorMessage: () => event.message,
    ));
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

  @override
  Future<void> close() async {
    await _tasksSub?.cancel();
    return super.close();
  }
}
