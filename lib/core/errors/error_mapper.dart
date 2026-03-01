import 'package:dartz/dartz.dart';

import 'exceptions.dart';
import 'failures.dart';

/// Maps exceptions to their corresponding failures.
/// Used in repository implementations to convert caught exceptions.
class ErrorMapper {
  ErrorMapper._();

  /// Maps any exception to a Failure
  static Failure mapExceptionToFailure(dynamic exception) {
    if (exception is AppException) {
      return _mapAppExceptionToFailure(exception);
    }
    
    // Handle common Dart/Flutter exceptions
    if (exception is FormatException) {
      return UnexpectedResponseFailure(message: exception.message);
    }
    
    // Default to unknown failure
    return UnknownFailure(
      message: exception?.toString() ?? 'An unexpected error occurred',
    );
  }

  /// Maps AppException subtypes to Failure subtypes
  static Failure _mapAppExceptionToFailure(AppException exception) {
    // Server exceptions
    if (exception is ServerException) {
      return ServerFailure(message: exception.message, code: exception.code);
    }
    if (exception is UnexpectedResponseException) {
      return UnexpectedResponseFailure(message: exception.message, code: exception.code);
    }
    if (exception is TimeoutException) {
      return TimeoutFailure(message: exception.message, code: exception.code);
    }
    
    // Network exceptions
    if (exception is NetworkException) {
      return NetworkFailure(message: exception.message, code: exception.code);
    }
    
    // Cache exceptions
    if (exception is CacheNotFoundException) {
      return CacheNotFoundFailure(message: exception.message, code: exception.code);
    }
    if (exception is CacheException) {
      return CacheFailure(message: exception.message, code: exception.code);
    }
    
    // Auth exceptions - more specific first
    if (exception is InvalidCredentialsException) {
      return InvalidCredentialsFailure(message: exception.message, code: exception.code);
    }
    if (exception is UnauthenticatedException) {
      return UnauthenticatedFailure(message: exception.message, code: exception.code);
    }
    if (exception is SessionExpiredException) {
      return SessionExpiredFailure(message: exception.message, code: exception.code);
    }
    if (exception is EmailAlreadyInUseException) {
      return EmailAlreadyInUseFailure(message: exception.message, code: exception.code);
    }
    if (exception is AccountDisabledException) {
      return AccountDisabledFailure(message: exception.message, code: exception.code);
    }
    if (exception is AuthException) {
      return AuthFailure(message: exception.message, code: exception.code);
    }
    
    // Validation exceptions
    if (exception is ValidationException) {
      return ValidationFailure(
        message: exception.message, 
        code: exception.code, 
        fieldErrors: exception.fieldErrors,
      );
    }
    
    // Permission exceptions
    if (exception is PermissionDeniedException) {
      return PermissionDeniedFailure(message: exception.message, code: exception.code);
    }
    if (exception is NotFoundException) {
      return NotFoundFailure(message: exception.message, code: exception.code);
    }
    
    // Firebase exceptions
    if (exception is FirebaseAppException) {
      return FirebaseFailure(message: exception.message, code: exception.code);
    }
    
    // Default case
    return UnknownFailure(message: exception.message);
  }


  /// Maps Firebase Auth error codes to appropriate exceptions
  static AppException mapFirebaseAuthError(String code, [String? message]) {
    switch (code) {
      case 'user-not-found':
        return InvalidCredentialsException(
          message: message ?? 'No account found with this email',
        );
      case 'wrong-password':
        return const InvalidCredentialsException(
          message: 'Invalid email or password',
        );
      case 'invalid-email':
        return ValidationException(
          message: message ?? 'Invalid email format',
          fieldErrors: const {'email': 'Invalid email format'},
        );
      case 'email-already-in-use':
        return EmailAlreadyInUseException(
          message: message ?? 'Email is already registered',
        );
      case 'weak-password':
        return ValidationException(
          message: message ?? 'Password is too weak',
          fieldErrors: const {'password': 'Password is too weak'},
        );
      case 'user-disabled':
        return AccountDisabledException(
          message: message ?? 'Account has been disabled',
        );
      case 'operation-not-allowed':
        return const PermissionDeniedException(
          message: 'Operation not allowed',
        );
      case 'too-many-requests':
        return const ServerException(
          message: 'Too many attempts, please try again later',
          code: 429,
        );
      case 'network-request-failed':
        return const NetworkException(
          message: 'Network request failed',
        );
      case 'expired-action-code':
        return const SessionExpiredException(
          message: 'Action code has expired',
        );
      case 'invalid-action-code':
        return const ValidationException(
          message: 'Invalid action code',
        );
      default:
        return ServerException(
          message: message ?? 'Authentication error occurred',
        );
    }
  }

  /// Maps HTTP status codes to appropriate exceptions
  static AppException mapHttpStatusCode(int statusCode, [String? message]) {
    if (statusCode == 400) {
      return ValidationException(
        message: message ?? 'Bad request',
        code: statusCode,
      );
    }
    if (statusCode == 401) {
      return UnauthenticatedException(
        message: message ?? 'Unauthorized',
        code: statusCode,
      );
    }
    if (statusCode == 403) {
      return PermissionDeniedException(
        message: message ?? 'Forbidden',
        code: statusCode,
      );
    }
    if (statusCode == 404) {
      return NotFoundException(
        message: message ?? 'Not found',
        code: statusCode,
      );
    }
    if (statusCode == 408) {
      return TimeoutException(
        message: message ?? 'Request timeout',
        code: statusCode,
      );
    }
    if (statusCode == 409) {
      return ServerException(
        message: message ?? 'Conflict',
        code: statusCode,
      );
    }
    if (statusCode == 422) {
      return ValidationException(
        message: message ?? 'Validation error',
        code: statusCode,
      );
    }
    if (statusCode == 429) {
      return ServerException(
        message: message ?? 'Too many requests',
        code: statusCode,
      );
    }
    if (statusCode >= 500) {
      return ServerException(
        message: message ?? 'Server error',
        code: statusCode,
      );
    }
    return ServerException(
      message: message ?? 'HTTP error occurred',
      code: statusCode,
    );
  }
}

/// Extension on Future to easily convert to Either
extension FutureEitherX<T> on Future<T> {
  /// Converts a Future to Either<Failure, T>
  /// Catches any exception and maps it to a Failure
  Future<Either<Failure, T>> toEither() async {
    try {
      final result = await this;
      return Right(result);
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }
}

/// Extension to easily work with Either types
extension EitherX<L, R> on Either<L, R> {
  /// Gets the right value or throws
  R getOrThrow() {
    return fold(
      (l) => throw Exception('Expected Right but got Left: $l'),
      (r) => r,
    );
  }

  /// Gets the right value or returns null
  R? getOrNull() {
    return fold(
      (l) => null,
      (r) => r,
    );
  }

  /// Returns true if this is a Left
  bool get isLeft => fold((_) => true, (_) => false);

  /// Returns true if this is a Right
  bool get isRight => fold((_) => false, (_) => true);
}
