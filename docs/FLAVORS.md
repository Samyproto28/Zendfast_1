# Flutter Flavors Guide - Development & Production Environments

This document explains how to build, run, and deploy Zendfast using development and production flavors.

## Table of Contents
- [Overview](#overview)
- [Quick Start](#quick-start)
- [Environment Configuration](#environment-configuration)
- [Building the App](#building-the-app)
- [iOS Setup (Manual Steps Required)](#ios-setup-manual-steps-required)
- [OneSignal Configuration](#onesignal-configuration)
- [Deep Link Testing](#deep-link-testing)
- [Troubleshooting](#troubleshooting)

---

## Overview

Zendfast uses Flutter flavors to maintain separate development and production environments with:

- **Different App IDs**: Allows installation of both versions simultaneously
  - Development: `com.zendfast.app.dev`
  - Production: `com.zendfast.app`

- **Different App Names**: Easy visual distinction
  - Development: "Zendfast Dev"
  - Production: "Zendfast"

- **Different Deep Link Schemes**: Isolated deep linking
  - Development: `zendfast-dev://`
  - Production: `zendfast://`

- **Environment-Specific Services**: Separate Supabase, OneSignal, and Superwall configurations

---

## Quick Start

### Development Build (Android)
```bash
./scripts/build_dev.sh apk
```

### Production Build (Android App Bundle)
```bash
./scripts/build_prod.sh appbundle
```

### Run Development Locally
```bash
./scripts/build_dev.sh run
# Or directly:
flutter run --flavor development --dart-define=ENV=development
```

---

## Environment Configuration

### Setup Steps

1. **Create environment files** from templates:
   ```bash
   cp .env.development .env.development.local
   cp .env.production .env.production.local
   ```

2. **Update `.env.development.local`** with your development credentials:
   ```env
   ENVIRONMENT=development

   # Development Supabase Project
   SUPABASE_URL=https://your-dev-project.supabase.co
   SUPABASE_ANON_KEY=your-development-anon-key

   # Development OneSignal App
   ONESIGNAL_APP_ID=your-dev-onesignal-app-id

   # Development Superwall Project
   SUPERWALL_API_KEY=pk_your_dev_superwall_key
   ```

3. **Update `.env.production.local`** with production credentials:
   ```env
   ENVIRONMENT=production

   # Production Supabase Project
   SUPABASE_URL=https://your-prod-project.supabase.co
   SUPABASE_ANON_KEY=your-production-anon-key

   # Production OneSignal App
   ONESIGNAL_APP_ID=your-prod-onesignal-app-id

   # Production Superwall Project
   SUPERWALL_API_KEY=pk_your_prod_superwall_key
   ```

4. **For local development**, you can also use the regular `.env` file (falls back to this if `.env.development` not found).

### Environment Variable Priority

The app reads environment configuration in this order:
1. `--dart-define` flags (highest priority, used in builds)
2. `.env` file (fallback for local development)

---

## Building the App

### Android Builds

#### Development APK
```bash
# Using script
./scripts/build_dev.sh apk

# Or manually
flutter build apk --flavor development \
  --dart-define=ENV=development \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=ONESIGNAL_APP_ID=$ONESIGNAL_APP_ID \
  --dart-define=SUPERWALL_API_KEY=$SUPERWALL_API_KEY
```

Output: `build/app/outputs/flutter-apk/app-development-release.apk`

#### Production App Bundle (for Google Play)
```bash
# Using script
./scripts/build_prod.sh appbundle

# Or manually
flutter build appbundle --flavor production \
  --dart-define=ENV=production \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=ONESIGNAL_APP_ID=$ONESIGNAL_APP_ID \
  --dart-define=SUPERWALL_API_KEY=$SUPERWALL_API_KEY
```

Output: `build/app/outputs/bundle/productionRelease/app-production-release.aab`

### iOS Builds

#### Development
```bash
./scripts/build_dev.sh ios
```

#### Production
```bash
./scripts/build_prod.sh ios
```

**Note**: iOS builds require additional manual setup in Xcode (see below).

---

## iOS Setup (Manual Steps Required)

Flutter flavors on iOS require creating separate build configurations and schemes in Xcode. Follow these steps:

### 1. Open Project in Xcode
```bash
open ios/Runner.xcworkspace
```

### 2. Create Build Configurations

1. In Xcode, select the **Runner** project in the left sidebar
2. Select the **Runner** target
3. Go to the **Info** tab
4. Under **Configurations**, duplicate the existing configs:

   **For Development:**
   - Duplicate "Debug" → Rename to "Development-Debug"
   - Duplicate "Release" → Rename to "Development-Release"
   - Set configuration file for both to `Flutter/Development.xcconfig`

   **For Production:**
   - Duplicate "Debug" → Rename to "Production-Debug"
   - Duplicate "Release" → Rename to "Production-Release"
   - Set configuration file for both to `Flutter/Production.xcconfig`

### 3. Create Schemes

1. Go to **Product > Scheme > Manage Schemes**
2. Duplicate the "Runner" scheme, name it "Development"
3. Edit the "Development" scheme:
   - Build Configuration (Run): Development-Debug
   - Build Configuration (Archive): Development-Release
4. Duplicate "Runner" again, name it "Production"
5. Edit the "Production" scheme:
   - Build Configuration (Run): Production-Debug
   - Build Configuration (Archive): Production-Release

### 4. Update Info.plist for Deep Links

The `CFBundleURLSchemes` should be configured per scheme. Since Info.plist doesn't support conditional values easily, you have two options:

**Option A: Manual Update Before Building** (Temporary)
Edit `ios/Runner/Info.plist` and change line 74:
```xml
<!-- For development builds -->
<string>zendfast-dev</string>

<!-- For production builds -->
<string>zendfast</string>
```

**Option B: Create Scheme-Specific Info.plist** (Recommended for CI/CD)
1. Create `ios/Runner/Info-Development.plist` and `ios/Runner/Info-Production.plist`
2. Set different URL schemes in each
3. Configure build phases to copy the correct file

### 5. Provisioning Profiles

You'll need separate provisioning profiles for each bundle identifier:
- Development: `com.zendfast.app.dev`
- Production: `com.zendfast.app`

Configure these in the Apple Developer Portal and Xcode signing settings.

---

## OneSignal Configuration

You need separate OneSignal applications for development and production to ensure notifications are properly isolated.

### Create Development OneSignal App

1. Go to [OneSignal Dashboard](https://onesignal.com/)
2. Click "New App/Website"
3. Name it "Zendfast Dev"
4. Configure for Android and iOS:
   - Android: Use package name `com.zendfast.app.dev`
   - iOS: Use bundle ID `com.zendfast.app.dev`
5. Copy the **App ID** to `.env.development`:
   ```env
   ONESIGNAL_APP_ID=your-dev-app-id-here
   ```

### Create Production OneSignal App

1. Click "New App/Website" again
2. Name it "Zendfast"
3. Configure for Android and iOS:
   - Android: Use package name `com.zendfast.app`
   - iOS: Use bundle ID `com.zendfast.app`
4. Copy the **App ID** to `.env.production`:
   ```env
   ONESIGNAL_APP_ID=your-prod-app-id-here
   ```

### Testing Push Notifications

Send a test notification from OneSignal dashboard:
1. Go to "Messages" → "New Push"
2. Select the appropriate app (Dev or Prod)
3. Send to "Test Users" or specific devices

---

## Deep Link Testing

Deep links are environment-specific to avoid conflicts.

### Development Deep Links
- Scheme: `zendfast-dev://`
- Examples:
  ```
  zendfast-dev://home
  zendfast-dev://fasting/view
  zendfast-dev://hydration
  ```

### Production Deep Links
- Scheme: `zendfast://`
- Examples:
  ```
  zendfast://home
  zendfast://fasting/view
  zendfast://hydration
  ```

### Testing on Android
```bash
# Development
adb shell am start -W -a android.intent.action.VIEW \
  -d "zendfast-dev://fasting/view" com.zendfast.app.dev

# Production
adb shell am start -W -a android.intent.action.VIEW \
  -d "zendfast://fasting/view" com.zendfast.app
```

### Testing on iOS (Simulator)
```bash
# Development
xcrun simctl openurl booted "zendfast-dev://fasting/view"

# Production
xcrun simctl openurl booted "zendfast://fasting/view"
```

---

## Troubleshooting

### Problem: Build fails with "SUPABASE_URL not configured"

**Solution**: Ensure environment variables are set:
```bash
# Check if environment file exists
ls -la .env.development

# Verify variables are loaded
cat .env.development | grep SUPABASE
```

### Problem: Both apps have the same name on device

**Solution**: Check that you're building with the correct flavor:
```bash
# Verify build command includes --flavor
flutter build apk --flavor development
```

### Problem: Deep links not working

**Solution**:
1. Verify AndroidManifest uses `@string/deep_link_scheme`
2. Check strings.xml in flavor-specific directories
3. Test with `adb shell` command above

### Problem: OneSignal notifications not received

**Solution**:
1. Verify correct OneSignal App ID for environment
2. Check app is using correct flavor build
3. Verify device has notification permissions
4. Check OneSignal dashboard for delivery status

### Problem: iOS build fails after flavor setup

**Solution**:
1. Clean build folder: `flutter clean && flutter pub get`
2. Delete Derived Data in Xcode
3. Verify xcconfig files are linked correctly
4. Check scheme configurations

### Problem: "AppConfig not initialized" error

**Solution**: Ensure `AppConfig.instance.initialize()` is called in `main.dart` before any other service initialization. Check that it's called before `SupabaseConfig.initialize()`.

### Problem: Can't install both apps simultaneously

**Solution**: Verify bundle IDs / app IDs are different:
```bash
# Android - check build.gradle.kts
grep applicationId android/app/build.gradle.kts

# iOS - check xcconfig files
cat ios/Flutter/Development.xcconfig
cat ios/Flutter/Production.xcconfig
```

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Build Development
on: [push]
jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build apk --flavor development \
          --dart-define=ENV=development \
          --dart-define=SUPABASE_URL=${{ secrets.DEV_SUPABASE_URL }} \
          --dart-define=SUPABASE_ANON_KEY=${{ secrets.DEV_SUPABASE_ANON_KEY }} \
          --dart-define=ONESIGNAL_APP_ID=${{ secrets.DEV_ONESIGNAL_APP_ID }} \
          --dart-define=SUPERWALL_API_KEY=${{ secrets.DEV_SUPERWALL_API_KEY }}
```

Store environment-specific secrets in GitHub repository settings under "Secrets and variables" → "Actions".

---

## Architecture Summary

```
lib/
├── config/
│   ├── app_config.dart           # Environment manager (singleton)
│   └── supabase_config.dart      # Uses AppConfig
├── services/
│   └── onesignal_service.dart    # Uses AppConfig
└── main.dart                      # Initializes AppConfig first

android/
└── app/
    ├── build.gradle.kts          # Flavor definitions
    └── src/
        ├── development/          # Dev-specific resources
        ├── production/           # Prod-specific resources
        └── main/                 # Shared resources

ios/
└── Flutter/
    ├── Development.xcconfig      # Dev bundle ID & config
    └── Production.xcconfig       # Prod bundle ID & config
```

---

## Additional Resources

- [Flutter Flavors Documentation](https://docs.flutter.dev/deployment/flavors)
- [OneSignal Flutter SDK](https://documentation.onesignal.com/docs/flutter-sdk-setup)
- [Supabase Flutter Documentation](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)
- [Deep Linking in Flutter](https://docs.flutter.dev/ui/navigation/deep-linking)

---

**Last Updated**: 2025-11-07
**Version**: 1.0.0
**Maintainer**: Zendfast Development Team
