import 'package:equatable/equatable.dart';

// Models for team members and invites
class TeamMember extends Equatable {
  final String name;
  final String email;
  final String role;
  final String? imageUrl;

  const TeamMember({
    required this.name,
    required this.email,
    required this.role,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [name, email, role, imageUrl];
}

class PendingInvite extends Equatable {
  final String email;
  final DateTime? invitedAt;

  const PendingInvite({
    required this.email,
    this.invitedAt,
  });

  @override
  List<Object?> get props => [email, invitedAt];
}

// State
class InviteProjectState extends Equatable {
  final String projectTitle;
  final String projectDescription;
  final String inviteEmail;
  final String? emailError;
  final bool isLoading;
  final bool isInviteSent;
  final String? errorMessage;
  final String? successMessage;
  final List<PendingInvite> pendingInvites;
  final List<TeamMember> teamMembers;

  const InviteProjectState({
    this.projectTitle = '',
    this.projectDescription = '',
    this.inviteEmail = '',
    this.emailError,
    this.isLoading = false,
    this.isInviteSent = false,
    this.errorMessage,
    this.successMessage,
    this.pendingInvites = const [],
    this.teamMembers = const [],
  });

  bool get isValid => inviteEmail.isNotEmpty && emailError == null;

  InviteProjectState copyWith({
    String? projectTitle,
    String? projectDescription,
    String? inviteEmail,
    String? Function()? emailError,
    bool? isLoading,
    bool? isInviteSent,
    String? Function()? errorMessage,
    String? Function()? successMessage,
    List<PendingInvite>? pendingInvites,
    List<TeamMember>? teamMembers,
  }) {
    return InviteProjectState(
      projectTitle: projectTitle ?? this.projectTitle,
      projectDescription: projectDescription ?? this.projectDescription,
      inviteEmail: inviteEmail ?? this.inviteEmail,
      emailError: emailError != null ? emailError() : this.emailError,
      isLoading: isLoading ?? this.isLoading,
      isInviteSent: isInviteSent ?? this.isInviteSent,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      successMessage: successMessage != null ? successMessage() : this.successMessage,
      pendingInvites: pendingInvites ?? this.pendingInvites,
      teamMembers: teamMembers ?? this.teamMembers,
    );
  }

  @override
  List<Object?> get props => [
        projectTitle,
        projectDescription,
        inviteEmail,
        emailError,
        isLoading,
        isInviteSent,
        errorMessage,
        successMessage,
        pendingInvites,
        teamMembers,
      ];
}
