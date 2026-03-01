import 'package:dartz/dartz.dart' hide Task;
import '../../core/errors/failures.dart';
import '../entities/task.dart';
import '../entities/subtask.dart';
import '../entities/comment.dart';

/// Repository interface for task operations (tasks, subtasks, comments).
/// Implementations should use Firestore/Storage and map exceptions to [Failure].
abstract class TaskRepository {
  // ==================== Task Operations ====================

  /// Gets all tasks for a project. Optionally filter by status/column.
  Future<Either<Failure, List<Task>>> getTasks({
    required String projectId,
    String? status,
  });

  /// Gets a single task by ID.
  Future<Either<Failure, Task>> getTask({
    required String taskId,
  });

  /// Creates a new task and returns it with generated ID.
  Future<Either<Failure, Task>> createTask({
    required Task task,
  });

  /// Updates an existing task.
  Future<Either<Failure, Task>> updateTask({
    required Task task,
  });

  /// Deletes a task and its subtasks/comments.
  Future<Either<Failure, Unit>> deleteTask({
    required String taskId,
  });

  /// Updates a task status/column (e.g., todo -> in_progress -> done).
  Future<Either<Failure, Task>> updateTaskStatus({
    required String taskId,
    required String status,
  });

  /// Reorders a task within its column.
  Future<Either<Failure, Unit>> updateTaskOrder({
    required String taskId,
    required int newOrder,
  });

  /// Assigns a task to a user.
  Future<Either<Failure, Task>> assignTask({
    required String taskId,
    required String userId,
  });

  /// Removes task assignment.
  Future<Either<Failure, Task>> unassignTask({
    required String taskId,
    required String userId,
  });

  /// Gets tasks assigned to a user (optionally filtered by project).
  Future<Either<Failure, List<Task>>> getTasksAssignedToUser({
    required String userId,
    String? projectId,
  });

  /// Watches all tasks for a project in real time.
  Stream<Either<Failure, List<Task>>> watchTasks({
    required String projectId,
  });

  /// Watches a single task in real time.
  Stream<Either<Failure, Task>> watchTask({
    required String taskId,
  });

  // ==================== Subtask Operations ====================

  Future<Either<Failure, List<Subtask>>> getSubtasks({
    required String taskId,
  });

  Future<Either<Failure, Subtask>> createSubtask({
    required Subtask subtask,
  });

  Future<Either<Failure, Subtask>> updateSubtask({
    required Subtask subtask,
  });

  Future<Either<Failure, Subtask>> toggleSubtaskCompletion({
    required String subtaskId,
    required String taskId,
  });

  Future<Either<Failure, Unit>> deleteSubtask({
    required String subtaskId,
    required String taskId,
  });

  Future<Either<Failure, Unit>> reorderSubtasks({
    required String taskId,
    required List<String> subtaskIds,
  });

  // ==================== Comment Operations ====================

  Future<Either<Failure, List<Comment>>> getComments({
    required String taskId,
  });

  Future<Either<Failure, Comment>> addComment({
    required Comment comment,
  });

  Future<Either<Failure, Comment>> updateComment({
    required Comment comment,
  });

  Future<Either<Failure, Unit>> deleteComment({
    required String commentId,
    required String taskId,
  });

  Stream<Either<Failure, List<Comment>>> watchComments({
    required String taskId,
  });
}
