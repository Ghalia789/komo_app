abstract class CreateProjectEvent {}

class CreateProjectNameChanged extends CreateProjectEvent {
  final String name;
  CreateProjectNameChanged(this.name);
}

class CreateProjectDescriptionChanged extends CreateProjectEvent {
  final String description;
  CreateProjectDescriptionChanged(this.description);
}

class CreateProjectIconSelected extends CreateProjectEvent {
  final String icon;
  CreateProjectIconSelected(this.icon);
}

class CreateProjectPaletteSelected extends CreateProjectEvent {
  final String paletteId;
  CreateProjectPaletteSelected(this.paletteId);
}

class CreateProjectDueDateChanged extends CreateProjectEvent {
  final DateTime? dueDate;
  CreateProjectDueDateChanged(this.dueDate);
}

class CreateProjectStartDateChanged extends CreateProjectEvent {
  final DateTime? startDate;
  CreateProjectStartDateChanged(this.startDate);
}

class CreateProjectSubmitted extends CreateProjectEvent {}

class CreateProjectReset extends CreateProjectEvent {}
