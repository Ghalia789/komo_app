import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/validators.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'reset_password_event.dart';
import 'reset_password_state.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  ResetPasswordBloc({
    required AuthRepository authRepository,
    required String email,
  })
      : _authRepository = authRepository,
        super(ResetPasswordState(email: email)) {
    on<ResetPasswordCodeChanged>(_onCodeChanged);
    on<ResetPasswordChanged>(_onPasswordChanged);
    on<ResetPasswordConfirmChanged>(_onConfirmChanged);
    on<ResetPasswordToggleVisibility>(_onToggleVisibility);
    on<ResetPasswordToggleConfirmVisibility>(_onToggleConfirmVisibility);
    on<ResetPasswordSubmitted>(_onSubmitted);
  }

  final AuthRepository _authRepository;

  void _onCodeChanged(ResetPasswordCodeChanged event, Emitter<ResetPasswordState> emit) {
    emit(state.copyWith(
      code: event.code,
      codeError: () => null,
      errorMessage: () => null,
    ));
  }

  void _onPasswordChanged(ResetPasswordChanged event, Emitter<ResetPasswordState> emit) {
    emit(state.copyWith(
      password: event.password,
      passwordError: () => null,
      errorMessage: () => null,
    ));
  }

  void _onConfirmChanged(ResetPasswordConfirmChanged event, Emitter<ResetPasswordState> emit) {
    emit(state.copyWith(
      confirmPassword: event.confirmPassword,
      confirmPasswordError: () => null,
      errorMessage: () => null,
    ));
  }

  void _onToggleVisibility(ResetPasswordToggleVisibility event, Emitter<ResetPasswordState> emit) {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  void _onToggleConfirmVisibility(ResetPasswordToggleConfirmVisibility event, Emitter<ResetPasswordState> emit) {
    emit(state.copyWith(isConfirmPasswordVisible: !state.isConfirmPasswordVisible));
  }

  Future<void> _onSubmitted(ResetPasswordSubmitted event, Emitter<ResetPasswordState> emit) async {
    if (state.email.isEmpty) {
      emit(state.copyWith(errorMessage: () => 'Email is missing. Please request a new code.'));
      return;
    }

    final codeError = state.code.isEmpty ? 'Reset code is required' : null;
    final passwordError = Validators.password(state.password);
    final confirmError = Validators.confirmPassword(state.confirmPassword, state.password);

    if (codeError != null || passwordError != null || confirmError != null) {
      emit(state.copyWith(
        codeError: () => codeError,
        passwordError: () => passwordError,
        confirmPasswordError: () => confirmError,
      ));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: () => null, infoMessage: () => null));

    try {
      final result = await _authRepository.confirmPasswordResetCode(
        email: state.email.trim(),
        code: state.code.trim(),
        newPassword: state.password,
      );

      result.fold(
        (failure) {
          emit(state.copyWith(
            isLoading: false,
            errorMessage: () => failure.message,
          ));
        },
        (_) {
          emit(state.copyWith(
            isLoading: false,
            isSuccess: true,
            infoMessage: () => 'Password reset successfully. Please log in with your new password.',
          ));
        },
      );
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: () => 'Something went wrong. Please try again.',
      ));
    }
  }
}
