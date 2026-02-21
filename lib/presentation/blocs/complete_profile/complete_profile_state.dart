class CompleteProfileState {
  final String name;
  final String jobTitle;
  final String company;
  final String role;
  final String? avatarPath;
  final String? nameError;
  final bool isLoading;
  final bool isSuccess;

  CompleteProfileState({
    this.name = '',
    this.jobTitle = '',
    this.company = '',
    this.role = '',
    this.avatarPath,
    this.nameError,
    this.isLoading = false,
    this.isSuccess = false,
  });

  bool get isValid => name.isNotEmpty && nameError == null;

  CompleteProfileState copyWith({
    String? name,
    String? jobTitle,
    String? company,
    String? role,
    String? avatarPath,
    String? nameError,
    bool? isLoading,
    bool? isSuccess,
  }) {
    return CompleteProfileState(
      name: name ?? this.name,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      role: role ?? this.role,
      avatarPath: avatarPath ?? this.avatarPath,
      nameError: nameError ?? this.nameError,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}