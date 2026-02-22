abstract class DashboardEvent {}

class DashboardLoadProjects extends DashboardEvent {}

class DashboardProjectSelected extends DashboardEvent {
  final String projectId;
  DashboardProjectSelected(this.projectId);
}

class DashboardCreateProjectPressed extends DashboardEvent {}

class DashboardProfilePressed extends DashboardEvent {}

class DashboardNotificationsPressed extends DashboardEvent {}

class DashboardSettingsPressed extends DashboardEvent {}