import 'package:equatable/equatable.dart';

import '../../../domain/entities/project.dart';

class DashboardState extends Equatable {
  final List<Project> projects;
  final bool isLoading;
  final String? errorMessage;

  const DashboardState({
    this.projects = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  DashboardState copyWith({
    List<Project>? projects,
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return DashboardState(
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [projects, isLoading, errorMessage];
}