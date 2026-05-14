import 'package:equatable/equatable.dart';

class LoginState extends Equatable {
  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;
  final bool isLoading;
  final bool isSuccess;
  final bool requiresEmailVerification;
  final String? errorMessage;
  final String? infoMessage;
  final bool rememberMe;

  const LoginState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
    this.isLoading = false,
    this.isSuccess = false,
    this.requiresEmailVerification = false,
    this.errorMessage,
    this.infoMessage,
    this.rememberMe = true,
  });

  bool get isValid => 
    email.isNotEmpty && 
    password.isNotEmpty &&
    emailError == null &&
    passwordError == null;

  LoginState copyWith({
    String? email,
    String? password,
    String? Function()? emailError,
    String? Function()? passwordError,
    bool? isLoading,
    bool? isSuccess,
    bool? requiresEmailVerification,
    String? Function()? errorMessage,
    String? Function()? infoMessage,
    bool? rememberMe,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: emailError != null ? emailError() : this.emailError,
      passwordError: passwordError != null ? passwordError() : this.passwordError,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
        requiresEmailVerification:
          requiresEmailVerification ?? this.requiresEmailVerification,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      infoMessage: infoMessage != null ? infoMessage() : this.infoMessage,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }

  @override
  List<Object?> get props => [
        email,
        password,
        emailError,
        passwordError,
        isLoading,
        isSuccess,
        requiresEmailVerification,
        errorMessage,
        infoMessage,
        rememberMe,
      ];
}