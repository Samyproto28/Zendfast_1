import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/content_item.dart';
import '../../services/database_service.dart';
import '../../router/navigation_extensions.dart';
import '../../config/cache_config.dart';

/// Screen displaying educational content (articles, videos, etc.)
/// Allows users to browse and filter learning resources
class LearningScreen extends ConsumerStatefulWidget {
  const LearningScreen({super.key});

  @override
  ConsumerState<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends ConsumerState<LearningScreen> {
  ContentCategory? _selectedCategory;
  List<ContentItem> _content = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() => _isLoading = true);

    try {
      // Load all content from database
      final content = await DatabaseService.instance.getContentItems();

      setState(() {
        _content = content;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading content: $e');
      setState(() => _isLoading = false);
    }
  }

  List<ContentItem> get _filteredContent {
    if (_selectedCategory == null) {
      return _content;
    }
    return _content.where((item) => item.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search coming soon')),
              );
            },
            tooltip: 'Search',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildCategoryFilter(context),
                  Expanded(
                    child: _filteredContent.isEmpty
                        ? _buildEmptyState(context)
                        : _buildContentList(context),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildCategoryChip(
              label: 'All',
              isSelected: _selectedCategory == null,
              onTap: () => setState(() => _selectedCategory = null),
            ),
            const SizedBox(width: 8),
            ...ContentCategory.values.map((category) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildCategoryChip(
                  label: _getCategoryDisplayName(category),
                  isSelected: _selectedCategory == category,
                  onTap: () => setState(() => _selectedCategory = category),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildContentList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredContent.length,
      itemBuilder: (context, index) {
        final item = _filteredContent[index];
        return _buildContentCard(context, item, key: ValueKey(item.id));
      },
    );
  }

  Widget _buildContentCard(BuildContext context, ContentItem item, {Key? key}) {
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.goToLearningArticle(item.id.toString()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.thumbnailUrl != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.grey[300],
                  child: item.thumbnailUrl!.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: item.thumbnailUrl!,
                          fit: BoxFit.cover,
                          cacheManager: LearningContentCacheManager(),
                          memCacheWidth: CacheConfig.thumbnailCacheWidth,
                          memCacheHeight: CacheConfig.thumbnailCacheHeight,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              _buildPlaceholderImage(item.contentType),
                          fadeInDuration: CacheConfig.fadeDuration,
                        )
                      : _buildPlaceholderImage(item.contentType),
                ),
              )
            else
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _buildPlaceholderImage(item.contentType),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildContentTypeChip(item.contentType),
                      const SizedBox(width: 8),
                      _buildCategoryBadge(item.category),
                      const Spacer(),
                      if (item.isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'PREMIUM',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (item.author != null) ...[
                        Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          item.author!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      if (item.formattedDuration != null) ...[
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          item.formattedDuration!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(ContentType type) {
    IconData icon;
    Color color;

    switch (type) {
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
      color: color.withValues(alpha: 0.1),
      child: Center(
        child: Icon(icon, size: 64, color: color),
      ),
    );
  }

  Widget _buildContentTypeChip(ContentType type) {
    IconData icon;
    Color color;

    switch (type) {
      case ContentType.article:
        icon = Icons.article;
        color = Colors.blue;
        break;
      case ContentType.video:
        icon = Icons.videocam;
        color = Colors.red;
        break;
      case ContentType.audio:
        icon = Icons.headphones;
        color = Colors.purple;
        break;
      case ContentType.meditation:
        icon = Icons.spa;
        color = Colors.green;
        break;
      case ContentType.exercise:
        icon = Icons.fitness_center;
        color = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            _getContentTypeDisplayName(type),
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(ContentCategory category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getCategoryDisplayName(category),
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _selectedCategory == null
                  ? 'No content available'
                  : 'No ${_getCategoryDisplayName(_selectedCategory!).toLowerCase()} content',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new educational resources',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getContentTypeDisplayName(ContentType type) {
    switch (type) {
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

  String _getCategoryDisplayName(ContentCategory category) {
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
        return 'Stress';
      case ContentCategory.general:
        return 'General';
    }
  }
}
