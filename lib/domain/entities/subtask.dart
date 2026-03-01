import 'package:equatable/equatable.dart';

/// Subtask entity representing a subtask in the domain layer.
/// This is a pure business object without Firebase/API concerns.
class Subtask extends Equatable {
  final String id;
  final String taskId;
  final String title;
  final bool isCompleted;
  final DateTime? dueDate;
  final int order;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Subtask({
    required this.id,
    required this.taskId,
    required this.title,
    this.isCompleted = false,
    this.dueDate,
    this.order = 0,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates an empty subtask
  factory Subtask.empty() => Subtask(
        id: '',
        taskId: '',
        title: '',
        createdAt: DateTime.now(),
      );

  /// Check if subtask is empty/not loaded
  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;

  /// Check if subtask is overdue
  bool get isOverdue =>
      dueDate != null && !isCompleted && DateTime.now().isAfter(dueDate!);

  Subtask copyWith({
    String? id,
    String? taskId,
    String? title,
    bool? isCompleted,
    DateTime? Function()? dueDate,
    int? order,
    DateTime? createdAt,
    DateTime? Function()? updatedAt,
  }) {
    return Subtask(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate != null ? dueDate() : this.dueDate,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        title,
        isCompleted,
        dueDate,
        order,
        createdAt,
        updatedAt,
      ];
}
