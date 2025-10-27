import '../widgets/ui_states/empty_state.dart';

/// Immutable UI state model for global state management
///
/// Represents the current UI state across the application, including
/// loading, error, and empty states.
///
/// Example usage:
/// ```dart
/// final state = UIState.loading();
/// final state = UIState.error('Error al cargar datos');
/// final state = UIState.empty(type: EmptyStateType.noData);
/// final state = UIState.success();
/// ```
class UIState {
  /// Whether the UI is in a loading state
  final bool isLoading;

  /// Optional error message if in error state
  final String? errorMessage;

  /// Whether the UI is in an empty state
  final bool isEmpty;

  /// Type of empty state for context-aware rendering
  final EmptyStateType? emptyStateType;

  /// Private constructor
  const UIState._({
    required this.isLoading,
    this.errorMessage,
    required this.isEmpty,
    this.emptyStateType,
  });

  /// Initial/idle state - no loading, error, or empty state
  const UIState.initial()
      : isLoading = false,
        errorMessage = null,
        isEmpty = false,
        emptyStateType = null;

  /// Loading state - shows loading indicator
  const UIState.loading()
      : isLoading = true,
        errorMessage = null,
        isEmpty = false,
        emptyStateType = null;

  /// Error state - shows error message with optional retry
  const UIState.error(String message)
      : isLoading = false,
        errorMessage = message,
        isEmpty = false,
        emptyStateType = null;

  /// Empty state - shows empty state UI
  const UIState.empty({EmptyStateType? type})
      : isLoading = false,
        errorMessage = null,
        isEmpty = true,
        emptyStateType = type ?? EmptyStateType.noData;

  /// Success state - clears all states (same as initial)
  const UIState.success()
      : isLoading = false,
        errorMessage = null,
        isEmpty = false,
        emptyStateType = null;

  /// Whether the UI has an error
  bool get hasError => errorMessage != null;

  /// Whether the UI is in a success/idle state (no loading, error, or empty)
  bool get isSuccess => !isLoading && !hasError && !isEmpty;

  /// Creates a copy of this UIState with the given fields replaced
  UIState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isEmpty,
    EmptyStateType? emptyStateType,
    bool clearError = false,
    bool clearEmpty = false,
  }) {
    return UIState._(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isEmpty: isEmpty ?? this.isEmpty,
      emptyStateType: clearEmpty ? null : (emptyStateType ?? this.emptyStateType),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UIState &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage &&
        other.isEmpty == isEmpty &&
        other.emptyStateType == emptyStateType;
  }

  @override
  int get hashCode {
    return Object.hash(
      isLoading,
      errorMessage,
      isEmpty,
      emptyStateType,
    );
  }

  @override
  String toString() {
    return 'UIState(isLoading: $isLoading, errorMessage: $errorMessage, isEmpty: $isEmpty, emptyStateType: $emptyStateType)';
  }
}
