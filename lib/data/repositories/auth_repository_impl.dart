import 'package:cloud_firestore/cloud_firestore.dart';
    import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../core/constants/app_constants.dart';
import '../../core/errors/error_mapper.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required fb.FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required FirebaseFunctions functions,
  })
      : _auth = auth,
        _firestore = firestore,
        _functions = functions;

  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection(FirebaseConstants.usersCollection);

  @override
  bool get isAuthenticated => _auth.currentUser != null;

  @override
  Stream<domain.User?> get authStateChanges => _auth.authStateChanges().asyncMap(
        (fb.User? user) async {
          if (user == null) return null;
          final result = await _fetchUserProfile(user.uid);
          return result.fold((_) => null, (u) => u);
        },
      );

  @override
  Future<Either<Failure, domain.User>> signIn({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        return const Left(AuthFailure(message: 'Authentication failed'));
      }
      final userResult = await _fetchUserProfile(uid);
      return await userResult.fold(
        (failure) async {
          if (failure is NotFoundFailure) {
            final fbUser = credential.user;
            final model = UserModel(
              id: uid,
              email: fbUser?.email ?? email.trim(),
              name: fbUser?.displayName?.isNotEmpty == true
                  ? fbUser!.displayName!
                  : (fbUser?.email ?? email.trim()),
              createdAt: DateTime.now(),
            );
            await _usersCol.doc(uid).set(model.toJson());
            return Right(model.toDomain());
          }
          return Left(failure);
        },
        (user) async => Right(user),
      );
    } on fb.FirebaseAuthException catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(
        ErrorMapper.mapFirebaseAuthError(e.code, e.message),
      ));
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, domain.User>> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final fbUser = credential.user;
      if (fbUser == null) {
        return const Left(AuthFailure(message: 'Signup failed'));
      }

      final displayName = name?.trim();
      if (displayName != null && displayName.isNotEmpty) {
        await fbUser.updateDisplayName(displayName);
      }

      final userModel = UserModel(
        id: fbUser.uid,
        email: fbUser.email ?? email.trim(),
        name: displayName?.isNotEmpty == true ? displayName! : (fbUser.email ?? ''),
        createdAt: DateTime.now(),
      );

      await _usersCol.doc(fbUser.uid).set(userModel.toJson());

      return Right(userModel.toDomain());
    } on fb.FirebaseAuthException catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(
        ErrorMapper.mapFirebaseAuthError(e.code, e.message),
      ));
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _auth.signOut();
      return const Right(unit);
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, domain.User>> getCurrentUser() async {
    final fbUser = _auth.currentUser;
    if (fbUser == null) {
      return const Left(UnauthenticatedFailure());
    }
    return _fetchUserProfile(fbUser.uid);
  }

  @override
  Future<Either<Failure, Unit>> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return const Right(unit);
    } on fb.FirebaseAuthException catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(
        ErrorMapper.mapFirebaseAuthError(e.code, e.message),
      ));
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendPasswordResetCode({required String email}) async {
    try {
      final callable = _functions.httpsCallable('sendPasswordResetCode');
      await callable.call(<String, dynamic>{
        'email': email.trim(),
      });
      return const Right(unit);
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'not-found') {
        return const Left(
          AuthFailure(
            message: 'Password reset backend is not deployed yet. Deploy Cloud Functions and try again.',
          ),
        );
      }
      return Left(AuthFailure(message: e.message ?? 'Unable to send reset code'));
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, String>> verifyPasswordResetCode({required String code}) async {
    try {
      final email = await _auth.verifyPasswordResetCode(code);
      return Right(email);
    } on fb.FirebaseAuthException catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(
        ErrorMapper.mapFirebaseAuthError(e.code, e.message),
      ));
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> confirmPasswordReset({required String code, required String newPassword}) async {
    try {
      await _auth.confirmPasswordReset(code: code, newPassword: newPassword);
      return const Right(unit);
    } on fb.FirebaseAuthException catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(
        ErrorMapper.mapFirebaseAuthError(e.code, e.message),
      ));
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> confirmPasswordResetCode({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final callable = _functions.httpsCallable('confirmPasswordResetCode');
      await callable.call(<String, dynamic>{
        'email': email.trim(),
        'code': code.trim(),
        'newPassword': newPassword,
      });
      return const Right(unit);
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'not-found') {
        return const Left(
          AuthFailure(
            message: 'Password reset backend is not deployed yet. Deploy Cloud Functions and try again.',
          ),
        );
      }
      return Left(AuthFailure(message: e.message ?? 'Unable to reset password'));
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  Future<Either<Failure, domain.User>> _fetchUserProfile(String uid) async {
    try {
      final snap = await _usersCol.doc(uid).get();
      if (!snap.exists || snap.data() == null) {
        return const Left(NotFoundFailure(message: 'User profile not found'));
      }
      final data = snap.data()!..putIfAbsent('id', () => uid);
      final model = UserModel.fromJson(data);
      return Right(model.toDomain());
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }
}
