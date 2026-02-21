import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/validators.dart';
import 'signup_event.dart';
import 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  SignupBloc() : super(SignupState()) {
    on<SignupEmailChanged>(_onEmailChanged);
    on<SignupPasswordChanged>(_onPasswordChanged);
    on<SignupConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<SignupTogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<SignupToggleConfirmPasswordVisibility>(_onToggleConfirmPasswordVisibility);
    on<SignupSubmitted>(_onSubmitted);
    on<SignupLoginPressed>(_onLoginPressed);
  }

  void _onEmailChanged(SignupEmailChanged event, Emitter<SignupState> emit) {
    final error = Validators.email(event.email);
    emit(state.copyWith(
      email: event.email,
      emailError: error,
    ));
  }

  void _onPasswordChanged(SignupPasswordChanged event, Emitter<SignupState> emit) {
    final error = Validators.password(event.password);
    
    // Re-validate confirm password if it exists (real-time matching)
    String? confirmError;
    if (state.confirmPassword.isNotEmpty) {
      confirmError = Validators.confirmPassword(state.confirmPassword, event.password);
    }
    
    emit(state.copyWith(
      password: event.password,
      passwordError: error,
      confirmPasswordError: confirmError,
    ));
  }

  void _onConfirmPasswordChanged(SignupConfirmPasswordChanged event, Emitter<SignupState> emit) {
    final error = Validators.confirmPassword(event.confirmPassword, state.password);
    
    emit(state.copyWith(
      confirmPassword: event.confirmPassword,
      confirmPasswordError: error,
    ));
  }

  void _onTogglePasswordVisibility(SignupTogglePasswordVisibility event, Emitter<SignupState> emit) {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  void _onToggleConfirmPasswordVisibility(SignupToggleConfirmPasswordVisibility event, Emitter<SignupState> emit) {
    emit(state.copyWith(isConfirmPasswordVisible: !state.isConfirmPasswordVisible));
  }

  Future<void> _onSubmitted(SignupSubmitted event, Emitter<SignupState> emit) async {
    final emailError = Validators.email(state.email);
    final passwordError = Validators.password(state.password);
    final confirmError = Validators.confirmPassword(state.confirmPassword, state.password);

    if (emailError != null || passwordError != null || confirmError != null) {
      emit(state.copyWith(
        emailError: emailError,
        passwordError: passwordError,
        confirmPasswordError: confirmError,
      ));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));

    // TODO: Call Firebase Auth createUser
    await Future.delayed(const Duration(seconds: 2));

    emit(state.copyWith(isLoading: false, isSuccess: true));
  }

  void _onLoginPressed(SignupLoginPressed event, Emitter<SignupState> emit) {}
}