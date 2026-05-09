import 'dart:io';

import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';

/// Repository interface for user profile operations.
/// 
/// Implementations should handle Firestore user document operations
/// and Storage operations for avatars.
abstract class UserRepository {
  /// Gets a user by their ID.
  /// 
  /// Returns [User] on success, [NotFoundFailure] if user doesn't exist.
  Future<Either<Failure, User>> getUser({
    required String userId,
  });

  /// Gets the current user's profile from Firestore.
  /// 
  /// This fetches the full user document, not just auth state.
  Future<Either<Failure, User>> getCurrentUserProfile();

  /// Updates a user's profile information.
  /// 
  /// Returns updated [User] on success.
  Future<Either<Failure, User>> updateProfile({
    required User user,
  });

  /// Updates specific fields of a user's profile.
  /// 
  /// Only provided fields will be updated.
  Future<Either<Failure, User>> updateProfileFields({
    required String userId,
    String? name,
    String? jobTitle,
    String? company,
    String? role,
    String? avatarUrl,
  });

  /// Creates a new user profile in Firestore.
  /// 
  /// This should be called after successful signup to create the user document.
  Future<Either<Failure, User>> createUserProfile({
    required User user,
  });

  /// Uploads a user's avatar image.
  /// 
  /// Returns the download URL of the uploaded image.
  Future<Either<Failure, String>> uploadAvatar({
    required String userId,
    required File imageFile,
  });

  /// Deletes a user's account and all associated data.
  /// 
  /// This should delete:
  /// - User document from Firestore
  /// - Avatar from Storage
  /// - Auth account
  Future<Either<Failure, Unit>> deleteAccount({
    required String userId,
  });

  /// Soft-deletes (archives/deactivates) the account but keeps data recoverable.
  Future<Either<Failure, Unit>> softDeleteAccount({
    required String userId,
  });

  /// Restores a previously soft-deleted account.
  Future<Either<Failure, Unit>> restoreAccount({
    required String userId,
  });

  /// Hard-deletes account and associated data permanently.
  Future<Either<Failure, Unit>> hardDeleteAccount({
    required String userId,
  });

  /// Checks if a user profile exists in Firestore.
  Future<Either<Failure, bool>> userProfileExists({
    required String userId,
  });

  /// Gets users by a list of IDs.
  /// 
  /// Useful for fetching project members.
  Future<Either<Failure, List<User>>> getUsersByIds({
    required List<String> userIds,
  });

  /// Searches for users by email or name.
  /// 
  /// Used for inviting users to projects.
  Future<Either<Failure, List<User>>> searchUsers({
    required String query,
    int limit = 10,
  });
}
