import 'package:flutter/material.dart';

enum TaskPriority { low, medium, high, urgent }

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
  final Color leftBorderColor; // Left accent color
  final DateTime createdAt;
  final DateTime? updatedAt;

  TaskModel({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    required this.columnId,
    required this.tags,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.startDate,
    required this.totalSubtasks,
    required this.completedSubtasks,
    required this.commentCount,
    this.assigneeName,
    this.assigneeId,
    this.assigneePhotoUrl,
    required this.leftBorderColor,
    required this.createdAt,
    this.updatedAt,
  });

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
        tags: ['Design'],
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
        tags: ['Research'],
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
        tags: ['Planning'],
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
        tags: ['Design'],
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
        tags: ['Design'],
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
        tags: ['Design'],
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
        tags: ['Dev'],
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
        tags: ['Content'],
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
        tags: ['Dev'],
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
        tags: ['Design'],
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
        tags: ['Research'],
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
        tags: ['Design'],
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
