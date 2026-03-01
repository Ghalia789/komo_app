import 'package:equatable/equatable.dart';

/// Base failure class for functional error handling with Either pattern.
/// All failures should extend this class.
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

// ==================== Server Failures ====================

/// Failure for server/API related errors
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Server error occurred',
    super.code,
  });
}

/// Failure when server returns unexpected response
class UnexpectedResponseFailure extends Failure {
  const UnexpectedResponseFailure({
    super.message = 'Unexpected response from server',
    super.code,
  });
}

/// Failure for timeout errors
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Request timed out',
    super.code,
  });
}

// ==================== Network Failures ====================

/// Failure for network connectivity issues
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection',
    super.code,
  });
}

// ==================== Cache Failures ====================

/// Failure for local storage/cache errors
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Cache error occurred',
    super.code,
  });
}

/// Failure when cached data is not found
class CacheNotFoundFailure extends Failure {
  const CacheNotFoundFailure({
    super.message = 'No cached data found',
    super.code,
  });
}

// ==================== Auth Failures ====================

/// Failure for authentication errors
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Authentication failed',
    super.code,
  });
}

/// Failure when user credentials are invalid
class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure({
    super.message = 'Invalid email or password',
    super.code,
  });
}

/// Failure when user is not authenticated
class UnauthenticatedFailure extends Failure {
  const UnauthenticatedFailure({
    super.message = 'User is not authenticated',
    super.code,
  });
}

/// Failure when user session has expired
class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure({
    super.message = 'Session has expired, please login again',
    super.code,
  });
}

/// Failure when email is already in use
class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure({
    super.message = 'Email is already registered',
    super.code,
  });
}

/// Failure when user account is disabled
class AccountDisabledFailure extends Failure {
  const AccountDisabledFailure({
    super.message = 'Account has been disabled',
    super.code,
  });
}

// ==================== Validation Failures ====================

/// Failure for input validation errors
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    super.message = 'Validation failed',
    super.code,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

// ==================== Permission Failures ====================

/// Failure when user lacks permission
class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure({
    super.message = 'Permission denied',
    super.code,
  });
}

/// Failure when resource is not found
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Resource not found',
    super.code,
  });
}

// ==================== Firebase Failures ====================

/// Failure for Firebase specific errors
class FirebaseFailure extends Failure {
  const FirebaseFailure({
    super.message = 'Firebase error occurred',
    super.code,
  });
}

// ==================== Unknown Failures ====================

/// Failure for unexpected/unknown errors
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred',
    super.code,
  });
}
