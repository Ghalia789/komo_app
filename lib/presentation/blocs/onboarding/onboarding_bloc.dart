import 'package:flutter_bloc/flutter_bloc.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(OnboardingState()) {
    on<OnboardingPageChanged>(_onPageChanged);
    on<OnboardingNextPressed>(_onNextPressed);
    on<OnboardingSkipPressed>(_onSkipPressed);
    on<OnboardingGetStartedPressed>(_onGetStartedPressed);
    on<OnboardingLoginPressed>(_onLoginPressed);
  }

  void _onPageChanged(OnboardingPageChanged event, Emitter<OnboardingState> emit) {
    emit(state.copyWith(currentPage: event.pageIndex));
  }

  void _onNextPressed(OnboardingNextPressed event, Emitter<OnboardingState> emit) {
    if (state.currentPage < 2) {
      emit(state.copyWith(currentPage: state.currentPage + 1));
    }
  }

  void _onSkipPressed(OnboardingSkipPressed event, Emitter<OnboardingState> emit) {
    // Navigation handled in UI
  }

  void _onGetStartedPressed(OnboardingGetStartedPressed event, Emitter<OnboardingState> emit) {
    // Navigation handled in UI
  }

  void _onLoginPressed(OnboardingLoginPressed event, Emitter<OnboardingState> emit) {
    // Navigation handled in UI
  }
}