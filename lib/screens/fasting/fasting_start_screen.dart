import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/timer_provider.dart';
import '../../providers/auth_computed_providers.dart';
import '../../router/navigation_extensions.dart';

/// Screen for starting a new fasting session
/// Allows user to select fasting plan type and duration
class FastingStartScreen extends ConsumerStatefulWidget {
  const FastingStartScreen({super.key});

  @override
  ConsumerState<FastingStartScreen> createState() => _FastingStartScreenState();
}

class _FastingStartScreenState extends ConsumerState<FastingStartScreen> {
  String _selectedPlan = '16:8';
  int _durationHours = 16;
  bool _isLoading = false;

  final Map<String, int> _fastingPlans = {
    '12:12': 12,
    '14:10': 14,
    '16:8': 16,
    '18:6': 18,
    '20:4': 20,
    'OMAD (23:1)': 23,
    '24 Hour': 24,
    'Custom': 0, // Custom duration
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Fasting'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(context),
              const SizedBox(height: 32),
              _buildPlanSelectionSection(context),
              const SizedBox(height: 32),
              _buildDurationSection(context),
              const SizedBox(height: 32),
              _buildStartButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Fasting Plan',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select a fasting schedule that works best for you. You can always adjust it later.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildPlanSelectionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fasting Plan',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _fastingPlans.keys.map((plan) {
            final isSelected = _selectedPlan == plan;
            return ChoiceChip(
              label: Text(plan),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedPlan = plan;
                    if (plan != 'Custom') {
                      _durationHours = _fastingPlans[plan]!;
                    }
                  });
                }
              },
              selectedColor: Colors.blue,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDurationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hours',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '$_durationHours hours',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Slider(
                  value: _durationHours.toDouble(),
                  min: 4,
                  max: 48,
                  divisions: 44,
                  label: '$_durationHours hours',
                  onChanged: (value) {
                    setState(() {
                      _durationHours = value.toInt();
                      _selectedPlan = 'Custom';
                    });
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Expected completion: ${_getCompletionTime()}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _startFasting,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.play_arrow),
        label: Text(_isLoading ? 'Starting...' : 'Start Fasting'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getCompletionTime() {
    final completionTime = DateTime.now().add(Duration(hours: _durationHours));
    final hour = completionTime.hour;
    final minute = completionTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$displayHour:$minute $period';
  }

  Future<void> _startFasting() async {
    setState(() => _isLoading = true);

    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Start the fast using the timer provider
      await ref.read(timerProvider.notifier).startFast(
            userId: userId,
            durationMinutes: _durationHours * 60,
            planType: _selectedPlan,
          );

      if (!mounted) return;

      // Navigate to progress screen
      context.goToFastingProgress();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fast started! Duration: $_durationHours hours'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error starting fast: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
