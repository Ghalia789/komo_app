import 'package:equatable/equatable.dart';

class ResetPasswordState extends Equatable {
  final String email;
  final String code;
  final String password;
  final String confirmPassword;
  final String? codeError;
  final String? passwordError;
  final String? confirmPasswordError;
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final String? infoMessage;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;

  const ResetPasswordState({
    this.email = '',
    this.code = '',
    this.password = '',
    this.confirmPassword = '',
    this.codeError,
    this.passwordError,
    this.confirmPasswordError,
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.infoMessage,
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
  });

  bool get isValid =>
      code.isNotEmpty &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      codeError == null &&
      passwordError == null &&
      confirmPasswordError == null;

  ResetPasswordState copyWith({
    String? email,
    String? code,
    String? password,
    String? confirmPassword,
    String? Function()? codeError,
    String? Function()? passwordError,
    String? Function()? confirmPasswordError,
    bool? isLoading,
    bool? isSuccess,
    String? Function()? errorMessage,
    String? Function()? infoMessage,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
  }) {
    return ResetPasswordState(
      email: email ?? this.email,
      code: code ?? this.code,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      codeError: codeError != null ? codeError() : this.codeError,
      passwordError: passwordError != null ? passwordError() : this.passwordError,
      confirmPasswordError: confirmPasswordError != null ? confirmPasswordError() : this.confirmPasswordError,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      infoMessage: infoMessage != null ? infoMessage() : this.infoMessage,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible: isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
    );
  }

  @override
  List<Object?> get props => [
      email,
        code,
        password,
        confirmPassword,
        codeError,
        passwordError,
        confirmPasswordError,
        isLoading,
        isSuccess,
        errorMessage,
        infoMessage,
        isPasswordVisible,
        isConfirmPasswordVisible,
      ];
}
