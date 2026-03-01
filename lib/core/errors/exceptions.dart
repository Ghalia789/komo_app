/// Base exception class for the application
abstract class AppException implements Exception {
  final String message;
  final int? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

// ==================== Server Exceptions ====================

/// Exception for server/API errors
class ServerException extends AppException {
  const ServerException({
    super.message = 'Server error occurred',
    super.code,
    super.originalError,
  });
}

/// Exception when server returns unexpected response
class UnexpectedResponseException extends AppException {
  const UnexpectedResponseException({
    super.message = 'Unexpected response from server',
    super.code,
    super.originalError,
  });
}

/// Exception for request timeout
class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'Request timed out',
    super.code,
    super.originalError,
  });
}

// ==================== Network Exceptions ====================

/// Exception for network connectivity issues
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection',
    super.code,
    super.originalError,
  });
}

// ==================== Cache Exceptions ====================

/// Exception for local storage/cache errors
class CacheException extends AppException {
  const CacheException({
    super.message = 'Cache error occurred',
    super.code,
    super.originalError,
  });
}

/// Exception when cached data is not found
class CacheNotFoundException extends AppException {
  const CacheNotFoundException({
    super.message = 'No cached data found',
    super.code,
    super.originalError,
  });
}

// ==================== Auth Exceptions ====================

/// Exception for authentication errors
class AuthException extends AppException {
  const AuthException({
    super.message = 'Authentication failed',
    super.code,
    super.originalError,
  });
}

/// Exception when credentials are invalid
class InvalidCredentialsException extends AppException {
  const InvalidCredentialsException({
    super.message = 'Invalid email or password',
    super.code,
    super.originalError,
  });
}

/// Exception when user is not authenticated
class UnauthenticatedException extends AppException {
  const UnauthenticatedException({
    super.message = 'User is not authenticated',
    super.code,
    super.originalError,
  });
}

/// Exception when session has expired
class SessionExpiredException extends AppException {
  const SessionExpiredException({
    super.message = 'Session has expired',
    super.code,
    super.originalError,
  });
}

/// Exception when email is already in use
class EmailAlreadyInUseException extends AppException {
  const EmailAlreadyInUseException({
    super.message = 'Email is already registered',
    super.code,
    super.originalError,
  });
}

/// Exception when account is disabled
class AccountDisabledException extends AppException {
  const AccountDisabledException({
    super.message = 'Account has been disabled',
    super.code,
    super.originalError,
  });
}

// ==================== Validation Exceptions ====================

/// Exception for validation errors
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    super.message = 'Validation failed',
    super.code,
    super.originalError,
    this.fieldErrors,
  });
}

// ==================== Permission Exceptions ====================

/// Exception when permission is denied
class PermissionDeniedException extends AppException {
  const PermissionDeniedException({
    super.message = 'Permission denied',
    super.code,
    super.originalError,
  });
}

/// Exception when resource is not found
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Resource not found',
    super.code,
    super.originalError,
  });
}

// ==================== Firebase Exceptions ====================

/// Exception for Firebase specific errors
class FirebaseAppException extends AppException {
  const FirebaseAppException({
    super.message = 'Firebase error occurred',
    super.code,
    super.originalError,
  });
}
