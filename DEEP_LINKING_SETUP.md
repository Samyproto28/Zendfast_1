# Deep Linking Setup Guide

## Overview

This document describes the complete deep linking setup for the ZendFast app, including:
- **Custom URL Scheme**: `zendfast://` for app-to-app deep links
- **Universal Links (iOS)**: `https://zendfast.app/*` for web-to-app links on iOS
- **App Links (Android)**: `https://zendfast.app/*` for web-to-app links on Android
- **OneSignal Integration**: Push notification deep linking

## Architecture

### Deep Link Flow

```
User clicks link → System checks domain association → Opens app → Router handles navigation
```

### Supported Routes

All routes support both custom scheme and HTTPS domain:

| Route | Custom Scheme | HTTPS URL |
|-------|--------------|-----------|
| Home | `zendfast://home` | `https://zendfast.app/home` |
| Fasting Overview | `zendfast://fasting` | `https://zendfast.app/fasting` |
| Start Fast | `zendfast://fasting/start` | `https://zendfast.app/fasting/start` |
| Fasting Progress | `zendfast://fasting/progress` | `https://zendfast.app/fasting/progress` |
| Hydration | `zendfast://hydration` | `https://zendfast.app/hydration` |
| Learning | `zendfast://learning` | `https://zendfast.app/learning` |
| Article Detail | `zendfast://learning/articles/:id` | `https://zendfast.app/learning/articles/:id` |
| Profile | `zendfast://profile` | `https://zendfast.app/profile` |
| Settings | `zendfast://settings` | `https://zendfast.app/settings` |

## Files Created

### 1. Universal Links Configuration (iOS)

**File**: `.well-known/apple-app-site-association`

This JSON file must be hosted at:
```
https://zendfast.app/.well-known/apple-app-site-association
```

**Important**:
- Replace `TEAM_ID` with your actual Apple Team ID (found in Apple Developer account)
- File must be served with `Content-Type: application/json` header
- No file extension (.json) should be in the URL path
- Must be accessible over HTTPS with a valid SSL certificate

### 2. App Links Configuration (Android)

**File**: `.well-known/assetlinks.json`

This JSON file must be hosted at:
```
https://zendfast.app/.well-known/assetlinks.json
```

**Important**:
- Replace SHA256 fingerprints with your actual signing key fingerprints:
  - **Release key fingerprint**: Use the keystore you'll use for Play Store releases
  - **Debug key fingerprint**: Use for local development/testing

**Getting SHA256 Fingerprints**:

```bash
# For debug key (typically ~/.android/debug.keystore)
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# For release key (replace with your keystore path)
keytool -list -v -keystore /path/to/your/release.keystore -alias your_key_alias

# Look for the SHA256 line in the output
```

### 3. iOS Entitlements

**File**: `ios/Runner/Runner.entitlements`

This file has been created with the Associated Domains capability.

**Manual Step Required**:
You must add this entitlements file to your Xcode project:

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the Runner target
3. Go to "Signing & Capabilities" tab
4. Click "+ Capability"
5. Add "Associated Domains"
6. Add domain: `applinks:zendfast.app`
7. In "Build Settings", search for "Code Signing Entitlements"
8. Set the value to `Runner/Runner.entitlements`

### 4. Android Manifest

**File**: `android/app/src/main/AndroidManifest.xml`

Already updated with App Links intent-filter. The configuration includes:
- `android:autoVerify="true"` for automatic verification
- Path prefixes for all supported routes
- HTTPS scheme with `zendfast.app` host

### 5. Deep Link Handler

**File**: `lib/utils/deep_link_handler.dart`

Central handler for processing all deep links. Supports:
- Custom scheme URLs (`zendfast://`)
- HTTPS URLs (via Universal/App Links)
- OneSignal notification payloads

### 6. OneSignal Notification Templates

**File**: `lib/services/onesignal_service.dart`

Notification templates now include proper deep link URLs:
- `fastingStartTemplate`: `zendfast://fasting/view`
- `fastingMilestoneTemplate`: `zendfast://fasting/view`
- `fastingCompleteTemplate`: `zendfast://fasting/complete`
- `hydrationReminderTemplate`: `zendfast://hydration`
- `reEngagementTemplate`: `zendfast://home`
- `learningContentTemplate`: `zendfast://learning/articles/:id`

## Setup Steps

### Phase 1: App Configuration (✅ Completed)

- [x] Create route constants and type-safe navigation
- [x] Create all app screens with navigation
- [x] Update router with auth guards and error handling
- [x] Update deep link handler for all routes
- [x] Update OneSignal notification templates
- [x] Create Universal/App Links configuration files
- [x] Update Android manifest
- [x] Create iOS entitlements file

### Phase 2: Domain Setup (❌ Required - Manual Steps)

1. **Upload Configuration Files to Web Server**

   Upload these files to your web server at `https://zendfast.app`:

   ```
   .well-known/apple-app-site-association
   .well-known/assetlinks.json
   ```

   **Web Server Configuration**:
   - Ensure files are accessible over HTTPS
   - Set correct Content-Type headers:
     - `apple-app-site-association`: `application/json`
     - `assetlinks.json`: `application/json`
   - No authentication/login required to access these files
   - Files should be at exact paths (no redirects)

2. **Update Apple Team ID** (iOS)

   In `apple-app-site-association`:
   ```json
   "appIDs": [
     "TEAM_ID.com.zendfast.app"  // Replace TEAM_ID
   ]
   ```

3. **Update SHA256 Fingerprints** (Android)

   In `assetlinks.json`:
   ```json
   "sha256_cert_fingerprints": [
     "YOUR_RELEASE_KEY_SHA256",
     "YOUR_DEBUG_KEY_SHA256"
   ]
   ```

4. **Configure Xcode Project** (iOS)

   Follow the manual steps in section 3 above to add the entitlements file to Xcode.

### Phase 3: Testing

See "Testing Deep Links" section below.

## Testing Deep Links

### 1. Test Custom Scheme (Local Development)

**Using ADB (Android)**:
```bash
# Test home screen
adb shell am start -W -a android.intent.action.VIEW -d "zendfast://home" com.zendfast.app

# Test fasting start
adb shell am start -W -a android.intent.action.VIEW -d "zendfast://fasting/start" com.zendfast.app

# Test article detail
adb shell am start -W -a android.intent.action.VIEW -d "zendfast://learning/articles/123" com.zendfast.app
```

**Using xcrun (iOS Simulator)**:
```bash
# Test home screen
xcrun simctl openurl booted "zendfast://home"

# Test fasting progress
xcrun simctl openurl booted "zendfast://fasting/progress"

# Test hydration
xcrun simctl openurl booted "zendfast://hydration"
```

**Using Safari (iOS Device)**:
Type custom URL in Safari address bar and navigate.

### 2. Test Universal Links (iOS)

**Prerequisites**:
- App installed on device
- `apple-app-site-association` hosted at domain
- Team ID configured correctly
- Entitlements added in Xcode

**Testing**:
1. Open Safari on iOS device (not simulator)
2. Navigate to: `https://zendfast.app/home`
3. App should open automatically (if configured correctly)
4. If opens in browser, long-press the link and select "Open in ZendFast"

**Verification**:
```bash
# Verify domain association (requires macOS)
swcutil query -s zendfast.app -u https://zendfast.app/.well-known/apple-app-site-association
```

### 3. Test App Links (Android)

**Prerequisites**:
- App installed on device
- `assetlinks.json` hosted at domain
- SHA256 fingerprints configured correctly
- App signed with matching certificate

**Testing**:
1. Send yourself an email/SMS with link: `https://zendfast.app/home`
2. Click the link
3. System should show app as option to handle link
4. Select "Always open with ZendFast"

**Verification**:
```bash
# Check domain verification status
adb shell pm get-app-links com.zendfast.app

# Manually verify domain
adb shell pm verify-app-links --re-verify com.zendfast.app

# Check verification state (should show "verified")
adb shell pm get-app-links --user 0 com.zendfast.app
```

### 4. Test OneSignal Notifications

**Setup**:
1. Ensure OneSignal is configured with `ONESIGNAL_APP_ID` in `.env`
2. App has requested and been granted notification permissions
3. Device/simulator has valid OneSignal player ID

**Testing via OneSignal Dashboard**:
1. Go to OneSignal Dashboard → Messages → New Push
2. Select target users/segments
3. Set message content
4. Add Launch URL: `zendfast://fasting/start`
5. Send notification
6. Tap notification → app should open to fasting start screen

**Testing Programmatically**:
```dart
// In your Flutter code, trigger a test notification
final template = OneSignalService.instance.fastingStartTemplate(
  fastingPlan: '16:8',
  targetHours: 16,
);
// Send via OneSignal API (requires backend implementation)
```

## Troubleshooting

### Universal Links Not Working (iOS)

**Symptom**: Links open in Safari instead of app

**Solutions**:
1. **Verify domain association file**:
   ```bash
   curl https://zendfast.app/.well-known/apple-app-site-association
   ```
   - Should return JSON (not HTML/error page)
   - Should have correct Team ID
   - Should be accessible without authentication

2. **Check entitlements**:
   - Open Xcode → Runner target → Signing & Capabilities
   - Verify "Associated Domains" capability is present
   - Verify `applinks:zendfast.app` is listed

3. **Reset iOS association cache**:
   - Settings → Safari → Advanced → Website Data → Remove All
   - Restart device
   - Reinstall app

4. **Check iOS logs**:
   ```bash
   # Connect device and check logs
   log stream --predicate 'process == "swcd"' --level debug
   ```

### App Links Not Working (Android)

**Symptom**: Links open in browser instead of app

**Solutions**:
1. **Verify domain association file**:
   ```bash
   curl https://zendfast.app/.well-known/assetlinks.json
   ```
   - Should return JSON
   - Should have correct package name: `com.zendfast.app`
   - Should have correct SHA256 fingerprints

2. **Verify SHA256 fingerprint**:
   ```bash
   # Get fingerprint from installed APK
   keytool -list -printcert -jarfile app-release.apk

   # Compare with assetlinks.json
   ```

3. **Check verification status**:
   ```bash
   # Should show "verified" for zendfast.app
   adb shell pm get-app-links com.zendfast.app
   ```

4. **Force re-verification**:
   ```bash
   # Clear verification state
   adb shell pm set-app-links --package com.zendfast.app 0 all

   # Re-verify
   adb shell pm verify-app-links --re-verify com.zendfast.app

   # Check status (wait 30 seconds)
   adb shell pm get-app-links com.zendfast.app
   ```

5. **Check Android logs**:
   ```bash
   adb logcat | grep -i "IntentFilter"
   ```

### Custom Scheme Not Working

**Symptom**: Custom URLs don't open app

**Solutions**:
1. **Verify AndroidManifest.xml**:
   - Check intent-filter with `android:scheme="zendfast"` exists
   - Check activity is exported: `android:exported="true"`

2. **Verify iOS Info.plist**:
   ```bash
   # Check if URL scheme is registered
   grep -A 5 "CFBundleURLSchemes" ios/Runner/Info.plist
   ```

3. **Test with explicit intent (Android)**:
   ```bash
   adb shell am start -W -a android.intent.action.VIEW \
     -d "zendfast://home" \
     -n com.zendfast.app/.MainActivity
   ```

### Deep Link Handler Not Executing

**Symptom**: App opens but navigation doesn't happen

**Solutions**:
1. **Check router initialization**:
   - Ensure `DeepLinkHandler.handleDeepLink()` is called in app initialization
   - Check `main.dart` for proper setup

2. **Add debug logging**:
   ```dart
   // In deep_link_handler.dart
   debugPrint('🔗 Handling deep link: $url');
   ```

3. **Verify GoRouter configuration**:
   - Check routes are registered in `app_router.dart`
   - Check route paths match deep link handler paths

4. **Check auth guards**:
   - User might not be authenticated
   - Check redirect logic in `app_router.dart`

### OneSignal Notifications Not Deep Linking

**Symptom**: Notifications received but don't navigate

**Solutions**:
1. **Check OneSignal initialization**:
   ```dart
   // Ensure initialized before notification handlers
   await OneSignalService.instance.initialize();
   ```

2. **Verify notification handler**:
   - Check `_handleNotificationOpened()` in `onesignal_service.dart`
   - Ensure `launchURL` is being extracted correctly

3. **Check notification payload**:
   - Add logging in notification handlers
   - Verify `launchURL` or `action_url` fields are present

4. **Test with simple notification first**:
   - Send notification with just `zendfast://home`
   - Verify basic functionality before testing complex routes

## Security Considerations

### 1. Domain Verification

- **Never** serve association files over HTTP (must be HTTPS)
- **Always** use valid SSL certificates (not self-signed)
- **Protect** against MITM attacks with certificate pinning (optional)

### 2. Deep Link Validation

Current implementation validates:
- URL scheme matches expected scheme (`zendfast`)
- Paths match registered routes
- Invalid paths redirect to home (fail-safe)

### 3. Authentication Guards

All protected routes require authentication:
- Router automatically redirects to login if not authenticated
- Deep links respect authentication state
- No sensitive data exposed in URL parameters

### 4. Data Handling

- Don't pass sensitive data (passwords, tokens) in deep link URLs
- Use route parameters for IDs only
- Fetch sensitive data server-side after navigation

## Maintenance

### When Adding New Routes

1. **Update route constants**:
   ```dart
   // lib/router/route_constants.dart
   static const String newRoute = '/new-route';
   ```

2. **Update deep link handler**:
   ```dart
   // lib/utils/deep_link_handler.dart
   case 'new-route':
     router.go('/new-route');
     return true;
   ```

3. **Update association files**:
   ```json
   // .well-known/apple-app-site-association
   {
     "/": "/new-route",
     "comment": "Description of route"
   }

   // .well-known/assetlinks.json (if using path prefixes)
   <data android:pathPrefix="/new-route" />
   ```

4. **Update this documentation**:
   - Add route to "Supported Routes" table
   - Add testing examples if needed

### When Changing Domain

1. Update `apple-app-site-association` host references
2. Update `assetlinks.json` and re-upload
3. Update `AndroidManifest.xml` `android:host` value
4. Update `Runner.entitlements` associated domain
5. Test all links with new domain

## References

- [Apple Universal Links Documentation](https://developer.apple.com/ios/universal-links/)
- [Android App Links Documentation](https://developer.android.com/training/app-links)
- [OneSignal Flutter SDK Documentation](https://documentation.onesignal.com/docs/flutter-sdk-setup)
- [GoRouter Deep Linking](https://pub.dev/documentation/go_router/latest/topics/Deep%20linking-topic.html)

## Support

For issues related to:
- **Routing**: Check `lib/router/app_router.dart` and `lib/utils/deep_link_handler.dart`
- **OneSignal**: Check `lib/services/onesignal_service.dart`
- **iOS Universal Links**: Check `ios/Runner/Runner.entitlements` and Xcode project settings
- **Android App Links**: Check `android/app/src/main/AndroidManifest.xml`
