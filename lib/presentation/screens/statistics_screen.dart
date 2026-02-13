import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/settings_provider.dart';
import '../../data/repositories/workout_repository.dart';
import '../components/statistics/stat_box.dart';
import '../components/statistics/muscle_distribution_chart.dart';
import '../components/statistics/bar_metric_chart.dart';
import '../components/statistics/frequency_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isWeekly = true;
  String _selectedMetric = 'Volume';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<WorkoutRepository>(
        builder: (context, repo, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Toggle Week/Month
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ToggleBtn(
                            label: 'Week',
                            isActive: _isWeekly,
                            onTap: () => setState(() => _isWeekly = true),
                          ),
                          _ToggleBtn(
                            label: 'Month',
                            isActive: !_isWeekly,
                            onTap: () => setState(() => _isWeekly = false),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Summary Stats
                Row(
                  children: [
                    Expanded(
                      child: StatBox(
                        label: 'Workouts',
                        value: _isWeekly ? '${repo.workoutsThisWeek}' : '${repo.workoutsLast30Days}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Consumer<SettingsProvider>(
                        builder: (context, settings, child) {
                          final label = settings.unitLabel;
                          final displayVolume = settings.convertToDisplay(repo.totalVolume);
                          final value = (displayVolume / 1000).toStringAsFixed(1);
                          return StatBox(
                            label: 'Total Volume',
                            value: '${value}k',
                            unit: label,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Muscle Distribution
                const Text('Muscle Distribution', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                MuscleDistributionChart(data: repo.getRadarStats(_isWeekly)),
                const SizedBox(height: 32),

                // Trend Chart
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$_selectedMetric Trend', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    _MetricSelector(
                      selected: _selectedMetric,
                      onChanged: (val) => setState(() => _selectedMetric = val),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                BarMetricChart(
                  data: repo.getAggregatedStats(_isWeekly, _selectedMetric),
                  metric: _selectedMetric,
                ),
                const SizedBox(height: 32),

                // Frequency Chart
                const Text('Workout Frequency', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                FrequencyChart(data: repo.getAggregatedStats(_isWeekly, 'Volume')),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleBtn({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _MetricSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _MetricSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final metrics = ['Volume', 'Reps', 'Sets', 'Duration'];
    return Row(
      children: metrics.map((m) {
        final isSelected = selected == m;
        return GestureDetector(
          onTap: () => onChanged(m),
          child: Container(
            margin: const EdgeInsets.only(left: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                width: 1,
              ),
            ),
            child: Text(
              m,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
