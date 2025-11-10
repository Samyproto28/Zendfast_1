# Zendfast - Complete Codebase Architecture

> **Last Updated:** 2025-01-10 | Task 11 completed
> **Purpose:** Comprehensive codebase reference to eliminate extensive research on each task
> **Auto-updated:** by Claude Code after each completed task

## 📊 Project Overview

**Tech Stack:**
- **Framework:** Flutter 3.27.1
- **State Management:** Riverpod 2.6.1
- **Backend:** Supabase (auth, database, realtime)
- **Local DB:** Isar 3.1.0+1
- **Routing:** GoRouter 14.6.2
- **Typography:** Google Fonts (Inter, Source Sans 3, Nunito Sans)
- **Language:** Dart 3.6.0

**Project Stats:**
- Total Files: 1394
- Dart Files: 100+
- Models: 17
- Providers: 8
- Services: 13
- Screens: 15+
- Reusable Widgets: 22+

---

## 🗂️ Directory Structure

```
lib/
├── main.dart                          # App entry point
├── app.dart                           # Root widget with router
├── config/
│   ├── router.dart                    # GoRouter configuration
│   └── supabase_config.dart          # Supabase initialization
├── models/                            # Data models
│   ├── auth_state.dart
│   ├── fasting_plan.dart
│   ├── fasting_session.dart          # Isar collection
│   ├── fasting_state.dart
│   ├── timer_state.dart
│   ├── onboarding_state.dart
│   ├── consent_record.dart           # Isar collection
│   └── user.dart
├── providers/                         # Riverpod providers
│   ├── auth_provider.dart            # AuthNotifier
│   ├── auth_computed_providers.dart  # Computed auth providers
│   ├── timer_provider.dart           # TimerNotifier
│   └── onboarding_provider.dart      # OnboardingNotifier
├── services/                          # Business logic layer
│   ├── auth_service.dart             # Singleton
│   ├── timer_service.dart            # Singleton
│   ├── consent_manager.dart          # Singleton
│   ├── supabase_error_handler.dart   # Error handling
│   ├── isar_service.dart             # Isar DB service
│   └── analytics_service.dart        # Analytics tracking
├── screens/                           # UI screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── onboarding/
│   │   ├── welcome_screen.dart
│   │   ├── goal_selection_screen.dart
│   │   └── plan_selection_screen.dart
│   ├── fasting/
│   │   └── fasting_home_screen.dart  # Task 10
│   └── profile/
│       └── settings_screen.dart
├── widgets/                           # Reusable widgets
│   ├── fasting/
│   │   ├── fasting_timer_display.dart      # Task 10.1
│   │   ├── circular_progress_ring.dart     # Task 10.2
│   │   ├── fasting_control_buttons.dart    # Task 10.2
│   │   ├── fasting_context_info.dart       # Task 10.3
│   │   └── fasting_plan_card.dart          # Task 9
│   ├── auth/
│   │   └── auth_form.dart
│   └── common/
│       ├── loading_overlay.dart
│       └── error_dialog.dart
├── theme/                             # Design system
│   ├── colors.dart                    # ZendfastColors
│   ├── typography.dart                # Text styles
│   ├── spacing.dart                   # ZendfastSpacing
│   ├── animations.dart                # ZendfastAnimations
│   └── theme.dart                     # ThemeData
├── utils/                             # Utilities
│   ├── result.dart                    # Result<T> type
│   ├── validators.dart                # Form validators
│   └── constants.dart                 # App constants
└── l10n/                              # Localization
    └── app_en.arb

test/
├── models/
├── services/
│   └── consent_manager_test.dart
├── providers/
└── widgets/

integration_test/
└── app_test.dart
```

---

## 📦 Models (Complete List)

### 1. FastingSession (Isar Collection)
**Path:** `lib/models/fasting_session.dart`
**Purpose:** Persistent storage of fasting sessions
**Task:** 7

```dart
@collection
class FastingSession {
  Id id;
  String userId;
  DateTime startTime;
  DateTime? endTime;
  int durationMinutes;
  bool completed;
  bool interrupted;
  String? planType;
  DateTime createdAt;
  DateTime updatedAt;
  int? syncVersion;

  // Getters
  Duration get elapsedTime;
  double get progressPercentage;
  bool get isActive;
  bool get isCompleted;

  // Methods
  Map<String, dynamic> toJson();
  factory FastingSession.fromJson(Map<String, dynamic> json);
}
```

### 2. TimerState
**Path:** `lib/models/timer_state.dart`
**Purpose:** Represents current timer state (SharedPreferences)
**Task:** 8

```dart
class TimerState {
  final DateTime? startTime;
  final int durationMinutes;
  final bool isRunning;
  final String planType;
  final String userId;
  final int? sessionId;
  final Duration timezoneOffset;
  final FastingState state;

  // Getters
  int get remainingMilliseconds;
  int get elapsedMilliseconds;
  bool get isCompleted;
  FastingState get derivedState;
  double get progress;           // 0.0 to 1.0
  String get formattedRemainingTime;  // HH:MM:SS
  String get formattedElapsedTime;    // HH:MM:SS

  // Methods
  bool hasTimezoneChanged();
  double get timezoneOffsetDifferenceHours;
  Map<String, dynamic> toJson();
  factory TimerState.fromJson(Map<String, dynamic> json);
  factory TimerState.empty(String userId);
  TimerState copyWith({...});
}
```

### 3. FastingState (Enum)
**Path:** `lib/models/fasting_state.dart`
**Purpose:** Type-safe fasting session states
**Task:** 8

```dart
enum FastingState {
  idle,      // No active session
  fasting,   // Timer running
  paused,    // Timer paused
  completed, // Session finished
}

extension FastingStateExtension on FastingState {
  bool get canStart;
  bool get canPause;
  bool get canResume;
  bool get canComplete;
  bool get canInterrupt;
  bool get isActive;
  String get displayName;
  String toJson();
  static FastingState fromJson(String json);
}
```

### 4. FastingPlan
**Path:** `lib/models/fasting_plan.dart`
**Purpose:** Predefined fasting plan configurations
**Task:** 9

```dart
enum FastingPlanType {
  plan12_12, plan14_10, plan16_8,
  plan18_6, plan24h, plan48h
}

enum DifficultyLevel {
  beginner, intermediate, advanced
}

enum RecommendedFor {
  fatLoss, autophagy, both
}

class FastingPlan {
  final FastingPlanType type;
  final String title;
  final String description;
  final int fastingHours;
  final int eatingHours;
  final DifficultyLevel difficultyLevel;
  final RecommendedFor recommendedFor;
  final List<String> benefits;
  final IconData icon;

  // Static factory methods
  static FastingPlan plan12_12();
  static FastingPlan plan14_10();
  static FastingPlan plan16_8();
  static FastingPlan plan18_6();
  static FastingPlan plan24h();
  static FastingPlan plan48h();

  // Methods
  static List<FastingPlan> getAllPlans();
  static FastingPlan getByType(FastingPlanType type);
  String get difficultyLevelName;
  Color getDifficultyColor(BuildContext context);
  String get recommendedForText;
  String get durationText;
  Map<String, dynamic> toJson();
  factory FastingPlan.fromJson(Map<String, dynamic> json);
}
```

### 5. AuthState
**Path:** `lib/models/auth_state.dart`
**Purpose:** Authentication state representation
**Task:** 3

```dart
class AuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;

  // Factory constructors
  factory AuthState.loading();
  factory AuthState.authenticated(User user);
  factory AuthState.unauthenticated();
  factory AuthState.error(String message);

  // Getters
  bool get isAuthenticated;
  String? get userId;
  String? get userEmail;

  // Methods
  AuthState copyWith({...});
}
```

### 6. OnboardingState
**Path:** `lib/models/onboarding_state.dart`
**Purpose:** Onboarding flow state
**Task:** 9

```dart
class OnboardingState {
  final bool isCompleted;
  final String? selectedGoal;
  final String? selectedPlanType;
  final int currentStep;

  // Methods
  OnboardingState copyWith({...});
  Map<String, dynamic> toJson();
  factory OnboardingState.fromJson(Map<String, dynamic> json);
}
```

### 7. ConsentRecord (Isar Collection)
**Path:** `lib/models/consent_record.dart`
**Purpose:** GDPR consent tracking
**Task:** 6

```dart
@collection
class ConsentRecord {
  Id id;
  String userId;
  bool analyticsConsent;
  bool marketingConsent;
  bool necessaryConsent;
  DateTime consentDate;
  String? ipAddress;
  String? userAgent;
  DateTime lastUpdated;

  // Methods
  Map<String, dynamic> toJson();
  factory ConsentRecord.fromJson(Map<String, dynamic> json);
}
```

### 8-17. Additional Models
- **User** - Supabase user model extensions
- **Result<T>** - Error handling wrapper (`lib/utils/result.dart`)
- **SupabaseError** - Error types
- **Route models** - Navigation data
- **Form models** - Validation states

---

## 🔄 Providers (Riverpod State Management)

### 1. authNotifierProvider
**Path:** `lib/providers/auth_provider.dart`
**Type:** `StateNotifierProvider<AuthNotifier, AuthState>`
**Task:** 3

```dart
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  // Methods
  Future<void> signIn({required String email, required String password});
  Future<void> signUp({required String email, required String password});
  Future<void> signOut();
  Future<void> resetPassword({required String email});
  Future<void> updateProfile({String? displayName, String? photoUrl});

  // Internal
  void _initialize();
}
```

### 2. Auth Computed Providers
**Path:** `lib/providers/auth_computed_providers.dart`
**Purpose:** Derived auth state values
**Task:** 3

```dart
// Returns bool
final isAuthenticatedProvider = Provider<bool>((ref) => ...);

// Returns User?
final currentUserProvider = Provider<User?>((ref) => ...);

// Returns String?
final currentUserIdProvider = Provider<String?>((ref) => ...);
final currentUserEmailProvider = Provider<String?>((ref) => ...);

// Returns bool
final isAuthLoadingProvider = Provider<bool>((ref) => ...);

// Returns String?
final authErrorMessageProvider = Provider<String?>((ref) => ...);
```

### 3. timerProvider
**Path:** `lib/providers/timer_provider.dart`
**Type:** `StateNotifierProvider<TimerNotifier, TimerState?>`
**Task:** 8

```dart
final timerProvider =
    StateNotifierProvider<TimerNotifier, TimerState?>((ref) {
  return TimerNotifier();
});

class TimerNotifier extends StateNotifier<TimerState?> {
  // Getters
  TimerState? get currentState;
  bool get isRunning;
  int get remainingMilliseconds;
  int get elapsedMilliseconds;
  double get progress;                // 0.0 to 1.0
  bool get isCompleted;
  String get formattedRemainingTime;  // HH:MM:SS
  String get formattedElapsedTime;    // HH:MM:SS
  FastingState get fastingState;

  // Task 8 Specification Methods
  Future<void> startFast({
    required String userId,
    required int durationMinutes,
    required String planType,
  });
  Future<void> pauseFast();
  Future<void> resumeFast();
  Future<void> completeFast();
  Future<void> interruptFast();

  // Legacy methods (compatibility)
  Future<void> startTimer({...});
  Future<void> pauseTimer();
  Future<void> resumeTimer();
  Future<void> cancelTimer({bool wasInterrupted = true});

  // State sync
  Future<void> syncState();
}
```

### 4. onboardingProvider
**Path:** `lib/providers/onboarding_provider.dart`
**Type:** `StateNotifierProvider<OnboardingNotifier, OnboardingState>`
**Task:** 9

```dart
final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier();
});

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  // Methods
  Future<void> saveGoal(String goal);
  Future<void> saveFastingPlan(String planType);
  Future<void> nextStep();
  Future<void> previousStep();
  Future<void> completeOnboarding();
  Future<void> skipOnboarding();
}
```

---

## ⚙️ Services (Business Logic Layer)

### 1. AuthService (Singleton)
**Path:** `lib/services/auth_service.dart`
**Task:** 3

```dart
class AuthService {
  static final AuthService instance = AuthService._internal();

  // Properties
  final SupabaseClient _supabase;
  AuthState get currentState;
  Stream<AuthState> get authStateChanges;

  // Methods
  Future<Result<User>> signIn({
    required String email,
    required String password
  });

  Future<Result<User>> signUp({
    required String email,
    required String password
  });

  Future<Result<void>> signOut();

  Future<Result<void>> resetPassword({required String email});

  Future<Result<User>> updateProfile({
    String? displayName,
    String? photoUrl,
  });

  // Internal
  void _initialize();
  User? _getCurrentUser();
}
```

### 2. TimerService (Singleton)
**Path:** `lib/services/timer_service.dart`
**Task:** 8

```dart
class TimerService {
  static final TimerService instance = TimerService._internal();

  // Properties
  TimerState? get currentState;
  Stream<TimerState> get stateStream;

  // Task 8 Methods
  Future<void> startFast({
    required String userId,
    required int durationMinutes,
    required String planType,
  });

  Future<void> pauseFast();
  Future<void> resumeFast();
  Future<void> completeFast();
  Future<void> interruptFast();

  // Legacy methods
  Future<void> startTimer({...});
  Future<void> pauseTimer();
  Future<void> resumeTimer();
  Future<void> cancelTimer({bool wasInterrupted = true});

  // State management
  Future<void> syncState();
  Future<void> _saveState(TimerState state);
  Future<TimerState?> _loadState();

  // Session management
  Future<void> _createSession();
  Future<void> _updateSession();
  Future<void> _completeSession();
}
```

### 3. ConsentManager (Singleton)
**Path:** `lib/services/consent_manager.dart`
**Task:** 6

```dart
class ConsentManager {
  static final ConsentManager instance = ConsentManager._internal();

  // Methods
  Future<ConsentRecord?> getCurrentConsent(String userId);

  Future<void> saveConsent({
    required String userId,
    required bool analyticsConsent,
    required bool marketingConsent,
    bool necessaryConsent = true,
  });

  Future<void> updateConsent({
    required String userId,
    bool? analyticsConsent,
    bool? marketingConsent,
  });

  Future<bool> hasGivenConsent(String userId, String consentType);

  Future<void> revokeAllConsent(String userId);

  Future<List<ConsentRecord>> getConsentHistory(String userId);
}
```

### 4. SupabaseErrorHandler
**Path:** `lib/services/supabase_error_handler.dart`
**Task:** 5

```dart
class SupabaseErrorHandler {
  // Static methods
  static String handleError(dynamic error);
  static String getUserFriendlyMessage(String errorCode);
  static bool isNetworkError(dynamic error);
  static bool isAuthError(dynamic error);

  // Error code mapping
  static const Map<String, String> _errorMessages = {...};
}
```

### 5. IsarService
**Path:** `lib/services/isar_service.dart`
**Purpose:** Local database management

```dart
class IsarService {
  static Isar? _isar;

  static Future<void> initialize();
  static Isar get instance;

  // Collections
  IsarCollection<FastingSession> get fastingSessions;
  IsarCollection<ConsentRecord> get consentRecords;
}
```

### 6. AnalyticsService (Singleton)
**Path:** `lib/services/analytics_service.dart`
**Task:** 11.3

```dart
class AnalyticsService {
  static final AnalyticsService instance = AnalyticsService._internal();

  // Methods
  Future<void> logEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  });
}
```

**Current Implementation:** Minimal stub with console logging. Ready for Firebase Analytics or other analytics SDK integration.

**Key Events:**
- `panic_button_used` - Tracks when user taps panic button during active fasting
  - Parameters: timestamp, fasting_duration_minutes, plan_type, elapsed_minutes

### 7-13. Additional Services
- **NotificationService** - Push notifications
- **SyncService** - Supabase sync
- **CacheService** - Data caching
- **ValidationService** - Form validation
- **NetworkService** - Connectivity checks
- **StorageService** - SharedPreferences wrapper

---

## 🎨 Theme System (Complete Design System)

### Colors
**Path:** `lib/theme/colors.dart`
**Class:** `ZendfastColors`

```dart
// Primary Colors - Teal for calmness and trust
static const Color primaryTeal = Color(0xFF069494);
static const Color primaryTealLight = Color(0xFF38AEAE);
static const Color primaryTealDark = Color(0xFF047A7A);

// Secondary Colors - Green for growth and balance
static const Color secondaryGreen = Color(0xFF7FB069);
static const Color secondaryGreenLight = Color(0xFF99C284);
static const Color secondaryGreenDark = Color(0xFF659654);

// Panic Button - Orange for urgency but warmth
static const Color panicOrange = Color(0xFFFFB366);
static const Color panicOrangeLight = Color(0xFFFFC285);
static const Color panicOrangeDark = Color(0xFFFF9F47);

// Semantic Colors
static const Color success = Color(0xFF4CAF50);
static const Color warning = Color(0xFFFFA726);
static const Color error = Color(0xFFEF5350);
static const Color info = Color(0xFF42A5F5);

// Light Theme Surface Colors
static const Color lightBackground = Color(0xFFFAFAFA);
static const Color lightSurface = Color(0xFFFFFFFF);
static const Color lightSurfaceVariant = Color(0xFFF5F5F5);

// Dark Theme Surface Colors
static const Color darkBackground = Color(0xFF121212);
static const Color darkSurface = Color(0xFF1E1E1E);
static const Color darkSurfaceVariant = Color(0xFF2C2C2C);

// Text Colors
static const Color lightTextPrimary = Color(0xFF212121);
static const Color lightTextSecondary = Color(0xFF757575);
static const Color darkTextPrimary = Color(0xFFFFFFFF);
static const Color darkTextSecondary = Color(0xFFBDBDBD);

// Factory methods
static ColorScheme lightColorScheme();
static ColorScheme darkColorScheme();
```

### Typography
**Path:** `lib/theme/typography.dart`
**Google Fonts Used:**
- **Inter** - Headers and display text
- **Source Sans 3** - Body text (16sp minimum)
- **Nunito Sans** - Emotional/supportive text

```dart
// Display styles
displayLarge: 57sp
displayMedium: 45sp
displaySmall: 36sp

// Headline styles
headlineLarge: 32sp
headlineMedium: 28sp
headlineSmall: 24sp

// Title styles
titleLarge: 22sp
titleMedium: 16sp
titleSmall: 14sp

// Body styles
bodyLarge: 16sp
bodyMedium: 16sp  // Minimum for accessibility
bodySmall: 14sp

// Label styles
labelLarge: 14sp
labelMedium: 12sp
labelSmall: 11sp
```

### Spacing
**Path:** `lib/theme/spacing.dart`
**Class:** `ZendfastSpacing`

```dart
static const double xs = 4.0;   // Extra small
static const double s = 8.0;    // Small
static const double m = 16.0;   // Medium
static const double l = 24.0;   // Large
static const double xl = 32.0;  // Extra large
static const double xxl = 40.0; // Extra extra large

// Follows 8dp grid system
```

### Animations
**Path:** `lib/theme/animations.dart`
**Class:** `ZendfastAnimations`

```dart
// Durations
static const Duration fast = Duration(milliseconds: 200);
static const Duration standard = Duration(milliseconds: 300);
static const Duration slow = Duration(milliseconds: 500);

// Task 10 uses 250ms for consistency
static const Duration taskStandard = Duration(milliseconds: 250);

// Curves
static const Curve standardCurve = Curves.easeInOut;
static const Curve emphasizedCurve = Curves.easeOutCubic;
static const Curve deceleratedCurve = Curves.easeOut;
```

### Border Radius
```dart
static const double small = 4.0;
static const double medium = 8.0;
static const double large = 12.0;
static const double extraLarge = 16.0;
static const double round = 999.0;
```

---

## 🗺️ Routing & Navigation

**Path:** `lib/config/router.dart`
**Router:** GoRouter 14.6.2

### Routes Defined

```dart
// Auth Routes
'/login'              → LoginScreen
'/signup'             → SignupScreen
'/forgot-password'    → ForgotPasswordScreen

// Onboarding Routes
'/onboarding'         → WelcomeScreen
'/onboarding/goals'   → GoalSelectionScreen
'/onboarding/plans'   → PlanSelectionScreen (Task 9)

// Main App Routes
'/'                   → FastingHomeScreen (Task 10)
'/profile'            → ProfileScreen
'/settings'           → SettingsScreen
'/history'            → HistoryScreen

// Redirect Logic
- Unauthenticated → '/login'
- Authenticated + !onboarded → '/onboarding'
- Authenticated + onboarded → '/'
```

### Auth Guard Pattern
```dart
redirect: (context, state) {
  final isAuthenticated = ref.read(isAuthenticatedProvider);
  final isOnboarded = ref.read(onboardingProvider).isCompleted;

  if (!isAuthenticated && !state.location.startsWith('/login')) {
    return '/login';
  }

  if (isAuthenticated && !isOnboarded) {
    return '/onboarding';
  }

  return null; // No redirect
}
```

---

## 📱 Screens (All Categorized)

### Auth Screens

#### LoginScreen
**Path:** `lib/screens/auth/login_screen.dart`
**Providers:** `authNotifierProvider`
**Features:**
- Email/password login form
- "Forgot password" link
- "Sign up" navigation
- Error display
- Loading state

#### SignupScreen
**Path:** `lib/screens/auth/signup_screen.dart`
**Providers:** `authNotifierProvider`
**Features:**
- Email/password signup form
- Password confirmation
- Terms acceptance
- Error handling

#### ForgotPasswordScreen
**Path:** `lib/screens/auth/forgot_password_screen.dart`
**Providers:** `authNotifierProvider`
**Features:**
- Email input
- Reset link sending
- Success confirmation

### Onboarding Screens

#### WelcomeScreen
**Path:** `lib/screens/onboarding/welcome_screen.dart`
**Features:**
- App introduction
- Feature highlights
- "Get Started" button

#### GoalSelectionScreen
**Path:** `lib/screens/onboarding/goal_selection_screen.dart`
**Providers:** `onboardingProvider`
**Features:**
- Multiple goal options
- Visual cards
- Continue/skip buttons

#### PlanSelectionScreen (Task 9)
**Path:** `lib/screens/onboarding/plan_selection_screen.dart`
**Providers:** `onboardingProvider`
**Features:**
- Display all 6 FastingPlan options
- FastingPlanCard widgets
- Selection state management
- Plan details display
- Continue/skip navigation

### Fasting Screens

#### FastingHomeScreen (Task 10)
**Path:** `lib/screens/fasting/fasting_home_screen.dart`
**Providers:** `timerProvider`, `authNotifierProvider`
**Features:**
- Central timer display (48sp bold)
- Circular progress ring
- Control buttons (start/pause/resume/stop)
- Contextual information (phase, milestones)
- Plan selector bottom sheet
- Dynamic background gradient
- State-based UI changes
- Smooth animations (250ms)

**Components Used:**
- `FastingTimerDisplay` (Subtask 10.1)
- `CircularProgressRing` (Subtask 10.2a)
- `FastingControlButtons` (Subtask 10.2b)
- `FastingContextInfo` (Subtask 10.3)

### Profile Screens

#### SettingsScreen
**Path:** `lib/screens/profile/settings_screen.dart`
**Features:**
- Account settings
- Notification preferences
- Consent management
- Sign out

---

## 🧩 Widgets (Reusable Components Catalog)

### Fasting Widgets

#### FastingTimerDisplay (Task 10.1)
**Path:** `lib/widgets/fasting/fasting_timer_display.dart`
**Type:** `ConsumerWidget`
**Purpose:** Large timer display with dynamic colors

```dart
class FastingTimerDisplay extends ConsumerWidget {
  // Features:
  // - 48sp bold Inter font
  // - Tabular figures for consistent width
  // - Dynamic colors based on FastingState
  // - AnimatedDefaultTextStyle (250ms transitions)
  // - Accessibility labels

  // Colors by state:
  // - fasting: secondaryGreen
  // - paused: panicOrange
  // - completed: primaryTeal
  // - idle: onSurfaceVariant (grey)
}
```

#### CircularProgressRing (Task 10.2a)
**Path:** `lib/widgets/fasting/circular_progress_ring.dart`
**Type:** `ConsumerWidget`
**Purpose:** Progress indicator wrapping timer

```dart
class CircularProgressRing extends ConsumerWidget {
  // Features:
  // - 280dp diameter, 8dp stroke
  // - TweenAnimationBuilder for smooth progress
  // - Dynamic color matching timer state
  // - Centers FastingTimerDisplay inside
  // - Subtle shadow for depth
  // - Accessibility labels
}
```

#### FastingControlButtons (Task 10.2b)
**Path:** `lib/widgets/fasting/fasting_control_buttons.dart`
**Type:** `ConsumerWidget`
**Purpose:** State-dependent control buttons

```dart
class FastingControlButtons extends ConsumerWidget {
  final VoidCallback? onStartPressed;

  // Features:
  // - AnimatedSwitcher for button transitions (250ms)
  // - Haptic feedback on all presses
  // - Confirmation dialog for interrupt/stop
  // - Error handling with SnackBar

  // Button states:
  // - idle: "Iniciar Ayuno" (green filled)
  // - fasting: "Pausar" (orange), "Detener" (red outlined)
  // - paused: "Reanudar" (green), "Detener" (red outlined)
}
```

#### FastingContextInfo (Task 10.3)
**Path:** `lib/widgets/fasting/fasting_context_info.dart`
**Type:** `ConsumerStatefulWidget`
**Purpose:** Contextual phase information

```dart
class FastingContextInfo extends ConsumerStatefulWidget {
  // Features:
  // - Phase labels with emojis
  // - Elapsed/remaining time toggle
  // - Smart milestone calculation
  // - AnimatedSwitcher for all transitions (250ms)
  // - AnimatedContainer for layout changes

  // Milestones calculated:
  // - 12h: fase de cetosis
  // - 16h: autofagia
  // - 18h: beneficios máximos
  // - 24h: ayuno extendido
}
```

#### FastingPlanCard (Task 9)
**Path:** `lib/widgets/fasting/fasting_plan_card.dart`
**Type:** `StatelessWidget`
**Purpose:** Display fasting plan option

```dart
class FastingPlanCard extends StatelessWidget {
  final FastingPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  // Features:
  // - Material 3 design
  // - Selection state visual
  // - Difficulty badge
  // - Benefits list
  // - AnimatedContainer (250ms)
}
```

#### PanicButton (Task 11.1 & 11.2)
**Path:** `lib/widgets/fasting/panic_button.dart`
**Type:** `ConsumerStatefulWidget`
**Purpose:** Emotional support FAB during active fasting

```dart
class PanicButton extends ConsumerStatefulWidget {
  // Features:
  // - Only visible when fastingState.isActive (fasting or paused)
  // - Orange color (#FFB366 - panicOrange)
  // - Heart icon (white)
  // - Pulse animation (1.0 to 1.1 scale, 1500ms, repeating)
  // - Haptic feedback on tap
  // - Opens PanicButtonModal
  // - Tracks analytics event 'panic_button_used'
  // - 6.0dp elevation

  // Animation:
  // - AnimationController with SingleTickerProviderStateMixin
  // - Tween<double>(1.0, 1.1) with Curves.easeInOut
  // - AnimatedBuilder wrapping Transform.scale
  // - Repeats infinitely (reverse: true)
}
```

#### PanicButtonModal (Task 11)
**Path:** `lib/widgets/fasting/panic_button_modal.dart`
**Type:** `ConsumerWidget`
**Purpose:** Bottom sheet with emotional support content

```dart
class PanicButtonModal extends ConsumerWidget {
  // Static method:
  static Future<void> show({required BuildContext context});

  // Features:
  // - Bottom sheet with rounded top corners (24dp)
  // - Handle bar (40w × 4h dp)
  // - Title: "Apoyo Emocional"
  // - 5 motivational phrases with icons:
  //   1. "Eres más fuerte de lo que crees"
  //   2. "Bebe agua lentamente"
  //   3. "Toma 5 respiraciones profundas"
  //   4. "Sal a caminar 5 minutos"
  //   5. "Llama a un amigo"
  // - Each phrase closes modal on tap
  // - "No puedo continuar" destructive button (red)
  // - Confirmation dialog before interrupting fast
  // - Calls timerProvider.notifier.interruptFast()
  // - SingleChildScrollView for content
  // - Draggable and dismissible
}
```

### Common Widgets

#### LoadingOverlay
**Path:** `lib/widgets/common/loading_overlay.dart`
**Purpose:** Full-screen loading indicator

#### ErrorDialog
**Path:** `lib/widgets/common/error_dialog.dart`
**Purpose:** Consistent error display

---

## 📐 Code Patterns & Best Practices

### Riverpod Patterns

#### ConsumerWidget Pattern
```dart
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch provider for reactive updates
    final state = ref.watch(myProvider);

    // Read provider for one-time access (callbacks)
    onPressed: () => ref.read(myProvider.notifier).method();

    return Widget(...);
  }
}
```

#### ConsumerStatefulWidget Pattern
```dart
class MyWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<MyWidget> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myProvider);
    return Widget(...);
  }
}
```

### Error Handling Pattern

#### Result<T> Type
```dart
// Success
return Result.success(data);

// Failure
return Result.failure('Error message');

// Usage
final result = await service.method();
result.when(
  success: (data) => handleSuccess(data),
  failure: (error) => handleError(error),
);
```

#### Try-Catch with SupabaseErrorHandler
```dart
try {
  await supabase.method();
} catch (e) {
  final message = SupabaseErrorHandler.handleError(e);
  // Show user-friendly message
}
```

### Animation Pattern (Task 10 Standard)

#### Consistent Animations
```dart
// Duration: 250ms
// Curve: Curves.easeInOut

AnimatedContainer(
  duration: const Duration(milliseconds: 250),
  curve: Curves.easeInOut,
  // ... properties
)

AnimatedSwitcher(
  duration: const Duration(milliseconds: 250),
  transitionBuilder: (child, animation) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  },
  child: widget,
)

AnimatedDefaultTextStyle(
  duration: const Duration(milliseconds: 250),
  curve: Curves.easeInOut,
  style: textStyle,
  child: Text(...),
)
```

### Navigation Pattern

#### GoRouter Navigation
```dart
// Navigate to route
context.go('/path');

// Navigate with parameters
context.go('/user/${userId}');

// Navigate and replace
context.goNamed('routeName', pathParameters: {...});

// Pop
context.pop();
context.pop(result);
```

### Theme Usage Pattern

#### Accessing Theme
```dart
// Colors
final colorScheme = Theme.of(context).colorScheme;
final primaryColor = colorScheme.primary;

// Custom colors
ZendfastColors.primaryTeal;
ZendfastColors.secondaryGreen;
ZendfastColors.panicOrange;

// Typography
final textTheme = Theme.of(context).textTheme;
final headlineStyle = textTheme.headlineMedium;

// Spacing
ZendfastSpacing.m  // 16dp
ZendfastSpacing.l  // 24dp
```

### Haptic Feedback Pattern
```dart
import 'package:flutter/services.dart';

onPressed: () {
  HapticFeedback.mediumImpact();
  // ... action
}
```

### State Color Mapping Pattern
```dart
Color getColorForState(FastingState state, ColorScheme scheme) {
  switch (state) {
    case FastingState.fasting:
      return ZendfastColors.secondaryGreen;
    case FastingState.paused:
      return ZendfastColors.panicOrange;
    case FastingState.completed:
      return scheme.primary;
    case FastingState.idle:
      return scheme.onSurfaceVariant;
  }
}
```

---

## 🔌 External Integrations

### Supabase

#### Configuration
**Path:** `lib/config/supabase_config.dart`

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_ANON_KEY',
);

final supabase = Supabase.instance.client;
```

#### Auth Usage
```dart
// Sign up
await supabase.auth.signUp(
  email: email,
  password: password,
);

// Sign in
await supabase.auth.signInWithPassword(
  email: email,
  password: password,
);

// Sign out
await supabase.auth.signOut();

// Get current user
final user = supabase.auth.currentUser;

// Listen to auth changes
supabase.auth.onAuthStateChange.listen((data) {
  final event = data.event;
  final session = data.session;
});
```

#### Database Usage
```dart
// Insert
await supabase.from('table').insert({...});

// Query
final data = await supabase.from('table')
  .select()
  .eq('column', value);

// Update
await supabase.from('table')
  .update({...})
  .eq('id', id);

// Delete
await supabase.from('table')
  .delete()
  .eq('id', id);
```

### Isar Local Database

#### Initialization
```dart
await IsarService.initialize();
final isar = IsarService.instance;
```

#### CRUD Operations
```dart
// Write
await isar.writeTxn(() async {
  await isar.fastingSessions.put(session);
});

// Read
final session = await isar.fastingSessions.get(id);

// Query
final sessions = await isar.fastingSessions
  .filter()
  .userIdEqualTo(userId)
  .findAll();

// Delete
await isar.writeTxn(() async {
  await isar.fastingSessions.delete(id);
});
```

---

## 📋 Dependencies (pubspec.yaml)

### Core Dependencies
```yaml
flutter:
  sdk: flutter

# State Management
flutter_riverpod: ^2.6.1

# Backend
supabase_flutter: ^2.9.1

# Local Database
isar: ^3.1.0+1
isar_flutter_libs: ^3.1.0+1

# Routing
go_router: ^14.6.2

# UI
google_fonts: ^6.2.1

# Storage
shared_preferences: ^2.3.4

# Utilities
uuid: ^4.5.1
intl: ^0.20.1
```

### Dev Dependencies
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  build_runner: ^2.4.14
  isar_generator: ^3.1.0+1
```

### Assets
```yaml
flutter:
  uses-material-design: true
  # Assets to be declared here
```

---

## 🔄 Recent Changes (Last 5 Tasks)

### Task 11: Panic Button Implementation (Completed 2025-01-10)
**Files Created:**
- `lib/services/analytics_service.dart`
- `lib/widgets/fasting/panic_button.dart`
- `lib/widgets/fasting/panic_button_modal.dart`
- `test/services/analytics_service_test.dart`
- `test/widgets/fasting/panic_button_test.dart`
- `test/widgets/fasting/panic_button_modal_test.dart`

**Files Modified:**
- `lib/screens/fasting/fasting_home_screen.dart` (added floatingActionButton)

**Features:**
- Emotional support FAB visible only during active fasting (fasting or paused states)
- Smooth pulse animation (1.0 to 1.1 scale, 1500ms repeating)
- Haptic feedback on button tap
- Bottom sheet modal with 5 motivational phrases
- Confirmation dialog before interrupting fast
- Analytics event tracking (panic_button_used with metadata)
- Fully scrollable modal content
- Draggable and dismissible bottom sheet

**Test Coverage:**
- 34 total tests (5 analytics + 17 panic button + 12 modal)
- Full TDD implementation with Red-Green-Refactor cycles
- All tests passing

**Patterns Followed:**
- ConsumerStatefulWidget with SingleTickerProviderStateMixin
- AnimationController lifecycle management
- State-based visibility logic (FastingState.isActive)
- Confirmation dialogs for destructive actions
- Analytics integration with contextual metadata
- Orange color (#FFB366) for urgency but warmth

### Task 10: FastingHomeScreen (Completed 2025-01-10)
**Files Created:**
- `lib/screens/fasting/fasting_home_screen.dart`
- `lib/widgets/fasting/fasting_timer_display.dart`
- `lib/widgets/fasting/circular_progress_ring.dart`
- `lib/widgets/fasting/fasting_control_buttons.dart`
- `lib/widgets/fasting/fasting_context_info.dart`

**Features:**
- Main fasting screen with timer, progress ring, and controls
- Dynamic color states based on FastingState
- Smooth 250ms animations throughout
- Haptic feedback on button presses
- Plan selector bottom sheet
- Milestone tracking system

**Patterns Established:**
- 250ms animation duration standard
- Curves.easeInOut for all transitions
- State-based color mapping
- AnimatedSwitcher for state changes
- Accessibility labels on all components

### Task 9: Plan Selection Screen (Completed)
**Files Created:**
- `lib/screens/onboarding/plan_selection_screen.dart`
- `lib/widgets/fasting/fasting_plan_card.dart`
- `lib/models/fasting_plan.dart`

**Features:**
- 6 predefined fasting plans (12/12 to 48h)
- Difficulty levels (beginner/intermediate/advanced)
- Benefits lists
- Material 3 card design

### Task 8: Timer Provider & Service (Completed)
**Files Created:**
- `lib/providers/timer_provider.dart`
- `lib/services/timer_service.dart`
- `lib/models/timer_state.dart`
- `lib/models/fasting_state.dart`

**Features:**
- Background timer service
- SharedPreferences persistence
- Real-time state stream
- 5 main methods: startFast, pauseFast, resumeFast, completeFast, interruptFast
- Timezone change detection

### Task 7: Fasting Session Model (Completed)
**Files Created:**
- `lib/models/fasting_session.dart`

**Features:**
- Isar collection for session storage
- Progress calculation
- JSON serialization for Supabase sync
- Helper methods for elapsed time and status

### Task 6: Consent Manager (Completed)
**Files Created:**
- `lib/services/consent_manager.dart`
- `lib/models/consent_record.dart`

**Features:**
- GDPR compliance
- Consent tracking in Isar
- Analytics/marketing consent separation
- Consent history

---

## 🎯 Quick Reference Tables

### Provider Quick Reference
| Provider | File | State Type | Key Methods |
|----------|------|------------|-------------|
| timerProvider | timer_provider.dart | TimerState? | startFast(), pauseFast(), resumeFast(), completeFast(), interruptFast() |
| authNotifierProvider | auth_provider.dart | AuthState | signIn(), signUp(), signOut(), resetPassword() |
| onboardingProvider | onboarding_provider.dart | OnboardingState | saveGoal(), saveFastingPlan(), completeOnboarding() |
| isAuthenticatedProvider | auth_computed_providers.dart | bool | (computed from authNotifierProvider) |
| currentUserIdProvider | auth_computed_providers.dart | String? | (computed from authNotifierProvider) |

### Service Quick Reference
| Service | File | Type | Key Methods |
|---------|------|------|-------------|
| AuthService | auth_service.dart | Singleton | signIn(), signUp(), signOut(), resetPassword() |
| TimerService | timer_service.dart | Singleton | startFast(), pauseFast(), resumeFast(), completeFast() |
| ConsentManager | consent_manager.dart | Singleton | saveConsent(), updateConsent(), getCurrentConsent() |
| AnalyticsService | analytics_service.dart | Singleton | logEvent() |
| IsarService | isar_service.dart | Static | initialize(), fastingSessions, consentRecords |

### Model Quick Reference
| Model | File | Type | Key Fields |
|-------|------|------|-----------|
| FastingSession | fasting_session.dart | Isar Collection | userId, startTime, endTime, durationMinutes, completed |
| TimerState | timer_state.dart | Class | startTime, durationMinutes, isRunning, planType, state |
| FastingState | fasting_state.dart | Enum | idle, fasting, paused, completed |
| FastingPlan | fasting_plan.dart | Class | type, title, fastingHours, eatingHours, difficulty |
| AuthState | auth_state.dart | Class | user, isLoading, errorMessage |

### Color Quick Reference
| Color | Hex | Usage |
|-------|-----|-------|
| primaryTeal | #069494 | Primary brand, completed state |
| secondaryGreen | #7FB069 | Fasting active state, success |
| panicOrange | #FFB366 | Paused state, warnings |
| success | #4CAF50 | Success messages |
| warning | #FFA726 | Warning messages |
| error | #EF5350 | Error messages |

### Route Quick Reference
| Route | Screen | Auth Required | Onboarding Required |
|-------|--------|---------------|---------------------|
| /login | LoginScreen | No | No |
| /signup | SignupScreen | No | No |
| /onboarding | WelcomeScreen | Yes | No |
| /onboarding/plans | PlanSelectionScreen | Yes | No |
| / | FastingHomeScreen | Yes | Yes |
| /settings | SettingsScreen | Yes | Yes |

---

## 📝 Update Instructions for Claude

**When completing a task, automatically update this document:**

1. **Add new files** to appropriate sections with full paths
2. **Update "Last Updated"** with current date and task number
3. **Add to "Recent Changes"** section (keep last 5 tasks)
4. **Update affected sections:**
   - New providers → Add to Providers section with full API
   - New services → Add to Services section
   - New models → Add to Models section with fields
   - New screens → Add to Screens section
   - New widgets → Add to Widgets section
   - New patterns → Add to Code Patterns section
5. **Update Quick Reference Tables** if new major components added
6. **Document new dependencies** in Dependencies section if added
7. **Note any breaking changes** in Recent Changes

**Keep this document:**
- ✅ Comprehensive - Every file matters
- ✅ Current - Update after each task
- ✅ Searchable - Clear headers and structure
- ✅ Practical - File paths and code signatures included
- ✅ Organized - Easy to scan sections

---

## 🔍 Document Usage Tips

**For Claude Code:**
- Read this document at the start of each task for instant context
- Only research specific aspects not covered here
- Update after completing each task
- Keep Recent Changes current

**For Developers:**
- Quick reference for component locations
- Understanding project architecture
- Onboarding new team members
- Finding reusable components

**For Task Planning:**
- Check existing components before creating new ones
- Understand dependencies between tasks
- Follow established patterns
- Maintain consistency

---

*This document is auto-maintained by Claude Code and serves as the single source of truth for the Zendfast codebase architecture.*
