import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_computed_providers.dart';
import '../../services/database_service.dart';
import '../../models/hydration_log.dart';

/// Screen for tracking daily water intake
/// Allows users to log water consumption and view daily progress
class HydrationScreen extends ConsumerStatefulWidget {
  const HydrationScreen({super.key});

  @override
  ConsumerState<HydrationScreen> createState() => _HydrationScreenState();
}

class _HydrationScreenState extends ConsumerState<HydrationScreen> {
  static const double _dailyGoalLiters = 2.5; // 2.5L daily goal
  double _todayIntake = 0.0; // in liters
  List<HydrationLog> _todayLogs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTodayIntake();
  }

  Future<void> _loadTodayIntake() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      // Get today's hydration logs from database
      final logs = await DatabaseService.instance.getTodayHydration(userId);

      setState(() {
        _todayLogs = logs;
        _todayIntake = logs.fold(0.0, (sum, log) => sum + log.amountLiters);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading hydration logs: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_todayIntake / _dailyGoalLiters).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hydration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History coming soon')),
              );
            },
            tooltip: 'History',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressCard(context, progress),
                    const SizedBox(height: 24),
                    _buildQuickAddSection(context),
                    const SizedBox(height: 24),
                    _buildTodayLogsSection(context),
                    const SizedBox(height: 24),
                    _buildTipsSection(context),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, double progress) {
    final glassesCount = (_todayIntake / 0.25).round(); // Assuming 250ml per glass

    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.cyan.withValues(alpha: 0.2),
              Colors.blue.withValues(alpha: 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Intake',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_todayIntake.toStringAsFixed(1)}L',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.cyan[700],
                          ),
                    ),
                    Text(
                      'Goal: ${_dailyGoalLiters}L',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress >= 1.0 ? Colors.green : Colors.cyan,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.water_drop,
                          size: 32,
                          color: progress >= 1.0 ? Colors.green : Colors.cyan,
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '$glassesCount glasses (250ml each)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Add',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickAddButton(
                context,
                amount: 250,
                unit: 'ml',
                icon: Icons.local_cafe,
                label: 'Cup',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickAddButton(
                context,
                amount: 500,
                unit: 'ml',
                icon: Icons.water_drop,
                label: 'Bottle',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickAddButton(
                context,
                amount: 1000,
                unit: 'ml',
                icon: Icons.sports_bar,
                label: 'Large',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showCustomAmountDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Custom Amount'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAddButton(
    BuildContext context, {
    required int amount,
    required String unit,
    required IconData icon,
    required String label,
  }) {
    return ElevatedButton(
      onPressed: () => _addWater(amount.toDouble()),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 4),
          Text(label),
          Text(
            '$amount$unit',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayLogsSection(BuildContext context) {
    if (_todayLogs.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(Icons.water_drop_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'No water logged today',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start tracking your hydration above',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Logs',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ..._todayLogs.map((log) => _buildLogItem(context, log)),
      ],
    );
  }

  Widget _buildLogItem(BuildContext context, HydrationLog log) {
    final timeStr = '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.cyan,
          child: Icon(Icons.water_drop, color: Colors.white, size: 20),
        ),
        title: Text('${log.amountMl.toInt()} ml'),
        subtitle: Text(timeStr),
        trailing: Text(
          '${log.amountLiters.toStringAsFixed(2)}L',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.cyan[700],
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  Widget _buildTipsSection(BuildContext context) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Hydration Tips',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTipItem('Drink water before meals to aid digestion'),
            _buildTipItem('Keep a water bottle nearby throughout the day'),
            _buildTipItem('Set reminders if you often forget to drink'),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(tip)),
        ],
      ),
    );
  }

  Future<void> _addWater(double amountMl) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    try {
      // Create hydration log
      final log = HydrationLog(
        userId: userId,
        amountMl: amountMl,
      );

      // Save to database
      await DatabaseService.instance.logHydration(log);

      // Reload today's intake
      await _loadTodayIntake();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${amountMl.toInt()}ml'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging water: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showCustomAmountDialog(BuildContext context) async {
    final controller = TextEditingController();

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Amount'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount (ml)',
            hintText: '250',
            suffixText: 'ml',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = int.tryParse(controller.text);
              if (amount != null && amount > 0) {
                Navigator.of(context).pop(amount);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null) {
      await _addWater(result.toDouble());
    }
  }
}
