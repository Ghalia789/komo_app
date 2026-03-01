import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Assignee extends Equatable {
  final String id;
  final String name;
  final Color color;

  const Assignee({
    required this.id,
    required this.name,
    required this.color,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  // Mock assignees
  static const List<Assignee> mockAssignees = [
    Assignee(id: '1', name: 'Sarah Chen', color: Color(0xFFD4A017)),
    Assignee(id: '2', name: 'Mike Johnson', color: Color(0xFF9600BF)),
    Assignee(id: '3', name: 'Emma Davis', color: Color(0xFF268060)),
  ];

  @override
  List<Object?> get props => [id, name, color];
}

class CreateTaskState extends Equatable {
  final String title;
  final String description;
  final String priority; // 'low', 'medium', 'high', 'urgent'
  final DateTime? dueDate;
  final DateTime? startDate;
  final List<String> selectedTags;
  final List<String> selectedAssigneeIds;
  final List<String> subtasks;
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  // Available options
  static const List<String> priorities = ['Low', 'Medium', 'High', 'Urgent'];
  static const List<String> availableTags = [
    'Design',
    'Development',
    'Research',
    'Bug',
    'Feature',
    'Docs',
  ];

  const CreateTaskState({
    this.title = '',
    this.description = '',
    this.priority = 'Medium',
    this.dueDate,
    this.startDate,
    this.selectedTags = const [],
    this.selectedAssigneeIds = const [],
    this.subtasks = const [],
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  bool get isValid => title.trim().isNotEmpty;

  Color getPriorityColor(String p) {
    switch (p.toLowerCase()) {
      case 'low':
        return const Color(0xFF7D627F);
      case 'medium':
        return const Color(0xFFD4A017);
      case 'high':
        return const Color(0xFFE87A2D);
      case 'urgent':
        return const Color(0xFFB85C6E);
      default:
        return const Color(0xFF7D627F);
    }
  }

  Color getTagColor(String tag) {
    switch (tag.toLowerCase()) {
      case 'design':
        return const Color(0xFF9600BF);
      case 'development':
        return const Color(0xFF268060);
      case 'research':
        return const Color(0xFF4F9BD8);
      case 'bug':
        return const Color(0xFFB85C6E);
      case 'feature':
        return const Color(0xFFD4A017);
      case 'docs':
        return const Color(0xFF7D627F);
      default:
        return const Color(0xFF7D627F);
    }
  }

  CreateTaskState copyWith({
    String? title,
    String? description,
    String? priority,
    DateTime? Function()? dueDate,
    DateTime? Function()? startDate,
    List<String>? selectedTags,
    List<String>? selectedAssigneeIds,
    List<String>? subtasks,
    bool? isLoading,
    bool? isSuccess,
    String? Function()? errorMessage,
  }) {
    return CreateTaskState(
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate != null ? dueDate() : this.dueDate,
      startDate: startDate != null ? startDate() : this.startDate,
      selectedTags: selectedTags ?? this.selectedTags,
      selectedAssigneeIds: selectedAssigneeIds ?? this.selectedAssigneeIds,
      subtasks: subtasks ?? this.subtasks,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        title,
        description,
        priority,
        dueDate,
        startDate,
        selectedTags,
        selectedAssigneeIds,
        subtasks,
        isLoading,
        isSuccess,
        errorMessage,
      ];
}
