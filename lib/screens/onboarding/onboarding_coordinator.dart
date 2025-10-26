import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/onboarding/onboarding_progress_indicator.dart';
import 'splash_screen.dart';
import 'intro_screen.dart';
import 'questionnaire_screen.dart';
import 'paywall_screen.dart';
import 'detox_recommendation_screen.dart';
import '../../theme/spacing.dart';

/// Main onboarding coordinator managing the 5-screen flow
/// Uses PageView to navigate between screens with smooth transitions
class OnboardingCoordinator extends ConsumerStatefulWidget {
  const OnboardingCoordinator({super.key});

  @override
  ConsumerState<OnboardingCoordinator> createState() =>
      _OnboardingCoordinatorState();
}

class _OnboardingCoordinatorState
    extends ConsumerState<OnboardingCoordinator> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Navigate to next page
  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Navigate to previous page
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Skip current screen and go to next
  void _skipPage() {
    _nextPage();
  }

  /// Handle page change
  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    ref.read(onboardingProvider.notifier).setPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Handle back button
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentPage > 0) {
          _previousPage();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // PageView with all screens
            PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe
              children: [
                // Screen 1: Splash
                OnboardingSplashScreen(
                  onComplete: _nextPage,
                ),

                // Screen 2: Intro
                OnboardingIntroScreen(
                  onNext: _nextPage,
                ),

                // Screen 3: Questionnaire (skippable)
                OnboardingQuestionnaireScreen(
                  onNext: _nextPage,
                  onSkip: _skipPage,
                ),

                // Screen 4: Paywall (skippable)
                OnboardingPaywallScreen(
                  onNext: _nextPage,
                  onSkip: _skipPage,
                ),

                // Screen 5: Detox Recommendation (final screen, handles completion)
                const OnboardingDetoxRecommendationScreen(),
              ],
            ),

            // Progress indicator (shown from screen 2 onwards)
            if (_currentPage > 0)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(ZendfastSpacing.m),
                    child: OnboardingProgressIndicator(
                      currentStep: _currentPage,
                      totalSteps: 5,
                    ),
                  ),
                ),
              ),

            // Back button (shown from screen 2 onwards, except last screen)
            if (_currentPage > 0 && _currentPage < 4)
              Positioned(
                top: 0,
                left: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(ZendfastSpacing.s),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _previousPage,
                      tooltip: 'Atrás',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

