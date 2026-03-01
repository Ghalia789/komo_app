import 'package:equatable/equatable.dart';

/// Project entity representing a project in the domain layer.
/// This is a pure business object without Firebase/API concerns.
class Project extends Equatable {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final int taskCount;
  final int completedTasks;
  final List<String> memberIds;
  final List<String> memberAvatars;
  final String color;
  final String? icon;
  final DateTime? dueDate;
  final DateTime? startDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    this.taskCount = 0,
    this.completedTasks = 0,
    this.memberIds = const [],
    this.memberAvatars = const [],
    required this.color,
    this.icon,
    this.dueDate,
    this.startDate,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates an empty project (for initial state)
  factory Project.empty() => Project(
        id: '',
        name: '',
        description: '',
        ownerId: '',
        color: 'purple',
        createdAt: DateTime.now(),
      );

  /// Check if project is empty/not loaded
  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;

  /// Progress percentage (0.0 to 1.0)
  double get progress =>
      taskCount > 0 ? completedTasks / taskCount : 0.0;

  /// Progress percentage as int (0 to 100)
  int get progressPercent => (progress * 100).round();

  /// Check if project is overdue
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
    if (days < 0) return 'Overdue';
    if (days == 0) return 'Due today';
    if (days == 1) return 'Due tomorrow';
    return 'Due in $days days';
  }

  /// Summary description for display
  String get summaryDescription => '$taskCount tasks • $dueDateText';

  /// Number of team members
  int get memberCount => memberIds.length;

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    int? taskCount,
    int? completedTasks,
    List<String>? memberIds,
    List<String>? memberAvatars,
    String? color,
    String? Function()? icon,
    DateTime? Function()? dueDate,
    DateTime? Function()? startDate,
    DateTime? createdAt,
    DateTime? Function()? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      taskCount: taskCount ?? this.taskCount,
      completedTasks: completedTasks ?? this.completedTasks,
      memberIds: memberIds ?? this.memberIds,
      memberAvatars: memberAvatars ?? this.memberAvatars,
      color: color ?? this.color,
      icon: icon != null ? icon() : this.icon,
      dueDate: dueDate != null ? dueDate() : this.dueDate,
      startDate: startDate != null ? startDate() : this.startDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        ownerId,
        taskCount,
        completedTasks,
        memberIds,
        memberAvatars,
        color,
        icon,
        dueDate,
        startDate,
        createdAt,
        updatedAt,
      ];
}
