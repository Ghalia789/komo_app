abstract class CreateTaskEvent {}

class CreateTaskTitleChanged extends CreateTaskEvent {
  final String title;
  CreateTaskTitleChanged(this.title);
}

class CreateTaskDescriptionChanged extends CreateTaskEvent {
  final String description;
  CreateTaskDescriptionChanged(this.description);
}

class CreateTaskPriorityChanged extends CreateTaskEvent {
  final String priority;
  CreateTaskPriorityChanged(this.priority);
}

class CreateTaskTagToggled extends CreateTaskEvent {
  final String tag;
  CreateTaskTagToggled(this.tag);
}

class CreateTaskAssigneeToggled extends CreateTaskEvent {
  final String assigneeId;
  CreateTaskAssigneeToggled(this.assigneeId);
}

class CreateTaskAddSubtask extends CreateTaskEvent {
  final String title;
  CreateTaskAddSubtask(this.title);
}

class CreateTaskRemoveSubtask extends CreateTaskEvent {
  final int index;
  CreateTaskRemoveSubtask(this.index);
}

class CreateTaskSubmitted extends CreateTaskEvent {}

class CreateTaskReset extends CreateTaskEvent {}
