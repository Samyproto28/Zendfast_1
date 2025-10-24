import 'package:flutter/material.dart';
import '../providers/timer_provider.dart';

/// Observes app lifecycle changes and syncs timer state
/// when app returns to foreground
class AppLifecycleObserver extends WidgetsBindingObserver {
  final TimerNotifier timerNotifier;

  AppLifecycleObserver(this.timerNotifier);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground - sync timer state
        _onAppResumed();
        break;
      case AppLifecycleState.inactive:
        // App is inactive (e.g., phone call, system dialog)
        _onAppInactive();
        break;
      case AppLifecycleState.paused:
        // App went to background
        _onAppPaused();
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        _onAppDetached();
        break;
      case AppLifecycleState.hidden:
        // App is hidden (iOS specific)
        break;
    }
  }

  /// Called when app returns to foreground
  void _onAppResumed() {
    debugPrint('App resumed - syncing timer state');
    timerNotifier.syncState();
  }

  /// Called when app becomes inactive
  void _onAppInactive() {
    debugPrint('App inactive');
    // No action needed - background service continues
  }

  /// Called when app goes to background
  void _onAppPaused() {
    debugPrint('App paused - background service continues');
    // No action needed - background service handles timer
  }

  /// Called when app is being terminated
  void _onAppDetached() {
    debugPrint('App detached');
    // Background service will continue if timer is running
  }
}
