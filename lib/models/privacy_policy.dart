import 'package:isar/isar.dart';

part 'privacy_policy.g.dart';

/// Represents a privacy policy version
/// Loaded dynamically from Supabase for easy updates without app releases
@collection
class PrivacyPolicy {
  /// Auto-increment primary key
  Id id = Isar.autoIncrement;

  /// Version number of the privacy policy
  @Index(unique: true)
  late int version;

  /// Full text content of the privacy policy (supports Markdown)
  late String content;

  /// Language code (ISO 639-1: 'es', 'en', etc.)
  @Index()
  String language;

  /// Date when this policy becomes effective
  late DateTime effectiveDate;

  /// Whether this is the currently active policy
  @Index()
  late bool isActive;

  /// When this record was created
  late DateTime createdAt;

  /// When this record was last updated
  late DateTime updatedAt;

  /// Constructor
  PrivacyPolicy({
    this.id = Isar.autoIncrement,
    required this.version,
    required this.content,
    this.language = 'es',
    required this.effectiveDate,
    this.isActive = false,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  /// Helper method to update the timestamp
  void markUpdated() {
    updatedAt = DateTime.now();
  }

  /// Convert to JSON for Supabase synchronization (snake_case keys)
  Map<String, dynamic> toJson() {
    return {
      'id': id == Isar.autoIncrement ? null : id,
      'version': version,
      'content': content,
      'language': language,
      'effective_date': effectiveDate.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON (Supabase synchronization with snake_case keys)
  factory PrivacyPolicy.fromJson(Map<String, dynamic> json) {
    final policy = PrivacyPolicy(
      version: json['version'] as int,
      content: json['content'] as String,
      language: json['language'] as String? ?? 'es',
      effectiveDate: DateTime.parse(json['effective_date'] as String),
      isActive: json['is_active'] as bool? ?? false,
    );

    // Set id if provided (from Supabase)
    if (json['id'] != null) {
      // Supabase uses UUID, we need to handle this differently
      // For now, we'll use auto-increment in Isar
      policy.id = Isar.autoIncrement;
    }

    // Set timestamps if provided (otherwise constructor sets them)
    if (json['created_at'] != null) {
      policy.createdAt = DateTime.parse(json['created_at'] as String);
    }
    if (json['updated_at'] != null) {
      policy.updatedAt = DateTime.parse(json['updated_at'] as String);
    }

    return policy;
  }

  /// Get formatted effective date
  @ignore
  String get formattedEffectiveDate {
    return '${effectiveDate.day.toString().padLeft(2, '0')}/'
        '${effectiveDate.month.toString().padLeft(2, '0')}/'
        '${effectiveDate.year}';
  }

  /// Get preview of content (first 200 characters)
  @ignore
  String get contentPreview {
    if (content.length <= 200) return content;
    return '${content.substring(0, 200)}...';
  }
}
