import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart' hide Task;

import '../../core/constants/app_constants.dart';
import '../../core/errors/error_mapper.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/subtask.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/comment_model.dart';
import '../models/subtask_model.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _tasksCol =>
      _firestore.collection(FirebaseConstants.tasksCollection);
  CollectionReference<Map<String, dynamic>> get _subtasksCol =>
      _firestore.collection(FirebaseConstants.subtasksCollection);
  CollectionReference<Map<String, dynamic>> get _commentsCol =>
      _firestore.collection(FirebaseConstants.commentsCollection);

  // ── helpers ────────────────────────────────────────────────────────────

  Task _mapTaskDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data() ?? {});
    data['id'] = doc.id;
    return TaskModel.fromJson(data).toDomain();
  }

  Subtask _mapSubtaskDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data() ?? {});
    data['id'] = doc.id;
    return SubtaskModel.fromJson(data).toDomain();
  }

  Comment _mapCommentDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data() ?? {});
    data['id'] = doc.id;
    return CommentModel.fromJson(data).toDomain();
  }

  // ── Task Operations ────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Task>>> getTasks({
    required String projectId,
    String? status,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _tasksCol.where('projectId', isEqualTo: projectId);
      if (status != null && status.isNotEmpty) {
        query = query.where('columnId', isEqualTo: status);
      }
      final snap = await query.orderBy('order').get();
      return Right(snap.docs.map(_mapTaskDoc).toList());
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Task>> getTask({required String taskId}) async {
    try {
      final snap = await _tasksCol.doc(taskId).get();
      if (!snap.exists || snap.data() == null) {
        return const Left(NotFoundFailure(message: 'Task not found'));
      }
      return Right(_mapTaskDoc(snap));
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Task>> createTask({required Task task}) async {
    try {
      final docRef =
          task.id.isNotEmpty ? _tasksCol.doc(task.id) : _tasksCol.doc();
      final now = DateTime.now();
      final model = TaskModel.fromDomain(
        task.copyWith(
          id: docRef.id,
          createdAt: now,
          updatedAt: () => now,
        ),
      );
      await docRef.set(model.toJson());
      return Right(model.toDomain());
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Task>> updateTask({required Task task}) async {
    if (task.id.isEmpty) {
      return const Left(ValidationFailure(message: 'Task id is required'));
    }
    try {
      final docRef = _tasksCol.doc(task.id);
      final model =
          TaskModel.fromDomain(task.copyWith(updatedAt: () => DateTime.now()));
      await docRef.update(model.toJson());
      return Right(model.toDomain());
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTask({required String taskId}) async {
    try {
      await _tasksCol.doc(taskId).delete();
      // Remove associated subtasks and comments
      final subtaskSnap =
          await _subtasksCol.where('taskId', isEqualTo: taskId).get();
      for (final doc in subtaskSnap.docs) {
        await doc.reference.delete();
      }
      final commentSnap =
          await _commentsCol.where('taskId', isEqualTo: taskId).get();
      for (final doc in commentSnap.docs) {
        await doc.reference.delete();
      }
      return const Right(unit);
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Task>> updateTaskStatus({
    required String taskId,
    required String status,
  }) async {
    try {
      await _tasksCol.doc(taskId).update({
        'columnId': status,
        'updatedAt': DateTime.now(),
      });
      return getTask(taskId: taskId);
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTaskOrder({
    required String taskId,
    required int newOrder,
  }) async {
    try {
      await _tasksCol.doc(taskId).update({
        'order': newOrder,
        'updatedAt': DateTime.now(),
      });
      return const Right(unit);
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Task>> assignTask({
    required String taskId,
    required String userId,
  }) async {
    try {
      await _tasksCol.doc(taskId).update({
        'assigneeId': userId,
        'updatedAt': DateTime.now(),
      });
      return getTask(taskId: taskId);
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Task>> unassignTask({
    required String taskId,
    required String userId,
  }) async {
    try {
      await _tasksCol.doc(taskId).update({
        'assigneeId': null,
        'assigneeName': null,
        'assigneePhotoUrl': null,
        'updatedAt': DateTime.now(),
      });
      return getTask(taskId: taskId);
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksAssignedToUser({
    required String userId,
    String? projectId,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _tasksCol.where('assigneeId', isEqualTo: userId);
      if (projectId != null && projectId.isNotEmpty) {
        query = query.where('projectId', isEqualTo: projectId);
      }
      final snap = await query.get();
      return Right(snap.docs.map(_mapTaskDoc).toList());
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Stream<Either<Failure, List<Task>>> watchTasks({required String projectId}) {
    return _tasksCol
        .where('projectId', isEqualTo: projectId)
        .orderBy('order')
        .snapshots()
        .map<Either<Failure, List<Task>>>(
          (snap) => Right(snap.docs.map(_mapTaskDoc).toList()),
        )
        .handleError((Object e) =>
            Left<Failure, List<Task>>(ErrorMapper.mapExceptionToFailure(e)));
  }

  @override
  Stream<Either<Failure, Task>> watchTask({required String taskId}) {
    return _tasksCol.doc(taskId).snapshots().map<Either<Failure, Task>>(
      (snap) {
        if (!snap.exists || snap.data() == null) {
          return const Left(NotFoundFailure(message: 'Task not found'));
        }
        return Right(_mapTaskDoc(snap));
      },
    ).handleError((Object e) =>
        Left<Failure, Task>(ErrorMapper.mapExceptionToFailure(e)));
  }

  // ── Subtask Operations ─────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Subtask>>> getSubtasks(
      {required String taskId}) async {
    try {
      final snap = await _subtasksCol
          .where('taskId', isEqualTo: taskId)
          .orderBy('order')
          .get();
      return Right(snap.docs.map(_mapSubtaskDoc).toList());
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Subtask>> createSubtask(
      {required Subtask subtask}) async {
    try {
      final docRef = subtask.id.isNotEmpty
          ? _subtasksCol.doc(subtask.id)
          : _subtasksCol.doc();
      final now = DateTime.now();
      final model = SubtaskModel.fromDomain(
        subtask.copyWith(id: docRef.id, createdAt: now, updatedAt: () => now),
      );
      await docRef.set(model.toJson());
      // Increment totalSubtasks on the parent task
      await _tasksCol.doc(subtask.taskId).update({
        'totalSubtasks': FieldValue.increment(1),
        'updatedAt': now,
      });
      return Right(model.toDomain());
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Subtask>> updateSubtask(
      {required Subtask subtask}) async {
    try {
      final model = SubtaskModel.fromDomain(
          subtask.copyWith(updatedAt: () => DateTime.now()));
      await _subtasksCol.doc(subtask.id).update(model.toJson());
      return Right(model.toDomain());
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Subtask>> toggleSubtaskCompletion({
    required String subtaskId,
    required String taskId,
  }) async {
    try {
      final snap = await _subtasksCol.doc(subtaskId).get();
      if (!snap.exists || snap.data() == null) {
        return const Left(NotFoundFailure(message: 'Subtask not found'));
      }
      final current = _mapSubtaskDoc(snap);
      final toggled = current.copyWith(
        isCompleted: !current.isCompleted,
        updatedAt: () => DateTime.now(),
      );
      await snap.reference.update({
        'isCompleted': toggled.isCompleted,
        'updatedAt': toggled.updatedAt,
      });
      // Update completedSubtasks count on parent task
      await _tasksCol.doc(taskId).update({
        'completedSubtasks':
            FieldValue.increment(toggled.isCompleted ? 1 : -1),
        'updatedAt': DateTime.now(),
      });
      return Right(toggled);
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteSubtask({
    required String subtaskId,
    required String taskId,
  }) async {
    try {
      final snap = await _subtasksCol.doc(subtaskId).get();
      if (snap.exists) {
        final subtask = _mapSubtaskDoc(snap);
        await snap.reference.delete();
        await _tasksCol.doc(taskId).update({
          'totalSubtasks': FieldValue.increment(-1),
          if (subtask.isCompleted) 'completedSubtasks': FieldValue.increment(-1),
          'updatedAt': DateTime.now(),
        });
      }
      return const Right(unit);
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> reorderSubtasks({
    required String taskId,
    required List<String> subtaskIds,
  }) async {
    try {
      final batch = _firestore.batch();
      for (var i = 0; i < subtaskIds.length; i++) {
        batch.update(_subtasksCol.doc(subtaskIds[i]), {'order': i});
      }
      await batch.commit();
      return const Right(unit);
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  // ── Comment Operations ─────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Comment>>> getComments(
      {required String taskId}) async {
    try {
      final snap = await _commentsCol
          .where('taskId', isEqualTo: taskId)
          .orderBy('createdAt')
          .get();
      return Right(snap.docs.map(_mapCommentDoc).toList());
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Comment>> addComment(
      {required Comment comment}) async {
    try {
      final docRef = comment.id.isNotEmpty
          ? _commentsCol.doc(comment.id)
          : _commentsCol.doc();
      final now = DateTime.now();
      final model = CommentModel.fromDomain(
          comment.copyWith(id: docRef.id, createdAt: now));
      await docRef.set(model.toJson());
      // Increment commentCount on task
      await _tasksCol.doc(comment.taskId).update({
        'commentCount': FieldValue.increment(1),
        'updatedAt': now,
      });
      return Right(model.toDomain());
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Comment>> updateComment(
      {required Comment comment}) async {
    try {
      final model = CommentModel.fromDomain(
          comment.copyWith(updatedAt: () => DateTime.now()));
      await _commentsCol.doc(comment.id).update(model.toJson());
      return Right(model.toDomain());
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteComment({
    required String commentId,
    required String taskId,
  }) async {
    try {
      await _commentsCol.doc(commentId).delete();
      await _tasksCol.doc(taskId).update({
        'commentCount': FieldValue.increment(-1),
        'updatedAt': DateTime.now(),
      });
      return const Right(unit);
    } catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Stream<Either<Failure, List<Comment>>> watchComments(
      {required String taskId}) {
    return _commentsCol
        .where('taskId', isEqualTo: taskId)
        .orderBy('createdAt')
        .snapshots()
        .map<Either<Failure, List<Comment>>>(
          (snap) => Right(snap.docs.map(_mapCommentDoc).toList()),
        )
        .handleError((Object e) =>
            Left<Failure, List<Comment>>(ErrorMapper.mapExceptionToFailure(e)));
  }
}
