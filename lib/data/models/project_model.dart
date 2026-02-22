import 'package:flutter/material.dart';

class ProjectModel {
  final String id;
  final String name;
  final String description;
  final int taskCount;
  final int completedTasks;
  final List<String> memberAvatars;
  final String color; // 'purple', 'ocean', 'sunset', 'mono'

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.taskCount,
    required this.completedTasks,
    required this.memberAvatars,
    required this.color,
  });

  // Mock data for now
  static List<ProjectModel> get mockProjects => [
    ProjectModel(
      id: '1',
      name: 'Website Redesign',
      description: '5 tasks • Due tomorrow',
      taskCount: 5,
      completedTasks: 3,
      memberAvatars: [],
      color: 'purple',
    ),
    ProjectModel(
      id: '2',
      name: 'Carbone App Deployment',
      description: '3 tasks • Due 20 Feb 2026',
      taskCount: 3,
      completedTasks: 1,
      memberAvatars: [],
      color: 'ocean',
    ),
    ProjectModel(
      id: '3',
      name: 'Cloud Strategy Planning',
      description: '11 tasks • Due 25 Feb 2026',
      taskCount: 11,
      completedTasks: 4,
      memberAvatars: [],
      color: 'sunset',
    ),
  ];

  double get progressPercent => taskCount == 0 ? 0 : completedTasks / taskCount;

  Color getColorValue() {
    switch (color) {
      case 'purple':
        return const Color(0xFF9600BF);
      case 'ocean':
        return const Color(0xFF268060);
      case 'sunset':
        return const Color(0xFFD4A017);
      case 'mono':
        return const Color(0xFF3E0C54);
      default:
        return const Color(0xFF9600BF);
    }
  }
}