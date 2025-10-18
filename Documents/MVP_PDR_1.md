<rpg-method>
# Zendfast MVP - RPG-Structured PRD

This PRD follows the Repository Planning Graph (RPG) methodology for dependency-aware task breakdown with Task Master.

**Core Principles:**
- Dual-Semantics: Separate WHAT (functional capabilities) from HOW (code structure)
- Explicit Dependencies: Clear topological ordering
- Progressive Refinement: Build foundation first, iterate upward
</rpg-method>

---

<overview>
## Problem Statement

Users attempting intermittent fasting lack integrated tools for:
- Real-time timer tracking with background persistence
- Emotional support during critical hunger moments (panic/cravings)
- Hydration management and educational content in one place

**Pain Point:** Existing fasting apps provide timers but no emotional resilience support when users want to quit mid-fast.

## Target Users

1. **Beginner Fasters** - First-time users needing guidance and detox protocol
2. **Experienced Fasters** - Seeking metrics, streaks, and advanced tracking
3. **Health-Conscious Users** - Interested in learning content and science behind fasting

## Success Metrics

- **70%** fasting session completion rate
- **40%** panic button usage during active fasts
- **50%** 48-hour detox completion (first-time users)
- **30%** D7 retention
- **15%** premium conversion rate
</overview>

---

<functional-decomposition>
## Capability Tree

### Capability: Fasting Management
**Purpose:** Core timer, plans, and session lifecycle management

#### Feature: Plan Selection
- **Description**: User selects from predefined or custom fasting plans
- **Inputs**: User preference, experience level
- **Outputs**: Selected plan configuration (fasting/eating windows)
- **Behavior**: Store plan, configure timer, enable background service

#### Feature: Timer Engine
- **Description**: Real-time countdown with background persistence
- **Inputs**: Plan configuration, current time, user state
- **Outputs**: Elapsed/remaining time, phase state (fasting/eating)
- **Behavior**: Run in background service, persist across app kills, emit notifications

#### Feature: Session Management
- **Description**: Start, pause, complete, or interrupt fasting sessions
- **Inputs**: User action (start/stop/interrupt), timer state
- **Outputs**: Updated session record, metrics update
- **Behavior**: Save to Isar, sync to Supabase, update streak/metrics

---

### Capability: Emotional Support (Differentiator)
**Purpose:** Help users resist cravings and complete fasting sessions

#### Feature: Panic Button
- **Description**: Emergency overlay with motivational content during active fast
- **Inputs**: User tap (only during fasting phase), current fast progress
- **Outputs**: Modal with motivation, meditation option, or interrupt option
- **Behavior**: Show motivational quote, breathing exercise option, track panic events

#### Feature: Meditation Engine (4-4-8 Breathing)
- **Description**: Guided breathing animation to calm cravings
- **Inputs**: User starts meditation from panic modal
- **Outputs**: Visual breathing animation, cycle counter
- **Behavior**: Play Lottie animation, track completion, offer "continue fast" or "can't continue" options

#### Feature: Motivational Content
- **Description**: Dynamic quotes and anti-binge tips
- **Inputs**: Panic button trigger, user progress
- **Outputs**: Contextual message
- **Behavior**: Random selection from curated library

---

### Capability: Hydration Tracking
**Purpose:** Prevent dehydration during fasting

#### Feature: Water Goal Calculation
- **Description**: Auto-calculate daily water goal from user weight
- **Inputs**: User weight (kg)
- **Outputs**: Daily water goal (ml), glass size (ml)
- **Behavior**: Formula = weight_kg × 32 ml, configurable glass size

#### Feature: Water Logging
- **Description**: Quick-tap to log water intake
- **Inputs**: User tap, glass size
- **Outputs**: Updated hydration progress (%)
- **Behavior**: Increment daily total, update Isar, show visual progress

#### Feature: Hydration Reminders
- **Description**: Push notifications for water intake
- **Inputs**: User schedule, hydration goal
- **Outputs**: OneSignal push notification
- **Behavior**: Fire reminders at intervals, pause during eating windows (optional)

---

### Capability: Metrics & Analytics
**Purpose:** Track progress, streaks, and patterns

#### Feature: Dashboard Visualization
- **Description**: Show current streak, total hours fasted, completion rate
- **Inputs**: Session history, current date
- **Outputs**: Widgets (streak, total hours, calendar heatmap)
- **Behavior**: Query Isar, calculate stats, render charts

#### Feature: History & Calendar
- **Description**: Visual calendar with completed/interrupted fasts
- **Inputs**: User fasting sessions (from Isar)
- **Outputs**: Calendar UI with color-coded days
- **Behavior**: Green = completed, orange = interrupted, gray = no session

#### Feature: Pattern Analysis
- **Description**: Identify best fasting days/times for user
- **Inputs**: Historical session data
- **Outputs**: Insights (e.g., "You complete 80% of fasts starting Monday mornings")
- **Behavior**: Run basic analytics on session start times and completion rates

---

### Capability: Learning Content
**Purpose:** Educate users on fasting science and best practices

#### Feature: Content Library
- **Description**: Curated articles, videos, studies
- **Inputs**: User browsing, search query
- **Outputs**: List of content items (title, category, thumbnail)
- **Behavior**: Fetch from Supabase, cache locally, support offline viewing for articles

#### Feature: Video Integration
- **Description**: Embedded YouTube videos on fasting topics
- **Inputs**: Video URL, user selection
- **Outputs**: Embedded player or external link
- **Behavior**: Use youtube_player_flutter, requires internet

#### Feature: Favorites
- **Description**: Save favorite articles/videos for later
- **Inputs**: User tap "favorite" icon
- **Outputs**: Updated favorites list
- **Behavior**: Store in Isar, sync to Supabase

---

### Capability: User Management & Onboarding
**Purpose:** Authentication, profile setup, and first-time experience

#### Feature: Authentication
- **Description**: Email/password login via Supabase Auth
- **Inputs**: Email, password
- **Outputs**: Authenticated session token
- **Behavior**: Supabase Auth, store session, enable RLS

#### Feature: Onboarding Flow
- **Description**: Welcome screens, questionnaire, detox recommendation
- **Inputs**: User answers (weight, height, first-time status)
- **Outputs**: User profile record
- **Behavior**: 6-step flow (splash → intro → register → quiz → paywall → detox question)

#### Feature: 48-Hour Detox Plan
- **Description**: Optional carnivore-style detox before first fast
- **Inputs**: User accepts detox recommendation
- **Outputs**: 48-hour timer, food guidelines
- **Behavior**: Track detox timer separately, show completion before fasting plan selection

#### Feature: Profile Management
- **Description**: Update weight, height, hydration settings
- **Inputs**: User edits
- **Outputs**: Updated user_profiles record
- **Behavior**: Update Isar and Supabase, recalculate hydration goal
</functional-decomposition>

---

<structural-decomposition>
## Repository Structure

```
lib/
├── core/                         # Foundation layer
│   ├── theme/                    # Design system (ZendfastColors, typography)
│   ├── services/                 # Background service, notifications
│   ├── database/                 # Isar schemas and sync manager
│   └── utils/                    # Helpers, constants
├── features/
│   ├── auth/                     # Authentication capability
│   │   ├── providers/            # Riverpod auth state
│   │   ├── screens/              # Login, register
│   │   └── services/             # Supabase auth service
│   ├── onboarding/               # Onboarding capability
│   │   ├── screens/              # Splash, intro, quiz, detox
│   │   └── providers/            # Onboarding state
│   ├── fasting/                  # Fasting management capability
│   │   ├── models/               # FastingPlan, FastingSession (Isar)
│   │   ├── providers/            # Timer state, plan selection
│   │   ├── services/             # Timer engine, background service
│   │   └── screens/              # Home (timer UI), plan selection
│   ├── panic/                    # Emotional support capability
│   │   ├── screens/              # Panic modal, meditation screen
│   │   ├── providers/            # Panic state
│   │   └── widgets/              # Breathing animation (Lottie)
│   ├── hydration/                # Hydration capability
│   │   ├── models/               # HydrationLog (Isar)
│   │   ├── providers/            # Hydration state
│   │   └── widgets/              # Water button, progress bar
│   ├── metrics/                  # Analytics capability
│   │   ├── providers/            # Metrics calculation
│   │   └── screens/              # Dashboard, calendar, history
│   ├── learning/                 # Learning content capability
│   │   ├── models/               # ContentItem (Isar)
│   │   ├── providers/            # Content state
│   │   └── screens/              # Content list, article/video viewer
│   └── profile/                  # Profile management capability
│       ├── models/               # UserProfile (Isar)
│       ├── providers/            # Profile state
│       └── screens/              # Settings, profile edit
├── shared/
│   └── widgets/                  # Reusable UI components
└── main.dart                     # App entry point
```

## Module Definitions

### Module: core/database
- **Maps to capability**: Foundation (all capabilities depend on this)
- **Responsibility**: Isar database setup, schemas, Supabase sync
- **Exports**:
  - `DatabaseService` - Initialize Isar, register schemas
  - `SyncManager` - Bidirectional sync with Supabase
  - Isar collection getters (sessions, profiles, hydration logs)

### Module: features/fasting
- **Maps to capability**: Fasting Management
- **Responsibility**: Timer logic, session lifecycle, plan selection
- **Exports**:
  - `TimerService` - Background timer engine
  - `fastingTimerProvider` - Current timer state (Riverpod)
  - `FastingHomeScreen` - Main timer UI

### Module: features/panic
- **Maps to capability**: Emotional Support
- **Responsibility**: Panic button, meditation, motivational content
- **Exports**:
  - `PanicModal` - Emergency overlay widget
  - `MeditationScreen` - 4-4-8 breathing animation
  - `panicStateProvider` - Panic event tracking

### Module: features/hydration
- **Maps to capability**: Hydration Tracking
- **Responsibility**: Water logging, goal calculation, reminders
- **Exports**:
  - `HydrationService` - Goal calculation, log management
  - `WaterButton` - Quick-log widget
  - `hydrationProvider` - Daily progress state

### Module: features/metrics
- **Maps to capability**: Metrics & Analytics
- **Responsibility**: Dashboard, history, pattern analysis
- **Exports**:
  - `MetricsService` - Calculate stats from Isar sessions
  - `MetricsDashboardScreen` - Main metrics UI
  - `metricsProvider` - Computed metrics state

### Module: features/learning
- **Maps to capability**: Learning Content
- **Responsibility**: Content library, favorites, video playback
- **Exports**:
  - `ContentService` - Fetch and cache content
  - `LearningHomeScreen` - Content browsing UI
  - `contentProvider` - Content state and favorites

### Module: features/auth
- **Maps to capability**: User Management (Authentication)
- **Responsibility**: Supabase Auth, session management
- **Exports**:
  - `AuthService` - Login, register, logout
  - `authStateProvider` - Current user session
  - `LoginScreen`, `RegisterScreen`

### Module: features/onboarding
- **Maps to capability**: User Management (Onboarding)
- **Responsibility**: First-time user flow, detox recommendation
- **Exports**:
  - `OnboardingCoordinator` - 6-step flow orchestration
  - `DetoxScreen` - 48-hour detox timer
  - `onboardingProvider` - Onboarding state
</structural-decomposition>

---

<dependency-graph>
## Dependency Chain

### Foundation Layer (Phase 0)
**No dependencies - built first**

- **core/theme**: Design system (colors, typography, spacing)
- **core/database**: Isar setup, schemas, sync manager
- **core/services/background_service**: Flutter background service wrapper
- **core/services/notification_service**: OneSignal initialization

### Data Layer (Phase 1)
- **features/auth**: Depends on [core/database]
- **features/onboarding**: Depends on [features/auth]

### Core Fasting (Phase 2)
- **features/fasting/models**: Depends on [core/database]
- **features/fasting/services**: Depends on [core/services/background_service, features/fasting/models]
- **features/fasting/screens**: Depends on [features/fasting/services, core/theme]

### Emotional Support (Phase 3)
- **features/panic**: Depends on [features/fasting/services, core/theme]
  - Must read timer state to enable panic button only during fasting

### Hydration & Metrics (Phase 4)
- **features/hydration**: Depends on [core/database, core/services/notification_service, features/auth]
- **features/metrics**: Depends on [features/fasting/models, core/database]

### Content & Profile (Phase 5)
- **features/learning**: Depends on [core/database, features/auth]
- **features/profile**: Depends on [features/auth, features/hydration, features/metrics]

### Monetization (Phase 6)
- **Superwall integration**: Depends on [features/auth, features/onboarding]

### Launch (Phase 7)
- **Testing, polish, deployment**: Depends on all above
</dependency-graph>

---

<implementation-roadmap>
## Development Phases

### Phase 0: Foundation (Week 1)
**Goal**: Establish core infrastructure

**Entry Criteria**: Flutter project initialized, dependencies installed

**Tasks**:
- [ ] Setup Isar v3.1.0 with schemas (FastingSession, UserProfile, HydrationLog, ContentItem)
  - Acceptance: Isar collections queryable, build_runner completes
  - Test: Unit tests for CRUD operations
- [ ] Create design system (ZendfastColors, typography, spacing constants)
  - Acceptance: Theme applied globally via ThemeData
  - Test: Visual snapshot tests
- [ ] Configure Supabase client (auth, database, RLS)
  - Acceptance: Supabase client initialized, auth flow works
  - Test: Integration test for auth
- [ ] Setup background service wrapper
  - Acceptance: Background service runs on app kill
  - Test: Timer persists across force-quit

**Exit Criteria**: Other features can import foundation without errors

**Delivers**: Runnable app with empty screens, working database and theme

---

### Phase 1: Authentication & Onboarding (Week 2)
**Goal**: User registration and first-time experience

**Entry Criteria**: Phase 0 complete

**Tasks**:
- [ ] Implement Supabase Auth (email/password) (depends on: Supabase setup)
  - Acceptance: Users can register, login, logout
  - Test: Integration tests for auth flows
- [ ] Build onboarding flow (splash → intro → quiz → paywall) (depends on: Auth)
  - Acceptance: New users complete 6-step flow
  - Test: E2E test for full onboarding
- [ ] Add 48-hour detox screen (depends on: Onboarding flow)
  - Acceptance: First-time users can opt into detox timer
  - Test: Detox timer counts down correctly

**Exit Criteria**: Users can sign up, complete onboarding, and reach main app

**Delivers**: Working registration and user profiles stored in Supabase

---

### Phase 2: Core Fasting Timer (Weeks 3-4)
**Goal**: MVP-critical fasting timer with background persistence

**Entry Criteria**: Phase 1 complete, users authenticated

**Tasks**:
- [ ] Create Isar FastingSession model (depends on: Isar setup)
- [ ] Build TimerService with background persistence (depends on: Background service, FastingSession model)
  - Acceptance: Timer runs in background, survives app kill
  - Test: Timer accuracy within ±5 seconds after 16-hour fast
- [ ] Design plan selection UI (12/12, 14/10, 16/8, 18/6, 24h, 2d) (depends on: Design system)
- [ ] Build FastingHomeScreen with timer UI (depends on: TimerService, Plan selection)
  - Acceptance: Users see countdown, can start/stop timer
  - Test: E2E test for starting and completing a fast
- [ ] Implement session completion and metrics update (depends on: TimerService)
  - Acceptance: Completed sessions saved to Isar
  - Test: Verify sessions persist and sync to Supabase

**Exit Criteria**: Users can select plan, start timer, complete fast, see session saved

**Delivers**: Functional fasting timer (MVP core value)

---

### Phase 3: Panic Button & Meditation (Week 5)
**Goal**: Emotional support differentiator

**Entry Criteria**: Phase 2 complete, timer working

**Tasks**:
- [ ] Build PanicModal UI (depends on: Timer state)
  - Acceptance: Modal appears only during active fast
  - Test: Panic button hidden during eating window
- [ ] Add motivational quotes library (depends on: PanicModal)
- [ ] Implement 4-4-8 breathing animation (Lottie) (depends on: PanicModal)
  - Acceptance: Animation plays smoothly, cycles tracked
  - Test: Performance test (60fps on mid-range devices)
- [ ] Handle "I broke my fast" flow (depends on: Timer service)
  - Acceptance: Interrupted sessions marked in Isar, metrics updated
  - Test: Verify interrupted sessions sync correctly

**Exit Criteria**: Users can access panic button, meditate, or mark fast as interrupted

**Delivers**: Emotional support feature (key differentiator)

---

### Phase 4: Hydration & Metrics Dashboard (Week 6)
**Goal**: Complete MVP feature set

**Entry Criteria**: Phase 3 complete

**Tasks**:
- [ ] Build HydrationService (goal calculation, logging) (depends on: UserProfile, Isar)
  - Acceptance: Water goal auto-calculated from weight
  - Test: Goal formula accuracy (weight_kg × 32)
- [ ] Create WaterButton widget (depends on: HydrationService)
  - Acceptance: One tap logs water, updates progress
  - Test: Rapid taps handle correctly (debouncing)
- [ ] Build MetricsDashboardScreen (depends on: FastingSession data)
  - Acceptance: Shows streak, total hours, completion rate
  - Test: Verify metrics calculation accuracy
- [ ] Add calendar heatmap (depends on: Metrics calculations)
  - Acceptance: Visual calendar with color-coded days
  - Test: Verify colors match session status

**Exit Criteria**: Users can log water and view metrics dashboard

**Delivers**: Complete MVP (timer + panic + hydration + metrics)

---

### Phase 5: Learning Content & Profile (Week 7)
**Goal**: Content library and profile management

**Entry Criteria**: Phase 4 complete

**Tasks**:
- [ ] Create ContentItem Isar model and Supabase table (depends on: Database setup)
- [ ] Build ContentService (fetch, cache, favorites) (depends on: ContentItem model)
- [ ] Design LearningHomeScreen UI (depends on: ContentService)
  - Acceptance: Users browse articles, videos, studies
  - Test: Offline access for cached articles
- [ ] Integrate youtube_player_flutter (depends on: LearningHomeScreen)
  - Acceptance: Videos play in-app or open externally
  - Test: Video playback on iOS and Android
- [ ] Build ProfileScreen (settings, weight update) (depends on: UserProfile)
  - Acceptance: Users update weight, theme, notification preferences
  - Test: Changes persist and sync

**Exit Criteria**: Users can browse learning content and edit profile

**Delivers**: Educational content and profile customization

---

### Phase 6: Monetization & Notifications (Week 8)
**Goal**: Revenue and engagement features

**Entry Criteria**: Phase 5 complete

**Tasks**:
- [ ] Integrate Superwall paywall (depends on: Onboarding complete)
  - Acceptance: Paywall shows after onboarding, A/B testing works
  - Test: Verify premium unlock flows
- [ ] Setup OneSignal push notifications (depends on: Notification service)
  - Acceptance: Users receive reminders for water, fast start/end
  - Test: Notifications arrive on iOS and Android
- [ ] Configure notification triggers (depends on: Timer state, Hydration schedule)
  - Acceptance: Notifications fire at correct times
  - Test: Verify delivery in background

**Exit Criteria**: Paywall functional, notifications working

**Delivers**: Revenue stream and user retention tools

---

### Phase 7: Testing, Polish & Launch (Week 9-10)
**Goal**: Production-ready app

**Entry Criteria**: All features complete

**Tasks**:
- [ ] Accessibility audit (WCAG 2.1 AA) (depends on: All UI)
  - Acceptance: All screens pass accessibility scanner
  - Test: Manual testing with TalkBack/VoiceOver
- [ ] Performance optimization (depends on: All features)
  - Acceptance: App launches <2s, animations 60fps
  - Test: Performance profiling on low-end devices
- [ ] E2E testing suite (depends on: All features)
  - Acceptance: Critical paths covered
  - Test: Automated E2E tests pass
- [ ] Setup Sentry error monitoring (depends on: All features)
  - Acceptance: Crashes reported to Sentry
  - Test: Trigger test error, verify report
- [ ] Beta testing with 20 users (depends on: All above)
  - Acceptance: Feedback collected, critical bugs fixed
- [ ] App Store submission (depends on: Beta testing complete)
  - Acceptance: Apps published to iOS App Store and Google Play

**Exit Criteria**: App live in stores

**Delivers**: Production-ready Zendfast MVP
</implementation-roadmap>

---

<test-strategy>
## Test Pyramid

```
        /\
       /E2E\       ← 10% (Full user flows, slow)
      /------\
     /Integration\ ← 30% (Feature interactions)
    /------------\
   /  Unit Tests  \ ← 60% (Fast, isolated)
  /----------------\
```

## Coverage Requirements

- **Line coverage**: 80% minimum
- **Critical paths**: 100% (timer, panic button, auth)

## Critical Test Scenarios

### Timer Service
**Happy path**: Start timer → wait 30s → verify countdown accurate
**Edge cases**: App killed mid-fast → reopen → timer continues
**Error cases**: Device reboot → timer resumes from correct time
**Integration**: Timer syncs session to Supabase after completion

### Panic Button
**Happy path**: During fast → tap panic → modal appears
**Edge cases**: Rapid taps → modal shown once
**Error cases**: Offline → motivational content loads from cache
**Integration**: "I broke my fast" → session marked interrupted in metrics

### Hydration
**Happy path**: Tap water button → progress updates
**Edge cases**: Goal reached → congratulations message
**Error cases**: Offline → log stored locally, synced later

### Sync Manager
**Happy path**: Create session → syncs to Supabase
**Edge cases**: Conflict (edit on two devices) → latest timestamp wins
**Error cases**: Network failure → retry with exponential backoff

## Test Generation Guidelines

- Use `integration_test` package for E2E
- Mock Supabase calls in unit tests (use Mocktail)
- Test timer accuracy with Stopwatch comparison
- Verify accessibility with Accessibility Scanner
- Test Lottie animations on physical devices (performance)
</test-strategy>

---

<architecture>
## System Components

**Flutter App (Frontend)**
- Riverpod for state management
- Isar v3.1.0 for local database
- flutter_background_service for timer persistence
- Lottie for animations

**Supabase (Backend)**
- PostgreSQL database (user_profiles, fasting_sessions, hydration_logs, content_items)
- Row Level Security (RLS) for user data isolation
- Edge Functions for metrics calculation, push notifications, sync
- Supabase Auth for authentication

**Third-Party Services**
- OneSignal: Push notifications
- Superwall: Paywall and subscription management
- Sentry: Error monitoring
- YouTube API: Video embedding

## Data Models

**FastingSession (Isar)**
```dart
@collection
class FastingSession {
  Id id = Isar.autoIncrement;
  String userId;
  DateTime startTime;
  DateTime? endTime;
  int durationMinutes;
  bool completed;
  bool interrupted;
  String? planType; // "16/8", "18/6", etc.
}
```

**UserProfile (Supabase)**
```sql
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  weight_kg DECIMAL(5,2),
  height_cm INT,
  daily_hydration_goal INT GENERATED ALWAYS AS (ROUND(weight_kg * 32)::INT) STORED,
  created_at TIMESTAMP DEFAULT NOW()
);
```

## Technology Stack

**Decision: Flutter**
- **Rationale**: Cross-platform (iOS/Android), single codebase, fast development
- **Trade-offs**: Larger app size vs native
- **Alternatives**: React Native (rejected: performance concerns)

**Decision: Isar v3.1.0**
- **Rationale**: Fast local database, zero-config sync support, better than Hive/Drift
- **Trade-offs**: Newer library vs SQLite stability
- **Alternatives**: Drift (rejected: more boilerplate)

**Decision: Riverpod**
- **Rationale**: Type-safe state management, better than Provider
- **Trade-offs**: Learning curve vs simplicity
- **Alternatives**: Bloc (rejected: too verbose)
</architecture>

---

<risks>
## Technical Risks

**Risk**: Timer inaccuracy in background (iOS restrictions)
- **Impact**: High - Core feature failure
- **Likelihood**: Medium
- **Mitigation**: Use flutter_background_service, test extensively on iOS
- **Fallback**: Use scheduled notifications as backup timer

**Risk**: Lottie animation performance on low-end devices
- **Impact**: Medium - Meditation UX degraded
- **Likelihood**: Medium
- **Mitigation**: Optimize animation JSON, test on low-end devices
- **Fallback**: Use static images if performance <30fps

**Risk**: Sync conflicts (simultaneous edits on multiple devices)
- **Impact**: Medium - Data loss
- **Likelihood**: Low
- **Mitigation**: Last-write-wins with timestamps
- **Fallback**: Manual conflict resolution UI

**Risk**: Push notification delivery failure
- **Impact**: Medium - Reduced engagement
- **Likelihood**: Medium
- **Mitigation**: Use OneSignal (reliable service), handle failures gracefully
- **Fallback**: In-app notification fallback

**Risk**: Supabase Edge Function cold starts
- **Impact**: Low - Slower sync
- **Likelihood**: High
- **Mitigation**: Keep functions warm with scheduled pings
- **Fallback**: Client-side calculations as backup

## Scope Risks

**Risk**: Feature creep (social features, meal planning)
- **Impact**: High - MVP delay
- **Mitigation**: Strict scope control, defer non-MVP features
- **Fallback**: Launch with core features only

**Risk**: Medical/legal liability (detox plan, health advice)
- **Impact**: High - Legal issues
- **Mitigation**: Add disclaimers, consult with lawyer, avoid medical claims
- **Fallback**: Remove detox plan if legal risk too high
</risks>

---

<appendix>
## Glossary

- **Fasting Window**: Period of no calorie intake
- **Eating Window**: Period where eating is allowed
- **Panic Button**: Emergency support feature during cravings
- **4-4-8 Breathing**: Inhale 4s, hold 4s, exhale 8s
- **Detox Plan**: 48-hour carnivore-style prep before first fast
- **RLS**: Row Level Security (Supabase database security)

## Open Questions

- Should we allow custom notification sounds?
- Do we need offline support for YouTube videos (download)?
- Should we integrate with Apple Health/Google Fit?

## References

- RPG Methodology: https://arxiv.org/abs/2404.00682
- Intermittent Fasting Research: NIH studies on metabolic benefits
- Flutter Background Service: https://pub.dev/packages/flutter_background_service
- Isar Documentation: https://isar.dev
</appendix>
