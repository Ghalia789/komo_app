import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/task.dart';

class TaskModel {
  final String id;
  final String projectId; // Link to parent project
  final String title;
  final String? description;
  final String columnId; // 'todo', 'in_progress', 'done'
  final List<String> tags; // ['Design', 'Research', etc.]
  final TaskPriority priority;
  final DateTime? dueDate;
  final DateTime? startDate;
  final int totalSubtasks;
  final int completedSubtasks;
  final int commentCount;
  final String? assigneeName; // Person assigned to this task
  final String? assigneeId;
  final String? assigneePhotoUrl; // Avatar URL
  final int order;
  final Color leftBorderColor; // Left accent color for UI
  final DateTime createdAt;
  final DateTime? updatedAt;

  TaskModel({
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
    this.assigneeName,
    this.assigneeId,
    this.assigneePhotoUrl,
    this.order = 0,
    Color? leftBorderColor,
    required this.createdAt,
    this.updatedAt,
  }) : leftBorderColor = leftBorderColor ?? _priorityColor(priority);

  factory TaskModel.fromDomain(Task task) => TaskModel(
        id: task.id,
        projectId: task.projectId,
        title: task.title,
        description: task.description,
        columnId: task.columnId,
        tags: task.tags,
        priority: task.priority,
        dueDate: task.dueDate,
        startDate: task.startDate,
        totalSubtasks: task.totalSubtasks,
        completedSubtasks: task.completedSubtasks,
        commentCount: task.commentCount,
        assigneeName: task.assigneeName,
        assigneeId: task.assigneeId,
        assigneePhotoUrl: task.assigneePhotoUrl,
        order: task.order,
        leftBorderColor: _priorityColor(task.priority),
        createdAt: task.createdAt,
        updatedAt: task.updatedAt,
      );

  Task toDomain() => Task(
        id: id,
        projectId: projectId,
        title: title,
        description: description,
        columnId: columnId,
        tags: tags,
        priority: priority,
        dueDate: dueDate,
        startDate: startDate,
        totalSubtasks: totalSubtasks,
        completedSubtasks: completedSubtasks,
        commentCount: commentCount,
        assigneeId: assigneeId,
        assigneeName: assigneeName,
        assigneePhotoUrl: assigneePhotoUrl,
        order: order,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'] as String? ?? '',
        projectId: json['projectId'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        columnId: json['columnId'] as String? ?? 'todo',
        tags: (json['tags'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        priority: _priorityFromString(json['priority'] as String?),
        dueDate: _fromTimestamp(json['dueDate']),
        startDate: _fromTimestamp(json['startDate']),
        totalSubtasks: json['totalSubtasks'] as int? ?? 0,
        completedSubtasks: json['completedSubtasks'] as int? ?? 0,
        commentCount: json['commentCount'] as int? ?? 0,
        assigneeName: json['assigneeName'] as String?,
        assigneeId: json['assigneeId'] as String?,
        assigneePhotoUrl: json['assigneePhotoUrl'] as String?,
        order: json['order'] as int? ?? 0,
        leftBorderColor: json['leftBorderColor'] != null
            ? Color(json['leftBorderColor'] as int)
            : null,
        createdAt: _fromTimestamp(json['createdAt']) ?? DateTime.now(),
        updatedAt: _fromTimestamp(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'title': title,
        'description': description,
        'columnId': columnId,
        'tags': tags,
        'priority': priority.name,
        'dueDate': dueDate,
        'startDate': startDate,
        'totalSubtasks': totalSubtasks,
        'completedSubtasks': completedSubtasks,
        'commentCount': commentCount,
        'assigneeName': assigneeName,
        'assigneeId': assigneeId,
        'assigneePhotoUrl': assigneePhotoUrl,
        'order': order,
        'leftBorderColor': leftBorderColor.value,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  String get progressText => '$completedSubtasks/$totalSubtasks';

  bool get hasSubtasks => totalSubtasks > 0;

  bool get hasComments => commentCount > 0;

  bool get isOverdue => dueDate != null && DateTime.now().isAfter(dueDate!);

  int? get daysRemaining {
    if (dueDate == null) return null;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  String get dueDateText {
    if (dueDate == null) return 'No deadline';
    final days = daysRemaining!;
    if (days < 0) return 'Overdue by ${-days} days';
    if (days == 0) return 'Due today';
    if (days == 1) return 'Due tomorrow';
    return 'Due in $days days';
  }

  // Mock data for testing
  static List<TaskModel> getMockTasks() {
    final now = DateTime.now();
    return [
      // À faire (To Do)
      TaskModel(
        id: '1',
        projectId: '1',
        title: 'Design homepage',
        description: 'Create a modern, responsive homepage design following the new brand guidelines. Include hero section, features grid, and testimonials.',
        columnId: 'todo',
        tags: const ['Design'],
        priority: TaskPriority.urgent,
        dueDate: now.add(const Duration(days: 1)),
        startDate: now.subtract(const Duration(days: 2)),
        totalSubtasks: 15,
        completedSubtasks: 0,
        commentCount: 3,
        assigneeName: 'Sarah Chen',
        assigneeId: '1',
        assigneePhotoUrl: null,
        leftBorderColor: const Color(0xFF9600BF),
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      TaskModel(
        id: '2',
        projectId: '1',
        title: 'Create wireframes',
        description: 'Low-fidelity wireframes for the main user flows including onboarding, dashboard, and settings screens.',
        columnId: 'todo',
        tags: const ['Research'],
        priority: TaskPriority.medium,
        dueDate: now.add(const Duration(days: 3)),
        startDate: now,
        totalSubtasks: 8,
        completedSubtasks: 0,
        commentCount: 3,
        assigneeName: 'Mike Johnson',
        assigneeId: '2',
        assigneePhotoUrl: null,
        leftBorderColor: const Color(0xFF4F9BD8),
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      TaskModel(
        id: '3',
        projectId: '1',
        title: 'User testing plan',
        description: 'Prepare user testing protocol and recruit 5-10 participants for usability testing next week.',
        columnId: 'todo',
        tags: const ['Planning'],
        priority: TaskPriority.high,
        dueDate: now.add(const Duration(days: 7)),
        totalSubtasks: 0,
        completedSubtasks: 0,
        commentCount: 0,
        assigneeName: 'Anna Lee',
        assigneePhotoUrl: null,
        leftBorderColor: const Color(0xFFE6A23C),
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      TaskModel(
        id: '4',
        projectId: '1',
        title: 'Update color palette',
        columnId: 'todo',
        tags: const ['Design'],
        priority: TaskPriority.low,
        dueDate: now.add(const Duration(days: 5)),
        totalSubtasks: 1,
        completedSubtasks: 0,
        commentCount: 0,
        assigneeName: 'Emma Davis',
        assigneePhotoUrl: null,
        leftBorderColor: const Color(0xFF9600BF),
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      TaskModel(
        id: '5',
        projectId: '1',
        title: 'Mobile mockups',
        columnId: 'todo',
        tags: const ['Design'],
        priority: TaskPriority.urgent,
        dueDate: now.add(const Duration(days: 2)),
        totalSubtasks: 6,
        completedSubtasks: 0,
        commentCount: 0,
        assigneeName: 'Sarah Chen',
        assigneePhotoUrl: null,
        leftBorderColor: const Color(0xFF9600BF),
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      
      // En cours (In Progress)
      TaskModel(
        id: '6',
        projectId: '2',
        title: 'Design homepage',
        columnId: 'in_progress',
        tags: const ['Design'],
        priority: TaskPriority.urgent,
        dueDate: now.add(const Duration(days: 1)),
        startDate: now.subtract(const Duration(days: 3)),
        totalSubtasks: 0,
        completedSubtasks: 0,
        commentCount: 0,
        assigneeName: 'Sarah Chen',
        assigneePhotoUrl: null,
        leftBorderColor: const Color(0xFFE6A23C),
        createdAt: now.subtract(const Duration(days: 6)),
      ),
      TaskModel(
        id: '7',
        projectId: '2',
        title: 'Development setup',
        columnId: 'in_progress',
        tags: const ['Dev'],
        priority: TaskPriority.medium,
        dueDate: now.add(const Duration(days: 4)),
        startDate: now.subtract(const Duration(days: 5)),
        totalSubtasks: 12,
        completedSubtasks: 7,
        commentCount: 0,
        assigneeName: 'Tom Wilson',
        assigneePhotoUrl: null,
        leftBorderColor: const Color(0xFFE6A23C),
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      TaskModel(
        id: '8',
        projectId: '2',
        title: 'Content strategy',
        columnId: 'in_progress',
        tags: const ['Content'],
        priority: TaskPriority.medium,
        dueDate: now.add(const Duration(days: 6)),
        totalSubtasks: 5,
        completedSubtasks: 0,
        commentCount: 0,
        assigneeName: 'Mike Johnson',
        assigneePhotoUrl: null,
        leftBorderColor: const Color(0xFFE6A23C),
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      TaskModel(
        id: '9',
        projectId: '2',
        title: 'API integration',
        columnId: 'in_progress',
        tags: const ['Dev'],
        priority: TaskPriority.urgent,
        dueDate: now,
        startDate: now.subtract(const Duration(days: 2)),
        totalSubtasks: 9,
        completedSubtasks: 3,
        commentCount: 2,
        assigneeName: 'Alex Kim',
        assigneePhotoUrl: null,
        leftBorderColor: const Color(0xFFE6A23C),
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      
      // Terminé (Done)
      TaskModel(
        id: '10',
        projectId: '3',
        title: 'Brand guidelines',
        columnId: 'done',
        tags: const ['Design'],
        priority: TaskPriority.high,
        dueDate: now.subtract(const Duration(days: 2)),
        startDate: now.subtract(const Duration(days: 10)),
        totalSubtasks: 10,
        completedSubtasks: 10,
        commentCount: 0,
        assigneeName: 'Emma Davis',
        assigneePhotoUrl: null,
        leftBorderColor: const Color(0xFF268060),
        createdAt: now.subtract(const Duration(days: 14)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      TaskModel(
        id: '11',
        projectId: '3',
        title: 'Competitor analysis',
        columnId: 'done',
        tags: const ['Research'],
        priority: TaskPriority.medium,
        dueDate: now.subtract(const Duration(days: 1)),
        startDate: now.subtract(const Duration(days: 8)),
        totalSubtasks: 5,
        completedSubtasks: 5,
        commentCount: 6,
        assigneeName: 'Mike Johnson',
        assigneePhotoUrl: null,
        leftBorderColor: const Color(0xFF268060),
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      TaskModel(
        id: '12',
        projectId: '3',
        title: 'Logo redesign',
        columnId: 'done',
        tags: const ['Design'],
        priority: TaskPriority.high,
        dueDate: now.subtract(const Duration(days: 3)),
        startDate: now.subtract(const Duration(days: 12)),
        totalSubtasks: 12,
        completedSubtasks: 12,
        commentCount: 4,
        assigneeName: 'Sarah Chen',
        assigneePhotoUrl: null,
        leftBorderColor: const Color(0xFF268060),
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }
}

TaskPriority _priorityFromString(String? value) {
  switch (value) {
    case 'low':
      return TaskPriority.low;
    case 'high':
      return TaskPriority.high;
    case 'urgent':
      return TaskPriority.urgent;
    default:
      return TaskPriority.medium;
  }
}

Color _priorityColor(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.low:
      return const Color(0xFF7C7C7C);
    case TaskPriority.medium:
      return const Color(0xFF4F9BD8);
    case TaskPriority.high:
      return const Color(0xFFE6A23C);
    case TaskPriority.urgent:
      return const Color(0xFF9600BF);
  }
}

DateTime? _fromTimestamp(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is Timestamp) return value.toDate();
  return null;
}
