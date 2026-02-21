class OnboardingState {
  final int currentPage;
  final bool isLastPage;

  OnboardingState({
    this.currentPage = 0,
  }) : isLastPage = currentPage == 2;

  OnboardingState copyWith({
    int? currentPage,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
    );
  }
}