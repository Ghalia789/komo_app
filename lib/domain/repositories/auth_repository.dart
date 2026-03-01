import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';

/// Repository interface for authentication operations.
/// 
/// Implementations should handle Firebase Auth operations and convert
/// exceptions to appropriate [Failure] types.
abstract class AuthRepository {
  /// Signs in a user with email and password.
  /// 
  /// Returns [User] on success, [AuthFailure] on authentication errors,
  /// or [NetworkFailure] if there's no internet connection.
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  });

  /// Creates a new user account with email and password.
  /// 
  /// Returns [User] on success, [AuthFailure] if email is already in use,
  /// or [ValidationFailure] for invalid email/password format.
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    String? name,
  });

  /// Signs out the current user.
  /// 
  /// Returns [Unit] (void) on success.
  Future<Either<Failure, Unit>> signOut();

  /// Gets the currently authenticated user.
  /// 
  /// Returns [User] if authenticated, [AuthFailure] if not authenticated.
  Future<Either<Failure, User>> getCurrentUser();

  /// Sends a password reset email to the given address.
  /// 
  /// Returns [Unit] on success (even if email doesn't exist for security).
  Future<Either<Failure, Unit>> sendPasswordResetEmail({
    required String email,
  });

  /// Verifies a password reset code is valid.
  /// 
  /// Returns the email address associated with the code on success.
  Future<Either<Failure, String>> verifyPasswordResetCode({
    required String code,
  });

  /// Confirms password reset with the code and new password.
  /// 
  /// Returns [Unit] on success.
  Future<Either<Failure, Unit>> confirmPasswordReset({
    required String code,
    required String newPassword,
  });

  /// Checks if a user is currently authenticated.
  /// 
  /// This is a synchronous check of the current auth state.
  bool get isAuthenticated;

  /// Stream of authentication state changes.
  /// 
  /// Emits [User] when signed in, null when signed out.
  Stream<User?> get authStateChanges;
}
