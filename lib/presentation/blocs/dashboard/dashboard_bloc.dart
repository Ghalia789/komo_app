import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/project_model.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardState()) {
    on<DashboardLoadProjects>(_onLoadProjects);
    on<DashboardProjectSelected>(_onProjectSelected);
    on<DashboardCreateProjectPressed>(_onCreateProjectPressed);
    on<DashboardProfilePressed>(_onProfilePressed);
    on<DashboardNotificationsPressed>(_onNotificationsPressed);
    on<DashboardSettingsPressed>(_onSettingsPressed);
  }

  Future<void> _onLoadProjects(DashboardLoadProjects event, Emitter<DashboardState> emit) async {
    emit(state.copyWith(isLoading: true));
    
    // TODO: Load from Firebase
    await Future.delayed(const Duration(milliseconds: 500));
    
    emit(state.copyWith(
      isLoading: false,
      projects: ProjectModel.mockProjects,
    ));
  }

  void _onProjectSelected(DashboardProjectSelected event, Emitter<DashboardState> emit) {
    // Navigation handled in UI
  }

  void _onCreateProjectPressed(DashboardCreateProjectPressed event, Emitter<DashboardState> emit) {
    // Navigation handled in UI
  }

  void _onProfilePressed(DashboardProfilePressed event, Emitter<DashboardState> emit) {}
  void _onNotificationsPressed(DashboardNotificationsPressed event, Emitter<DashboardState> emit) {}
  void _onSettingsPressed(DashboardSettingsPressed event, Emitter<DashboardState> emit) {}
}