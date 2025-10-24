import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';

/// Simple widget to test the background timer functionality
/// Can be used to start/stop/pause timer and view its state
class TimerTestWidget extends StatelessWidget {
  const TimerTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timerProvider, child) {
        final isRunning = timerProvider.isRunning;
        final formattedTime = isRunning
            ? timerProvider.formattedRemainingTime
            : timerProvider.formattedElapsedTime;
        final progress = timerProvider.progress;

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Fasting Timer Test',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),

                // Timer display
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        formattedTime,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isRunning) ...[
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withValues(alpha: 0.3),
                          minHeight: 8,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(progress * 100).toInt()}% complete',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Timer controls
                Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    if (!isRunning)
                      ElevatedButton.icon(
                        onPressed: () => _startTimer(context, timerProvider),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start 16h Fast'),
                      ),

                    if (isRunning)
                      ElevatedButton.icon(
                        onPressed: () => timerProvider.pauseTimer(),
                        icon: const Icon(Icons.pause),
                        label: const Text('Pause'),
                      ),

                    if (!isRunning && timerProvider.currentState != null)
                      ElevatedButton.icon(
                        onPressed: () => timerProvider.resumeTimer(),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Resume'),
                      ),

                    if (timerProvider.currentState != null)
                      ElevatedButton.icon(
                        onPressed: () => timerProvider.cancelTimer(),
                        icon: const Icon(Icons.stop),
                        label: const Text('Cancel'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Theme.of(context).colorScheme.onError,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Info text
                Text(
                  isRunning
                      ? 'Timer is running in background. You can close the app!'
                      : 'Start a timer to test background persistence',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startTimer(BuildContext context, TimerProvider timerProvider) {
    // For testing, use a dummy user ID
    // In production, this would come from authentication
    timerProvider.startTimer(
      userId: 'test_user',
      durationMinutes: 960, // 16 hours
      planType: '16:8',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Timer started! Try closing the app and reopening it.'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
