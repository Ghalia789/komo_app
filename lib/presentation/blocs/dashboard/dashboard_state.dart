import '../../../data/models/project_model.dart';

class DashboardState {
  final List<ProjectModel> projects;
  final bool isLoading;
  final String? errorMessage;

  DashboardState({
    this.projects = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  DashboardState copyWith({
    List<ProjectModel>? projects,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DashboardState(
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}