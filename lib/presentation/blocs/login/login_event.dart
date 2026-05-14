// Events = "Something happened in UI"
// User can: type email, type password, tap login, tap signup

abstract class LoginEvent {}

// Initialize: load remembered email/flag
class LoginInitializeRequested extends LoginEvent {}

// User typed in email field
class LoginEmailChanged extends LoginEvent {
  final String email;
  LoginEmailChanged(this.email);
}

// User typed in password field
class LoginPasswordChanged extends LoginEvent {
  final String password;
  LoginPasswordChanged(this.password);
}

// User toggled remember me
class LoginRememberMeToggled extends LoginEvent {
  final bool rememberMe;
  LoginRememberMeToggled(this.rememberMe);
}

// User tapped "Log In" button
class LoginSubmitted extends LoginEvent {}

// User tapped "Sign up" link
class LoginSignUpPressed extends LoginEvent {}

// User tapped "Forgot password"
class LoginForgotPasswordPressed extends LoginEvent {}

// User confirmed forgot password action
class LoginForgotPasswordSubmitted extends LoginEvent {
  final String email;
  LoginForgotPasswordSubmitted(this.email);
}

// User tapped "Resend verification email"
class LoginResendVerificationPressed extends LoginEvent {}