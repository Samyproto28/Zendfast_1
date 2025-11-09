import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/content_item.dart';
import '../../services/database_service.dart';
import '../../router/route_params.dart';
import '../../config/cache_config.dart';
import 'package:go_router/go_router.dart';

/// Screen displaying detailed view of a learning article/content item
/// Shows full content, metadata, and related actions
class ArticleDetailScreen extends ConsumerStatefulWidget {
  final String articleId;

  const ArticleDetailScreen({
    super.key,
    required this.articleId,
  });

  /// Create from GoRouterState
  factory ArticleDetailScreen.fromState(GoRouterState state) {
    final params = ArticleRouteParams.fromState(state);
    return ArticleDetailScreen(articleId: params.articleId);
  }

  @override
  ConsumerState<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends ConsumerState<ArticleDetailScreen> {
  ContentItem? _article;
  bool _isLoading = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  Future<void> _loadArticle() async {
    setState(() => _isLoading = true);

    try {
      final id = int.tryParse(widget.articleId);
      if (id == null) {
        throw Exception('Invalid article ID');
      }

      final article = await DatabaseService.instance.getContentItem(id);

      setState(() {
        _article = article;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading article: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_article == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Article not found',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMetadata(context),
                const Divider(),
                _buildContent(context),
                const SizedBox(height: 24),
                _buildRelatedSection(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _article!.title,
          style: const TextStyle(
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3.0,
                color: Colors.black45,
              ),
            ],
          ),
        ),
        background: _article!.thumbnailUrl != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  _article!.thumbnailUrl!.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: _article!.thumbnailUrl!,
                          fit: BoxFit.cover,
                          cacheManager: LearningContentCacheManager(),
                          memCacheWidth: CacheConfig.fullImageCacheWidth,
                          memCacheHeight: CacheConfig.fullImageCacheHeight,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              _buildPlaceholderImage(),
                          fadeInDuration: CacheConfig.fadeDuration,
                        )
                      : _buildPlaceholderImage(),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : _buildPlaceholderImage(),
      ),
      actions: [
        IconButton(
          icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border),
          onPressed: _toggleSave,
          tooltip: _isSaved ? 'Remove from saved' : 'Save for later',
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: _shareArticle,
          tooltip: 'Share',
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    IconData icon;
    Color color;

    switch (_article!.contentType) {
      case ContentType.article:
        icon = Icons.article;
        color = Colors.blue;
        break;
      case ContentType.video:
        icon = Icons.play_circle_outline;
        color = Colors.red;
        break;
      case ContentType.audio:
        icon = Icons.headphones;
        color = Colors.purple;
        break;
      case ContentType.meditation:
        icon = Icons.self_improvement;
        color = Colors.green;
        break;
      case ContentType.exercise:
        icon = Icons.fitness_center;
        color = Colors.orange;
        break;
    }

    return Container(
      color: color.withValues(alpha: 0.2),
      child: Center(
        child: Icon(icon, size: 80, color: color.withValues(alpha: 0.5)),
      ),
    );
  }

  Widget _buildMetadata(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildContentTypeChip(),
              const SizedBox(width: 8),
              _buildCategoryChip(),
              const Spacer(),
              if (_article!.isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'PREMIUM',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (_article!.author != null) ...[
                Icon(Icons.person_outline, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _article!.author!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
                const SizedBox(width: 16),
              ],
              if (_article!.formattedDuration != null) ...[
                Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _article!.formattedDuration!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentTypeChip() {
    final type = _article!.contentType;
    IconData icon;
    Color color;
    String label;

    switch (type) {
      case ContentType.article:
        icon = Icons.article;
        color = Colors.blue;
        label = 'Article';
        break;
      case ContentType.video:
        icon = Icons.videocam;
        color = Colors.red;
        label = 'Video';
        break;
      case ContentType.audio:
        icon = Icons.headphones;
        color = Colors.purple;
        label = 'Audio';
        break;
      case ContentType.meditation:
        icon = Icons.spa;
        color = Colors.green;
        label = 'Meditation';
        break;
      case ContentType.exercise:
        icon = Icons.fitness_center;
        color = Colors.orange;
        label = 'Exercise';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip() {
    final category = _article!.category;
    String label;

    switch (category) {
      case ContentCategory.mindfulness:
        label = 'Mindfulness';
        break;
      case ContentCategory.nutrition:
        label = 'Nutrition';
        break;
      case ContentCategory.fasting:
        label = 'Fasting';
        break;
      case ContentCategory.sleep:
        label = 'Sleep';
        break;
      case ContentCategory.stress:
        label = 'Stress';
        break;
      case ContentCategory.general:
        label = 'General';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_article!.description != null) ...[
            Text(
              _article!.description!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    height: 1.6,
                  ),
            ),
            const SizedBox(height: 24),
          ],
          if (_article!.url.isNotEmpty)
            ElevatedButton.icon(
              onPressed: _openContent,
              icon: const Icon(Icons.open_in_new),
              label: Text(_getOpenButtonLabel()),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRelatedSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Related Content',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Related content will appear here based on category and tags.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getOpenButtonLabel() {
    switch (_article!.contentType) {
      case ContentType.article:
        return 'Read Full Article';
      case ContentType.video:
        return 'Watch Video';
      case ContentType.audio:
        return 'Listen to Audio';
      case ContentType.meditation:
        return 'Start Meditation';
      case ContentType.exercise:
        return 'View Exercise';
    }
  }

  void _toggleSave() {
    setState(() {
      _isSaved = !_isSaved;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isSaved ? 'Saved for later' : 'Removed from saved'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _shareArticle() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing functionality coming soon')),
    );
  }

  void _openContent() {
    // TODO: Open URL in browser or in-app browser
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening: ${_article!.url}')),
    );
  }
}
