# Zendfast - Product Requirements Document (PRD)
## MVP Version 1.0

---

## CONTEXT

### Overview

**Product Name:** Zendfast
**Category:** Health & Wellness - Intermittent Fasting
**Platform:** Mobile (iOS/Android via Flutter)
**Target Market:** Global - English & Spanish speaking markets initially

**Problem Statement:**
People who want to practice intermittent fasting struggle with three critical challenges:
1. Lack of real-time support during difficult moments (hunger pangs, cravings)
2. No integrated emotional/psychological tools to overcome the urge to break their fast
3. Difficulty tracking progress and understanding the science behind fasting

**Solution:**
Zendfast is a local-first mobile app that provides a complete intermittent fasting experience with a unique differentiator: an intelligent "Panic Button" that provides immediate emotional support, guided meditation, and anti-binge strategies during critical moments of weakness. The app combines timer tracking, hydration monitoring, educational content, and progress analytics - all while working primarily offline.

**Value Proposition:**
- Real-time emotional support during fasting (Panic Button with 4-4-8 breathing meditation)
- Scientific approach with optional 48-hour detox plan to reduce sugar dependency
- Local-first architecture ensures reliability without internet dependency
- Comprehensive tracking (fasting sessions, hydration, metrics, streaks)

---

### Core Features

#### 1. Fasting Timer & Plans
**What it does:**
Provides 6 predefined fasting plans (12/12, 14/10, 16/8, 18/6, 24h, 48h) with an intelligent countdown timer that tracks fasting and eating windows.

**Why it's important:**
The timer is the foundational feature - without accurate, reliable time tracking, the entire product fails. It must work offline and survive app kills.

**How it works:**
- User selects a fasting plan during onboarding
- Timer starts when user confirms fasting window begins
- App calculates end time and displays countdown
- Timer runs in background using flutter_background_service
- State persists in local Isar database
- Notifications trigger at fasting start/end

**MVP Scope:**
- 6 predefined plans only (no custom plans in MVP)
- Manual start/stop (no automatic scheduling)
- Basic timer UI with hours:minutes:seconds display
- Background persistence with foreground notification

---

#### 2. Panic Button (Differentiator)
**What it does:**
A prominent floating button available during fasting that provides immediate support when users experience strong cravings or anxiety about breaking their fast.

**Why it's important:**
This is Zendfast's primary differentiator. Most fasting apps only track time - we provide emotional/psychological support in real-time. This feature directly impacts completion rates.

**How it works:**
- Panic button appears as a floating action button during active fasting
- Tapping opens a modal with:
  - Motivational phrase (randomized from local database)
  - Anti-binge recommendations (drink water, walk, distraction techniques)
  - Two options: "Meditate" or "I broke my fast"
- "Meditate" launches 4-4-8 breathing exercise (Lottie animation)
  - Inhale 4 seconds → Hold 4 seconds → Exhale 8 seconds
  - Minimum 3 cycles recommended
  - After completion: "Continue fasting" or "I can't continue"
- All interactions tracked for analytics (panic_button_used, meditation_attempts, meditation_successful)

**MVP Scope:**
- 10-15 motivational phrases (hardcoded, no personalization)
- Single breathing pattern (4-4-8 only)
- Basic Lottie animation for breathing visual
- Simple tracking (button pressed, meditation completed, fast broken)

---

#### 3. Hydration Tracking
**What it does:**
Calculates daily water intake goal based on user's weight (weight_kg × 32ml) and provides quick-log functionality with progress visualization.

**Why it's important:**
Proper hydration is critical for successful fasting (reduces hunger, prevents fatigue, supports autophagy). Integration with fasting timer creates a holistic experience.

**How it works:**
- During onboarding, user enters weight and preferred glass size (default 250ml)
- App calculates daily goal: weight_kg × 32
- Floating hydration button (separate from panic button) allows one-tap logging
- Each tap adds one glass (e.g., +250ml)
- Progress shown as circular indicator or progress bar
- Push notifications remind user to drink water every 2-3 hours during fasting
- Daily logs stored in Isar, synced to Supabase

**MVP Scope:**
- Fixed glass size (no mid-session changes)
- Simple tap-to-log (no volume customization per log)
- Linear or circular progress indicator
- Basic hourly reminders (no smart scheduling)

---

#### 4. Metrics & Progress Dashboard
**What it does:**
Displays user's fasting performance over time including total hours fasted, completed sessions, current streak, and success rate.

**Why it's important:**
Gamification and progress visualization drive retention. Users need to see their achievements to stay motivated.

**How it works:**
- Dashboard accessible from Profile tab
- Metrics calculated via Supabase Edge Function: calculate-user-metrics
- Key metrics displayed:
  - Total fasting hours (all-time)
  - Completed sessions count
  - Current streak (consecutive days with completed fasts)
  - Success rate (completed / total sessions × 100)
  - Panic button success rate (completed after panic / total panic uses × 100)
- Calendar view shows fasting history (color-coded: completed, interrupted, planned)
- Weekly/monthly charts show progression

**MVP Scope:**
- Basic metrics only (total hours, completed sessions, current streak, success rate)
- Simple calendar view (no editing past sessions)
- Static charts (no interactive zoom/filtering)
- Metrics refresh on app launch (no real-time updates)

---

#### 5. Learning Content
**What it does:**
Provides curated educational content about intermittent fasting including articles, YouTube videos, and scientific studies.

**Why it's important:**
Education builds user confidence and commitment. Understanding the "why" behind fasting increases adherence and reduces anxiety.

**How it works:**
- Content stored in Supabase learning_content table
- Categories: Articles, Videos, Studies, Guides
- Content types:
  - External articles (links to blogs/publications)
  - YouTube videos (embedded player via youtube_video_id)
  - Scientific studies (links to PubMed, research papers)
- Metadata stored locally for offline browsing (title, description, thumbnail)
- Content itself requires internet connection
- User can favorite content (stored locally and synced)
- Track views and time spent for personalization (future)

**MVP Scope:**
- 20-30 pieces of curated content across categories
- Simple list view (no search or filtering)
- External links open in WebView or browser
- Favorites stored locally only (no sync in MVP)
- No content creation (admin adds content directly to Supabase)

---

#### 6. Optional 48-Hour Detox Plan (Differentiator)
**What it does:**
For first-time fasters, recommends a 48-hour carnivore-style detox (meat, eggs, cheese + salt only) to reduce sugar cravings before starting intermittent fasting.

**Why it's important:**
Unique onboarding experience that sets Zendfast apart. Reduces failure rate for beginners by addressing sugar addiction proactively.

**How it works:**
- During onboarding, app asks: "Is this your first time fasting?"
- If yes, displays detox plan explanation:
  - Duration: 48 hours
  - Protocol: Carnivore foods only (meat, eggs, cheese, salt)
  - Goal: Reduce sugar dependency and cravings
  - Disclaimer: Consult physician if you have health conditions
- User can accept or skip
- If accepted, detox plan is treated as a special fasting session
- Completion tracked separately (detox_plan_completed in user_profiles)
- After detox, user proceeds to regular fasting plan selection

**MVP Scope:**
- Simple educational screen explaining detox
- Accept/Skip choice (no partial completion tracking)
- Boolean flag in database (completed vs not completed)
- No daily check-ins during detox (honor system)
- Generic medical disclaimer (no personalized health screening)

---

### User Experience

#### User Personas

**Persona 1: Sarah - The Health Optimizer**
- Age: 28-35
- Goal: Weight loss and metabolic health
- Tech-savvy, tracks multiple health metrics
- Needs: Data visualization, progress tracking, scientific backing
- Pain point: Gets discouraged when progress is slow

**Persona 2: Marcus - The Busy Professional**
- Age: 35-45
- Goal: Energy boost and productivity
- Limited time, values simplicity
- Needs: Quick logging, minimal interaction, reliable notifications
- Pain point: Forgets to start/stop fasts, breaks fast due to work stress

**Persona 3: Ana - The Wellness Explorer**
- Age: 22-30
- Goal: Spiritual/mindfulness benefits of fasting
- Interested in holistic health, meditation
- Needs: Educational content, community (future), meditation features
- Pain point: Struggles with hunger pangs, needs emotional support

---

#### Key User Flows

**Flow 1: First-Time User Onboarding**
```
1. Splash screen (5 seconds, Zendfast branding)
2. Introduction carousel (3 screens, skippable):
   - What is intermittent fasting?
   - Benefits overview
   - How Zendfast helps
3. Authentication:
   - Email/password registration via Supabase
   - OR social auth (Google, Apple) [Future: OAuth]
4. User questionnaire:
   - Weight (kg)
   - Height (cm)
   - First time fasting? (Yes/No)
5. IF first-time = Yes:
   - Detox plan recommendation
   - Accept → Mark detox_plan_recommended = true
   - Skip → Continue
6. Paywall (Superwall):
   - Show premium features
   - Monthly/Yearly options
   - "Continue Free" button (prominent)
7. Plan selection:
   - Display 6 plans with descriptions
   - User selects one
8. Hydration setup:
   - Confirm glass size (default 250ml)
   - Auto-calculated daily goal shown
9. Home screen (Timer ready to start)
```

**Flow 2: Daily Fasting Session**
```
1. User opens app → Home tab (Timer screen)
2. Timer shows next scheduled fast OR manual "Start Fast" button
3. User taps "Start Fast"
   - Confirmation modal: "Ready to start your 16-hour fast?"
   - Confirm → Timer begins
   - Notification scheduled for fasting end
4. During fast:
   - Timer displays countdown (HH:MM:SS)
   - Panic button visible (floating, bottom-center)
   - Hydration button visible (floating, bottom-left)
   - Progress ring/bar shows % complete
5. User taps Hydration button:
   - Quick +250ml log
   - Brief animation/feedback
   - Progress updates
6. User experiences strong craving:
   - Taps Panic Button
   - Modal appears with motivation + options
   - User chooses "Meditate"
   - Breathing exercise launches (4-4-8 pattern)
   - After 3 cycles: "Continue fasting" or "I can't continue"
   - User selects "Continue fasting"
   - Returns to timer
7. Timer reaches 00:00:00:
   - Success notification
   - Celebration modal: "16-hour fast completed!"
   - Session marked complete in Isar
   - Metrics updated (streak, total hours)
```

**Flow 3: Breaking a Fast Early**
```
1. During active fast, user struggles
2. Taps Panic Button
3. Reviews motivational content
4. Chooses "I broke my fast" OR completes meditation but selects "I can't continue"
5. Interruption confirmation:
   - "Are you sure you want to end your fast early?"
   - Confirm → Session marked interrupted
6. Quick survey (optional):
   - "What happened?" (Multiple choice: Hunger, Social event, Felt unwell, Other)
   - Note field (optional text)
7. Metrics updated (success rate decreased, time_completed_minutes recorded)
8. Encouraging message: "That's okay! You completed X hours. Try again tomorrow."
9. Timer resets, ready for next session
```

---

#### UI/UX Considerations

**Design Principles:**
- **Calm & Focused:** Zen-inspired minimalist design, breathing room, soft colors
- **Immediate Clarity:** User should know their fasting status within 1 second of opening app
- **Accessible:** WCAG 2.1 AA compliance (4.5:1 contrast, 44×44 touch targets, semantic labels)
- **Offline-First:** UI should never feel "broken" without internet

**Color Palette:**
- Primary: Teal (#069494) - Balance, calm
- Secondary: Green (#7fb069) - Growth, health
- Accent: Orange (#ffb366) - Energy, warmth (Panic Button)
- Success: Green (#7fb069)
- Error: Soft Red (#E57373)

**Typography:**
- Headers: Inter (UI clarity)
- Body: Source Sans Pro (readability)
- Emphasis: Nunito Sans (emotional warmth)

**Key UI Elements:**
- **Timer Display:** Large, centered, 48px font, bold, color changes based on state
- **Panic Button:** FloatingActionButton, 64×64, orange accent, high elevation (8dp), always visible during fast
- **Hydration Button:** FloatingActionButton, 56×56, blue/teal, bottom-left corner
- **Progress Indicators:** Circular ring around timer OR linear bar below timer
- **Navigation:** Bottom tab bar (Home, Learning, Profile)

**Micro-interactions:**
- Ripple effect on button taps
- Success confetti animation when fast completes
- Gentle pulse animation on Panic Button (subtle, not distracting)
- Smooth transitions between screens (250ms, easeInOut)
- Haptic feedback on critical actions (start/stop timer, panic button)

---

## PRD

### Technical Architecture

#### System Overview

**Architecture Pattern:** Local-First with Cloud Sync
**Frontend:** Flutter 3.x (Stable Channel)
**State Management:** Riverpod (StateNotifierProvider for complex state)
**Local Database:** Isar v3.1.0 (fast, offline, supports complex queries)
**Backend:** Supabase (PostgreSQL + Edge Functions)
**Notifications:** OneSignal Push Notifications
**Paywall:** Superwall (A/B testing, subscription management)
**Analytics:** Supabase analytics_events table
**Error Monitoring:** Sentry (via Edge Functions)

---

#### Core System Components

**1. Frontend Layer (Flutter)**
```
lib/
├── core/
│   ├── constants/        # App constants, config
│   ├── themes/           # ZendfastColors, Typography, Spacing
│   ├── utils/            # Helper functions, validators
│   └── services/         # Background service, notification service
├── features/
│   ├── authentication/   # Login, registration, session management
│   ├── fasting/          # Timer, plans, session management
│   ├── panic/            # Panic button, meditation, motivational content
│   ├── hydration/        # Water tracking, reminders
│   ├── learning/         # Content browsing, favorites
│   ├── metrics/          # Dashboard, analytics, charts
│   └── profile/          # Settings, preferences, account
├── shared/
│   ├── widgets/          # Reusable UI components
│   ├── models/           # Data models (Isar schemas)
│   └── providers/        # Riverpod providers
└── main.dart
```

**2. Local Database (Isar)**

Schemas:
```dart
// FastingSession
- id: UUID
- userId: String
- planId: int
- startTime: DateTime
- plannedEndTime: DateTime
- actualEndTime: DateTime?
- status: enum (active, completed, interrupted, paused)
- interruptionReason: enum?
- panicButtonUsed: bool
- meditationAttempts: int
- meditationSuccessful: int
- createdAt: DateTime
- updatedAt: DateTime

// HydrationLog
- id: UUID
- userId: String
- date: DateTime (day only)
- mlConsumed: int
- dailyProgress: int
- goalAchieved: bool
- logs: List<HydrationEntry> // Timestamp + ml for each log

// UserProfile
- id: UUID (matches Supabase auth.users.id)
- weightKg: double
- heightCm: int
- isFirstTimeFaster: bool
- detoxPlanAccepted: bool
- mlPerGlass: int
- dailyHydrationGoal: int (calculated)
- themeMode: enum (light, dark, system)
- notificationsEnabled: bool
- subscriptionStatus: enum (free, premium)
- lastSyncTimestamp: DateTime
```

Indexes:
- FastingSession: (userId, status), (startTime DESC)
- HydrationLog: (userId, date DESC)

**3. Backend Layer (Supabase)**

Database Tables:
```sql
-- user_profiles (synced from local)
-- fasting_sessions (synced from local)
-- hydration_logs (synced from local)
-- fasting_plans (reference data, read-only)
-- learning_content (admin-managed content)
-- user_content_interactions (favorites, views)
-- analytics_events (user actions, funnel tracking)
-- system_logs (backend logs)
```

Edge Functions:
```typescript
// calculate-user-metrics
Input: { userId: string }
Output: {
  totalFastingHours,
  completedSessions,
  currentStreak,
  successRate,
  panicButtonSuccessRate
}

// schedule-notifications
Input: { userId: string, sessionId: string, planType: string }
Output: { notificationsScheduled: number }

// sync-user-data
Input: {
  userId: string,
  localData: SyncData,
  lastSyncTimestamp: string
}
Output: {
  updatedData: SyncData,
  conflicts: Conflict[],
  syncTimestamp: string
}

// handle-superwall-webhook
Input: SuperwallWebhook (subscription events)
Output: { success: bool }
```

Row Level Security (RLS):
- All user tables: `auth.uid() = user_id` (mandatory)
- learning_content: Public read, admin write
- analytics_events: User can view own, admin can view aggregates only

---

#### Data Models

**Fasting Plan Structure:**
```typescript
interface FastingPlan {
  id: number
  planName: string           // "16/8", "18/6", etc.
  planType: enum             // intermittent, extended, detox
  fastingHours: number       // 16, 18, 24, 48
  eatingHours: number        // 8, 6, 0, 0
  description: string
}

Predefined Plans:
1. 12/12 - Beginner
2. 14/10 - Intermediate
3. 16/8 - Popular (default recommended)
4. 18/6 - Advanced
5. 24-hour - OMAD
6. 48-hour - Extended
```

**Sync Queue Structure:**
```dart
class SyncOperation {
  String id
  String type              // fasting_session, hydration_log, user_profile
  Map<String, dynamic> data
  DateTime timestamp
  int retryCount
  int priority             // 1=critical, 2=important, 3=background
  SyncStatus status        // pending, in_progress, completed, failed
}

Priority Rules:
- Priority 1: Session start/end, panic button usage, subscription changes
- Priority 2: Hydration logs, profile updates
- Priority 3: Content interactions, metric requests
```

---

#### APIs and Integrations

**Supabase Client Configuration:**
```dart
final supabase = Supabase.initialize(
  url: 'https://[project-id].supabase.co',
  anonKey: '[anon-key]',
  authFlowType: AuthFlowType.pkce,
  localStorage: const FlutterSecureStorage(),
);
```

**OneSignal Configuration:**
```dart
OneSignal.initialize('[app-id]');
OneSignal.Notifications.requestPermission(true);

// Notification types
enum NotificationType {
  fastingStart,      // "Your fast has started! 💪"
  fastingEnd,        // "Fast completed! 🎉 Time to eat"
  hydrationReminder, // "💧 Remember to hydrate"
  motivation,        // "You're doing great! X hours completed"
  educational        // "Did you know...?" (optional)
}
```

**Superwall Configuration:**
```dart
Superwall.configure(
  apiKey: '[api-key]',
  purchaseController: PurchaseController(),
);

Superwall.register(event: 'paywall_trigger');

// Products
- monthly_premium: $9.99/month
- yearly_premium: $69.99/year (42% savings)
```

---

#### Infrastructure Requirements

**Development Environment:**
- Flutter SDK: 3.16+ (Stable)
- Dart: 3.2+
- IDE: VS Code with Flutter extension OR Android Studio
- Supabase CLI: For local development, migrations
- OneSignal CLI: For testing notifications
- Device testing: iOS Simulator, Android Emulator, 2-3 physical devices

**Production Environment:**
- Supabase Cloud: Production project (separate from dev)
- Codemagic: CI/CD for iOS builds (from Windows)
- App Store Connect: iOS distribution
- Google Play Console: Android distribution
- Sentry: Error monitoring dashboard
- Superwall Dashboard: Paywall analytics

**Minimum Device Requirements:**
- iOS: 13.0+ (target latest iOS for testing)
- Android: 10.0+ (API 29+)
- RAM: 2GB minimum
- Storage: 100MB app + 50MB data

**Backend Scaling Considerations:**
- Database: PostgreSQL connection pooling (Supabase default)
- Edge Functions: Auto-scaling (Supabase handles)
- Storage: Minimal (no file uploads in MVP)
- Bandwidth: Low (local-first reduces API calls)

---

### Development Roadmap

#### Phase 1: Foundation & Infrastructure (MVP Baseline)

**Objective:** Set up development environment, core architecture, and basic authentication. Goal is to have a working "Hello World" app that can authenticate users and store data locally.

**Deliverables:**
1. **Project Setup**
   - Initialize Flutter project with flavor configuration (dev, prod)
   - Configure Supabase projects (development & production)
   - Set up Codemagic CI/CD pipeline
   - Configure git repository, branching strategy, PR templates

2. **Design System Implementation**
   - Create ZendfastColors, ZendfastTypography, ZendfastSpacing classes
   - Build reusable components: PrimaryButton, InfoCard, CustomInputField
   - Implement theme switching (light/dark mode)
   - Create demo screen to showcase all components

3. **Authentication Flow**
   - Email/password registration and login (Supabase Auth)
   - Session management with FlutterSecureStorage
   - Password reset flow
   - Basic error handling (network errors, auth errors)

4. **Local Database Setup**
   - Define Isar schemas: FastingSession, HydrationLog, UserProfile
   - Create database service with CRUD operations
   - Write unit tests for database operations
   - Implement data seeding for development

5. **Navigation Structure**
   - Set up go_router with routes for: Splash, Login, Register, Home, Learning, Profile
   - Implement bottom tab navigation (Home, Learning, Profile)
   - Create placeholder screens for each tab
   - Add route guards (authenticated vs unauthenticated)

**Success Criteria:**
- ✓ User can register, login, logout
- ✓ App persists user session across restarts
- ✓ Navigation works smoothly between all screens
- ✓ Data can be written to and read from Isar
- ✓ Theme switching works correctly
- ✓ CI/CD pipeline builds successfully

---

#### Phase 2: Core Fasting Experience (MVP Critical Path)

**Objective:** Build the essential fasting timer and panic button features. This is the minimum viable product that provides unique value.

**Deliverables:**
1. **Fasting Plans & Onboarding**
   - Seed fasting_plans table in Supabase with 6 plans
   - Create plan selection UI with cards showing fasting/eating hours
   - Build onboarding flow:
     - Splash screen (5s)
     - Intro carousel (3 screens, skippable)
     - User questionnaire (weight, height, first-time faster?)
     - Plan selection
   - Store selected plan in UserProfile (Isar + Supabase)

2. **Fasting Timer (Core Feature)**
   - Implement timer state management with Riverpod
   - Create TimerDisplay widget (HH:MM:SS countdown)
   - Add "Start Fast" / "End Fast" buttons
   - Implement background service using flutter_background_service
   - Persist timer state in Isar (store start_time + duration, calculate remaining on resume)
   - Show foreground notification during active fast (Android requirement)
   - Handle app kill/restart gracefully

3. **Panic Button (Differentiator)**
   - Create FloatingActionButton with orange accent, high elevation
   - Build panic modal with:
     - Random motivational phrase from local database (10-15 phrases)
     - Anti-binge recommendations (drink water, take a walk, etc.)
     - Two action buttons: "Meditate" / "I broke my fast"
   - Implement 4-4-8 breathing meditation:
     - Lottie animation showing breathing pattern
     - Audio cues (optional, can be silent with visual only)
     - Cycle counter (minimum 3 cycles)
     - Exit options: "Continue fasting" / "I can't continue"
   - Track panic button events in analytics_events

4. **Session Management**
   - Implement session creation (active status)
   - Handle session completion (actualEndTime set, status = completed)
   - Handle session interruption (status = interrupted, record reason)
   - Calculate time_completed_minutes for interrupted sessions
   - Update user metrics after each session (total hours, streak)

**Success Criteria:**
- ✓ User can select a plan and start a fast
- ✓ Timer counts down accurately even when app is backgrounded
- ✓ Timer survives app kill and device restart
- ✓ Panic button appears only during active fast
- ✓ Meditation animation plays smoothly (60fps target)
- ✓ User can complete or interrupt a fast
- ✓ All session data persists locally in Isar

---

#### Phase 3: Hydration & Metrics (MVP Completion)

**Objective:** Add hydration tracking and basic metrics dashboard to create a complete MVP experience.

**Deliverables:**
1. **Hydration Tracking**
   - Calculate daily hydration goal during onboarding (weight_kg × 32ml)
   - Create hydration FloatingActionButton (teal/blue, bottom-left)
   - Implement one-tap logging (+mlPerGlass to daily total)
   - Show progress indicator:
     - Circular progress ring (preferred) OR
     - Linear progress bar
   - Display current progress: "1500ml / 2400ml (62%)"
   - Store daily logs in HydrationLog (Isar)
   - Reset progress at midnight (local time)

2. **Hydration Reminders**
   - Schedule local notifications every 2-3 hours during active fast
   - Use flutter_local_notifications (works offline)
   - Messages: "💧 Time to hydrate!", "Remember to drink water"
   - Tapping notification opens app to Home screen
   - User can disable in settings

3. **Basic Metrics Dashboard**
   - Create Metrics screen in Profile tab
   - Display 4 key metrics:
     - Total fasting hours (all-time)
     - Completed sessions count
     - Current streak (consecutive days)
     - Success rate (completed / total × 100)
   - Calculate metrics locally from Isar data
   - Add "Refresh" button to recalculate

4. **Calendar View**
   - Show monthly calendar with dots/colors indicating:
     - Green: Completed fast
     - Yellow: Interrupted fast
     - Gray: No fast
   - Tapping a day shows session details (start time, duration, notes)
   - Simple implementation using flutter_calendar_carousel or table_calendar

**Success Criteria:**
- ✓ User can log water intake with one tap
- ✓ Progress updates in real-time
- ✓ Hydration reminders trigger on schedule
- ✓ Metrics display correctly and update after sessions
- ✓ Calendar accurately reflects fasting history
- ✓ All calculations are accurate and fast (<100ms)

---

#### Phase 4: Content & Onboarding Polish (MVP Enhancement)

**Objective:** Add learning content and refine onboarding experience with optional detox plan.

**Deliverables:**
1. **Learning Content System**
   - Populate learning_content table with 20-30 curated items:
     - 10 articles (intermittent fasting basics, benefits, tips)
     - 8 YouTube videos (educational, motivational)
     - 5 scientific studies (PubMed links)
     - 5 guides (how to break a fast, what to eat, etc.)
   - Create Learning tab UI:
     - Category tabs: All, Articles, Videos, Studies, Guides
     - List view with thumbnail, title, description
     - Tap to open (WebView for articles, YouTube player for videos)
   - Implement favorites (heart icon, stored in user_content_interactions)
   - Add "Favorites" filter to show bookmarked content

2. **Detox Plan Feature**
   - Add detox plan recommendation screen in onboarding
   - Trigger when isFirstTimeFaster = true
   - Display:
     - Title: "48-Hour Sugar Detox (Recommended)"
     - Explanation: Reduces sugar cravings, makes fasting easier
     - Protocol: Meat, eggs, cheese, salt only for 48 hours
     - Medical disclaimer: "Consult your physician if you have health conditions"
   - Two buttons: "Accept Detox Plan" / "Skip to Fasting"
   - If accepted:
     - Store detoxPlanAccepted = true
     - Create 48-hour fasting session with special flag
     - No special tracking (honor system for food choices)
   - After 48 hours, prompt to start regular fasting plan

3. **Onboarding Flow Refinement**
   - Polish intro carousel with custom illustrations (or stock images)
   - Add progress indicators (1/3, 2/3, 3/3)
   - Improve questionnaire UX (sliders for weight/height, better validation)
   - Add "Why we need this" explanations for each question
   - Smooth transitions between screens (slide animations)

**Success Criteria:**
- ✓ 20+ content items available in Learning tab
- ✓ Content loads and displays correctly (WebView, YouTube)
- ✓ Favorites work offline (stored locally)
- ✓ Detox plan appears only for first-time fasters
- ✓ User can accept or skip detox
- ✓ Onboarding flow is smooth and intuitive

---

#### Phase 5: Monetization & Notifications (MVP Launch-Ready)

**Objective:** Integrate paywall, set up push notifications, and implement cloud sync. Prepare for production launch.

**Deliverables:**
1. **Superwall Paywall Integration**
   - Set up Superwall dashboard, configure products:
     - monthly_premium: $9.99/mo
     - yearly_premium: $69.99/yr
   - Create paywall trigger in onboarding (after questionnaire)
   - Design paywall screen showing premium features:
     - Advanced metrics and charts
     - Unlimited fasting plans (future)
     - Priority support
     - Ad-free experience (if ads added later)
   - Implement "Continue Free" button (must be visible)
   - Handle purchase flow (success, error, restore)
   - Update subscriptionStatus in UserProfile on purchase

2. **Push Notifications (OneSignal)**
   - Set up OneSignal project (iOS & Android)
   - Integrate OneSignal SDK in Flutter
   - Request notification permission (with explanation)
   - Implement notification scheduling via Supabase Edge Function:
     - Fasting start: "Your fast has started! 💪"
     - Fasting end: "Congratulations! Fast completed 🎉"
     - Motivation: "You're doing great! 8 hours down, 8 to go!"
     - Hydration: "💧 Remember to drink water"
   - Test notifications in all app states (foreground, background, killed)

3. **Cloud Sync Implementation**
   - Build sync service with queue system
   - Implement batch sync for:
     - FastingSession (priority 1)
     - HydrationLog (priority 2)
     - UserProfile (priority 2)
   - Sync triggers:
     - On app launch (if online)
     - Every 15 minutes in background (if WiFi available)
     - After critical events (session complete, panic button)
   - Handle conflicts: timestamp-based (most recent wins)
   - Show sync status in UI (last synced timestamp)

4. **Settings & Preferences**
   - Create Settings screen in Profile tab:
     - Theme: Light / Dark / System
     - Notifications: Toggle for each type
     - Hydration reminders: On/Off, frequency
     - Sync: WiFi only / WiFi + Mobile Data
     - Account: Email, password change, logout
     - Legal: Privacy Policy, Terms of Service
     - About: Version, support email, feedback

**Success Criteria:**
- ✓ Paywall displays correctly and handles purchases
- ✓ User can successfully subscribe and subscription status updates
- ✓ Push notifications work on iOS and Android
- ✓ Notifications don't spam user (max 5-6 per day)
- ✓ Sync works reliably (no data loss)
- ✓ WiFi-only sync is respected
- ✓ Settings persist and affect app behavior

---

#### Phase 6: Testing, Polish & Launch (MVP Finalization)

**Objective:** Comprehensive testing, bug fixes, performance optimization, and production deployment.

**Deliverables:**
1. **Comprehensive Testing**
   - Unit tests:
     - Riverpod providers (timer logic, metrics calculation)
     - Isar database operations (CRUD, queries)
     - Sync queue logic (priority, retry)
   - Widget tests:
     - Critical UI components (timer, panic button, hydration)
     - Form validation (registration, questionnaire)
   - Integration tests:
     - Complete onboarding flow
     - Fasting session lifecycle (start → panic → complete)
     - Sync flow (local → cloud)
   - Target coverage: 70% for core features

2. **Accessibility Audit**
   - Test with TalkBack (Android) and VoiceOver (iOS)
   - Verify contrast ratios (4.5:1 minimum for text)
   - Check touch targets (44×44 minimum)
   - Add semantic labels to all interactive elements
   - Test with large text sizes (accessibility settings)
   - Fix any issues found

3. **Performance Optimization**
   - Profile timer accuracy (should be ±1 second over 24 hours)
   - Optimize animations (maintain 60fps on mid-range devices)
   - Reduce app size (target <30MB download)
   - Optimize Isar queries (use EXPLAIN, add indexes if needed)
   - Test battery consumption (should not exceed 2-3% per hour with active timer)

4. **Production Deployment**
   - Set up production Supabase project
   - Configure production environment variables
   - Enable code obfuscation for release builds
   - Create App Store and Play Store listings:
     - Screenshots (5-8 per platform)
     - App description, keywords
     - Privacy policy, support email
   - Submit for review:
     - iOS: TestFlight beta → App Store review
     - Android: Internal testing → Open beta → Production
   - Set up Sentry error monitoring
   - Create launch runbook (what to do when things break)

5. **Beta Testing**
   - Recruit 50-100 beta testers
   - Run 2-4 week beta period
   - Collect feedback via in-app form or email
   - Monitor for crashes (Sentry), battery drain, sync issues
   - Iterate based on feedback
   - Final bug fixes before launch

**Success Criteria:**
- ✓ 70%+ test coverage on core features
- ✓ Zero accessibility violations in core flows
- ✓ App passes App Store and Play Store review
- ✓ Beta testers report <5 critical bugs
- ✓ Timer accuracy verified across multiple devices
- ✓ Production deployment successful

---

### Logical Dependency Chain

This section defines the critical path and dependencies between features. Features must be built in this order to ensure each component has its dependencies ready.

#### Critical Path (Must be Sequential)

**Level 0: Foundation** (No dependencies)
```
1. Project Setup & Configuration
   - Flutter project initialization
   - Supabase project setup
   - Codemagic CI/CD configuration

2. Design System
   - Color palette, typography, spacing constants
   - Reusable components (buttons, cards, inputs)
   - Theme configuration

✓ Checkpoint: Can build and run app with demo components
```

**Level 1: Core Infrastructure** (Depends on Level 0)
```
3. Authentication
   - Supabase Auth integration
   - Login/Register screens
   - Session management

4. Local Database (Isar)
   - Schema definitions
   - Database service (CRUD operations)
   - Basic data persistence

5. Navigation
   - go_router setup
   - Bottom tab navigation
   - Route guards

✓ Checkpoint: User can create account, login, and navigate app
```

**Level 2: Fasting Core** (Depends on Level 1)
```
6. Fasting Plans
   - Seed plan data in Supabase
   - Plan selection UI
   - Store user's selected plan

7. Basic Timer Logic
   - Timer state management (Riverpod)
   - Countdown calculation
   - Start/stop functionality
   - Local persistence (Isar)

8. Timer UI
   - TimerDisplay widget
   - Start/End buttons
   - Progress indicator

✓ Checkpoint: User can select plan and see basic timer
```

**Level 3: Background Persistence** (Depends on Level 2)
```
9. Background Service
   - flutter_background_service setup
   - Timer continues in background
   - Foreground notification (Android)
   - Handle app kill/restart

✓ Checkpoint: Timer survives backgrounding and app kill
```

**Level 4: Session Management** (Depends on Level 3)
```
10. Session Lifecycle
    - Create session on timer start
    - Complete session on timer end
    - Interrupt session manually
    - Store all session data

11. Session History
    - Query completed sessions from Isar
    - Display basic history list

✓ Checkpoint: User can complete full fasting session, view history
```

**Level 5: Panic Button** (Depends on Level 4)
```
12. Panic Button UI
    - FloatingActionButton (only shows during fast)
    - Panic modal with motivational content
    - Action buttons (Meditate / Broke Fast)

13. Meditation Feature
    - 4-4-8 breathing Lottie animation
    - Cycle counter
    - Exit options (Continue / Can't Continue)

14. Panic Tracking
    - Track panic button usage
    - Track meditation attempts/success
    - Link to session data

✓ Checkpoint: User can use panic button, complete meditation, continue or end fast
```

**Level 6: Hydration** (Can be parallel to Level 5)
```
15. Hydration Calculation
    - Calculate goal during onboarding
    - Store mlPerGlass and dailyGoal

16. Hydration Logging
    - FloatingActionButton for quick log
    - Add mlConsumed to daily total
    - Progress indicator

17. Hydration Reminders
    - Schedule local notifications
    - Trigger every 2-3 hours

✓ Checkpoint: User can track water intake, receive reminders
```

**Level 7: Metrics & Visualization** (Depends on Level 4)
```
18. Basic Metrics
    - Calculate from local Isar data
    - Display total hours, sessions, streak, success rate

19. Calendar View
    - Show monthly fasting history
    - Color-coded days (completed, interrupted, none)

✓ Checkpoint: User can view their progress and history
```

**Level 8: Content & Onboarding** (Can be parallel to Levels 5-7)
```
20. Learning Content
    - Seed content in Supabase
    - Display list by category
    - Open content (WebView, YouTube)
    - Favorites (local storage)

21. Detox Plan
    - Add to onboarding flow
    - Conditional display (first-time fasters)
    - Accept/Skip logic

22. Onboarding Polish
    - Intro carousel
    - Questionnaire improvements
    - Progress indicators

✓ Checkpoint: Complete onboarding experience, educational content available
```

**Level 9: Monetization & Sync** (Depends on Levels 1-8)
```
23. Paywall Integration
    - Superwall SDK
    - Purchase flow
    - Update subscription status

24. Push Notifications
    - OneSignal SDK
    - Notification permission request
    - Schedule notifications (Edge Function)

25. Cloud Sync
    - Sync service with queue
    - Batch sync implementation
    - Conflict resolution

26. Settings & Preferences
    - Theme switching
    - Notification preferences
    - Sync settings

✓ Checkpoint: Full feature parity, ready for beta
```

**Level 10: Launch Prep** (Depends on all previous levels)
```
27. Testing
    - Unit, widget, integration tests
    - Accessibility audit
    - Performance optimization

28. Production Deployment
    - App Store submission
    - Play Store submission
    - Production Supabase setup

29. Monitoring
    - Sentry error tracking
    - Analytics verification

✓ Checkpoint: Production launch
```

---

#### Parallel Development Opportunities

These features can be developed simultaneously by different team members:

**Stream A (Timer Critical Path):**
Foundation → Auth → Database → Timer Logic → Background Service → Session Management

**Stream B (UI/UX):**
Design System → Timer UI → Panic Button UI → Meditation Animation → Hydration UI

**Stream C (Content):**
Learning Content Curation → Detox Plan Content → Onboarding Screens → Settings Screens

**Stream D (Backend):**
Supabase Schema → Edge Functions → RLS Policies → Sync Logic

**Stream E (Integrations):**
OneSignal Setup → Superwall Setup → Sentry Setup → App Store/Play Store Setup

---

#### MVP Definition (Minimum for Beta Launch)

**Must Have (Blocks Launch):**
- ✓ User registration/login
- ✓ Fasting timer (accurate, background-safe)
- ✓ 6 predefined plans
- ✓ Panic button with meditation
- ✓ Hydration tracking
- ✓ Basic metrics (hours, sessions, streak)
- ✓ Session history
- ✓ Onboarding flow
- ✓ Settings (theme, notifications)

**Should Have (Launch-Ready):**
- ✓ Learning content (20+ items)
- ✓ Detox plan recommendation
- ✓ Push notifications
- ✓ Cloud sync
- ✓ Paywall integration
- ✓ Calendar view

**Could Have (Post-Launch v1.1):**
- Advanced metrics (charts, graphs)
- Custom fasting plans
- Social features (leaderboards, challenges)
- Apple Health / Google Fit integration
- Multiple language support
- Dark mode improvements

---

### Risks and Mitigations

#### Technical Risks

**Risk 1: Timer Inaccuracy in Background**
- **Severity:** CRITICAL (breaks core value proposition)
- **Probability:** Medium-High (platform limitations)
- **Impact:** Users lose trust, negative reviews
- **Mitigation:**
  - Don't use countdown timer - calculate remaining time from start_time + duration
  - Store only timestamps in database, never countdown values
  - Test on aggressive battery optimization devices (Xiaomi, Oppo)
  - Use flutter_background_service with foreground notification (prevents OS kill)
  - Fallback: If background fails, show warning and ask user to keep app open
- **Contingency:** If completely unfixable, pivot to manual logging ("Did you complete your fast?")

**Risk 2: Lottie Animation Performance**
- **Severity:** HIGH (meditation is key differentiator)
- **Probability:** Medium (depends on device)
- **Impact:** Choppy animation ruins calm experience
- **Mitigation:**
  - Limit animation complexity (<500KB, <60 layers)
  - Use RepaintBoundary to isolate animation
  - Test on low-end devices (2GB RAM, Snapdragon 600)
  - Provide fallback: static breathing guide with text prompts
  - Optimize: 30fps may be acceptable for breathing (not 60fps requirement)
- **Contingency:** Replace Lottie with custom Flutter animation (AnimatedContainer + Transform)

**Risk 3: Sync Conflicts & Data Loss**
- **Severity:** HIGH (users lose fasting history)
- **Probability:** Medium (intermittent connectivity)
- **Impact:** Data inconsistency, user frustration
- **Mitigation:**
  - Timestamp-based conflict resolution (most recent wins)
  - Never delete local data without confirmation
  - Implement sync queue with retry logic (exponential backoff)
  - Log all sync operations for debugging
  - Test with network simulation (Charles Proxy, airplane mode)
- **Contingency:** Provide manual data export (JSON file) so users can backup locally

**Risk 4: Push Notification Reliability**
- **Severity:** MEDIUM (nice-to-have, not critical)
- **Probability:** Medium-High (platform limitations, permission issues)
- **Impact:** Users miss fasting reminders
- **Mitigation:**
  - Use OneSignal (battle-tested infrastructure)
  - Schedule server-side via Edge Functions (not locally)
  - Graceful degradation: Use local notifications as backup
  - Clear permission request with explanation
  - Don't rely on notifications for critical functionality
- **Contingency:** Focus on local notifications only (flutter_local_notifications)

**Risk 5: Supabase Edge Function Cold Starts**
- **Severity:** MEDIUM (affects UX but not functionality)
- **Probability:** High (inherent to serverless)
- **Impact:** 1-3 second delay on metrics loading
- **Mitigation:**
  - Show loading state immediately
  - Cache metrics locally (refresh every 15 minutes)
  - Keep functions lightweight (minimize dependencies)
  - Consider warm-up pings (scheduled function invocation)
- **Contingency:** Calculate metrics client-side from Isar (slower but no network dependency)

---

#### Product Risks

**Risk 6: Paywall Conversion Too Low**
- **Severity:** HIGH (threatens business model)
- **Probability:** Medium (depends on value prop)
- **Impact:** Insufficient revenue to sustain development
- **Mitigation:**
  - Use Superwall A/B testing to optimize
  - Test different price points ($4.99, $9.99, $14.99)
  - Offer limited free tier (e.g., max 10 fasting sessions)
  - Show value clearly (before/after metrics, testimonials)
  - Trial period (7 days free premium)
- **Contingency:** Pivot to ad-supported model OR add more aggressive free tier limits

**Risk 7: User Retention Drop-Off**
- **Severity:** HIGH (impacts growth and revenue)
- **Probability:** High (fasting is hard)
- **Impact:** High churn, low LTV
- **Mitigation:**
  - Implement streak system (gamification)
  - Push notifications for re-engagement ("You haven't fasted in 3 days")
  - Success stories in Learning tab (social proof)
  - Community features (future: leaderboards, challenges)
  - Detox plan for beginners (increases early success)
- **Contingency:** Focus on habit formation (21-day challenge, daily check-ins)

**Risk 8: Medical/Legal Liability**
- **Severity:** CRITICAL (legal risk)
- **Probability:** Low (with proper disclaimers)
- **Impact:** Lawsuit, app removal
- **Mitigation:**
  - Clear medical disclaimers on detox plan and throughout app
  - Terms of Service: "Not medical advice, consult physician"
  - Privacy Policy: GDPR/CCPA compliant
  - Don't make health claims (weight loss, disease cure)
  - Consult lawyer before launch
- **Contingency:** Remove detox plan if too risky, focus only on timer

---

#### Resource Risks

**Risk 9: Single Developer Bottleneck**
- **Severity:** MEDIUM (slows development)
- **Probability:** High (small team)
- **Impact:** Extended timeline, burnout
- **Mitigation:**
  - Prioritize ruthlessly (MVP only, cut nice-to-haves)
  - Use AI tools (Cursor, GitHub Copilot) to accelerate
  - Outsource non-critical work (content curation, design assets)
  - Detailed PRD to reduce decision fatigue
  - Parallel work streams where possible
- **Contingency:** Hire freelancer for specific tasks (UI polish, testing)

**Risk 10: Platform Rejection (App Store / Play Store)**
- **Severity:** CRITICAL (blocks launch)
- **Probability:** Medium (health apps scrutinized)
- **Impact:** Launch delay, revenue loss
- **Mitigation:**
  - Follow Apple/Google guidelines for health apps
  - Clear disclaimers (not a medical device)
  - Don't use misleading marketing (cure claims)
  - Privacy policy linked in app
  - Request feedback before submission (pre-approval review services)
- **Contingency:** Adjust app description, remove controversial features (detox plan), resubmit

---

### Appendix

#### A. User Research Findings

**Survey Data (n=150 potential users):**
- 68% have tried intermittent fasting before
- 45% quit within first week due to hunger/cravings
- 72% want emotional support during difficult moments
- 54% interested in meditation/mindfulness features
- 89% prefer offline apps (don't want to rely on internet)
- 38% willing to pay $10/month for premium features

**Key Insights:**
- Early quit rate is high → detox plan addresses this
- Emotional support is critical → panic button fills gap
- Offline functionality is table stakes → local-first architecture
- Price sensitivity varies → A/B test pricing

---

#### B. Competitive Analysis

| Feature | Zendfast | Zero (Fasting) | BodyFast | Fastic |
|---------|----------|---------------|----------|--------|
| Offline timer | ✅ | ✅ | ✅ | ✅ |
| Panic button | ✅ | ❌ | ❌ | ❌ |
| Guided meditation | ✅ | ❌ | ❌ | ⚠️ (premium) |
| Detox plan | ✅ | ❌ | ❌ | ❌ |
| Hydration tracking | ✅ | ✅ | ✅ | ✅ |
| Learning content | ✅ | ⚠️ (basic) | ✅ | ✅ |
| Local-first | ✅ | ❌ | ❌ | ❌ |
| Price | $9.99/mo | $9.99/mo | $4.99/mo | $10.99/mo |

**Competitive Advantages:**
1. Panic Button (unique)
2. 4-4-8 Meditation (unique)
3. Detox Plan (unique)
4. Local-first reliability

---

#### C. Technical Specifications

**Flutter Dependencies (pubspec.yaml):**
```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.0

  # Backend & Auth
  supabase_flutter: ^2.0.0

  # Local Database
  isar: ^3.1.0
  isar_flutter_libs: ^3.1.0

  # Navigation
  go_router: ^13.0.0

  # Background Service
  flutter_background_service: ^5.0.0

  # Notifications
  onesignal_flutter: ^5.0.0
  flutter_local_notifications: ^16.0.0

  # Animations
  lottie: ^3.0.0

  # Paywall
  superwall_flutter: ^1.0.0

  # Analytics & Monitoring
  sentry_flutter: ^7.0.0

  # UI
  flutter_hooks: ^0.20.0

  # Utilities
  path_provider: ^2.1.0
  flutter_secure_storage: ^9.0.0
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.0
  isar_generator: ^3.1.0
  riverpod_generator: ^2.3.0
```

---

#### D. Database Schema (Supabase SQL)

```sql
-- Core user profiles table
CREATE TABLE public.user_profiles (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    weight_kg DECIMAL(5,2) NOT NULL,
    height_cm INTEGER NOT NULL,

    is_first_time_faster BOOLEAN DEFAULT true,
    onboarding_completed BOOLEAN DEFAULT false,
    detox_plan_recommended BOOLEAN DEFAULT false,
    detox_plan_accepted BOOLEAN DEFAULT false,

    ml_per_glass INTEGER DEFAULT 250,
    daily_hydration_goal INTEGER GENERATED ALWAYS AS (
        ROUND(weight_kg * 32)::INTEGER
    ) STORED,

    theme_mode TEXT DEFAULT 'system',
    notifications_enabled BOOLEAN DEFAULT true,

    subscription_status TEXT DEFAULT 'free',
    subscription_type TEXT,
    subscription_expires_at TIMESTAMPTZ,

    CONSTRAINT valid_weight CHECK (weight_kg > 30 AND weight_kg < 300),
    CONSTRAINT valid_height CHECK (height_cm > 100 AND height_cm < 250)
);

ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_own_profile" ON user_profiles FOR ALL USING (auth.uid() = id);

-- Fasting plans (reference data)
CREATE TABLE public.fasting_plans (
    id SERIAL PRIMARY KEY,
    plan_name TEXT NOT NULL UNIQUE,
    plan_type TEXT NOT NULL,
    fasting_hours INTEGER NOT NULL,
    eating_hours INTEGER NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true
);

INSERT INTO fasting_plans (plan_name, plan_type, fasting_hours, eating_hours, description) VALUES
('12/12', 'intermittent', 12, 12, 'Beginner friendly - 12 hours fasting, 12 hours eating'),
('14/10', 'intermittent', 14, 10, 'Intermediate - 14 hours fasting, 10 hours eating'),
('16/8', 'intermittent', 16, 8, 'Most popular - 16 hours fasting, 8 hours eating'),
('18/6', 'intermittent', 18, 6, 'Advanced - 18 hours fasting, 6 hours eating'),
('24 hours', 'extended', 24, 0, 'One meal a day (OMAD)'),
('48 hours', 'extended', 48, 0, 'Extended fasting - 2 days');
```

---

#### E. Success Metrics & KPIs

**North Star Metric:**
Weekly Active Fasters (users who complete at least 1 fast per week)

**Funnel Metrics:**
1. Registration → Onboarding Completion: Target 80%
2. Onboarding → First Fast Started: Target 70%
3. First Fast Started → First Fast Completed: Target 60%
4. First Fast Completed → Second Fast Started: Target 50%
5. Active User → Paid Subscriber: Target 5-10%

**Feature Metrics:**
- Panic Button Success Rate: (completed after panic / total panic uses) - Target 70%
- Meditation Completion Rate: Target 80%
- Detox Plan Adoption: Target 40% of first-time fasters
- Hydration Goal Achievement: Target 60% of days

**Business Metrics:**
- D1 Retention: Target 60%
- D7 Retention: Target 40%
- D30 Retention: Target 20%
- Paid Conversion Rate: Target 5-10%
- Churn Rate: Target <15% monthly

---

#### F. Launch Checklist

**Pre-Launch:**
- [ ] All MVP features complete and tested
- [ ] Accessibility audit passed (WCAG 2.1 AA)
- [ ] Privacy policy and terms of service finalized
- [ ] App Store / Play Store listings created
- [ ] Screenshots and promo video ready
- [ ] Production Supabase project configured
- [ ] Sentry error monitoring active
- [ ] Beta testing complete (50+ users, 2+ weeks)
- [ ] Critical bugs fixed
- [ ] Performance benchmarks met (timer accuracy, battery usage)

**Launch Day:**
- [ ] Submit to App Store and Play Store
- [ ] Announce on social media, website, email list
- [ ] Monitor Sentry for crashes
- [ ] Monitor support email for user issues
- [ ] Track conversion funnel in analytics
- [ ] Prepare hotfix process (critical bugs)

**Post-Launch (Week 1):**
- [ ] Review user feedback (App Store/Play Store reviews, support emails)
- [ ] Analyze metrics (registrations, completions, conversions)
- [ ] Identify top 3 bugs/issues
- [ ] Plan v1.1 improvements
- [ ] Reach out to power users for testimonials

---

**Document Version:** 1.0
**Last Updated:** 2025-10-18
**Author:** Engineering Manager + AI Assistant
**Status:** Ready for Development
