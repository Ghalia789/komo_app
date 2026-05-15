import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/project_repository.dart';
import '../../../domain/repositories/task_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required AuthRepository authRepository,
    required ProjectRepository projectRepository,
    required TaskRepository taskRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _projectRepository = projectRepository,
        _taskRepository = taskRepository,
        _userRepository = userRepository,
        super(const ProfileState()) {
    on<ProfileLoadData>(_onLoadData);
    on<ProfileAvatarChanged>(_onAvatarChanged);
    on<ProfileLogoutPressed>(_onLogoutPressed);
  }

  final AuthRepository _authRepository;
  final ProjectRepository _projectRepository;
  final TaskRepository _taskRepository;
  final UserRepository _userRepository;

  Future<void> _onLoadData(
    ProfileLoadData event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: () => null, logoutSuccess: false));

    final profileResult = await _userRepository.getCurrentUserProfile();

    await profileResult.fold(
      (failure) async => emit(state.copyWith(
        isLoading: false,
        errorMessage: () => failure.message,
      )),
      (user) async {
        final projectsResult = await _projectRepository.getProjects(
          userId: user.id,
        );

        final projects = projectsResult.fold(
          (_) => <Project>[],
          (list) => list,
        );

        var totalTasks = 0;
        var completedTasks = 0;
        final memberIds = <String>{};

        for (final project in projects) {
          final tasksResult = await _taskRepository.getTasks(
            projectId: project.id,
          );
          final tasks = tasksResult.fold((_) => const [], (list) => list);
          totalTasks += tasks.length;
          completedTasks += tasks.where((t) => t.columnId == 'done').length;
          memberIds.addAll(project.memberIds);
          memberIds.add(project.ownerId);
        }

        final onTimePercentage = totalTasks == 0
            ? 0
            : ((completedTasks / totalTasks) * 100).round();

        emit(state.copyWith(
          isLoading: false,
          name: user.name,
          email: user.email,
          role: user.role ?? '',
          jobTitle: user.jobTitle ?? '',
          company: user.company ?? '',
          avatarUrl: () => user.avatarUrl,
          tasksDone: completedTasks,
          projectsCount: projects.length,
          activeProjectsCount: projects.length,
          teamMembersCount: memberIds.length,
          onTimePercentage: onTimePercentage,
        ));
      },
    );
  }

  Future<void> _onAvatarChanged(
    ProfileAvatarChanged event,
    Emitter<ProfileState> emit,
  ) async {
    final imagePath = event.avatarPath;
    if (imagePath == null || imagePath.isEmpty) return;

    final userResult = await _authRepository.getCurrentUser();
    await userResult.fold(
      (failure) async {
        emit(state.copyWith(errorMessage: () => failure.message));
      },
      (user) async {
        final uploadResult = await _userRepository.uploadAvatar(
          userId: user.id,
          imageFile: File(imagePath),
        );

        uploadResult.fold(
          (failure) => emit(state.copyWith(errorMessage: () => failure.message)),
          (url) => emit(state.copyWith(avatarUrl: () => url, errorMessage: () => null)),
        );
      },
    );
  }

  Future<void> _onLogoutPressed(
    ProfileLogoutPressed event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoggingOut: true, errorMessage: () => null, logoutSuccess: false));

    final result = await _authRepository.signOut();

    result.fold(
      (failure) => emit(state.copyWith(
        isLoggingOut: false,
        errorMessage: () => failure.message,
      )),
      (_) => emit(state.copyWith(
        isLoggingOut: false,
        logoutSuccess: true,
      )),
    );
  }
}
