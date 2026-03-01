import 'package:equatable/equatable.dart';

/// Task priority levels
enum TaskPriority { low, medium, high, urgent }

/// Task entity representing a task in the domain layer.
/// This is a pure business object without Firebase/API concerns.
class Task extends Equatable {
  final String id;
  final String projectId;
  final String title;
  final String? description;
  final String columnId; // 'todo', 'in_progress', 'done'
  final List<String> tags;
  final TaskPriority priority;
  final DateTime? dueDate;
  final DateTime? startDate;
  final int totalSubtasks;
  final int completedSubtasks;
  final int commentCount;
  final String? assigneeId;
  final String? assigneeName;
  final String? assigneePhotoUrl;
  final int order;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Task({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    required this.columnId,
    this.tags = const [],
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.startDate,
    this.totalSubtasks = 0,
    this.completedSubtasks = 0,
    this.commentCount = 0,
    this.assigneeId,
    this.assigneeName,
    this.assigneePhotoUrl,
    this.order = 0,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates an empty task
  factory Task.empty() => Task(
        id: '',
        projectId: '',
        title: '',
        columnId: 'todo',
        createdAt: DateTime.now(),
      );

  /// Check if task is empty/not loaded
  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;

  /// Progress text for subtasks
  String get progressText => '$completedSubtasks/$totalSubtasks';

  /// Check if task has subtasks
  bool get hasSubtasks => totalSubtasks > 0;

  /// Check if task has comments
  bool get hasComments => commentCount > 0;

  /// Check if task is assigned
  bool get isAssigned => assigneeId != null;

  /// Check if task is overdue
  bool get isOverdue => dueDate != null && DateTime.now().isAfter(dueDate!);

  /// Days remaining until due date
  int? get daysRemaining {
    if (dueDate == null) return null;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  /// Human-readable due date text
  String get dueDateText {
    if (dueDate == null) return 'No deadline';
    final days = daysRemaining!;
    if (days < 0) return 'Overdue by ${-days} days';
    if (days == 0) return 'Due today';
    if (days == 1) return 'Due tomorrow';
    return 'Due in $days days';
  }

  /// Check if task is completed (in done column)
  bool get isCompleted => columnId == 'done';

  /// Check if task is in progress
  bool get isInProgress => columnId == 'in_progress';

  /// Check if task is to do
  bool get isTodo => columnId == 'todo';

  Task copyWith({
    String? id,
    String? projectId,
    String? title,
    String? Function()? description,
    String? columnId,
    List<String>? tags,
    TaskPriority? priority,
    DateTime? Function()? dueDate,
    DateTime? Function()? startDate,
    int? totalSubtasks,
    int? completedSubtasks,
    int? commentCount,
    String? Function()? assigneeId,
    String? Function()? assigneeName,
    String? Function()? assigneePhotoUrl,
    int? order,
    DateTime? createdAt,
    DateTime? Function()? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description != null ? description() : this.description,
      columnId: columnId ?? this.columnId,
      tags: tags ?? this.tags,
      priority: priority ?? this.priority,
      dueDate: dueDate != null ? dueDate() : this.dueDate,
      startDate: startDate != null ? startDate() : this.startDate,
      totalSubtasks: totalSubtasks ?? this.totalSubtasks,
      completedSubtasks: completedSubtasks ?? this.completedSubtasks,
      commentCount: commentCount ?? this.commentCount,
      assigneeId: assigneeId != null ? assigneeId() : this.assigneeId,
      assigneeName: assigneeName != null ? assigneeName() : this.assigneeName,
      assigneePhotoUrl:
          assigneePhotoUrl != null ? assigneePhotoUrl() : this.assigneePhotoUrl,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        title,
        description,
        columnId,
        tags,
        priority,
        dueDate,
        startDate,
        totalSubtasks,
        completedSubtasks,
        commentCount,
        assigneeId,
        assigneeName,
        assigneePhotoUrl,
        order,
        createdAt,
        updatedAt,
      ];
}
