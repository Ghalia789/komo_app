import 'package:equatable/equatable.dart';

abstract class ResetPasswordEvent extends Equatable {
  const ResetPasswordEvent();

  @override
  List<Object?> get props => [];
}

class ResetPasswordCodeChanged extends ResetPasswordEvent {
  final String code;

  const ResetPasswordCodeChanged(this.code);

  @override
  List<Object?> get props => [code];
}

class ResetPasswordChanged extends ResetPasswordEvent {
  final String password;

  const ResetPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class ResetPasswordConfirmChanged extends ResetPasswordEvent {
  final String confirmPassword;

  const ResetPasswordConfirmChanged(this.confirmPassword);

  @override
  List<Object?> get props => [confirmPassword];
}

class ResetPasswordToggleVisibility extends ResetPasswordEvent {
  const ResetPasswordToggleVisibility();
}

class ResetPasswordToggleConfirmVisibility extends ResetPasswordEvent {
  const ResetPasswordToggleConfirmVisibility();
}

class ResetPasswordSubmitted extends ResetPasswordEvent {
  const ResetPasswordSubmitted();
}
