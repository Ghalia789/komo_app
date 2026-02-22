import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/kanban_column_model.dart';
import '../../../data/models/task_model.dart';
import 'kanban_event.dart';
import 'kanban_state.dart';

class KanbanBloc extends Bloc<KanbanEvent, KanbanState> {
  KanbanBloc() : super(KanbanState()) {
    on<KanbanLoadData>(_onLoadData);
    on<KanbanToggleView>(_onToggleView);
    on<KanbanTaskTapped>(_onTaskTapped);
    on<KanbanInvitePressed>(_onInvitePressed);
  }

  Future<void> _onLoadData(KanbanLoadData event, Emitter<KanbanState> emit) async {
    emit(state.copyWith(isLoading: true));
    
    // TODO: Load from Firebase/API
    await Future.delayed(const Duration(milliseconds: 500));
    
    emit(state.copyWith(
      isLoading: false,
      columns: KanbanColumnModel.getMockColumns(),
      tasks: TaskModel.getMockTasks(),
    ));
  }

  void _onToggleView(KanbanToggleView event, Emitter<KanbanState> emit) {
    emit(state.copyWith(isBoardView: event.isBoardView));
  }

  void _onTaskTapped(KanbanTaskTapped event, Emitter<KanbanState> emit) {
    // Navigation handled in UI
  }

  void _onInvitePressed(KanbanInvitePressed event, Emitter<KanbanState> emit) {
    // Show invite dialog in UI
  }
}
