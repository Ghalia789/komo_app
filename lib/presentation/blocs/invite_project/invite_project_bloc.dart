import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/project_invitation.dart';
import '../../../domain/entities/user.dart' as domain_user;
import '../../../domain/repositories/project_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import 'invite_project_event.dart';
import 'invite_project_state.dart';

class InviteProjectBloc extends Bloc<InviteProjectEvent, InviteProjectState> {
  final ProjectRepository _projectRepository;
  final UserRepository _userRepository;

  InviteProjectBloc({
    required ProjectRepository projectRepository,
    required UserRepository userRepository,
  })  : _projectRepository = projectRepository,
        _userRepository = userRepository,
        super(const InviteProjectState()) {
    on<InviteProjectLoaded>(_onLoaded);
    on<InviteProjectRefreshRequested>(_onRefreshRequested);
    on<InviteEmailChanged>(_onEmailChanged);
    on<InviteSubmitted>(_onInviteSubmitted);
    on<InviteResend>(_onInviteResend);
    on<InviteRemove>(_onInviteRemove);
    on<TeamMemberMenuTapped>(_onTeamMemberMenuTapped);
    on<InviteMemberRemoved>(_onInviteMemberRemoved);
    on<LeaveProjectPressed>(_onLeaveProjectPressed);
  }

  List<TeamMember> _mapTeamMembers({
    required List<domain_user.User> users,
    required String ownerId,
  }) {
    return users.map<TeamMember>((user) {
      return TeamMember(
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.id == ownerId ? 'Owner' : 'Member',
        imageUrl: user.avatarUrl,
      );
    }).toList();
  }

  List<PendingInvite> _mapPendingInvites(List<ProjectInvitation> invites) {
    return invites
        .where((invite) => invite.isPending)
        .map(
          (invite) => PendingInvite(
            id: invite.id,
            email: invite.invitedEmail,
            invitedAt: invite.createdAt,
            lastSentAt: invite.lastSentAt,
          ),
        )
        .toList();
  }

  Future<void> _onLoaded(
    InviteProjectLoaded event,
    Emitter<InviteProjectState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: () => null));

    final projectResult =
        await _projectRepository.getProject(projectId: event.projectId);

    final failure = projectResult.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: () => failure.message,
      ));
      return;
    }

    final project = projectResult.getOrElse(() => throw Exception());
    final currentUserResult = await _userRepository.getCurrentUserProfile();
    final currentUserId = currentUserResult.fold((_) => '', (u) => u.id);
    final membersResult =
        await _projectRepository.getProjectMembers(projectId: event.projectId);
    final invitesResult =
      await _projectRepository.getPendingInvitations(projectId: event.projectId);

    final members = membersResult.fold((_) => <domain_user.User>[], (list) => list);
    final pendingInvites = invitesResult.fold((_) => const <PendingInvite>[], _mapPendingInvites);

    final teamMembers = _mapTeamMembers(
      users: members,
      ownerId: project.ownerId,
    );

    emit(state.copyWith(
      isLoading: false,
      projectId: event.projectId,
      ownerId: project.ownerId,
      currentUserId: currentUserId,
      projectTitle: project.name,
      projectDescription: project.description,
      teamMembers: teamMembers,
      pendingInvites: pendingInvites,
      leaveProjectSuccess: false,
    ));
  }

  Future<void> _onRefreshRequested(
    InviteProjectRefreshRequested event,
    Emitter<InviteProjectState> emit,
  ) async {
    if (state.projectId.isEmpty) return;

    emit(state.copyWith(isLoading: true, errorMessage: () => null));

    final projectResult =
        await _projectRepository.getProject(projectId: state.projectId);
    final membersResult =
        await _projectRepository.getProjectMembers(projectId: state.projectId);
    final invitesResult =
      await _projectRepository.getPendingInvitations(projectId: state.projectId);

    final failure = projectResult.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: () => failure.message,
      ));
      return;
    }

    final project = projectResult.getOrElse(() => throw Exception());
    final members = membersResult.fold((_) => <domain_user.User>[], (list) => list);
    final teamMembers = members.isEmpty
        ? state.teamMembers
        : _mapTeamMembers(users: members, ownerId: project.ownerId);
    final pendingInvites = invitesResult.fold(
      (_) => state.pendingInvites,
      _mapPendingInvites,
    );

    emit(state.copyWith(
      isLoading: false,
      ownerId: project.ownerId,
      projectTitle: project.name,
      projectDescription: project.description,
      teamMembers: teamMembers,
      pendingInvites: pendingInvites,
      successMessage: () => 'Members refreshed',
      leaveProjectSuccess: false,
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
      leaveProjectSuccess: false,
    ));
  }

  Future<void> _onInviteSubmitted(
    InviteSubmitted event,
    Emitter<InviteProjectState> emit,
  ) async {
    final emailError = Validators.email(state.inviteEmail);
    if (emailError != null) {
      emit(state.copyWith(emailError: () => emailError));
      return;
    }

    final alreadyMember = state.teamMembers.any(
      (m) => m.email.toLowerCase() == state.inviteEmail.toLowerCase(),
    );
    if (alreadyMember) {
      emit(state.copyWith(
        emailError: () => 'This person is already a team member',
      ));
      return;
    }

    emit(state.copyWith(isLoading: true, emailError: () => null));

    final result = await _projectRepository.inviteMember(
      projectId: state.projectId,
      userEmail: state.inviteEmail.trim(),
    );

    await result.fold(
      (failure) async {
        if (!failure.message.contains('No users found')) {
          emit(state.copyWith(
            isLoading: false,
            emailError: () => failure.message,
          ));
          return;
        }

        final createInviteResult = await _projectRepository.createPendingInvitation(
          projectId: state.projectId,
          invitedEmail: state.inviteEmail.trim(),
          invitedByUserId: state.currentUserId,
        );

        createInviteResult.fold(
          (inviteFailure) => emit(state.copyWith(
            isLoading: false,
            emailError: () => inviteFailure.message,
          )),
          (invitation) {
            final updatedPending = [
              PendingInvite(
                id: invitation.id,
                email: invitation.invitedEmail,
                invitedAt: invitation.createdAt,
                lastSentAt: invitation.lastSentAt,
              ),
              ...state.pendingInvites.where((i) => i.id != invitation.id),
            ];

            emit(state.copyWith(
              isLoading: false,
              isInviteSent: true,
              inviteEmail: '',
              pendingInvites: updatedPending,
              successMessage: () =>
                  'Invitation saved. It will be applied automatically when this user signs up.',
              leaveProjectSuccess: false,
            ));
          },
        );
      },
      (_) async {
        // Refresh members and pending invitations from Firestore after successful invite.
        final membersResult = await _projectRepository.getProjectMembers(
          projectId: state.projectId,
        );
        final invitesResult =
            await _projectRepository.getPendingInvitations(projectId: state.projectId);

        final members = membersResult.fold((_) => state.teamMembers, (list) {
          return _mapTeamMembers(users: list, ownerId: state.ownerId);
        });
        final pendingInvites =
            invitesResult.fold((_) => state.pendingInvites, _mapPendingInvites);

        emit(state.copyWith(
          isLoading: false,
          isInviteSent: true,
          inviteEmail: '',
          teamMembers: members,
          pendingInvites: pendingInvites,
          successMessage: () => 'Invitation sent successfully!',
          leaveProjectSuccess: false,
        ));

        await Future.delayed(const Duration(seconds: 2));
        if (!emit.isDone) {
          emit(state.copyWith(successMessage: () => null, isInviteSent: false));
        }
      },
    );
  }

  Future<void> _onInviteResend(
    InviteResend event,
    Emitter<InviteProjectState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _projectRepository.resendPendingInvitation(
      invitationId: event.invitationId,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: () => failure.message,
      )),
      (updated) async {
        final updatedPending = state.pendingInvites.map((invite) {
          if (invite.id != event.invitationId) return invite;
          return PendingInvite(
            id: invite.id,
            email: invite.email,
            invitedAt: invite.invitedAt,
            lastSentAt: updated.lastSentAt,
          );
        }).toList();

        emit(state.copyWith(
          isLoading: false,
          pendingInvites: updatedPending,
          successMessage: () => 'Invitation resent to ${updated.invitedEmail}',
        ));
        await Future.delayed(const Duration(seconds: 2));
        if (!emit.isDone) {
          emit(state.copyWith(successMessage: () => null));
        }
      },
    );
  }

  Future<void> _onInviteRemove(
    InviteRemove event,
    Emitter<InviteProjectState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _projectRepository.removePendingInvitation(
      invitationId: event.invitationId,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: () => failure.message,
      )),
      (_) {
        final updatedInvites = state.pendingInvites
            .where((invite) => invite.id != event.invitationId)
            .toList();
        emit(state.copyWith(
          isLoading: false,
          pendingInvites: updatedInvites,
          successMessage: () => 'Invitation removed',
        ));
      },
    );
  }

  void _onTeamMemberMenuTapped(
    TeamMemberMenuTapped event,
    Emitter<InviteProjectState> emit,
  ) {
    // Handled in the UI layer (show bottom sheet / dialog)
  }

  Future<void> _onInviteMemberRemoved(
    InviteMemberRemoved event,
    Emitter<InviteProjectState> emit,
  ) async {
    if (!state.isOwner) {
      emit(state.copyWith(
        errorMessage: () => 'Only the project owner can remove members.',
      ));
      return;
    }

    if (event.userId == state.ownerId) {
      emit(state.copyWith(
        errorMessage: () => 'Owner cannot be removed from the project.',
      ));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: () => null));

    final result = await _projectRepository.removeMember(
      projectId: state.projectId,
      userId: event.userId,
    );

    await result.fold(
      (failure) async {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: () => failure.message,
        ));
      },
      (updatedProject) async {
        final membersResult = await _projectRepository.getProjectMembers(
          projectId: state.projectId,
        );
        final members = membersResult.fold((_) => state.teamMembers, (list) {
          return _mapTeamMembers(
            users: list,
            ownerId: updatedProject.ownerId,
          );
        });

        emit(state.copyWith(
          isLoading: false,
          ownerId: updatedProject.ownerId,
          teamMembers: members,
          successMessage: () => 'Member removed successfully',
          leaveProjectSuccess: false,
        ));
      },
    );
  }

  Future<void> _onLeaveProjectPressed(
    LeaveProjectPressed event,
    Emitter<InviteProjectState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final currentUserResult = await _userRepository.getCurrentUserProfile();
    final currentUser = currentUserResult.fold((_) => null, (u) => u);

    if (currentUser == null) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: () => 'Could not identify current user',
        leaveProjectSuccess: false,
      ));
      return;
    }

    if (currentUser.id == state.ownerId) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: () => 'Owner cannot leave the project. Transfer ownership first.',
        leaveProjectSuccess: false,
      ));
      return;
    }

    final result = await _projectRepository.leaveProject(
      projectId: state.projectId,
      userId: currentUser.id,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: () => failure.message,
        leaveProjectSuccess: false,
      )),
      (_) => emit(state.copyWith(
        isLoading: false,
        leaveProjectSuccess: true,
        successMessage: () => 'You left the project',
      )),
      // Navigation back is handled by the UI layer watching errorMessage == null + isLoading == false
    );
  }
}
