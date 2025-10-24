import 'package:isar/isar.dart';

part 'content_item.g.dart';

/// Types of content available in the app
enum ContentType {
  article,
  video,
  audio,
  meditation,
  exercise,
}

/// Categories for organizing content
enum ContentCategory {
  mindfulness,
  nutrition,
  fasting,
  sleep,
  stress,
  general,
}

/// Represents a content item (article, video, meditation, etc.)
/// Used for educational and supportive mental health content
@collection
class ContentItem {
  /// Auto-increment primary key
  Id id = Isar.autoIncrement;

  /// Title of the content - indexed for search with case-insensitive matching
  @Index(caseSensitive: false)
  late String title;

  /// Type of content - indexed for filtering
  @Enumerated(EnumType.name)
  @Index()
  late ContentType contentType;

  /// Category of content - indexed for filtering
  @Enumerated(EnumType.name)
  @Index()
  late ContentCategory category;

  /// URL or path to the content
  late String url;

  /// Optional description or summary
  String? description;

  /// Duration in seconds (for videos, audio, meditations)
  int? durationSeconds;

  /// Whether this is premium content
  @Index()
  late bool isPremium;

  /// Optional thumbnail or cover image URL
  String? thumbnailUrl;

  /// Optional author or creator name
  String? author;

  /// When this content was created
  @Index()
  late DateTime createdAt;

  /// When this content was last updated
  late DateTime updatedAt;

  /// Constructor
  ContentItem({
    this.id = Isar.autoIncrement,
    required this.title,
    required this.contentType,
    required this.category,
    required this.url,
    this.description,
    this.durationSeconds,
    this.isPremium = false,
    this.thumbnailUrl,
    this.author,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  /// Get formatted duration string (e.g., "5:30", "1:23:45")
  @ignore
  String? get formattedDuration {
    if (durationSeconds == null) return null;

    final duration = Duration(seconds: durationSeconds!);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Get content type display name
  @ignore
  String get contentTypeDisplayName {
    switch (contentType) {
      case ContentType.article:
        return 'Article';
      case ContentType.video:
        return 'Video';
      case ContentType.audio:
        return 'Audio';
      case ContentType.meditation:
        return 'Meditation';
      case ContentType.exercise:
        return 'Exercise';
    }
  }

  /// Get category display name
  @ignore
  String get categoryDisplayName {
    switch (category) {
      case ContentCategory.mindfulness:
        return 'Mindfulness';
      case ContentCategory.nutrition:
        return 'Nutrition';
      case ContentCategory.fasting:
        return 'Fasting';
      case ContentCategory.sleep:
        return 'Sleep';
      case ContentCategory.stress:
        return 'Stress Management';
      case ContentCategory.general:
        return 'General Wellness';
    }
  }

  /// Helper method to update the content timestamp
  void markUpdated() {
    updatedAt = DateTime.now();
  }
}
