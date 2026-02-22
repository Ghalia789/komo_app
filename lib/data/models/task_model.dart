import 'package:flutter/material.dart';

class TaskModel {
  final String id;
  final String title;
  final String columnId; // 'todo', 'in_progress', 'done'
  final List<String> tags; // ['Design', 'Urgent', 'Research', etc.]
  final int totalSubtasks;
  final int completedSubtasks;
  final int commentCount;
  final String? assigneeName; // Person assigned to this task
  final String? assigneePhotoUrl; // Avatar URL
  final Color leftBorderColor; // Left accent color

  TaskModel({
    required this.id,
    required this.title,
    required this.columnId,
    required this.tags,
    required this.totalSubtasks,
    required this.completedSubtasks,
    required this.commentCount,
    this.assigneeName,
    this.assigneePhotoUrl,
    required this.leftBorderColor,
  });

  String get progressText => '$completedSubtasks/$totalSubtasks';
  
  bool get hasSubtasks => totalSubtasks > 0;
  
  bool get hasComments => commentCount > 0;

  // Mock data for testing
  static List<TaskModel> getMockTasks() {
    return [
      // À faire (To Do)
      TaskModel(
        id: '1',
        title: 'Design homepage',
        columnId: 'todo',
        tags: ['Design', 'Urgent'],
        totalSubtasks: 15,
        completedSubtasks: 0,
        commentCount: 3,
        assigneeName: 'Sarah Chen',
        assigneePhotoUrl: null,
        leftBorderColor: const Color(0xFF9600BF),
      ),
      TaskModel(
        id: '2',
        title: 'Create wireframes',
        columnId: 'todo',
        tags: ['Research'],
        totalSubtasks: 8,
        completedSubtasks: 0,
        commentCount: 3,
        assigneeName: 'Mike Johnson',
        assigneePhotoUrl: null,
        leftBorderColor: const Color(0xFF4F9BD8),
      ),
      TaskModel(
        id: '3',
        title: 'User testing plan',
        columnId: 'todo',
        tags: ['Planning'],
        totalSubtasks: 0,
        completedSubtasks: 0,
        commentCount: 0,
        assigneeName: 'Anna Lee',
        assigneePhotoUrl: null,
        leftBorderColor: const Color(0xFFE6A23C),
      ),
      TaskModel(
        id: '4',
        title: 'Update color palette',
        columnId: 'todo',
        tags: ['Design'],
        totalSubtasks: 1,
        completedSubtasks: 0,
        commentCount: 0,
        assigneeName: 'Emma Davis',
        assigneePhotoUrl: null,
        leftBorderColor: const Color(0xFF9600BF),
      ),
      TaskModel(
        id: '5',
        title: 'Mobile mockups',
        columnId: 'todo',
        tags: ['Design', 'Urgent'],
        totalSubtasks: 6,
        completedSubtasks: 0,
        commentCount: 0,
        assigneeName: 'Sarah Chen',
        assigneePhotoUrl: null,
        leftBorderColor: const Color(0xFF9600BF),
      ),
      
      // En cours (In Progress)
      TaskModel(
        id: '6',
        title: 'Design homepage',
        columnId: 'in_progress',
        tags: ['Design', 'Urgent'],
        totalSubtasks: 0,
        completedSubtasks: 0,
        commentCount: 0,
        assigneeName: 'Sarah Chen',
        assigneePhotoUrl: null,
        leftBorderColor: const Color(0xFFE6A23C),
      ),
      TaskModel(
        id: '7',
        title: 'Development setup',
        columnId: 'in_progress',
        tags: ['Dev'],
        totalSubtasks: 12,
        completedSubtasks: 7,
        commentCount: 0,
        assigneeName: 'Tom Wilson',
        assigneePhotoUrl: null,
        leftBorderColor: const Color(0xFFE6A23C),
      ),
      TaskModel(
        id: '8',
        title: 'Content strategy',
        columnId: 'in_progress',
        tags: ['Content'],
        totalSubtasks: 5,
        completedSubtasks: 0,
        commentCount: 0,
        assigneeName: 'Mike Johnson',
        assigneePhotoUrl: null,
        leftBorderColor: const Color(0xFFE6A23C),
      ),
      TaskModel(
        id: '9',
        title: 'API integration',
        columnId: 'in_progress',
        tags: ['Dev', 'Urgent'],
        totalSubtasks: 9,
        completedSubtasks: 3,
        commentCount: 2,
        assigneeName: 'Alex Kim',
        assigneePhotoUrl: null,
        leftBorderColor: const Color(0xFFE6A23C),
      ),
      
      // Terminé (Done)
      TaskModel(
        id: '10',
        title: 'Brand guidelines',
        columnId: 'done',
        tags: ['Design'],
        totalSubtasks: 10,
        completedSubtasks: 10,
        commentCount: 0,
        assigneeName: 'Emma Davis',
        assigneePhotoUrl: null,
        leftBorderColor: const Color(0xFF268060),
      ),
      TaskModel(
        id: '11',
        title: 'Competitor analysis',
        columnId: 'done',
        tags: ['Research'],
        totalSubtasks: 5,
        completedSubtasks: 5,
        commentCount: 6,
        assigneeName: 'Mike Johnson',
        assigneePhotoUrl: null,
        leftBorderColor: const Color(0xFF268060),
      ),
      TaskModel(
        id: '12',
        title: 'Logo redesign',
        columnId: 'done',
        tags: ['Design'],
        totalSubtasks: 12,
        completedSubtasks: 12,
        commentCount: 4,
        assigneeName: 'Sarah Chen',
        assigneePhotoUrl: null,
        leftBorderColor: const Color(0xFF268060),
      ),
    ];
  }
}
