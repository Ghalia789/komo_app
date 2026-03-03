import 'package:equatable/equatable.dart';

class CompleteProfileState extends Equatable {
  final String name;
  final String jobTitle;
  final String company;
  final String role;
  final String? avatarPath;
  final String? nameError;
  final String? errorMessage;
  final bool isLoading;
  final bool isSuccess;

  const CompleteProfileState({
    this.name = '',
    this.jobTitle = '',
    this.company = '',
    this.role = '',
    this.avatarPath,
    this.nameError,
    this.errorMessage,
    this.isLoading = false,
    this.isSuccess = false,
  });

  bool get isValid => name.isNotEmpty && nameError == null;

  CompleteProfileState copyWith({
    String? name,
    String? jobTitle,
    String? company,
    String? role,
    String? Function()? avatarPath,
    String? Function()? nameError,
    String? Function()? errorMessage,
    bool? isLoading,
    bool? isSuccess,
  }) {
    return CompleteProfileState(
      name: name ?? this.name,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      role: role ?? this.role,
      avatarPath: avatarPath != null ? avatarPath() : this.avatarPath,
      nameError: nameError != null ? nameError() : this.nameError,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [
        name,
        jobTitle,
        company,
        role,
        avatarPath,
        nameError,
        errorMessage,
        isLoading,
        isSuccess,
      ];
}