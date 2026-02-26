import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileState()) {
    on<ProfileLoadData>(_onLoadData);
    on<ProfileAvatarChanged>(_onAvatarChanged);
    on<ProfileLogoutPressed>(_onLogoutPressed);
  }

  Future<void> _onLoadData(
    ProfileLoadData event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    // TODO: Load from Firebase/API
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data
    emit(state.copyWith(
      isLoading: false,
      name: 'Sarah Chen',
      email: 'sarah.chen@example.com',
      role: 'Product Designer',
      tasksDone: 12,
      projectsCount: 3,
      onTimePercentage: 85,
      teamMembersCount: 5,
      activeProjectsCount: 3,
    ));
  }

  void _onAvatarChanged(
    ProfileAvatarChanged event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(avatarUrl: event.avatarPath));
  }

  Future<void> _onLogoutPressed(
    ProfileLogoutPressed event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoggingOut: true));

    // TODO: Clear user session, tokens, etc.
    await Future.delayed(const Duration(milliseconds: 300));

    emit(state.copyWith(isLoggingOut: false));
  }
}
