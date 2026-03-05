abstract class TaskDetailsEvent {}

class TaskDetailsLoadData extends TaskDetailsEvent {
  final String taskId;
  TaskDetailsLoadData(this.taskId);
}

class TaskDetailsSubtaskToggled extends TaskDetailsEvent {
  final String subtaskId;
  TaskDetailsSubtaskToggled(this.subtaskId);
}

class TaskDetailsSubtaskAdded extends TaskDetailsEvent {
  final String title;
  TaskDetailsSubtaskAdded(this.title);
}

class TaskDetailsSubtaskRemoved extends TaskDetailsEvent {
  final String subtaskId;
  TaskDetailsSubtaskRemoved(this.subtaskId);
}

class TaskDetailsAssigneeChanged extends TaskDetailsEvent {
  final String? assigneeId;
  final String? assigneeName;
  TaskDetailsAssigneeChanged(this.assigneeId, this.assigneeName);
}

class TaskDetailsTagToggled extends TaskDetailsEvent {
  final String tag;
  TaskDetailsTagToggled(this.tag);
}

class TaskDetailsCommentAdded extends TaskDetailsEvent {
  final String text;
  TaskDetailsCommentAdded(this.text);
}

class TaskDetailsStatusChanged extends TaskDetailsEvent {
  final String columnId; // 'todo', 'in_progress', 'done'
  TaskDetailsStatusChanged(this.columnId);
}

class TaskDetailsInvitePressed extends TaskDetailsEvent {}
