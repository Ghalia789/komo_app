abstract class KanbanEvent {}

class KanbanLoadData extends KanbanEvent {}

class KanbanToggleView extends KanbanEvent {
  final bool isBoardView;
  KanbanToggleView(this.isBoardView);
}

class KanbanTaskTapped extends KanbanEvent {
  final String taskId;
  KanbanTaskTapped(this.taskId);
}

class KanbanInvitePressed extends KanbanEvent {}
