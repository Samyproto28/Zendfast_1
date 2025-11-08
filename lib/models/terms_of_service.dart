import 'package:isar/isar.dart';

part 'terms_of_service.g.dart';

/// Represents a Terms of Service version
/// Loaded dynamically from Supabase for easy updates without app releases
@collection
class TermsOfService {
  /// Auto-increment primary key
  Id id = Isar.autoIncrement;

  /// Version number of the terms of service
  @Index(unique: true)
  late int version;

  /// Full text content of the terms of service (supports Markdown)
  late String content;

  /// Language code (ISO 639-1: 'es', 'en', etc.)
  @Index()
  String language;

  /// Date when these terms become effective
  late DateTime effectiveDate;

  /// Whether this is the currently active terms version
  @Index()
  late bool isActive;

  /// When this record was created
  late DateTime createdAt;

  /// When this record was last updated
  late DateTime updatedAt;

  /// Constructor
  TermsOfService({
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
  factory TermsOfService.fromJson(Map<String, dynamic> json) {
    final terms = TermsOfService(
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
      terms.id = Isar.autoIncrement;
    }

    // Set timestamps if provided (otherwise constructor sets them)
    if (json['created_at'] != null) {
      terms.createdAt = DateTime.parse(json['created_at'] as String);
    }
    if (json['updated_at'] != null) {
      terms.updatedAt = DateTime.parse(json['updated_at'] as String);
    }

    return terms;
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
