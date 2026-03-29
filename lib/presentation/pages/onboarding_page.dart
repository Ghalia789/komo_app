import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../blocs/blocs.dart';

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
      image: 'assets/images/hand_with_clipboard.png',
      title: 'Organize\nyour work',
      subtitle: 'Create projects, add tasks, track progress',
    ),
    OnboardingData(
      image: 'assets/images/collaborating.png',
      title: 'Work\ntogether',
      subtitle: 'Invite team members, assign tasks, comment',
    ),
    OnboardingData(
      image: 'assets/images/lightbulb.png',
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

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.isFirstLaunch, false);
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
                        onTap: () async {
                          context.read<OnboardingBloc>().add(OnboardingSkipPressed());
                          await _completeOnboarding();
                          if (!mounted) return;
                          Navigator.of(context)
                              .pushReplacementNamed(RouteConstants.signup);
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
              
              // Bottom section - FIXED
              Padding(
                padding: const EdgeInsets.all(24),
                child: BlocBuilder<OnboardingBloc, OnboardingState>(
                  builder: (context, state) {
                    // Pages 1-2: Dots + Small Next button
                    if (!state.isLastPage) {
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
                          
                          // Small Next button (NOT KomoButton)
                          SizedBox(
                            width: 90,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<OnboardingBloc>().add(OnboardingNextPressed());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Next',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    
                    // Page 3: Get Started button + Login link (centered)
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Small dark Get Started button
                        SizedBox(
                          width: 120,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () async {
                              context.read<OnboardingBloc>().add(OnboardingGetStartedPressed());
                              await _completeOnboarding();
                              if (!mounted) return;
                              Navigator.of(context)
                                  .pushReplacementNamed(RouteConstants.signup);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDark, // Dark purple
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Get Started',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward, size: 16),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Login link
                        GestureDetector(
                          onTap: () async {
                            context.read<OnboardingBloc>().add(OnboardingLoginPressed());
                            await _completeOnboarding();
                            if (!mounted) return;
                            Navigator.of(context)
                                .pushReplacementNamed(RouteConstants.login);
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