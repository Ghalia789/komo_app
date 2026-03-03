import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'signup_event.dart';
import 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  SignupBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(SignupState()) {
    on<SignupEmailChanged>(_onEmailChanged);
    on<SignupPasswordChanged>(_onPasswordChanged);
    on<SignupConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<SignupTogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<SignupToggleConfirmPasswordVisibility>(_onToggleConfirmPasswordVisibility);
    on<SignupSubmitted>(_onSubmitted);
    on<SignupLoginPressed>(_onLoginPressed);
  }

  final AuthRepository _authRepository;

  void _onEmailChanged(SignupEmailChanged event, Emitter<SignupState> emit) {
    emit(state.copyWith(
      email: event.email,
      emailError: null,  // Clear while typing
    ));
  }

  void _onPasswordChanged(SignupPasswordChanged event, Emitter<SignupState> emit) {
    emit(state.copyWith(
      password: event.password,
      passwordError: null,  // Clear while typing
    ));
  }

  void _onConfirmPasswordChanged(SignupConfirmPasswordChanged event, Emitter<SignupState> emit) {
    emit(state.copyWith(
      confirmPassword: event.confirmPassword,
      confirmPasswordError: null,  // Clear while typing
    ));
  }

  void _onTogglePasswordVisibility(SignupTogglePasswordVisibility event, Emitter<SignupState> emit) {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  void _onToggleConfirmPasswordVisibility(SignupToggleConfirmPasswordVisibility event, Emitter<SignupState> emit) {
    emit(state.copyWith(isConfirmPasswordVisible: !state.isConfirmPasswordVisible));
  }

  Future<void> _onSubmitted(SignupSubmitted event, Emitter<SignupState> emit) async {
    // Validate ALL fields on submit only
    final emailError = Validators.email(state.email);
    final passwordError = Validators.password(state.password);
    final confirmError = Validators.confirmPassword(state.confirmPassword, state.password);

    if (emailError != null || passwordError != null || confirmError != null) {
      emit(state.copyWith(
        emailError: () => emailError,
        passwordError: () => passwordError,
        confirmPasswordError: () => confirmError,
      ));
      return;  // Stop, show errors
    }

    emit(state.copyWith(isLoading: true, errorMessage: () => null));

    try {
      final result = await _authRepository.signUp(
        email: state.email.trim(),
        password: state.password,
      );

      result.fold(
        (failure) {
          final emailFieldError = failure is ValidationFailure
              ? (failure.fieldErrors?['email'])
              : null;
          emit(state.copyWith(
            isLoading: false,
            emailError: emailFieldError != null ? () => emailFieldError : null,
            errorMessage: () => failure.message,
          ));
        },
        (_) {
          emit(state.copyWith(
            isLoading: false,
            isSuccess: true,
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

  void _onLoginPressed(SignupLoginPressed event, Emitter<SignupState> emit) {}
}