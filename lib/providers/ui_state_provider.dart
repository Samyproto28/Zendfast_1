import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ui_state.dart';
import '../widgets/ui_states/empty_state.dart';

/// Global UI State Provider
///
/// Manages global UI states for loading, error, and empty states across the application.
/// Uses Riverpod's StateNotifier for reactive state management.
///
/// Example usage:
/// ```dart
/// // Read state
/// final uiState = ref.watch(uiStateProvider);
///
/// // Update state
/// ref.read(uiStateProvider.notifier).setLoading();
/// ref.read(uiStateProvider.notifier).setError('Error message');
/// ref.read(uiStateProvider.notifier).setEmpty(type: EmptyStateType.noData);
/// ref.read(uiStateProvider.notifier).setSuccess();
/// ```
final uiStateProvider = StateNotifierProvider.autoDispose<UIStateNotifier, UIState>((ref) {
  return UIStateNotifier();
});

/// UI State Notifier
///
/// Provides methods to update the global UI state reactively.
/// All state changes are immutable and trigger widget rebuilds automatically.
class UIStateNotifier extends StateNotifier<UIState> {
  UIStateNotifier() : super(const UIState.initial());

  /// Set loading state
  ///
  /// Shows loading indicator and clears any existing error or empty states.
  void setLoading() {
    state = const UIState.loading();
  }

  /// Set error state with message
  ///
  /// Shows error UI with the provided message and optional retry action.
  /// Clears loading and empty states.
  ///
  /// Example:
  /// ```dart
  /// notifier.setError('No se pudo conectar al servidor');
  /// ```
  void setError(String message) {
    state = UIState.error(message);
  }

  /// Set empty state
  ///
  /// Shows empty state UI with optional type for context-aware rendering.
  /// Clears loading and error states.
  ///
  /// Example:
  /// ```dart
  /// notifier.setEmpty(type: EmptyStateType.noResults);
  /// ```
  void setEmpty({EmptyStateType? type}) {
    state = UIState.empty(type: type);
  }

  /// Set success state
  ///
  /// Clears all states (loading, error, empty) to show success content.
  /// This is the same as calling clearState().
  void setSuccess() {
    state = const UIState.success();
  }

  /// Clear all states
  ///
  /// Resets to initial/idle state, removing loading, error, and empty states.
  void clearState() {
    state = const UIState.initial();
  }

  /// Check if currently in a specific state type
  bool get isLoading => state.isLoading;
  bool get hasError => state.hasError;
  bool get isEmpty => state.isEmpty;
  bool get isSuccess => state.isSuccess;
}
