import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_storage/firebase_storage.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/error_mapper.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    required FirebaseFirestore firestore,
    required fb.FirebaseAuth auth,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _auth = auth,
        _storage = storage;

  final FirebaseFirestore _firestore;
  final fb.FirebaseAuth _auth;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection(FirebaseConstants.usersCollection);

  @override
  Future<Either<Failure, domain.User>> getUser({required String userId}) async {
    try {
      final doc = await _usersCol.doc(userId).get();
      if (!doc.exists || doc.data() == null) {
        return const Left(NotFoundFailure(message: 'User not found'));
      }
      final data = doc.data()!..putIfAbsent('id', () => userId);
      final model = UserModel.fromJson(data);
      return Right(model.toDomain());
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, domain.User>> getCurrentUserProfile() async {
    final fbUser = _auth.currentUser;
    if (fbUser == null) {
      return const Left(UnauthenticatedFailure());
    }
    return getUser(userId: fbUser.uid);
  }

  @override
  Future<Either<Failure, domain.User>> createUserProfile({required domain.User user}) async {
    if (user.id.isEmpty) {
      return const Left(ValidationFailure(message: 'User id missing'));
    }
    try {
      final model = UserModel.fromDomain(user);
      final data = model.toJson()
        ..['createdAt'] = FieldValue.serverTimestamp()
        ..['updatedAt'] = FieldValue.serverTimestamp();
      await _usersCol.doc(user.id).set(data, SetOptions(merge: true));
      return getUser(userId: user.id);
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, domain.User>> updateProfile({required domain.User user}) async {
    if (user.id.isEmpty) {
      return const Left(ValidationFailure(message: 'User id missing'));
    }
    try {
      final model = UserModel.fromDomain(user);
      final data = model.toJson()
        ..remove('createdAt')
        ..['updatedAt'] = FieldValue.serverTimestamp();
      await _usersCol.doc(user.id).set(data, SetOptions(merge: true));
      return getUser(userId: user.id);
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, domain.User>> updateProfileFields({
    required String userId,
    String? name,
    String? jobTitle,
    String? company,
    String? avatarUrl,
  }) async {
    if (userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User id missing'));
    }

    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (jobTitle != null) data['jobTitle'] = jobTitle;
    if (company != null) data['company'] = company;
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
    data['updatedAt'] = FieldValue.serverTimestamp();

    try {
      await _usersCol.doc(userId).set(data, SetOptions(merge: true));
      return getUser(userId: userId);
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage
          .ref()
          .child('${FirebaseConstants.profileImagesPath}/$userId/$fileName');

      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();

      await _usersCol.doc(userId).set(
        {
          'avatarUrl': url,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      return Right(url);
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAccount({required String userId}) async {
    try {
      await _usersCol.doc(userId).delete();
      if (_auth.currentUser?.uid == userId) {
        await _auth.currentUser?.delete();
      }
      return const Right(unit);
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, bool>> userProfileExists({required String userId}) async {
    try {
      final doc = await _usersCol.doc(userId).get();
      return Right(doc.exists);
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<domain.User>>> getUsersByIds({
    required List<String> userIds,
  }) async {
    try {
      if (userIds.isEmpty) return const Right([]);

      const chunkSize = 10; // Firestore whereIn limit
      final chunks = <List<String>>[];
      for (var i = 0; i < userIds.length; i += chunkSize) {
        chunks.add(userIds.sublist(i, i + chunkSize > userIds.length ? userIds.length : i + chunkSize));
      }

      final List<domain.User> users = [];
      for (final chunk in chunks) {
        final snap = await _usersCol.where(FieldPath.documentId, whereIn: chunk).get();
        for (final doc in snap.docs) {
          final data = doc.data()..putIfAbsent('id', () => doc.id);
          users.add(UserModel.fromJson(data).toDomain());
        }
      }

      return Right(users);
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<domain.User>>> searchUsers({
    required String query,
    int limit = 10,
  }) async {
    try {
      final normalized = query.toLowerCase();
      final snap = await _usersCol.limit(limit).get();

      final users = snap.docs
          .map((doc) {
            final data = doc.data()..putIfAbsent('id', () => doc.id);
            return UserModel.fromJson(data).toDomain();
          })
          .where((user) =>
              user.name.toLowerCase().contains(normalized) ||
              user.email.toLowerCase().contains(normalized))
          .toList();

      return Right(users);
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }
}
