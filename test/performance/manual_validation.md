# Manual Performance Validation Guide

This document provides detailed procedures for manually validating performance metrics on physical devices. The abbreviated automated tests in CI provide quick feedback, but full validation requires manual testing on real hardware.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Test Devices](#test-devices)
3. [Timer Accuracy - Full 16-Hour Test](#timer-accuracy---full-16-hour-test)
4. [Battery Consumption - Full 16-Hour Test](#battery-consumption---full-16-hour-test)
5. [Memory Profiling with DevTools](#memory-profiling-with-devtools)
6. [Animation Performance Validation](#animation-performance-validation)
7. [App Launch Performance](#app-launch-performance)
8. [Reporting Results](#reporting-results)

---

## Prerequisites

### Required Tools

- Flutter SDK (matching project version)
- Physical test devices (Pixel 6 for Android, iPhone 13 for iOS)
- USB cables for device connection
- Flutter DevTools installed: `flutter pub global activate devtools`
- Notebook or spreadsheet for recording measurements

### Device Preparation

#### Android (Pixel 6)

1. Enable Developer Options:
   - Settings → About Phone → Tap "Build number" 7 times
2. Enable USB Debugging:
   - Settings → Developer Options → USB debugging
3. Disable battery optimization for the app:
   - Settings → Apps → Zendfast → Battery → Unrestricted
4. Keep screen timeout long or enable "Stay awake":
   - Developer Options → Stay awake (charges only)
5. Close all background apps

#### iOS (iPhone 13)

1. Enable Developer Mode:
   - Settings → Privacy & Security → Developer Mode
2. Trust development computer when prompted
3. Disable Low Power Mode:
   - Settings → Battery → Low Power Mode OFF
4. Close all background apps
5. Ensure good cellular/Wi-Fi signal

### Pre-Test Checklist

- [ ] Device fully charged to 100%
- [ ] All background apps closed
- [ ] Device not connected to power (for battery tests)
- [ ] Stable network connection
- [ ] Latest build installed on device
- [ ] Test environment is quiet and temperature-controlled

---

## Test Devices

### Target Devices

| Device | Platform | OS Version | Screen | Battery |
|--------|----------|------------|--------|---------|
| Pixel 6 | Android | 13+ | 6.4" AMOLED | 4614 mAh |
| iPhone 13 | iOS | 17+ | 6.1" OLED | 3227 mAh |

### Why These Devices?

- **Pixel 6**: Representative mid-range Android device, widely used
- **iPhone 13**: Popular iOS device with good battery life
- Both devices reflect real-world user hardware

---

## Timer Accuracy - Full 16-Hour Test

### Objective

Verify that the fasting timer maintains accuracy within ±5 seconds per hour over a full 16-hour fasting period.

### Procedure

#### Day Before Test

1. **Prepare the device:**
   ```bash
   flutter build apk --release  # Android
   flutter build ios --release  # iOS
   ```

2. **Install the app:**
   ```bash
   flutter install
   ```

3. **Charge device to 100%**

#### Test Execution (Evening)

1. **Record start conditions:**
   - Date and time: `_______________`
   - Device model: `_______________`
   - OS version: `_______________`
   - Battery level: `100%`
   - Room temperature: `_______________`

2. **Start the timer:**
   - Open Zendfast app
   - Start a 16-hour fasting timer (e.g., 8:00 PM)
   - Record exact start time from device clock: `_______________`
   - Record timer start time shown in app: `_______________`

3. **Minimize app to background**

4. **Set reference alarm:**
   - Set device alarm for exactly 16 hours later
   - Or use a separate stopwatch/clock

#### During Test (Overnight)

- Do NOT open the app
- Do NOT use the device extensively
- Keep device in a safe location
- Normal overnight usage is acceptable

#### Test Completion (Next Day)

1. **When alarm sounds (after 16 hours):**
   - Record exact current time: `_______________`
   - Open Zendfast app immediately
   - Record timer remaining time: `_______________`
   - Take screenshot of timer display

2. **Calculate drift:**
   ```
   Expected elapsed: 16 hours = 57,600 seconds
   Actual timer elapsed: _________ seconds
   Drift: _________ seconds
   Drift per hour: _________ seconds
   ```

3. **Verify accuracy:**
   - ✅ PASS: Drift ≤ 80 seconds total (±5s/hour × 16 hours)
   - ❌ FAIL: Drift > 80 seconds

### Expected Results

- **Total drift:** <80 seconds over 16 hours
- **Hourly drift:** <5 seconds per hour
- **Timer completion:** Timer should complete accurately

### Common Issues

- **Large drift**: Check for timezone changes, device sleep issues
- **Timer stopped**: Background service may have been killed by OS
- **App crashed**: Check logs, memory issues

---

## Battery Consumption - Full 16-Hour Test

### Objective

Verify that battery consumption is <5% per hour during background fasting timer operation.

### Procedure

#### Test Setup

1. **Charge device to 100%**
   - Use official charger
   - Wait until fully charged
   - Disconnect from power

2. **Record initial state:**
   - Battery level: `100%`
   - Start time: `_______________`
   - Device model: `_______________`

3. **Start fasting timer:**
   - Open Zendfast app
   - Start 16-hour fasting timer
   - Verify timer is running
   - Minimize app to background

4. **Prepare for background operation:**
   - Close all other apps
   - Keep device in airplane mode (optional for isolation)
   - Or keep on Wi-Fi/cellular for realistic test

#### During Test

- **Do NOT** charge the device
- **Do NOT** use the device (except periodic checks)
- Keep device at room temperature
- Normal standby mode

#### Periodic Monitoring (Optional)

Every 4 hours, quickly check:
- Battery level: `____%`
- Time: `_______________`
- Timer still running: Yes/No

**Sampling Schedule:**
| Time | Battery % | Elapsed Hours | Cumulative Drain |
|------|-----------|---------------|------------------|
| Start (0h) | 100% | 0 | 0% |
| +4h | ____% | 4 | ____% |
| +8h | ____% | 8 | ____% |
| +12h | ____% | 12 | ____% |
| +16h (end) | ____% | 16 | ____% |

#### Test Completion

1. **After 16 hours:**
   - Record final battery level: `____%`
   - Calculate total drain: `____%`
   - Calculate drain per hour: `____%/hr`

2. **Formula:**
   ```
   Total drain = Start% - End%
   Drain per hour = Total drain ÷ 16 hours
   ```

3. **Example calculation:**
   ```
   Start: 100%
   End: 25%
   Total drain: 75%
   Drain per hour: 75% ÷ 16 = 4.6875%/hr
   Result: PASS (< 5%/hr)
   ```

### Expected Results

- **Total drain:** <80% over 16 hours
- **Hourly drain:** <5% per hour
- **Typical actual drain:** 3-4% per hour

### Threshold

- ✅ PASS: ≤5% per hour
- ⚠️ WARNING: 5-7% per hour (investigate)
- ❌ FAIL: >7% per hour

### Factors Affecting Battery

- Background sync (Supabase)
- Push notifications (OneSignal)
- Network type (Wi-Fi vs cellular)
- Signal strength
- Device age and battery health
- OS battery optimization
- Other running apps

### Troubleshooting

**High drain (>5%/hr):**
- Check background services are running
- Verify notification frequency
- Check for wake locks
- Monitor network activity
- Test in airplane mode for isolation

**App killed by OS:**
- Check foreground service is active
- Verify battery optimization is disabled
- Check device power management settings

---

## Memory Profiling with DevTools

### Objective

Detect memory leaks and verify memory usage stays below 150MB during normal operation.

### Setup

1. **Start app in profile mode:**
   ```bash
   flutter run --profile
   ```

2. **Launch DevTools:**
   ```bash
   flutter pub global run devtools
   ```

3. **Connect DevTools to app:**
   - Open DevTools URL in browser
   - Select your device/app from the list

### Memory Profiling Procedure

#### Baseline Measurement

1. **Navigate to Memory tab** in DevTools
2. **Take heap snapshot:**
   - Click "Snapshot" button
   - Note memory usage: `_____ MB`
3. **Record baseline:**
   - RSS memory: `_____ MB`
   - Dart heap: `_____ MB`
   - External memory: `_____ MB`

#### Timer Operation Test

1. **Start a fasting timer**
2. **Wait 5 minutes**
3. **Take another snapshot:**
   - Memory after 5 min: `_____ MB`
   - Growth: `_____ MB`

4. **Continue for 1 hour**, taking snapshots every 15 minutes:

   | Time | RSS Memory | Dart Heap | Growth Rate |
   |------|------------|-----------|-------------|
   | 0 min | _____ MB | _____ MB | - |
   | 15 min | _____ MB | _____ MB | _____ MB/min |
   | 30 min | _____ MB | _____ MB | _____ MB/min |
   | 45 min | _____ MB | _____ MB | _____ MB/min |
   | 60 min | _____ MB | _____ MB | _____ MB/min |

#### Memory Leak Detection

1. **Perform this cycle 5 times:**
   - Start timer
   - Wait 2 minutes
   - Stop timer
   - Wait 30 seconds
   - Take snapshot

2. **Compare snapshots:**
   - Memory should return to near baseline after stopping timer
   - If memory keeps growing, there's a leak

3. **Use DevTools Diff view:**
   - Select two snapshots
   - Click "Diff Snapshots"
   - Look for unexpected object retention

### Expected Results

- **Baseline memory:** 50-80 MB
- **With timer running:** 60-100 MB
- **Maximum usage:** <150 MB
- **Growth rate:** <1 MB per minute
- **After timer stop:** Returns to near baseline

### Thresholds

- ✅ PASS: Memory < 150 MB, growth < 1 MB/min
- ⚠️ WARNING: Memory 150-200 MB or growth 1-2 MB/min
- ❌ FAIL: Memory > 200 MB or growth > 2 MB/min

---

## Animation Performance Validation

### Objective

Verify that all custom animations maintain 60fps (16.67ms per frame) performance.

### Setup

1. **Enable performance overlay:**
   ```bash
   flutter run --profile --enable-dart-profiling
   ```

2. **Or add in code temporarily:**
   ```dart
   MaterialApp(
     showPerformanceOverlay: true,
     // ...
   )
   ```

### Performance Overlay Explained

- **Green bar:** GPU thread (rasterization)
- **Blue/Red bar:** UI thread (Dart code)
- Target: Both bars stay below red line (16.67ms)

### Testing Procedure

#### Test Each Animation

1. **fadeIn animation:**
   - Trigger animation
   - Watch performance overlay
   - Record max frame time: `_____ ms`
   - Count dropped frames: `_____`

2. **scaleIn animation:**
   - Trigger animation
   - Record max frame time: `_____ ms`
   - Count dropped frames: `_____`

3. **slideIn animation:**
   - Trigger animation
   - Record max frame time: `_____ ms`
   - Count dropped frames: `_____`

4. **fadeSlideIn animation:**
   - Trigger animation
   - Record max frame time: `_____ ms`
   - Count dropped frames: `_____`

#### DevTools Timeline Profiling

1. **Navigate to Performance tab** in DevTools
2. **Start recording**
3. **Trigger animations**
4. **Stop recording**
5. **Analyze frame rendering:**
   - Look for red bars (dropped frames)
   - Check frame times
   - Identify slow operations

### Expected Results

- **Average frame time:** <16.67ms
- **Maximum frame time:** <18.33ms (10% tolerance)
- **Dropped frames:** <5 per animation
- **Frame rate:** Consistently 60fps

### Thresholds

- ✅ PASS: Avg <16.67ms, <5 dropped frames
- ⚠️ WARNING: Avg 16.67-20ms, 5-10 dropped frames
- ❌ FAIL: Avg >20ms or >10 dropped frames

---

## App Launch Performance

### Objective

Verify cold start <2s and warm start <500ms.

### Cold Start Test

**Cold start:** App not in memory, first launch after boot/kill.

1. **Force stop the app:**
   ```bash
   # Android
   adb shell am force-stop com.example.zendfast

   # iOS
   # Swipe up to kill app from multitasking
   ```

2. **Clear app from memory:**
   - On device: Force stop from app settings
   - Or reboot device for true cold start

3. **Measure launch time:**
   - Start stopwatch
   - Tap app icon
   - Stop when first screen is fully rendered
   - Record time: `_____ ms`

4. **Repeat 5 times and average:**

   | Attempt | Time (ms) |
   |---------|-----------|
   | 1 | _____ |
   | 2 | _____ |
   | 3 | _____ |
   | 4 | _____ |
   | 5 | _____ |
   | **Average** | **_____** |

### Warm Start Test

**Warm start:** App in background, return to foreground.

1. **Launch app normally**
2. **Press home button** (app goes to background)
3. **Wait 5 seconds**
4. **Measure warm start:**
   - Start stopwatch
   - Tap app icon
   - Stop when screen appears
   - Record time: `_____ ms`

5. **Repeat 5 times and average**

### Expected Results

- **Cold start:** <2000ms (2 seconds)
- **Warm start:** <500ms
- **Typical cold start:** 1500-1800ms
- **Typical warm start:** 300-400ms

### Thresholds

- ✅ PASS: Cold <2s, Warm <500ms
- ⚠️ WARNING: Cold 2-3s, Warm 500-1000ms
- ❌ FAIL: Cold >3s, Warm >1s

---

## Reporting Results

### Test Report Template

```markdown
# Performance Test Results

**Date:** [Date]
**Tester:** [Name]
**Device:** [Model]
**OS Version:** [Version]
**App Version:** [Version]
**Build:** [Release/Profile]

## Timer Accuracy (16-Hour Test)

- Start time: [Time]
- End time: [Time]
- Expected duration: 16 hours (57,600 seconds)
- Actual timer elapsed: [X] seconds
- Total drift: [X] seconds
- Drift per hour: [X] seconds
- **Result:** [PASS/FAIL]

## Battery Consumption (16-Hour Test)

- Start battery: 100%
- End battery: [X]%
- Total drain: [X]%
- Drain per hour: [X]%/hr
- **Result:** [PASS/FAIL]

## Memory Usage

- Baseline: [X] MB
- With timer: [X] MB
- Maximum: [X] MB
- Growth rate: [X] MB/min
- **Result:** [PASS/FAIL]

## Animation Performance

| Animation | Avg Frame Time | Dropped Frames | Result |
|-----------|----------------|----------------|--------|
| fadeIn | [X] ms | [X] | [PASS/FAIL] |
| scaleIn | [X] ms | [X] | [PASS/FAIL] |
| slideIn | [X] ms | [X] | [PASS/FAIL] |
| fadeSlideIn | [X] ms | [X] | [PASS/FAIL] |

## App Launch

- Cold start avg: [X] ms
- Warm start avg: [X] ms
- **Result:** [PASS/FAIL]

## Overall Assessment

[PASS/FAIL with notes]

## Issues Found

- [Issue 1]
- [Issue 2]

## Recommendations

- [Recommendation 1]
- [Recommendation 2]
```

### Where to Report

1. **Save report as:** `test/performance/reports/manual_test_[DATE]_[DEVICE].md`
2. **Attach to GitHub issue** if failures found
3. **Update baseline metrics** if performance improved

---

## Conclusion

Manual validation is essential for verifying real-world performance. While automated CI tests provide quick feedback, these manual procedures ensure the app performs well on actual hardware under realistic conditions.

**Questions?** Contact the development team or create an issue in the repository.
