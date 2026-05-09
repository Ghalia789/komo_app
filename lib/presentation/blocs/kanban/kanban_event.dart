import '../../../domain/entities/task.dart';

abstract class KanbanEvent {}

class KanbanLoadData extends KanbanEvent {
  final String projectId;
  KanbanLoadData(this.projectId);
}

class KanbanToggleView extends KanbanEvent {
  final bool isBoardView;
  KanbanToggleView(this.isBoardView);
}

class KanbanTaskTapped extends KanbanEvent {
  final String taskId;
  KanbanTaskTapped(this.taskId);
}

class KanbanInvitePressed extends KanbanEvent {}

class KanbanStreamUpdated extends KanbanEvent {
  final List<Task> tasks;

  KanbanStreamUpdated(this.tasks);
}

class KanbanStreamFailed extends KanbanEvent {
  final String message;

  KanbanStreamFailed(this.message);
}
