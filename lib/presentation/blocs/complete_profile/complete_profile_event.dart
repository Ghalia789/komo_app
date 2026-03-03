abstract class CompleteProfileEvent {}

class CompleteProfilePrefilled extends CompleteProfileEvent {
  final String? name;
  final String? jobTitle;
  final String? company;
  final String? role;
  final String? avatarUrl;

  CompleteProfilePrefilled({
    this.name,
    this.jobTitle,
    this.company,
    this.role,
    this.avatarUrl,
  });
}

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