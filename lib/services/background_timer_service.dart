import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/timer_state.dart';
import '../models/fasting_state.dart';

/// Background service for fasting timer persistence
/// Keeps timer running even when app is closed or in background
class BackgroundTimerService {
  static const String _timerStateKey = 'fasting_timer_state';
  static const String _notificationChannelId = 'fasting_timer_channel';
  static const int _notificationId = 1001;

  /// Initialize and configure the background service
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _notificationChannelId,
      'Fasting Timer',
      description: 'Shows your fasting timer progress',
      importance: Importance.low, // Low importance to avoid sound/vibration
      enableVibration: false,
      playSound: false,
    );

    final FlutterLocalNotificationsPlugin notificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // Create the notification channel on Android
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Configure the background service
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false, // We'll start it manually when timer starts
        isForegroundMode: true,
        notificationChannelId: _notificationChannelId,
        initialNotificationTitle: 'Fasting Timer',
        initialNotificationContent: 'Initializing...',
        foregroundServiceNotificationId: _notificationId,
        foregroundServiceTypes: [AndroidForegroundType.dataSync],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  /// Start the background service
  static Future<void> startService() async {
    final service = FlutterBackgroundService();
    await service.startService();
  }

  /// Stop the background service
  static Future<void> stopService() async {
    final service = FlutterBackgroundService();
    service.invoke('stop');
  }

  /// Update timer state in SharedPreferences
  static Future<void> saveTimerState(TimerState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_timerStateKey, jsonEncode(state.toJson()));
  }

  /// Load timer state from SharedPreferences
  static Future<TimerState?> loadTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    final stateJson = prefs.getString(_timerStateKey);

    if (stateJson == null) return null;

    try {
      final json = jsonDecode(stateJson) as Map<String, dynamic>;
      return TimerState.fromJson(json);
    } catch (e) {
      debugPrint('Error loading timer state: $e');
      return null;
    }
  }

  /// Clear timer state from SharedPreferences
  static Future<void> clearTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_timerStateKey);
  }

  /// iOS background task handler
  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  /// Main service entry point - runs in background isolate
  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    // Initialize bindings for background isolate
    DartPluginRegistrant.ensureInitialized();

    final notificationsPlugin = FlutterLocalNotificationsPlugin();

    // Listen for stop command
    service.on('stop').listen((event) {
      service.stopSelf();
    });

    // Listen for timer state updates from UI
    service.on('updateTimerState').listen((event) async {
      if (event != null && event['state'] != null) {
        final stateJson = event['state'] as Map<String, dynamic>;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_timerStateKey, jsonEncode(stateJson));
      }
    });

    // Update timer every second
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        // Load current timer state
        final prefs = await SharedPreferences.getInstance();
        final stateJson = prefs.getString(_timerStateKey);

        if (stateJson == null) {
          // No timer running, update notification to show idle state
          if (service is AndroidServiceInstance) {
            if (await service.isForegroundService()) {
              _updateNotification(
                notificationsPlugin,
                'No active fast',
                'Start a fasting timer to begin',
              );
            }
          }
          return;
        }

        final json = jsonDecode(stateJson) as Map<String, dynamic>;
        final state = TimerState.fromJson(json);

        if (!state.isRunning) {
          // Timer stopped, update notification
          if (service is AndroidServiceInstance) {
            if (await service.isForegroundService()) {
              _updateNotification(
                notificationsPlugin,
                'Timer paused',
                'Resume your fast to continue',
              );
            }
          }
          return;
        }

        // Check if timer completed
        if (state.isCompleted) {
          // Timer completed, send completion event
          service.invoke('timerCompleted', {
            'sessionId': state.sessionId,
            'completedAt': DateTime.now().toIso8601String(),
          });

          // Update notification for completion
          if (service is AndroidServiceInstance) {
            if (await service.isForegroundService()) {
              _updateNotification(
                notificationsPlugin,
                '🎉 Fast Complete!',
                'Great job! You completed your ${state.planType} fast',
              );
            }
          }

          // Stop the timer with completed state
          final completedState = state.copyWith(
            isRunning: false,
            state: FastingState.completed,
          );
          await prefs.setString(
            _timerStateKey,
            jsonEncode(completedState.toJson()),
          );

          return;
        }

        // Update notification with current progress
        if (service is AndroidServiceInstance) {
          if (await service.isForegroundService()) {
            final progressPercent = (state.progress * 100).toInt();
            _updateNotification(
              notificationsPlugin,
              '${state.planType} Fast • $progressPercent%',
              '⏱️ ${state.formattedRemainingTime} remaining',
              progress: state.progress,
              maxProgress: 1.0,
              showProgress: true,
            );
          }
        }

        // Send state update to UI (if listening)
        service.invoke('timerTick', {
          'remaining': state.remainingMilliseconds,
          'elapsed': state.elapsedMilliseconds,
          'progress': state.progress,
          'isCompleted': state.isCompleted,
        });
      } catch (e) {
        debugPrint('Background service error: $e');
      }
    });
  }

  /// Update the foreground notification
  static void _updateNotification(
    FlutterLocalNotificationsPlugin plugin,
    String title,
    String body, {
    double? progress,
    double? maxProgress,
    bool showProgress = false,
  }) {
    plugin.show(
      _notificationId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _notificationChannelId,
          'Fasting Timer',
          channelDescription: 'Shows your fasting timer progress',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          showProgress: showProgress,
          maxProgress: maxProgress != null ? (maxProgress * 100).toInt() : 100,
          progress: progress != null ? (progress * 100).toInt() : 0,
          enableVibration: false,
          playSound: false,
        ),
      ),
    );
  }
}
