abstract class OnboardingEvent {}

class OnboardingPageChanged extends OnboardingEvent {
  final int pageIndex;
  OnboardingPageChanged(this.pageIndex);
}

class OnboardingNextPressed extends OnboardingEvent {}

class OnboardingSkipPressed extends OnboardingEvent {}

class OnboardingGetStartedPressed extends OnboardingEvent {}

class OnboardingLoginPressed extends OnboardingEvent {}