import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/project_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({
    required AuthRepository authRepository,
    required ProjectRepository projectRepository,
  })  : _authRepository = authRepository,
        _projectRepository = projectRepository,
        super(const DashboardState()) {
    on<DashboardLoadProjects>(_onLoadProjects);
    on<DashboardProjectSelected>(_onProjectSelected);
    on<DashboardCreateProjectPressed>(_onCreateProjectPressed);
    on<DashboardProfilePressed>(_onProfilePressed);
    on<DashboardNotificationsPressed>(_onNotificationsPressed);
    on<DashboardSettingsPressed>(_onSettingsPressed);
  }

  final AuthRepository _authRepository;
  final ProjectRepository _projectRepository;

  Future<List<String>> _loadMemberAvatarsForProject(String projectId) async {
    final membersResult =
        await _projectRepository.getProjectMembers(projectId: projectId);

    return membersResult.fold(
      (_) => const <String>[],
      (members) => members
          .map((member) => member.avatarUrl)
          .whereType<String>()
          .map((url) => url.trim())
          .where((url) => url.isNotEmpty)
          .toSet()
          .toList(),
    );
  }

  Future<void> _onLoadProjects(
    DashboardLoadProjects event,
    Emitter<DashboardState> emit,
  ) async {
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
        final result =
            await _projectRepository.getProjects(userId: user.id);
        final failure = result.fold((f) => f, (_) => null);
        if (failure != null) {
          emit(state.copyWith(
            isLoading: false,
            errorMessage: () => failure.message,
          ));
          return;
        }

        final projects = result.getOrElse(() => const []);
        final enrichedProjects = await Future.wait(
          projects.map((project) async {
            final avatars =
                await _loadMemberAvatarsForProject(project.id);
            return project.copyWith(memberAvatars: avatars);
          }),
        );

        emit(state.copyWith(
          isLoading: false,
          projects: enrichedProjects,
        ));
      },
    );
  }

  void _onProjectSelected(
      DashboardProjectSelected event, Emitter<DashboardState> emit) {
    // Navigation handled in UI
  }

  void _onCreateProjectPressed(
      DashboardCreateProjectPressed event, Emitter<DashboardState> emit) {
    // Navigation handled in UI
  }

  void _onProfilePressed(
      DashboardProfilePressed event, Emitter<DashboardState> emit) {}
  void _onNotificationsPressed(
      DashboardNotificationsPressed event, Emitter<DashboardState> emit) {}
  void _onSettingsPressed(
      DashboardSettingsPressed event, Emitter<DashboardState> emit) {}
}