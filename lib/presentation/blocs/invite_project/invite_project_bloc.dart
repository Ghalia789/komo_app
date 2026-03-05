import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/validators.dart';
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
    final membersResult =
        await _projectRepository.getProjectMembers(projectId: event.projectId);

    final members = membersResult.fold((_) => [], (list) => list);

    final teamMembers = members.map((user) {
      return TeamMember(
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.id == project.ownerId ? 'Owner' : 'Member',
        imageUrl: user.avatarUrl,
      );
    }).toList();

    emit(state.copyWith(
      isLoading: false,
      projectId: event.projectId,
      ownerId: project.ownerId,
      projectTitle: project.name,
      projectDescription: project.description,
      teamMembers: teamMembers,
      pendingInvites: const [],
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

    result.fold(
      (failure) {
        final msg = failure.message.contains('No users found')
            ? 'No account found for this email. Ask them to sign up first.'
            : failure.message;
        emit(state.copyWith(
          isLoading: false,
          emailError: () => msg,
        ));
      },
      (_) async {
        // Refresh members from Firestore after successful invite
        final membersResult = await _projectRepository.getProjectMembers(
          projectId: state.projectId,
        );
        final members = membersResult.fold((_) => state.teamMembers, (list) {
          return list.map((user) {
            return TeamMember(
              id: user.id,
              name: user.name,
              email: user.email,
              role: user.id == state.ownerId ? 'Owner' : 'Member',
              imageUrl: user.avatarUrl,
            );
          }).toList();
        });

        emit(state.copyWith(
          isLoading: false,
          isInviteSent: true,
          inviteEmail: '',
          teamMembers: members,
          successMessage: () => 'Invitation sent successfully!',
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

    final result = await _projectRepository.inviteMember(
      projectId: state.projectId,
      userEmail: event.email,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: () => failure.message,
      )),
      (_) async {
        emit(state.copyWith(
          isLoading: false,
          successMessage: () => 'Invitation resent to ${event.email}',
        ));
        await Future.delayed(const Duration(seconds: 2));
        if (!emit.isDone) {
          emit(state.copyWith(successMessage: () => null));
        }
      },
    );
  }

  void _onInviteRemove(
    InviteRemove event,
    Emitter<InviteProjectState> emit,
  ) {
    final updatedInvites = state.pendingInvites
        .where((invite) => invite.email != event.email)
        .toList();
    emit(state.copyWith(pendingInvites: updatedInvites));
  }

  void _onTeamMemberMenuTapped(
    TeamMemberMenuTapped event,
    Emitter<InviteProjectState> emit,
  ) {
    // Handled in the UI layer (show bottom sheet / dialog)
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
      )),
      (_) => emit(state.copyWith(isLoading: false)),
      // Navigation back is handled by the UI layer watching errorMessage == null + isLoading == false
    );
  }
}
