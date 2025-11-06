import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/timer_provider.dart';
import '../../router/navigation_extensions.dart';

/// Main fasting screen that shows overview and current fasting status
/// Provides navigation to start new fast or view active fast progress
class FastingScreen extends ConsumerWidget {
  const FastingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fasting'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Navigate to fasting history
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History coming soon')),
              );
            },
            tooltip: 'History',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(context, timerState),
              const SizedBox(height: 24),
              _buildQuickActionsSection(context, timerState),
              const SizedBox(height: 24),
              _buildFastingPlansSection(context),
              const SizedBox(height: 24),
              _buildBenefitsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, timerState) {
    final bool isActive = timerState?.isRunning ?? false;

    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isActive
                ? [Colors.green.withValues(alpha: 0.2), Colors.blue.withValues(alpha: 0.2)]
                : [Colors.grey.withValues(alpha: 0.1), Colors.grey.withValues(alpha: 0.05)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              isActive ? Icons.timer : Icons.timer_outlined,
              size: 64,
              color: isActive ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isActive ? 'Fasting in Progress' : 'No Active Fast',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            if (isActive && timerState != null) ...[
              Text(
                _formatDuration(Duration(milliseconds: timerState.elapsedMilliseconds)),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: timerState.progress,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              const SizedBox(height: 8),
              Text(
                '${(timerState.progress * 100).toStringAsFixed(0)}% Complete',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ] else
              Text(
                'Ready to start your fasting journey',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, timerState) {
    final bool isActive = timerState?.isRunning ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isActive
                    ? () => context.goToFastingProgress()
                    : () => context.goToFastingStart(),
                icon: Icon(isActive ? Icons.trending_up : Icons.play_arrow),
                label: Text(isActive ? 'View Progress' : 'Start Fast'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: isActive ? Colors.green : Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFastingPlansSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Fasting Plans',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildPlanCard(
          context,
          title: '16:8',
          subtitle: 'Fast for 16 hours, eat in 8-hour window',
          icon: Icons.schedule,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildPlanCard(
          context,
          title: '18:6',
          subtitle: 'Fast for 18 hours, eat in 6-hour window',
          icon: Icons.watch_later,
          color: Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildPlanCard(
          context,
          title: 'OMAD',
          subtitle: 'One meal a day - 23 hour fast',
          icon: Icons.restaurant,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => context.goToFastingStart(),
      ),
    );
  }

  Widget _buildBenefitsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Benefits of Fasting',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildBenefitItem(
          context,
          icon: Icons.favorite,
          title: 'Improved Metabolism',
          description: 'Enhance your body\'s natural fat-burning ability',
        ),
        _buildBenefitItem(
          context,
          icon: Icons.psychology,
          title: 'Mental Clarity',
          description: 'Experience sharper focus and cognitive function',
        ),
        _buildBenefitItem(
          context,
          icon: Icons.healing,
          title: 'Cellular Repair',
          description: 'Trigger autophagy and cellular regeneration',
        ),
      ],
    );
  }

  Widget _buildBenefitItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}
