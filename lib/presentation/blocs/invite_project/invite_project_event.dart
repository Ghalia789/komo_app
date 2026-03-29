// Events = "Something happened in UI"

abstract class InviteProjectEvent {}

// User typed in email field
class InviteEmailChanged extends InviteProjectEvent {
  final String email;
  InviteEmailChanged(this.email);
}

// User tapped "Invite" button
class InviteSubmitted extends InviteProjectEvent {}

// User tapped "Resend" on pending invite
class InviteResend extends InviteProjectEvent {
  final String invitationId;
  InviteResend(this.invitationId);
}

// User tapped "Remove" on pending invite
class InviteRemove extends InviteProjectEvent {
  final String invitationId;
  InviteRemove(this.invitationId);
}

// User tapped menu on team member
class TeamMemberMenuTapped extends InviteProjectEvent {
  final String email;
  TeamMemberMenuTapped(this.email);
}

class InviteProjectRefreshRequested extends InviteProjectEvent {}

class InviteMemberRemoved extends InviteProjectEvent {
  final String userId;
  InviteMemberRemoved(this.userId);
}

// User tapped "Leave Project" button
class LeaveProjectPressed extends InviteProjectEvent {}

// Page loaded - fetch initial data
class InviteProjectLoaded extends InviteProjectEvent {
  final String projectId;
  InviteProjectLoaded(this.projectId);
}
