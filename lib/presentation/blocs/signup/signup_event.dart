abstract class SignupEvent {}

class SignupEmailChanged extends SignupEvent {
  final String email;
  SignupEmailChanged(this.email);
}

class SignupPasswordChanged extends SignupEvent {
  final String password;
  SignupPasswordChanged(this.password);
}

class SignupConfirmPasswordChanged extends SignupEvent {
  final String confirmPassword;
  SignupConfirmPasswordChanged(this.confirmPassword);
}

class SignupTogglePasswordVisibility extends SignupEvent {}

class SignupToggleConfirmPasswordVisibility extends SignupEvent {}

class SignupSubmitted extends SignupEvent {}

class SignupLoginPressed extends SignupEvent {}