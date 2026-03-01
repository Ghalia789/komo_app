import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/subtask.dart';

class SubtaskModel {
  final String id;
  final String taskId; // Link to parent task
  final String title;
  final bool isCompleted;
  final DateTime? dueDate;
  final int order;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SubtaskModel({
    required this.id,
    required this.taskId,
    required this.title,
    required this.isCompleted,
    this.dueDate,
    this.order = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory SubtaskModel.fromDomain(Subtask subtask) => SubtaskModel(
        id: subtask.id,
        taskId: subtask.taskId,
        title: subtask.title,
        isCompleted: subtask.isCompleted,
        dueDate: subtask.dueDate,
        order: subtask.order,
        createdAt: subtask.createdAt,
        updatedAt: subtask.updatedAt,
      );

  Subtask toDomain() => Subtask(
        id: id,
        taskId: taskId,
        title: title,
        isCompleted: isCompleted,
        dueDate: dueDate,
        order: order,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory SubtaskModel.fromJson(Map<String, dynamic> json) => SubtaskModel(
        id: json['id'] as String? ?? '',
        taskId: json['taskId'] as String? ?? '',
        title: json['title'] as String? ?? '',
        isCompleted: json['isCompleted'] as bool? ?? false,
        dueDate: _fromTimestamp(json['dueDate']),
        order: json['order'] as int? ?? 0,
        createdAt: _fromTimestamp(json['createdAt']) ?? DateTime.now(),
        updatedAt: _fromTimestamp(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'taskId': taskId,
        'title': title,
        'isCompleted': isCompleted,
        'dueDate': dueDate,
        'order': order,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  bool get isOverdue => dueDate != null && !isCompleted && DateTime.now().isAfter(dueDate!);

  SubtaskModel copyWith({
    String? id,
    String? taskId,
    String? title,
    bool? isCompleted,
    DateTime? dueDate,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubtaskModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Mock subtasks for a task
  static List<SubtaskModel> getMockSubtasks() {
    final now = DateTime.now();
    return [
      SubtaskModel(
        id: '1',
        taskId: '1',
        title: 'Create hero section mockup',
        isCompleted: true,
        order: 1,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      SubtaskModel(
        id: '2',
        taskId: '1',
        title: 'Design navigation bar',
        isCompleted: true,
        order: 2,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      SubtaskModel(
        id: '3',
        taskId: '1',
        title: 'Design footer layout',
        isCompleted: true,
        order: 3,
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      SubtaskModel(
        id: '4',
        taskId: '1',
        title: 'Create color palette',
        isCompleted: true,
        order: 4,
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      SubtaskModel(
        id: '5',
        taskId: '1',
        title: 'Design features section',
        isCompleted: false,
        dueDate: now.add(const Duration(days: 1)),
        order: 5,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      SubtaskModel(
        id: '6',
        taskId: '1',
        title: 'Create testimonials layout',
        isCompleted: false,
        dueDate: now.add(const Duration(days: 2)),
        order: 6,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      SubtaskModel(
        id: '7',
        taskId: '1',
        title: 'Design CTA buttons',
        isCompleted: false,
        order: 7,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      SubtaskModel(
        id: '8',
        taskId: '1',
        title: 'Mobile responsive design',
        isCompleted: false,
        dueDate: now.add(const Duration(days: 3)),
        order: 8,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      SubtaskModel(
        id: '9',
        taskId: '1',
        title: 'Create hover states',
        isCompleted: false,
        order: 9,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      SubtaskModel(
        id: '10',
        taskId: '1',
        title: 'Design loading states',
        isCompleted: false,
        order: 10,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      SubtaskModel(
        id: '11',
        taskId: '1',
        title: 'Create error states',
        isCompleted: false,
        order: 11,
        createdAt: now,
      ),
    ];
  }
}

DateTime? _fromTimestamp(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is Timestamp) return value.toDate();
  return null;
}
