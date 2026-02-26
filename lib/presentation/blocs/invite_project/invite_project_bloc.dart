import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/validators.dart';
import 'invite_project_event.dart';
import 'invite_project_state.dart';

class InviteProjectBloc extends Bloc<InviteProjectEvent, InviteProjectState> {
  InviteProjectBloc() : super(const InviteProjectState()) {
    on<InviteProjectLoaded>(_onLoaded);
    on<InviteEmailChanged>(_onEmailChanged);
    on<InviteSubmitted>(_onInviteSubmitted);
    on<InviteResend>(_onInviteResend);
    on<InviteRemove>(_onInviteRemove);
    on<TeamMemberMenuTapped>(_onTeamMemberMenuTapped);
    on<LeaveProjectPressed>(_onLeaveProjectPressed);
  }

  Future<void> _onLoaded(
    InviteProjectLoaded event,
    Emitter<InviteProjectState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    // TODO: Fetch project details and team members from API
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data
    emit(state.copyWith(
      isLoading: false,
      projectTitle: 'Website Redesign',
      projectDescription: 'Collaborate with your team on this project',
      pendingInvites: const [
        PendingInvite(
          email: 'john@gmail.com',
          invitedAt: null,
        ),
        PendingInvite(
          email: 'janedoe@company.com',
          invitedAt: null,
        ),
      ],
      teamMembers: const [
        TeamMember(
          name: 'Jane Smith',
          email: 'jane@company.com',
          role: 'Owner',
        ),
        TeamMember(
          name: 'Morgan Free',
          email: 'morgan@company.com',
          role: 'Member',
        ),
        TeamMember(
          name: 'Fay Spencer',
          email: 'fay@company.com',
          role: 'Member',
        ),
      ],
    ));
  }

  void _onEmailChanged(
    InviteEmailChanged event,
    Emitter<InviteProjectState> emit,
  ) {
    emit(state.copyWith(
      inviteEmail: event.email,
      emailError: () => null,
      isInviteSent: false,
    ));
  }

  Future<void> _onInviteSubmitted(
    InviteSubmitted event,
    Emitter<InviteProjectState> emit,
  ) async {
    // Validate email
    final emailError = Validators.email(state.inviteEmail);

    if (emailError != null) {
      emit(state.copyWith(emailError: () => emailError));
      return;
    }

    // Check if email is already in pending invites
    final isDuplicate = state.pendingInvites
        .any((invite) => invite.email.toLowerCase() == state.inviteEmail.toLowerCase());

    if (isDuplicate) {
      emit(state.copyWith(
        emailError: () => 'This email has already been invited',
      ));
      return;
    }

    // Check if email is already a team member
    final isTeamMember = state.teamMembers
        .any((member) => member.email.toLowerCase() == state.inviteEmail.toLowerCase());

    if (isTeamMember) {
      emit(state.copyWith(
        emailError: () => 'This person is already a team member',
      ));
      return;
    }

    emit(state.copyWith(isLoading: true));

    // TODO: Send invite via API
    await Future.delayed(const Duration(seconds: 1));

    // Add to pending invites
    final newInvite = PendingInvite(
      email: state.inviteEmail,
      invitedAt: DateTime.now(),
    );

    emit(state.copyWith(
      isLoading: false,
      isInviteSent: true,
      inviteEmail: '',
      pendingInvites: [...state.pendingInvites, newInvite],
      successMessage: () => 'Invitation sent successfully!',
    ));

    // Clear success message after a delay
    await Future.delayed(const Duration(seconds: 2));
    emit(state.copyWith(successMessage: () => null, isInviteSent: false));
  }

  Future<void> _onInviteResend(
    InviteResend event,
    Emitter<InviteProjectState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    // TODO: Resend invite via API
    await Future.delayed(const Duration(milliseconds: 500));

    emit(state.copyWith(
      isLoading: false,
      successMessage: () => 'Invitation resent to ${event.email}',
    ));

    await Future.delayed(const Duration(seconds: 2));
    emit(state.copyWith(successMessage: () => null));
  }

  void _onInviteRemove(
    InviteRemove event,
    Emitter<InviteProjectState> emit,
  ) {
    final updatedInvites = state.pendingInvites
        .where((invite) => invite.email != event.email)
        .toList();

    emit(state.copyWith(
      pendingInvites: updatedInvites,
      successMessage: () => 'Invitation removed',
    ));
  }

  void _onTeamMemberMenuTapped(
    TeamMemberMenuTapped event,
    Emitter<InviteProjectState> emit,
  ) {
    // TODO: Show bottom sheet or dialog with options
    // (Remove member, Change role, etc.)
  }

  Future<void> _onLeaveProjectPressed(
    LeaveProjectPressed event,
    Emitter<InviteProjectState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    // TODO: Call API to leave project
    await Future.delayed(const Duration(seconds: 1));

    // Navigate back handled in UI
    emit(state.copyWith(isLoading: false));
  }
}
