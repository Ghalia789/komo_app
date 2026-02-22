abstract class TaskDetailsEvent {}

class TaskDetailsLoadData extends TaskDetailsEvent {
  final String taskId;
  TaskDetailsLoadData(this.taskId);
}

class TaskDetailsSubtaskToggled extends TaskDetailsEvent {
  final String subtaskId;
  TaskDetailsSubtaskToggled(this.subtaskId);
}

class TaskDetailsCommentAdded extends TaskDetailsEvent {
  final String text;
  TaskDetailsCommentAdded(this.text);
}

class TaskDetailsInvitePressed extends TaskDetailsEvent {}
