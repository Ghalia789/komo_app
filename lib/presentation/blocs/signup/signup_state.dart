import 'package:equatable/equatable.dart';

class SignupState extends Equatable {
  final String email;
  final String password;
  final String confirmPassword;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const SignupState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  bool get isValid =>
    email.isNotEmpty &&
    password.isNotEmpty &&
    confirmPassword.isNotEmpty &&
    emailError == null &&
    passwordError == null &&
    confirmPasswordError == null;

  SignupState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    String? Function()? emailError,
    String? Function()? passwordError,
    String? Function()? confirmPasswordError,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
    bool? isLoading,
    bool? isSuccess,
    String? Function()? errorMessage,
  }) {
    return SignupState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      emailError: emailError != null ? emailError() : this.emailError,
      passwordError: passwordError != null ? passwordError() : this.passwordError,
      confirmPasswordError: confirmPasswordError != null ? confirmPasswordError() : this.confirmPasswordError,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible: isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        email,
        password,
        confirmPassword,
        emailError,
        passwordError,
        confirmPasswordError,
        isPasswordVisible,
        isConfirmPasswordVisible,
        isLoading,
        isSuccess,
        errorMessage,
      ];
}