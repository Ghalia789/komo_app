import 'package:flutter_bloc/flutter_bloc.dart';
import 'create_project_event.dart';
import 'create_project_state.dart';

class CreateProjectBloc extends Bloc<CreateProjectEvent, CreateProjectState> {
  CreateProjectBloc() : super(const CreateProjectState()) {
    on<CreateProjectNameChanged>(_onNameChanged);
    on<CreateProjectDescriptionChanged>(_onDescriptionChanged);
    on<CreateProjectIconSelected>(_onIconSelected);
    on<CreateProjectPaletteSelected>(_onPaletteSelected);
    on<CreateProjectDueDateChanged>(_onDueDateChanged);
    on<CreateProjectStartDateChanged>(_onStartDateChanged);
    on<CreateProjectSubmitted>(_onSubmitted);
    on<CreateProjectReset>(_onReset);
  }

  void _onNameChanged(
    CreateProjectNameChanged event,
    Emitter<CreateProjectState> emit,
  ) {
    emit(state.copyWith(
      name: event.name,
      errorMessage: () => null,
    ));
  }

  void _onDescriptionChanged(
    CreateProjectDescriptionChanged event,
    Emitter<CreateProjectState> emit,
  ) {
    emit(state.copyWith(
      description: event.description,
      errorMessage: () => null,
    ));
  }

  void _onIconSelected(
    CreateProjectIconSelected event,
    Emitter<CreateProjectState> emit,
  ) {
    emit(state.copyWith(selectedIcon: event.icon));
  }

  void _onPaletteSelected(
    CreateProjectPaletteSelected event,
    Emitter<CreateProjectState> emit,
  ) {
    emit(state.copyWith(selectedPaletteId: event.paletteId));
  }

  void _onDueDateChanged(
    CreateProjectDueDateChanged event,
    Emitter<CreateProjectState> emit,
  ) {
    emit(state.copyWith(dueDate: () => event.dueDate));
  }

  void _onStartDateChanged(
    CreateProjectStartDateChanged event,
    Emitter<CreateProjectState> emit,
  ) {
    emit(state.copyWith(startDate: () => event.startDate));
  }

  Future<void> _onSubmitted(
    CreateProjectSubmitted event,
    Emitter<CreateProjectState> emit,
  ) async {
    if (state.name.trim().isEmpty) {
      emit(state.copyWith(
        errorMessage: () => 'Project name is required',
      ));
      return;
    }

    emit(state.copyWith(isLoading: true));

    // TODO: Save project to backend
    await Future.delayed(const Duration(milliseconds: 800));

    emit(state.copyWith(
      isLoading: false,
      isSuccess: true,
    ));
  }

  void _onReset(
    CreateProjectReset event,
    Emitter<CreateProjectState> emit,
  ) {
    emit(const CreateProjectState());
  }
}
