import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(LoginState()) {
    on<LoginInitializeRequested>(_onInitializeRequested);
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginRememberMeToggled>(_onRememberMeToggled);
    on<LoginSubmitted>(_onSubmitted);
    on<LoginSignUpPressed>(_onSignUpPressed);
    on<LoginForgotPasswordPressed>(_onForgotPasswordPressed);
    on<LoginForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
    on<LoginResendVerificationPressed>(_onResendVerificationPressed);
  }

  final AuthRepository _authRepository;

  Future<void> _onInitializeRequested(
    LoginInitializeRequested event,
    Emitter<LoginState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(StorageKeys.rememberMe) ?? true;
    final rememberedEmail = rememberMe
        ? (prefs.getString(StorageKeys.rememberedEmail) ?? '')
        : '';

    emit(state.copyWith(
      email: rememberedEmail,
      rememberMe: rememberMe,
      emailError: () => null,
      errorMessage: () => null,
      infoMessage: () => null,
    ));
  }

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      email: event.email,
      emailError: () => null,
      requiresEmailVerification: false,
      errorMessage: () => null,
      infoMessage: () => null,
    ));
  }

  void _onPasswordChanged(LoginPasswordChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      password: event.password,
      passwordError: () => null,
      requiresEmailVerification: false,
      errorMessage: () => null,
      infoMessage: () => null,
    ));
  }

  Future<void> _onRememberMeToggled(
    LoginRememberMeToggled event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(rememberMe: event.rememberMe));
    await _persistRememberMe(event.rememberMe, state.email);
  }

  Future<void> _onSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    final emailError = Validators.email(state.email);
    final passwordError = Validators.password(state.password);

    if (emailError != null || passwordError != null) {
      emit(state.copyWith(
        emailError: () => emailError,
        passwordError: () => passwordError,
      ));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: () => null, infoMessage: () => null));

    try {
      final result = await _authRepository.signIn(
        email: state.email.trim(),
        password: state.password,
      );

      await _persistRememberMe(state.rememberMe, state.email.trim());

      await result.fold(
        (failure) {
          final emailFieldError = failure is ValidationFailure
              ? (failure.fieldErrors?['email'])
              : null;
          emit(state.copyWith(
            isLoading: false,
            emailError: emailFieldError != null ? () => emailFieldError : null,
            requiresEmailVerification: false,
            errorMessage: () => failure.message,
          ));
        },
        (_) async {
          final verifiedResult = await _authRepository.isCurrentUserEmailVerified(
            reload: true,
          );

          await verifiedResult.fold(
            (failure) async {
              emit(state.copyWith(
                isLoading: false,
                requiresEmailVerification: false,
                errorMessage: () => failure.message,
              ));
            },
            (isVerified) async {
              if (!isVerified) {
                emit(state.copyWith(
                  isLoading: false,
                  isSuccess: false,
                  requiresEmailVerification: true,
                  infoMessage: () =>
                      'Please verify your email to continue. Check your inbox or resend the link below.',
                ));
                return;
              }

              emit(state.copyWith(
                isLoading: false,
                requiresEmailVerification: false,
                isSuccess: true,
              ));
            },
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: () => ErrorMessages.somethingWentWrong,
      ));
    }
  }

  void _onSignUpPressed(LoginSignUpPressed event, Emitter<LoginState> emit) {}

  void _onForgotPasswordPressed(
    LoginForgotPasswordPressed event,
    Emitter<LoginState> emit,
  ) {
    add(LoginForgotPasswordSubmitted(state.email));
  }

  Future<void> _onForgotPasswordSubmitted(
    LoginForgotPasswordSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    final emailError = Validators.email(event.email);
    if (emailError != null) {
      emit(state.copyWith(emailError: () => emailError));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: () => null, infoMessage: () => null));

    try {
      final result = await _authRepository.sendPasswordResetCode(
        email: event.email.trim(),
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
            infoMessage: () => SuccessMessages.passwordResetSent,
          ));
        },
      );
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: () => ErrorMessages.somethingWentWrong,
      ));
    }
  }

  Future<void> _onResendVerificationPressed(
    LoginResendVerificationPressed event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: () => null, infoMessage: () => null));

    final result = await _authRepository.sendEmailVerification();
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
          infoMessage: () => 'Verification email sent. Please check your inbox.',
        ));
      },
    );
  }

  Future<void> _persistRememberMe(bool remember, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.rememberMe, remember);
    if (remember) {
      await prefs.setString(StorageKeys.rememberedEmail, email.trim());
    } else {
      await prefs.remove(StorageKeys.rememberedEmail);
    }
  }
}