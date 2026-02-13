import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme.dart';
import '../../data/repositories/workout_repository.dart';
import '../components/fitness_card.dart';

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
                        color: AppTheme.muted,
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
                      child: _StatBox(
                        label: 'Workouts',
                        value: _isWeekly ? '${repo.workoutsThisWeek}' : '${repo.workoutsLast30Days}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatBox(
                        label: 'Total Volume',
                        value: '${(repo.totalVolume / 1000).toStringAsFixed(1)}k',
                        unit: 'kg',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Muscle Distribution
                const Text('Muscle Distribution', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _MuscleDistributionChart(data: repo.getRadarStats(_isWeekly)),
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
                _BarMetricChart(
                  data: repo.getAggregatedStats(_isWeekly, _selectedMetric),
                  metric: _selectedMetric,
                ),
                const SizedBox(height: 32),

                // Frequency Chart
                const Text('Workout Frequency', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _FrequencyChart(data: repo.getAggregatedStats(_isWeekly, 'Volume')),
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
          color: isActive ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppTheme.mutedForeground,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;

  const _StatBox({required this.label, required this.value, this.unit});

  @override
  Widget build(BuildContext context) {
    return FitnessCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppTheme.mutedForeground, fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(unit!, style: const TextStyle(color: AppTheme.mutedForeground, fontSize: 12)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MuscleDistributionChart extends StatelessWidget {
  final List<double> data;

  const _MuscleDistributionChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || data.every((e) => e == 0)) {
      return const _EmptyChart();
    }
    
    return FitnessCard(
      child: Column(
        children: [
          SizedBox(
            height: 250,
            child: RadarChart(
              RadarChartData(
                dataSets: [
                  RadarDataSet(
                    fillColor: AppTheme.primary.withValues(alpha: 0.2),
                    borderColor: AppTheme.primary,
                    entryRadius: 3,
                    dataEntries: data.map((e) => RadarEntry(value: e)).toList(),
                  ),
                ],
                radarBackgroundColor: Colors.transparent,
                borderData: FlBorderData(show: false),
                radarBorderData: const BorderSide(color: AppTheme.border, width: 1),
                radarShape: RadarShape.polygon,
                getTitle: (index, angle) {
                  const labels = ['Back', 'Chest', 'Core', 'Shoulders', 'Arms', 'Legs'];
                  return RadarChartTitle(
                    text: labels[index],
                    angle: angle,
                  );
                },
                titleTextStyle: const TextStyle(color: AppTheme.mutedForeground, fontSize: 10),
                tickCount: 5,
                ticksTextStyle: const TextStyle(color: Colors.transparent),
                gridBorderData: const BorderSide(color: AppTheme.border, width: 1),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
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
              color: isSelected ? AppTheme.primary.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isSelected ? AppTheme.primary : AppTheme.border,
                width: 1,
              ),
            ),
            child: Text(
              m,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppTheme.primary : AppTheme.mutedForeground,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _BarMetricChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String metric;

  const _BarMetricChart({required this.data, required this.metric});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const _EmptyChart();

    return FitnessCard(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= data.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(data[index]['label'], style: const TextStyle(fontSize: 10, color: AppTheme.mutedForeground)),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: data.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value['value'],
                    color: AppTheme.primary,
                    width: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }).toList(),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => AppTheme.muted,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${rod.toY.toStringAsFixed(1)}${metric == 'Volume' ? 'k' : ''}',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FrequencyChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const _FrequencyChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const _EmptyChart();

    return FitnessCard(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= data.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(data[index]['label'], style: const TextStyle(fontSize: 10, color: AppTheme.mutedForeground)),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: data.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), (entry.value['value'] ?? 0) > 0 ? 1 : 0);
                }).toList(),
                isCurved: true,
                color: AppTheme.primary,
                barWidth: 3,
                dotData: const FlDotData(show: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) {
    return const FitnessCard(
      child: SizedBox(
        height: 100,
        child: Center(
          child: Text('No data for this period', style: TextStyle(color: AppTheme.mutedForeground)),
        ),
      ),
    );
  }
}
