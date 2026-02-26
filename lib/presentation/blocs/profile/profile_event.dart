abstract class ProfileEvent {}

class ProfileLoadData extends ProfileEvent {}

class ProfileAvatarChanged extends ProfileEvent {
  final String? avatarPath;
  ProfileAvatarChanged(this.avatarPath);
}

class ProfileLogoutPressed extends ProfileEvent {}
