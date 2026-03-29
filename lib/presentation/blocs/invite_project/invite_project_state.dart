import 'package:equatable/equatable.dart';

// Models for team members and invites
class TeamMember extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? imageUrl;

  const TeamMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, email, role, imageUrl];
}

class PendingInvite extends Equatable {
  final String id;
  final String email;
  final DateTime? invitedAt;
  final DateTime? lastSentAt;

  const PendingInvite({
    required this.id,
    required this.email,
    this.invitedAt,
    this.lastSentAt,
  });

  @override
  List<Object?> get props => [id, email, invitedAt, lastSentAt];
}

// State
class InviteProjectState extends Equatable {
  final String projectId;
  final String ownerId;
  final String currentUserId;
  final String projectTitle;
  final String projectDescription;
  final String inviteEmail;
  final String? emailError;
  final bool isLoading;
  final bool isInviteSent;
  final bool leaveProjectSuccess;
  final String? errorMessage;
  final String? successMessage;
  final List<PendingInvite> pendingInvites;
  final List<TeamMember> teamMembers;

  const InviteProjectState({
    this.projectId = '',
    this.ownerId = '',
    this.currentUserId = '',
    this.projectTitle = '',
    this.projectDescription = '',
    this.inviteEmail = '',
    this.emailError,
    this.isLoading = false,
    this.isInviteSent = false,
    this.leaveProjectSuccess = false,
    this.errorMessage,
    this.successMessage,
    this.pendingInvites = const [],
    this.teamMembers = const [],
  });

  bool get isValid => inviteEmail.isNotEmpty && emailError == null;
  bool get isOwner => currentUserId.isNotEmpty && currentUserId == ownerId;

  InviteProjectState copyWith({
    String? projectId,
    String? ownerId,
    String? currentUserId,
    String? projectTitle,
    String? projectDescription,
    String? inviteEmail,
    String? Function()? emailError,
    bool? isLoading,
    bool? isInviteSent,
    bool? leaveProjectSuccess,
    String? Function()? errorMessage,
    String? Function()? successMessage,
    List<PendingInvite>? pendingInvites,
    List<TeamMember>? teamMembers,
  }) {
    return InviteProjectState(
      projectId: projectId ?? this.projectId,
      ownerId: ownerId ?? this.ownerId,
      currentUserId: currentUserId ?? this.currentUserId,
      projectTitle: projectTitle ?? this.projectTitle,
      projectDescription: projectDescription ?? this.projectDescription,
      inviteEmail: inviteEmail ?? this.inviteEmail,
      emailError: emailError != null ? emailError() : this.emailError,
      isLoading: isLoading ?? this.isLoading,
      isInviteSent: isInviteSent ?? this.isInviteSent,
      leaveProjectSuccess: leaveProjectSuccess ?? this.leaveProjectSuccess,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      successMessage: successMessage != null ? successMessage() : this.successMessage,
      pendingInvites: pendingInvites ?? this.pendingInvites,
      teamMembers: teamMembers ?? this.teamMembers,
    );
  }

  @override
  List<Object?> get props => [
        projectId,
        ownerId,
        currentUserId,
        projectTitle,
        projectDescription,
        inviteEmail,
        emailError,
        isLoading,
        isInviteSent,
        leaveProjectSuccess,
        errorMessage,
        successMessage,
        pendingInvites,
        teamMembers,
      ];
}
