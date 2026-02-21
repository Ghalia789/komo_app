import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/validators.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  // Constructor: set initial state
  LoginBloc() : super(LoginState()) {
    // Register all event handlers
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
    on<LoginSignUpPressed>(_onSignUpPressed);
    on<LoginForgotPasswordPressed>(_onForgotPasswordPressed);
  }

  // EVENT: User typed email
  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    // Validate email immediately
    final error = Validators.email(event.email);
    
    emit(state.copyWith(
      email: event.email,
      emailError: error,
    ));
  }

  // EVENT: User typed password
  void _onPasswordChanged(LoginPasswordChanged event, Emitter<LoginState> emit) {
    // Validate password immediately
    final error = Validators.password(event.password);
    
    emit(state.copyWith(
      password: event.password,
      passwordError: error,
    ));
  }

  // EVENT: User tapped "Log In"
  Future<void> _onSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    // Validate both fields
    final emailError = Validators.email(state.email);
    final passwordError = Validators.password(state.password);

    // If any error, show them and stop
    if (emailError != null || passwordError != null) {
      emit(state.copyWith(
        emailError: emailError,
        passwordError: passwordError,
      ));
      return;
    }

    // Show loading
    emit(state.copyWith(isLoading: true, errorMessage: null));

    // TODO: Call Firebase Auth here
    // Example:
    // try {
    //   await FirebaseAuth.instance.signInWithEmailAndPassword(
    //     email: state.email,
    //     password: state.password,
    //   );
    //   emit(state.copyWith(isLoading: false, isSuccess: true));
    // } catch (e) {
    //   emit(state.copyWith(
    //     isLoading: false,
    //     errorMessage: 'Invalid email or password',
    //   ));
    // }

    // Simulate network delay for now
    await Future.delayed(const Duration(seconds: 2));

    // Success
    emit(state.copyWith(isLoading: false, isSuccess: true));
  }

  // EVENT: User tapped "Sign up"
  void _onSignUpPressed(LoginSignUpPressed event, Emitter<LoginState> emit) {
    // Navigation handled in UI, nothing to do here
  }

  // EVENT: User tapped "Forgot password"
  void _onForgotPasswordPressed(LoginForgotPasswordPressed event, Emitter<LoginState> emit) {
    // Navigation handled in UI
  }
}