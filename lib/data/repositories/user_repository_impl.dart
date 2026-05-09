import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
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

  CollectionReference<Map<String, dynamic>> get _projectsCol =>
      _firestore.collection(FirebaseConstants.projectsCollection);

  CollectionReference<Map<String, dynamic>> get _tasksCol =>
      _firestore.collection(FirebaseConstants.tasksCollection);

  CollectionReference<Map<String, dynamic>> get _subtasksCol =>
      _firestore.collection(FirebaseConstants.subtasksCollection);

  CollectionReference<Map<String, dynamic>> get _commentsCol =>
      _firestore.collection(FirebaseConstants.commentsCollection);

  CollectionReference<Map<String, dynamic>> get _notificationsCol =>
      _firestore.collection(FirebaseConstants.notificationsCollection);

  CollectionReference<Map<String, dynamic>> get _invitationsCol =>
      _firestore.collection(FirebaseConstants.invitationsCollection);

  String _stripGsPrefix(String value) {
    final trimmed = value.trim();
    if (trimmed.startsWith('gs://')) {
      return trimmed.substring(5);
    }
    return trimmed;
  }

  List<String> _candidateBuckets() {
    final options = Firebase.app().options;
    final projectId = options.projectId.trim();
    final configuredRaw = options.storageBucket?.trim() ?? '';
    final configured = _stripGsPrefix(configuredRaw);

    final candidates = <String>{};
    if (configured.isNotEmpty) {
      candidates.add(configured);
    }
    if (projectId.isNotEmpty) {
      candidates.add('$projectId.appspot.com');
      candidates.add('$projectId.firebasestorage.app');
    }
    return candidates.toList();
  }

  List<FirebaseStorage> _candidateStorageInstances() {
    final instances = <FirebaseStorage>{_storage};
    for (final bucket in _candidateBuckets()) {
      instances.add(FirebaseStorage.instanceFor(bucket: 'gs://$bucket'));
    }
    return instances.toList();
  }

  Future<void> _deleteByQuery(Query<Map<String, dynamic>> query) async {
    final snapshot = await query.get();
    if (snapshot.docs.isEmpty) return;

    var batch = _firestore.batch();
    var count = 0;
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
      count++;
      if (count >= 400) {
        await batch.commit();
        batch = _firestore.batch();
        count = 0;
      }
    }

    if (count > 0) {
      await batch.commit();
    }
  }

  Future<void> _hardDeleteProjectCascade(String projectId) async {
    final tasksSnap = await _tasksCol.where('projectId', isEqualTo: projectId).get();
    final taskIds = tasksSnap.docs.map((d) => d.id).toList();

    for (var i = 0; i < taskIds.length; i += 10) {
      final chunk = taskIds.sublist(i, i + 10 < taskIds.length ? i + 10 : taskIds.length);
      await _deleteByQuery(_subtasksCol.where('taskId', whereIn: chunk));
      await _deleteByQuery(_commentsCol.where('taskId', whereIn: chunk));
      await _deleteByQuery(_notificationsCol.where('relatedTaskId', whereIn: chunk));
    }

    await _deleteByQuery(_tasksCol.where('projectId', isEqualTo: projectId));
    await _deleteByQuery(_invitationsCol.where('projectId', isEqualTo: projectId));
    await _deleteByQuery(_notificationsCol.where('relatedProjectId', isEqualTo: projectId));
    await _projectsCol.doc(projectId).delete();
  }

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
    String? role,
    String? avatarUrl,
  }) async {
    if (userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User id missing'));
    }

    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (jobTitle != null) data['jobTitle'] = jobTitle;
    if (company != null) data['company'] = company;
    if (role != null) data['role'] = role;
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
    if (!imageFile.existsSync()) {
      return const Left(
        ValidationFailure(message: 'Selected image file no longer exists.'),
      );
    }

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      for (final storage in _candidateStorageInstances()) {
        try {
          final ref = storage
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
          // Try next candidate bucket.
        }
      }

      return Left(
        ValidationFailure(
          message:
              'Avatar upload failed for all configured storage buckets. Verify Firebase Storage bucket configuration for this app.',
        ),
      );
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAccount({required String userId}) async {
    return hardDeleteAccount(userId: userId);
  }

  @override
  Future<Either<Failure, Unit>> softDeleteAccount({required String userId}) async {
    try {
      await _usersCol.doc(userId).set({
        'isSoftDeleted': true,
        'accountStatus': 'archived',
        'softDeletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return const Right(unit);
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> restoreAccount({required String userId}) async {
    try {
      await _usersCol.doc(userId).set({
        'isSoftDeleted': false,
        'accountStatus': 'active',
        'softDeletedAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return const Right(unit);
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> hardDeleteAccount({required String userId}) async {
    try {
      final ownedProjects = await _projectsCol.where('ownerId', isEqualTo: userId).get();
      for (final project in ownedProjects.docs) {
        await _hardDeleteProjectCascade(project.id);
      }

      final memberProjects = await _projectsCol.where('memberIds', arrayContains: userId).get();
      for (final project in memberProjects.docs) {
        if (project.get('ownerId') == userId) continue;
        await project.reference.update({
          'memberIds': FieldValue.arrayRemove([userId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      final assignedTasks = await _tasksCol.where('assigneeId', isEqualTo: userId).get();
      for (final taskDoc in assignedTasks.docs) {
        await taskDoc.reference.update({
          'assigneeId': null,
          'assigneeName': null,
          'assigneePhotoUrl': null,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await _deleteByQuery(_commentsCol.where('authorId', isEqualTo: userId));
      await _deleteByQuery(_notificationsCol.where('userId', isEqualTo: userId));
      await _deleteByQuery(_invitationsCol.where('invitedByUserId', isEqualTo: userId));
      await _deleteByQuery(_invitationsCol.where('invitedUserId', isEqualTo: userId));
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
