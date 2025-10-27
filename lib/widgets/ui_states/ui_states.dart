/// Zendfast UI States
///
/// Barrel export file for all UI state widgets and utilities.
/// Provides a single import point for the UI state system.
///
/// Usage:
/// ```dart
/// import 'package:zendfast_1/widgets/ui_states/ui_states.dart';
///
/// // All UI state widgets and types are now available:
/// LoadingState()
/// ErrorState(message: 'Error')
/// EmptyState.noData()
/// AdaptiveStateWrapper(builder: (context) => MyContent())
/// EmptyStateType.noResults
/// ```
library;

// Core state widgets
export 'loading_state.dart';
export 'error_state.dart';
export 'empty_state.dart';
export 'adaptive_state_wrapper.dart';

// Re-export model for convenience (EmptyStateType enum)
export '../../models/ui_state.dart';
export '../../providers/ui_state_provider.dart';
