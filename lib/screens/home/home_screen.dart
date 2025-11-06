import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_computed_providers.dart';
import '../../providers/session_manager_provider.dart';
import '../../services/session_manager.dart';
import '../../router/navigation_extensions.dart';

/// Main home screen that serves as the dashboard for the app
/// Displays navigation cards to all main sections and user stats overview
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userEmail = ref.watch(currentUserEmailProvider);
    final sessionManager = ref.watch(sessionManagerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ZendFast'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.goToSettings(),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header
              _buildWelcomeHeader(userEmail),
              const SizedBox(height: 24),

              // Quick stats card
              _buildQuickStatsCard(context, sessionManager),
              const SizedBox(height: 24),

              // Main navigation cards
              Text(
                'Explore',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              _buildNavigationCards(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(String? email) {
    return Builder(
      builder: (context) {
        final username = email?.split('@').first ?? 'User';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              username,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickStatsCard(BuildContext context, SessionManager sessionManager) {
    // This would typically fetch real data from providers
    // For now, showing placeholder stats
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Icon(Icons.trending_up, color: Colors.green[600]),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  icon: Icons.timer_outlined,
                  label: 'Fasting',
                  value: 'Ready',
                  color: Colors.blue,
                ),
                _buildStatItem(
                  context,
                  icon: Icons.water_drop_outlined,
                  label: 'Hydration',
                  value: '0 / 8',
                  color: Colors.cyan,
                ),
                _buildStatItem(
                  context,
                  icon: Icons.book_outlined,
                  label: 'Learning',
                  value: 'New',
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildNavigationCards(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildNavigationCard(
          context,
          title: 'Fasting',
          subtitle: 'Start your journey',
          icon: Icons.timer,
          color: Colors.blue,
          onTap: () => context.goToFasting(),
        ),
        _buildNavigationCard(
          context,
          title: 'Hydration',
          subtitle: 'Track water intake',
          icon: Icons.water_drop,
          color: Colors.cyan,
          onTap: () => context.goToHydration(),
        ),
        _buildNavigationCard(
          context,
          title: 'Learning',
          subtitle: 'Explore content',
          icon: Icons.school,
          color: Colors.orange,
          onTap: () => context.goToLearning(),
        ),
        _buildNavigationCard(
          context,
          title: 'Profile',
          subtitle: 'View your stats',
          icon: Icons.person,
          color: Colors.purple,
          onTap: () => context.goToProfile(),
        ),
      ],
    );
  }

  Widget _buildNavigationCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
