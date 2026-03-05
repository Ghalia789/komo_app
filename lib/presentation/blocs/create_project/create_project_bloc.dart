import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/project_repository.dart';
import 'create_project_event.dart';
import 'create_project_state.dart';

class CreateProjectBloc extends Bloc<CreateProjectEvent, CreateProjectState> {
  CreateProjectBloc({
    required AuthRepository authRepository,
    required ProjectRepository projectRepository,
  })  : _authRepository = authRepository,
        _projectRepository = projectRepository,
        super(const CreateProjectState()) {
    on<CreateProjectNameChanged>(_onNameChanged);
    on<CreateProjectDescriptionChanged>(_onDescriptionChanged);
    on<CreateProjectIconSelected>(_onIconSelected);
    on<CreateProjectPaletteSelected>(_onPaletteSelected);
    on<CreateProjectDueDateChanged>(_onDueDateChanged);
    on<CreateProjectStartDateChanged>(_onStartDateChanged);
    on<CreateProjectSubmitted>(_onSubmitted);
    on<CreateProjectReset>(_onReset);
  }

  final AuthRepository _authRepository;
  final ProjectRepository _projectRepository;

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

    emit(state.copyWith(isLoading: true, errorMessage: () => null));

    final userResult = await _authRepository.getCurrentUser();
    await userResult.fold(
      (failure) async {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: () => failure.message,
        ));
      },
      (user) async {
        final project = Project(
          id: '',
          name: state.name.trim(),
          description: state.description.trim(),
          ownerId: user.id,
          memberIds: [user.id],
          color: state.selectedPalette.colorKey,
          icon: state.selectedIcon,
          dueDate: state.dueDate,
          startDate: state.startDate,
          createdAt: DateTime.now(),
        );

        final result = await _projectRepository.createProject(project: project);
        result.fold(
          (failure) => emit(state.copyWith(
            isLoading: false,
            errorMessage: () => failure.message,
          )),
          (created) => emit(state.copyWith(
            isLoading: false,
            isSuccess: true,
            createdProject: () => created,
          )),
        );
      },
    );
  }

  void _onReset(
    CreateProjectReset event,
    Emitter<CreateProjectState> emit,
  ) {
    emit(const CreateProjectState());
  }
}
