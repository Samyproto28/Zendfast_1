/// Represents an account deletion request with grace period
/// Supports GDPR "Right to Erasure" with 30-day recovery window
class AccountDeletionRequest {
  /// Unique identifier for the deletion request
  final String id;

  /// User identifier
  final String userId;

  /// When the deletion was requested
  final DateTime requestedAt;

  /// When the account will be automatically deleted (30 days after request)
  final DateTime scheduledDeletionDate;

  /// Unique token for account recovery (if user changes mind)
  final String? recoveryToken;

  /// Current status of the deletion request
  final DeletionRequestStatus status;

  /// When the deletion was cancelled (if applicable)
  final DateTime? cancelledAt;

  /// When the deletion was completed (if applicable)
  final DateTime? completedAt;

  /// Optional reason provided by user for deletion
  final String? deletionReason;

  /// When this record was created
  final DateTime createdAt;

  /// When this record was last updated
  final DateTime updatedAt;

  /// Constructor
  AccountDeletionRequest({
    required this.id,
    required this.userId,
    required this.requestedAt,
    required this.scheduledDeletionDate,
    this.recoveryToken,
    this.status = DeletionRequestStatus.pending,
    this.cancelledAt,
    this.completedAt,
    this.deletionReason,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert to JSON for Supabase synchronization (snake_case keys)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'requested_at': requestedAt.toIso8601String(),
      'scheduled_deletion_date': scheduledDeletionDate.toIso8601String(),
      'recovery_token': recoveryToken,
      'status': status.toString().split('.').last,
      'cancelled_at': cancelledAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'deletion_reason': deletionReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON (Supabase synchronization with snake_case keys)
  factory AccountDeletionRequest.fromJson(Map<String, dynamic> json) {
    return AccountDeletionRequest(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      requestedAt: DateTime.parse(json['requested_at'] as String),
      scheduledDeletionDate:
          DateTime.parse(json['scheduled_deletion_date'] as String),
      recoveryToken: json['recovery_token'] as String?,
      status: _statusFromString(json['status'] as String),
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      deletionReason: json['deletion_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert string to DeletionRequestStatus enum
  static DeletionRequestStatus _statusFromString(String status) {
    switch (status) {
      case 'pending':
        return DeletionRequestStatus.pending;
      case 'cancelled':
        return DeletionRequestStatus.cancelled;
      case 'completed':
        return DeletionRequestStatus.completed;
      default:
        throw ArgumentError('Unknown deletion request status: $status');
    }
  }

  /// Get days remaining until scheduled deletion
  int get daysUntilDeletion {
    final now = DateTime.now();
    final difference = scheduledDeletionDate.difference(now);
    return difference.inDays;
  }

  /// Check if deletion can still be cancelled
  bool get canBeCancelled {
    return status == DeletionRequestStatus.pending &&
        DateTime.now().isBefore(scheduledDeletionDate);
  }

  /// Get formatted scheduled deletion date
  String get formattedScheduledDate {
    return '${scheduledDeletionDate.day.toString().padLeft(2, '0')}/'
        '${scheduledDeletionDate.month.toString().padLeft(2, '0')}/'
        '${scheduledDeletionDate.year}';
  }

  /// Create a copy with updated fields
  AccountDeletionRequest copyWith({
    String? id,
    String? userId,
    DateTime? requestedAt,
    DateTime? scheduledDeletionDate,
    String? recoveryToken,
    DeletionRequestStatus? status,
    DateTime? cancelledAt,
    DateTime? completedAt,
    String? deletionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountDeletionRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      requestedAt: requestedAt ?? this.requestedAt,
      scheduledDeletionDate:
          scheduledDeletionDate ?? this.scheduledDeletionDate,
      recoveryToken: recoveryToken ?? this.recoveryToken,
      status: status ?? this.status,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      completedAt: completedAt ?? this.completedAt,
      deletionReason: deletionReason ?? this.deletionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Status of an account deletion request
enum DeletionRequestStatus {
  pending,   // Awaiting scheduled deletion date
  cancelled, // User recovered their account
  completed, // Account has been deleted
}
