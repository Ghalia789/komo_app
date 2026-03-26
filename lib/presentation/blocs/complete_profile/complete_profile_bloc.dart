import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import 'complete_profile_event.dart';
import 'complete_profile_state.dart';

class CompleteProfileBloc extends Bloc<CompleteProfileEvent, CompleteProfileState> {
  CompleteProfileBloc({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository,
        super(CompleteProfileState()) {
    on<CompleteProfilePrefilled>(_onPrefilled);
    on<CompleteProfileNameChanged>(_onNameChanged);
    on<CompleteProfileJobTitleChanged>(_onJobTitleChanged);
    on<CompleteProfileCompanyChanged>(_onCompanyChanged);
    on<CompleteProfileRoleChanged>(_onRoleChanged);
    on<CompleteProfileAvatarChanged>(_onAvatarChanged);
    on<CompleteProfileSubmitted>(_onSubmitted);
  }

  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  void _onPrefilled(CompleteProfilePrefilled event, Emitter<CompleteProfileState> emit) {
    emit(state.copyWith(
      name: event.name ?? state.name,
      jobTitle: event.jobTitle ?? state.jobTitle,
      company: event.company ?? state.company,
      role: event.role ?? state.role,
      avatarPath: () => event.avatarUrl ?? state.avatarPath,
      nameError: () => null,
      errorMessage: () => null,
    ));
  }

  void _onNameChanged(CompleteProfileNameChanged event, Emitter<CompleteProfileState> emit) {
    //final error = Validators.required(event.name, fieldName: 'Full Name');
    emit(state.copyWith(
      name: event.name,
      nameError: null,
    ));
  }

  void _onJobTitleChanged(CompleteProfileJobTitleChanged event, Emitter<CompleteProfileState> emit) {
    emit(state.copyWith(jobTitle: event.jobTitle));
  }

  void _onCompanyChanged(CompleteProfileCompanyChanged event, Emitter<CompleteProfileState> emit) {
    emit(state.copyWith(company: event.company));
  }

  void _onRoleChanged(CompleteProfileRoleChanged event, Emitter<CompleteProfileState> emit) {
    emit(state.copyWith(role: event.role));
  }

  void _onAvatarChanged(CompleteProfileAvatarChanged event, Emitter<CompleteProfileState> emit) {
    emit(state.copyWith(avatarPath: () => event.imagePath));
  }

  Future<void> _onSubmitted(CompleteProfileSubmitted event, Emitter<CompleteProfileState> emit) async {
    final nameError = Validators.required(state.name, fieldName: 'Full Name');
    
    if (nameError != null) {
      emit(state.copyWith(nameError: () => nameError, errorMessage: () => null));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: () => null));

    final currentUserResult = await _authRepository.getCurrentUser();
    String? userId;

    currentUserResult.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: () => failure.message,
        ));
      },
      (user) => userId = user.id,
    );

    if (userId == null) return;

    String? avatarUrl = state.avatarPath;
    if (avatarUrl != null && avatarUrl.isNotEmpty && !avatarUrl.startsWith('http')) {
      final uploadResult = await _userRepository.uploadAvatar(
        userId: userId!,
        imageFile: File(avatarUrl),
      );

      final uploaded = uploadResult.fold<String?>(
        (failure) {
          emit(state.copyWith(
            isLoading: false,
            errorMessage: () => failure.message,
          ));
          return null;
        },
        (url) => url,
      );

      if (uploaded == null) return;
      avatarUrl = uploaded;
    }

    final updateResult = await _userRepository.updateProfileFields(
      userId: userId!,
      name: state.name.trim(),
      jobTitle: state.jobTitle.trim().isNotEmpty ? state.jobTitle.trim() : null,
      company: state.company.trim().isNotEmpty ? state.company.trim() : null,
      role: state.role.trim().isNotEmpty ? state.role.trim() : null,
      avatarUrl: avatarUrl,
    );

    updateResult.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: () => failure.message,
      )),
      (_) => emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
      )),
    );
  }
}