import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/validators.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
    on<LoginSignUpPressed>(_onSignUpPressed);
    on<LoginForgotPasswordPressed>(_onForgotPasswordPressed);
  }

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    // Just save value, clear error while typing
    emit(state.copyWith(
      email: event.email,
      emailError: null,
    ));
  }

  void _onPasswordChanged(LoginPasswordChanged event, Emitter<LoginState> emit) {
    // Just save value, clear error while typing
    emit(state.copyWith(
      password: event.password,
      passwordError: null,
    ));
  }

  Future<void> _onSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    // Validate ONLY when submitting
    final emailError = Validators.email(state.email);
    final passwordError = Validators.password(state.password);

    // Show errors if any
    if (emailError != null || passwordError != null) {
      emit(state.copyWith(
        emailError: emailError,
        passwordError: passwordError,
      ));
      return;  // Stop, don't login
    }

    // Valid, proceed with login
    emit(state.copyWith(isLoading: true, errorMessage: null));
    
    // TODO: Call Firebase
    await Future.delayed(const Duration(seconds: 2));
    
    emit(state.copyWith(isLoading: false, isSuccess: true));
  }

  void _onSignUpPressed(LoginSignUpPressed event, Emitter<LoginState> emit) {}

  void _onForgotPasswordPressed(LoginForgotPasswordPressed event, Emitter<LoginState> emit) {}
}