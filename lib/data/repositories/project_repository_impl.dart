import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/error_mapper.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/user.dart' as domain_user;
import '../../domain/repositories/project_repository.dart';
import '../models/app_notification_model.dart';
import '../models/project_model.dart';
import '../models/user_model.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  ProjectRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _projectsCol =>
      _firestore.collection(FirebaseConstants.projectsCollection);

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection(FirebaseConstants.usersCollection);

  CollectionReference<Map<String, dynamic>> get _notificationsCol =>
      _firestore.collection(FirebaseConstants.notificationsCollection);

  // ── helpers ──────────────────────────────────────────────────────────────

  Project _mapDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data() ?? {});
    data['id'] = doc.id;
    return ProjectModel.fromJson(data).toDomain();
  }

  Future<List<domain_user.User>> _fetchUsersByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final users = <domain_user.User>[];
    // Firestore 'whereIn' is limited to 10 items per query
    final chunks = <List<String>>[];
    for (var i = 0; i < ids.length; i += 10) {
      chunks.add(ids.sublist(i, i + 10 < ids.length ? i + 10 : ids.length));
    }
    for (final chunk in chunks) {
      final snap =
          await _usersCol.where(FieldPath.documentId, whereIn: chunk).get();
      for (final doc in snap.docs) {
        final data = Map<String, dynamic>.from(doc.data())
          ..putIfAbsent('id', () => doc.id);
        users.add(UserModel.fromJson(data).toDomain());
      }
    }
    return users;
  }

  Future<List<String>> _emailsToUserIds(List<String> emails) async {
    final ids = <String>[];
    for (final email in emails) {
      final snap = await _usersCol
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) ids.add(snap.docs.first.id);
    }
    return ids;
  }

  // ── interface ─────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Project>>> getProjects(
      {required String userId}) async {
    try {
      final snap = await _projectsCol
          .where('memberIds', arrayContains: userId)
          .orderBy('updatedAt', descending: true)
          .get();
      return Right(snap.docs.map(_mapDoc).toList());
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Project>> getProject(
      {required String projectId}) async {
    try {
      final snap = await _projectsCol.doc(projectId).get();
      if (!snap.exists || snap.data() == null) {
        return const Left(NotFoundFailure(message: 'Project not found'));
      }
      return Right(_mapDoc(snap));
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Project>> createProject(
      {required Project project}) async {
    try {
      final docRef = project.id.isNotEmpty
          ? _projectsCol.doc(project.id)
          : _projectsCol.doc();

      final now = DateTime.now();
      // Ensure owner is always in memberIds
      final memberIds = <String>{project.ownerId, ...project.memberIds}.toList();

      final model = ProjectModel(
        id: docRef.id,
        name: project.name,
        description: project.description,
        ownerId: project.ownerId,
        taskCount: project.taskCount,
        completedTasks: project.completedTasks,
        memberIds: memberIds,
        memberAvatars: project.memberAvatars,
        color: project.color,
        icon: project.icon,
        dueDate: project.dueDate,
        startDate: project.startDate,
        createdAt: now,
        updatedAt: now,
      );

      await docRef.set(model.toJson());
      return Right(model.toDomain());
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Project>> updateProject(
      {required Project project}) async {
    if (project.id.isEmpty) {
      return const Left(ValidationFailure(message: 'Project id is required'));
    }
    try {
      final docRef = _projectsCol.doc(project.id);
      final snap = await docRef.get();
      if (!snap.exists) {
        return const Left(NotFoundFailure(message: 'Project not found'));
      }

      final updated = project.copyWith(updatedAt: () => DateTime.now());
      final model = ProjectModel.fromDomain(updated);
      await docRef.update(model.toJson());
      return Right(model.toDomain());
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteProject(
      {required String projectId}) async {
    try {
      await _projectsCol.doc(projectId).delete();
      return const Right(unit);
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<domain_user.User>>> getProjectMembers(
      {required String projectId}) async {
    try {
      final projectResult = await getProject(projectId: projectId);
      return await projectResult.fold(
        (f) async => Left(f),
        (project) async {
          final ids = <String>{project.ownerId, ...project.memberIds}.toList();
          return Right(await _fetchUsersByIds(ids));
        },
      );
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Project>> inviteMember({
    required String projectId,
    required String userEmail,
  }) =>
      inviteMembers(projectId: projectId, userEmails: [userEmail]);

  @override
  Future<Either<Failure, Project>> inviteMembers({
    required String projectId,
    required List<String> userEmails,
  }) async {
    if (userEmails.isEmpty) {
      return const Left(ValidationFailure(message: 'No emails provided'));
    }
    try {
      final ids = await _emailsToUserIds(userEmails);
      if (ids.isEmpty) {
        return const Left(
            NotFoundFailure(message: 'No users found for the provided emails'));
      }
      final docRef = _projectsCol.doc(projectId);
      await docRef.update({
        'memberIds': FieldValue.arrayUnion(ids),
        'updatedAt': DateTime.now(),
      });
      final snap = await docRef.get();
      if (!snap.exists || snap.data() == null) {
        return const Left(NotFoundFailure(message: 'Project not found'));
      }
      return Right(_mapDoc(snap));
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Project>> removeMember({
    required String projectId,
    required String userId,
  }) async {
    try {
      final docRef = _projectsCol.doc(projectId);
      final snap = await docRef.get();
      if (!snap.exists || snap.data() == null) {
        return const Left(NotFoundFailure(message: 'Project not found'));
      }
      final project = _mapDoc(snap);
      if (project.ownerId == userId) {
        return const Left(
            PermissionDeniedFailure(message: 'Owner cannot be removed'));
      }
      await docRef.update({
        'memberIds': FieldValue.arrayRemove([userId]),
        'updatedAt': DateTime.now(),
      });
      final updated = await docRef.get();
      return Right(_mapDoc(updated));
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> leaveProject({
    required String projectId,
    required String userId,
  }) async {
    try {
      final docRef = _projectsCol.doc(projectId);
      final snap = await docRef.get();
      if (!snap.exists || snap.data() == null) {
        return const Left(NotFoundFailure(message: 'Project not found'));
      }
      final project = _mapDoc(snap);
      if (project.ownerId == userId) {
        return const Left(
            PermissionDeniedFailure(message: 'Owner cannot leave the project'));
      }
      await docRef.update({
        'memberIds': FieldValue.arrayRemove([userId]),
        'updatedAt': DateTime.now(),
      });
      return const Right(unit);
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Stream<Either<Failure, Project>> watchProject({required String projectId}) {
    return _projectsCol.doc(projectId).snapshots().map<Either<Failure, Project>>(
      (snap) {
        if (!snap.exists || snap.data() == null) {
          return const Left(NotFoundFailure(message: 'Project not found'));
        }
        return Right(_mapDoc(snap));
      },
    ).handleError(
        (Object e) => Left<Failure, Project>(ErrorMapper.mapExceptionToFailure(e)));
  }

  @override
  Stream<Either<Failure, List<Project>>> watchProjects({required String userId}) {
    return _projectsCol
        .where('memberIds', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map<Either<Failure, List<Project>>>(
          (snapshot) => Right(snapshot.docs.map(_mapDoc).toList()),
        )
        .handleError((Object e) =>
            Left<Failure, List<Project>>(ErrorMapper.mapExceptionToFailure(e)));
  }

  @override
  Future<Either<Failure, List<Project>>> getRecentProjects({
    required String userId,
    int limit = 5,
  }) async {
    try {
      final snap = await _projectsCol
          .where('memberIds', arrayContains: userId)
          .orderBy('updatedAt', descending: true)
          .limit(limit)
          .get();
      return Right(snap.docs.map(_mapDoc).toList());
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> markProjectAccessed(
      {required String projectId}) async {
    try {
      await _projectsCol
          .doc(projectId)
          .update({'updatedAt': DateTime.now()});
      return const Right(unit);
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Stream<Either<Failure, List<AppNotification>>> watchNotifications({
    required String userId,
  }) {
    return _notificationsCol
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map<Either<Failure, List<AppNotification>>>(
          (snapshot) => Right(
            snapshot.docs.map((doc) {
              final data = Map<String, dynamic>.from(doc.data())
                ..putIfAbsent('id', () => doc.id);
              return AppNotificationModel.fromJson(data).toDomain();
            }).toList(),
          ),
        )
        .handleError((Object e) =>
            Left<Failure, List<AppNotification>>(ErrorMapper.mapExceptionToFailure(e)));
  }

  @override
  Future<Either<Failure, Unit>> markNotificationRead({
    required String notificationId,
  }) async {
    try {
      await _notificationsCol.doc(notificationId).update({
        'isRead': true,
        'updatedAt': DateTime.now(),
      });
      return const Right(unit);
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAllNotificationsRead({
    required String userId,
  }) async {
    try {
      final snapshot = await _notificationsCol
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) {
        return const Right(unit);
      }

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'updatedAt': DateTime.now(),
        });
      }
      await batch.commit();
      return const Right(unit);
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteNotification({
    required String notificationId,
  }) async {
    try {
      await _notificationsCol.doc(notificationId).delete();
      return const Right(unit);
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, AppNotification>> createNotification({
    required AppNotification notification,
  }) async {
    try {
      final docRef =
          notification.id.isNotEmpty ? _notificationsCol.doc(notification.id) : _notificationsCol.doc();
      final now = DateTime.now();

      final model = AppNotificationModel.fromDomain(
        notification.copyWith(
          id: docRef.id,
          createdAt: notification.createdAt,
          updatedAt: () => now,
        ),
      );

      await docRef.set(model.toJson());
      return Right(model.toDomain());
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }
}
