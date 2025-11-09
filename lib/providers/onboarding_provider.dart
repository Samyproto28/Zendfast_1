import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State class for onboarding flow data
class OnboardingState {
  final int currentPage;
  final double? weightKg;
  final double? heightCm;
  final String? fastingExperienceLevel;
  final bool? hasSubscribed;
  final bool? detoxPlanOptIn;
  final bool hasAcceptedPrivacyPolicy;
  final bool hasAcceptedTermsOfService;

  const OnboardingState({
    this.currentPage = 0,
    this.weightKg,
    this.heightCm,
    this.fastingExperienceLevel,
    this.hasSubscribed,
    this.detoxPlanOptIn,
    this.hasAcceptedPrivacyPolicy = false,
    this.hasAcceptedTermsOfService = false,
  });

  OnboardingState copyWith({
    int? currentPage,
    double? weightKg,
    double? heightCm,
    String? fastingExperienceLevel,
    bool? hasSubscribed,
    bool? detoxPlanOptIn,
    bool? hasAcceptedPrivacyPolicy,
    bool? hasAcceptedTermsOfService,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      fastingExperienceLevel:
          fastingExperienceLevel ?? this.fastingExperienceLevel,
      hasSubscribed: hasSubscribed ?? this.hasSubscribed,
      detoxPlanOptIn: detoxPlanOptIn ?? this.detoxPlanOptIn,
      hasAcceptedPrivacyPolicy:
          hasAcceptedPrivacyPolicy ?? this.hasAcceptedPrivacyPolicy,
      hasAcceptedTermsOfService:
          hasAcceptedTermsOfService ?? this.hasAcceptedTermsOfService,
    );
  }
}

/// Notifier for onboarding state management
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  /// Update current page index
  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  /// Save questionnaire data
  void saveQuestionnaireData({
    required double? weightKg,
    required double? heightCm,
    required String? fastingExperienceLevel,
  }) {
    state = state.copyWith(
      weightKg: weightKg,
      heightCm: heightCm,
      fastingExperienceLevel: fastingExperienceLevel,
    );
  }

  /// Save paywall subscription decision
  void savePaywallDecision(bool hasSubscribed) {
    state = state.copyWith(hasSubscribed: hasSubscribed);
  }

  /// Save detox plan opt-in decision
  void saveDetoxDecision(bool optIn) {
    state = state.copyWith(detoxPlanOptIn: optIn);
  }

  /// Save legal acceptance (Privacy Policy + Terms of Service)
  void saveLegalAcceptance({
    required bool privacyPolicy,
    required bool termsOfService,
  }) {
    state = state.copyWith(
      hasAcceptedPrivacyPolicy: privacyPolicy,
      hasAcceptedTermsOfService: termsOfService,
    );
  }

  /// Reset onboarding state (clear all data)
  void reset() {
    state = const OnboardingState();
  }
}

/// Provider for onboarding state
final onboardingProvider =
    StateNotifierProvider.autoDispose<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier();
});
