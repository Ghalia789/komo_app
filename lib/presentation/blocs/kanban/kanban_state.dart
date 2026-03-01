import 'package:equatable/equatable.dart';

import '../../../data/models/kanban_column_model.dart';
import '../../../data/models/task_model.dart';

class KanbanState extends Equatable {
  final List<KanbanColumnModel> columns;
  final List<TaskModel> tasks;
  final bool isBoardView; // true = Board, false = List
  final bool isLoading;
  final String? errorMessage;

  const KanbanState({
    this.columns = const [],
    this.tasks = const [],
    this.isBoardView = true,
    this.isLoading = false,
    this.errorMessage,
  });

  // Get tasks for a specific column
  List<TaskModel> getTasksForColumn(String columnId) {
    return tasks.where((task) => task.columnId == columnId).toList();
  }

  KanbanState copyWith({
    List<KanbanColumnModel>? columns,
    List<TaskModel>? tasks,
    bool? isBoardView,
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return KanbanState(
      columns: columns ?? this.columns,
      tasks: tasks ?? this.tasks,
      isBoardView: isBoardView ?? this.isBoardView,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [columns, tasks, isBoardView, isLoading, errorMessage];
}
