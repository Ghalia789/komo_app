import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  final String name;
  final String email;
  final String role;
  final String? avatarUrl;
  final int tasksDone;
  final int projectsCount;
  final int onTimePercentage;
  final int teamMembersCount;
  final int activeProjectsCount;
  final bool isLoading;
  final bool isLoggingOut;
  final bool logoutSuccess;
  final String? errorMessage;

  const ProfileState({
    this.name = '',
    this.email = '',
    this.role = '',
    this.avatarUrl,
    this.tasksDone = 0,
    this.projectsCount = 0,
    this.onTimePercentage = 0,
    this.teamMembersCount = 0,
    this.activeProjectsCount = 0,
    this.isLoading = false,
    this.isLoggingOut = false,
    this.logoutSuccess = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    String? name,
    String? email,
    String? role,
    String? Function()? avatarUrl,
    int? tasksDone,
    int? projectsCount,
    int? onTimePercentage,
    int? teamMembersCount,
    int? activeProjectsCount,
    bool? isLoading,
    bool? isLoggingOut,
    bool? logoutSuccess,
    String? Function()? errorMessage,
  }) {
    return ProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl != null ? avatarUrl() : this.avatarUrl,
      tasksDone: tasksDone ?? this.tasksDone,
      projectsCount: projectsCount ?? this.projectsCount,
      onTimePercentage: onTimePercentage ?? this.onTimePercentage,
      teamMembersCount: teamMembersCount ?? this.teamMembersCount,
      activeProjectsCount: activeProjectsCount ?? this.activeProjectsCount,
      isLoading: isLoading ?? this.isLoading,
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
      logoutSuccess: logoutSuccess ?? this.logoutSuccess,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        name,
        email,
        role,
        avatarUrl,
        tasksDone,
        projectsCount,
        onTimePercentage,
        teamMembersCount,
        activeProjectsCount,
        isLoading,
        isLoggingOut,
        logoutSuccess,
        errorMessage,
      ];
}
