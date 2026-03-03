import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository,
        super(const ProfileState()) {
    on<ProfileLoadData>(_onLoadData);
    on<ProfileAvatarChanged>(_onAvatarChanged);
    on<ProfileLogoutPressed>(_onLogoutPressed);
  }

  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  Future<void> _onLoadData(
    ProfileLoadData event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: () => null, logoutSuccess: false));

    final profileResult = await _userRepository.getCurrentUserProfile();

    profileResult.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: () => failure.message,
      )),
      (user) => emit(state.copyWith(
        isLoading: false,
        name: user.name,
        email: user.email,
        role: user.role ?? user.jobTitle ?? '',
        avatarUrl: () => user.avatarUrl,
      )),
    );
  }

  void _onAvatarChanged(
    ProfileAvatarChanged event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(avatarUrl: () => event.avatarPath));
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
