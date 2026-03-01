import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/project.dart';

class ProjectModel {
  final String id;
  final String name;
  final String description;
  final String ownerId; // Creator/owner of the project
  final int taskCount;
  final int completedTasks;
  final List<String> memberIds; // User IDs of team members
  final List<String> memberAvatars;
  final String color; // 'purple', 'ocean', 'sunset', 'mono'
  final String? icon;
  final DateTime? dueDate;
  final DateTime? startDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProjectModel({
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

  factory ProjectModel.fromDomain(Project project) => ProjectModel(
        id: project.id,
        name: project.name,
        description: project.description,
        ownerId: project.ownerId,
        taskCount: project.taskCount,
        completedTasks: project.completedTasks,
        memberIds: project.memberIds,
        memberAvatars: project.memberAvatars,
        color: project.color,
        icon: project.icon,
        dueDate: project.dueDate,
        startDate: project.startDate,
        createdAt: project.createdAt,
        updatedAt: project.updatedAt,
      );

  Project toDomain() => Project(
        id: id,
        name: name,
        description: description,
        ownerId: ownerId,
        taskCount: taskCount,
        completedTasks: completedTasks,
        memberIds: memberIds,
        memberAvatars: memberAvatars,
        color: color,
        icon: icon,
        dueDate: dueDate,
        startDate: startDate,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        ownerId: json['ownerId'] as String? ?? '',
        taskCount: json['taskCount'] as int? ?? 0,
        completedTasks: json['completedTasks'] as int? ?? 0,
        memberIds: (json['memberIds'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        memberAvatars: (json['memberAvatars'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        color: json['color'] as String? ?? 'purple',
        icon: json['icon'] as String?,
        dueDate: _fromTimestamp(json['dueDate']),
        startDate: _fromTimestamp(json['startDate']),
        createdAt: _fromTimestamp(json['createdAt']) ?? DateTime.now(),
        updatedAt: _fromTimestamp(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'ownerId': ownerId,
        'taskCount': taskCount,
        'completedTasks': completedTasks,
        'memberIds': memberIds,
        'memberAvatars': memberAvatars,
        'color': color,
        'icon': icon,
        'dueDate': dueDate,
        'startDate': startDate,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  bool get isOverdue => dueDate != null && DateTime.now().isAfter(dueDate!);

  int? get daysRemaining {
    if (dueDate == null) return null;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  String get dueDateText {
    if (dueDate == null) return 'No deadline';
    final days = daysRemaining!;
    if (days < 0) return 'Overdue';
    if (days == 0) return 'Due today';
    if (days == 1) return 'Due tomorrow';
    return 'Due in $days days';
  }

  String get summaryDescription => '$taskCount tasks • $dueDateText';

  // Mock data for now
  static List<ProjectModel> get mockProjects {
    final now = DateTime.now();
    return [
      ProjectModel(
        id: '1',
        name: 'Website Redesign',
        description: 'Complete overhaul of the company website with modern design',
        ownerId: '1',
        taskCount: 5,
        completedTasks: 3,
        memberIds: ['1', '2', '3'],
        memberAvatars: [],
        color: 'purple',
        dueDate: now.add(const Duration(days: 1)),
        startDate: now.subtract(const Duration(days: 14)),
        createdAt: now.subtract(const Duration(days: 14)),
      ),
      ProjectModel(
        id: '2',
        name: 'Carbone App Deployment',
        description: 'Deploy the Carbone application to production servers',
        ownerId: '2',
        taskCount: 3,
        completedTasks: 1,
        memberIds: ['2', '4'],
        memberAvatars: [],
        color: 'ocean',
        dueDate: DateTime(2026, 3, 5),
        startDate: now.subtract(const Duration(days: 7)),
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      ProjectModel(
        id: '3',
        name: 'Cloud Strategy Planning',
        description: 'Define cloud migration strategy and architecture',
        ownerId: '1',
        taskCount: 11,
        completedTasks: 4,
        memberIds: ['1', '2', '3', '4', '5'],
        memberAvatars: [],
        color: 'sunset',
        dueDate: DateTime(2026, 3, 10),
        startDate: now.subtract(const Duration(days: 21)),
        createdAt: now.subtract(const Duration(days: 21)),
      ),
    ];
  }

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

DateTime? _fromTimestamp(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is Timestamp) return value.toDate();
  return null;
}