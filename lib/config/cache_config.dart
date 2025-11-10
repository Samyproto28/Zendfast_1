import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Custom cache manager configuration for learning content images
///
/// Provides optimized caching settings for media assets including:
/// - 30-day cache retention for learning content images
/// - Maximum 200 cached objects
/// - Maximum 500MB cache size
/// - Custom file service for efficient downloads
class LearningContentCacheManager extends CacheManager {
  static const String key = 'learningContentCache';

  static LearningContentCacheManager? _instance;

  /// Singleton instance of the cache manager
  factory LearningContentCacheManager() {
    _instance ??= LearningContentCacheManager._();
    return _instance!;
  }

  LearningContentCacheManager._()
    : super(
        Config(
          key,
          // Cache images for 30 days
          stalePeriod: const Duration(days: 30),
          // Maximum 200 cached objects
          maxNrOfCacheObjects: 200,
          // Repository implementation (uses default)
          repo: JsonCacheInfoRepository(databaseName: key),
          // File service for downloads
          fileService: HttpFileService(),
        ),
      );
}

/// Cache configuration constants
class CacheConfig {
  /// Default cache duration for learning content
  static const Duration defaultCacheDuration = Duration(days: 30);

  /// Maximum number of cached images
  static const int maxCachedObjects = 200;

  /// Maximum cache size in MB
  static const int maxCacheSizeMB = 500;

  /// Memory cache width for thumbnails (pixels)
  /// Reduces memory usage by resizing images for display
  static const int thumbnailCacheWidth = 800;

  /// Memory cache height for thumbnails (pixels)
  static const int thumbnailCacheHeight = 600;

  /// Memory cache width for full-size images (pixels)
  static const int fullImageCacheWidth = 1200;

  /// Memory cache height for full-size images (pixels)
  static const int fullImageCacheHeight = 1600;

  /// Fade duration for image loading transitions
  static const Duration fadeDuration = Duration(milliseconds: 300);

  /// Whether to scale images down to fit screen size
  static const bool scaleToFit = true;

  /// Quality for JPEG compression (0-100)
  static const int imageQuality = 85;
}
