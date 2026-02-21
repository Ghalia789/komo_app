import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../blocs/blocs.dart';
import '../widgets/widgets.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingBloc(),
      child: const OnboardingView(),
    );
  }
}

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();

  final List<OnboardingData> _pages = [
    OnboardingData(
      image: 'assets/images/onboarding_1.png',
      title: 'Organize\nyour work',
      subtitle: 'Create projects, add tasks, track progress',
    ),
    OnboardingData(
      image: 'assets/images/onboarding_2.png',
      title: 'Work\ntogether',
      subtitle: 'Invite team members, assign tasks, comment',
    ),
    OnboardingData(
      image: 'assets/images/onboarding_3.png',
      title: 'Ready to start?',
      subtitle: '',
      isLast: true,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listenWhen: (previous, current) => previous.currentPage != current.currentPage,
      listener: (context, state) {
        _animateToPage(state.currentPage);
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Column(
            children: [
              // Skip button
              BlocBuilder<OnboardingBloc, OnboardingState>(
                builder: (context, state) {
                  return Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: GestureDetector(
                        onTap: () {
                          context.read<OnboardingBloc>().add(OnboardingSkipPressed());
                          Navigator.of(context).pushReplacementNamed('/signup');
                        },
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 14,
                            color: state.isLastPage
                                ? Colors.transparent
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              // Page content
              Expanded(
                child: BlocBuilder<OnboardingBloc, OnboardingState>(
                  builder: (context, state) {
                    return PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        context.read<OnboardingBloc>().add(OnboardingPageChanged(index));
                      },
                      itemCount: _pages.length,
                      itemBuilder: (context, index) {
                        return _buildPage(_pages[index]);
                      },
                    );
                  },
                ),
              ),
              
              // Bottom section
              Padding(
                padding: const EdgeInsets.all(24),
                child: BlocBuilder<OnboardingBloc, OnboardingState>(
                  builder: (context, state) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Dots
                        Row(
                          children: List.generate(
                            _pages.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: index == state.currentPage ? 8 : 6,
                              height: index == state.currentPage ? 8 : 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index == state.currentPage
                                    ? AppColors.primary
                                    : AppColors.textSecondary.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),
                        
                        // Button
                        if (!state.isLastPage)
                          SizedBox(
                            width: 100,
                            child: KomoButton(
                              text: 'Next',
                              type: KomoButtonType.primary,
                              onPressed: () {
                                context.read<OnboardingBloc>().add(OnboardingNextPressed());
                              },
                            ),
                          )
                        else
                          Expanded(
                            child: Column(
                              children: [
                                KomoButton(
                                  text: 'Get Started',
                                  type: KomoButtonType.primary,
                                  onPressed: () {
                                    context.read<OnboardingBloc>().add(OnboardingGetStartedPressed());
                                    Navigator.of(context).pushReplacementNamed('/signup');
                                  },
                                ),
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: () {
                                    context.read<OnboardingBloc>().add(OnboardingLoginPressed());
                                    Navigator.of(context).pushReplacementNamed('/login');
                                  },
                                  child: Text(
                                    'I already have an account',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            data.image,
            height: 280,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 48),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          if (data.subtitle.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              data.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class OnboardingData {
  final String image;
  final String title;
  final String subtitle;
  final bool isLast;

  OnboardingData({
    required this.image,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });
}