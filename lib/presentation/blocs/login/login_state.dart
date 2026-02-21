class LoginState {
  final String email;
  final String password;
  final String? emailError;      // NEW
  final String? passwordError;   // NEW
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  LoginState({
    this.email = '',
    this.password = '',
    this.emailError,             // NEW
    this.passwordError,          // NEW
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  bool get isValid => 
    email.isNotEmpty && 
    password.isNotEmpty &&
    emailError == null &&        // NEW: No errors
    passwordError == null;       // NEW

  LoginState copyWith({
    String? email,
    String? password,
    String? emailError,          // NEW
    String? passwordError,       // NEW
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: emailError ?? this.emailError,       // NEW
      passwordError: passwordError ?? this.passwordError, // NEW
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}