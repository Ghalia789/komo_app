import 'package:equatable/equatable.dart';

class LoginState extends Equatable {
  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const LoginState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
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
    String? Function()? errorMessage,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: emailError != null ? emailError() : this.emailError,
      passwordError: passwordError != null ? passwordError() : this.passwordError,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
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
        errorMessage,
      ];
}