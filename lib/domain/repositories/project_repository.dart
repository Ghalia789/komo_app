import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/app_notification.dart';
import '../entities/project.dart';
import '../entities/project_invitation.dart';
import '../entities/user.dart';

/// Repository interface for project operations.
/// 
/// Implementations should handle Firestore project document operations.
abstract class ProjectRepository {
  /// Gets all projects for a user.
  /// 
  /// Returns projects where the user is owner or member.
  Future<Either<Failure, List<Project>>> getProjects({
    required String userId,
  });

  /// Gets a project by ID.
  /// 
  /// Returns [NotFoundFailure] if project doesn't exist.
  Future<Either<Failure, Project>> getProject({
    required String projectId,
  });

  /// Creates a new project.
  /// 
  /// Returns the created [Project] with generated ID.
  Future<Either<Failure, Project>> createProject({
    required Project project,
  });

  /// Updates an existing project.
  /// 
  /// Returns the updated [Project].
  Future<Either<Failure, Project>> updateProject({
    required Project project,
  });

  /// Deletes a project and all associated data.
  /// 
  /// This should also delete all tasks, subtasks, and comments.
  Future<Either<Failure, Unit>> deleteProject({
    required String projectId,
  });

  /// Archives a project (soft hide from active lists).
  Future<Either<Failure, Unit>> archiveProject({
    required String projectId,
  });

  /// Restores a previously archived project.
  Future<Either<Failure, Unit>> restoreProject({
    required String projectId,
  });

  /// Marks a project as softly deleted (recoverable).
  Future<Either<Failure, Unit>> softDeleteProject({
    required String projectId,
  });

  /// Restores a softly deleted project.
  Future<Either<Failure, Unit>> restoreSoftDeletedProject({
    required String projectId,
  });

  /// Hard deletes a project with full cascade cleanup.
  Future<Either<Failure, Unit>> hardDeleteProject({
    required String projectId,
  });

  /// Gets the members of a project.
  /// 
  /// Returns list of [User] who are members.
  Future<Either<Failure, List<User>>> getProjectMembers({
    required String projectId,
  });

  /// Invites a user to a project.
  /// 
  /// Returns updated [Project] with new member.
  Future<Either<Failure, Project>> inviteMember({
    required String projectId,
    required String userEmail,
  });

  /// Invites multiple users to a project.
  /// 
  /// Returns updated [Project] with new members.
  Future<Either<Failure, Project>> inviteMembers({
    required String projectId,
    required List<String> userEmails,
  });

  /// Removes a member from a project.
  /// 
  /// Owner cannot be removed.
  Future<Either<Failure, Project>> removeMember({
    required String projectId,
    required String userId,
  });

  /// Leaves a project (for non-owner members).
  Future<Either<Failure, Unit>> leaveProject({
    required String projectId,
    required String userId,
  });

  /// Gets pending invitations for a project.
  Future<Either<Failure, List<ProjectInvitation>>> getPendingInvitations({
    required String projectId,
  });

  /// Creates or updates a pending invitation for an email.
  Future<Either<Failure, ProjectInvitation>> createPendingInvitation({
    required String projectId,
    required String invitedEmail,
    required String invitedByUserId,
  });

  /// Updates invitation send timestamp (resend action).
  Future<Either<Failure, ProjectInvitation>> resendPendingInvitation({
    required String invitationId,
  });

  /// Removes a pending invitation.
  Future<Either<Failure, Unit>> removePendingInvitation({
    required String invitationId,
  });

  /// Stream of project updates.
  /// 
  /// Useful for real-time updates on project changes.
  Stream<Either<Failure, Project>> watchProject({
    required String projectId,
  });

  /// Stream of all user's projects.
  /// 
  /// Emits whenever any project changes.
  Stream<Either<Failure, List<Project>>> watchProjects({
    required String userId,
  });

  /// Gets recent projects for the user.
  /// 
  /// Limited to the most recently accessed projects.
  Future<Either<Failure, List<Project>>> getRecentProjects({
    required String userId,
    int limit = 5,
  });

  /// Updates the last accessed timestamp for a project.
  Future<Either<Failure, Unit>> markProjectAccessed({
    required String projectId,
  });

  /// Stream of notifications for a user.
  Stream<Either<Failure, List<AppNotification>>> watchNotifications({
    required String userId,
  });

  /// Marks a single notification as read.
  Future<Either<Failure, Unit>> markNotificationRead({
    required String notificationId,
  });

  /// Marks all unread notifications as read for a user.
  Future<Either<Failure, Unit>> markAllNotificationsRead({
    required String userId,
  });

  /// Deletes a single notification.
  Future<Either<Failure, Unit>> deleteNotification({
    required String notificationId,
  });

  /// Creates a notification.
  Future<Either<Failure, AppNotification>> createNotification({
    required AppNotification notification,
  });
}
