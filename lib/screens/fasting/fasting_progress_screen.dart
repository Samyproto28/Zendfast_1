import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/timer_provider.dart';
import '../../providers/session_manager_provider.dart';
import '../../router/navigation_extensions.dart';
import 'dart:math' as math;

/// Screen showing active fasting progress with timer and controls
/// Displays elapsed time, remaining time, and milestone achievements
class FastingProgressScreen extends ConsumerWidget {
  const FastingProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final sessionManager = ref.watch(sessionManagerProvider);

    // If no active fast, redirect to fasting screen
    if (timerState == null || !timerState.isRunning) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.goToFasting();
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fasting Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showTipsBottomSheet(context),
            tooltip: 'Fasting Tips',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTimerCircle(context, timerState),
              const SizedBox(height: 32),
              _buildTimeInfo(context, timerState),
              const SizedBox(height: 32),
              _buildMilestones(context, timerState),
              const SizedBox(height: 32),
              _buildControlButtons(context, sessionManager),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerCircle(BuildContext context, timerState) {
    final progress = timerState.progress.clamp(0.0, 1.0);
    final size = MediaQuery.of(context).size.width * 0.7;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          CustomPaint(
            size: Size(size, size),
            painter: _CircleProgressPainter(
              progress: progress,
              backgroundColor: Colors.grey[300]!,
              progressColor: Colors.green,
            ),
          ),
          // Time display
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatDuration(timerState.elapsedTime),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Elapsed Time',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(BuildContext context, timerState) {
    final remaining = timerState.remainingTime;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTimeInfoItem(
              context,
              icon: Icons.schedule,
              label: 'Remaining',
              value: _formatDuration(remaining),
              color: Colors.orange,
            ),
            Container(
              width: 1,
              height: 50,
              color: Colors.grey[300],
            ),
            _buildTimeInfoItem(
              context,
              icon: Icons.flag,
              label: 'Target',
              value: '${timerState.targetDuration.inHours}h',
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
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

  Widget _buildMilestones(BuildContext context, timerState) {
    final elapsedHours = timerState.elapsedTime.inHours;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Milestones',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildMilestoneItem(
          context,
          hour: 12,
          title: 'Glycogen Depleted',
          description: 'Body starts burning fat',
          reached: elapsedHours >= 12,
        ),
        _buildMilestoneItem(
          context,
          hour: 16,
          title: 'Ketosis Begins',
          description: 'Enhanced fat burning mode',
          reached: elapsedHours >= 16,
        ),
        _buildMilestoneItem(
          context,
          hour: 24,
          title: 'Autophagy Activated',
          description: 'Cellular repair process begins',
          reached: elapsedHours >= 24,
        ),
        _buildMilestoneItem(
          context,
          hour: 48,
          title: 'Growth Hormone Peak',
          description: 'Maximum metabolic benefits',
          reached: elapsedHours >= 48,
        ),
      ],
    );
  }

  Widget _buildMilestoneItem(
    BuildContext context, {
    required int hour,
    required String title,
    required String description,
    required bool reached,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: reached ? Colors.green : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                reached ? Icons.check : Icons.schedule,
                color: reached ? Colors.white : Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration: reached ? null : TextDecoration.none,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${hour}h',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
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

  Widget _buildControlButtons(BuildContext context, sessionManager) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final confirmed = await _showCompleteDialog(context);
              if (confirmed == true && context.mounted) {
                await sessionManager.completeSession(context);
              }
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('Complete Fast'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await _showInterruptDialog(context);
              if (confirmed == true && context.mounted) {
                await sessionManager.interruptSession(context);
              }
            },
            icon: const Icon(Icons.stop),
            label: const Text('End Fast'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  Future<bool?> _showCompleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Fast?'),
        content: const Text(
          'Congratulations! Are you ready to complete your fast?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showInterruptDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Fast?'),
        content: const Text(
          'Are you sure you want to end your fast early? Your progress will still be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('End Fast'),
          ),
        ],
      ),
    );
  }

  void _showTipsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fasting Tips',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildTipItem(context, 'Stay hydrated - drink plenty of water'),
            _buildTipItem(context, 'Keep yourself busy to avoid thinking about food'),
            _buildTipItem(context, 'Listen to your body - it\'s okay to stop if needed'),
            _buildTipItem(context, 'Avoid strenuous exercise during longer fasts'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(BuildContext context, String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Custom painter for circular progress indicator
class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  _CircleProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 12.0;

    // Draw background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final startAngle = -math.pi / 2; // Start from top
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
