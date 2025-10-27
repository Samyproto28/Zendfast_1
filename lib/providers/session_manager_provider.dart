import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/session_manager.dart';
import '../services/timer_service.dart';
import '../services/database_service.dart';
import '../services/supabase_sync_service.dart';

/// Provider for SessionManager singleton
/// Provides access to session management functionality throughout the app
final sessionManagerProvider = Provider<SessionManager>((ref) {
  return SessionManager(
    timerService: TimerService.instance,
    databaseService: DatabaseService.instance,
    syncService: SupabaseSyncService.instance,
  );
});
