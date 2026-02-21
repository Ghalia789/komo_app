abstract class CompleteProfileEvent {}

class CompleteProfileNameChanged extends CompleteProfileEvent {
  final String name;
  CompleteProfileNameChanged(this.name);
}

class CompleteProfileJobTitleChanged extends CompleteProfileEvent {
  final String jobTitle;
  CompleteProfileJobTitleChanged(this.jobTitle);
}

class CompleteProfileCompanyChanged extends CompleteProfileEvent {
  final String company;
  CompleteProfileCompanyChanged(this.company);
}

class CompleteProfileRoleChanged extends CompleteProfileEvent {
  final String role;
  CompleteProfileRoleChanged(this.role);
}

class CompleteProfileAvatarChanged extends CompleteProfileEvent {
  final String? imagePath;
  CompleteProfileAvatarChanged(this.imagePath);
}

class CompleteProfileSubmitted extends CompleteProfileEvent {}