
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../data/repositories/workout_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../components/fitness_card.dart';
import '../components/buttons.dart';

import 'package:fl_chart/fl_chart.dart';
import 'exercise_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isWeekly = true;
  String _selectedMetric = 'Volume';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.muted,
                  child: Icon(LucideIcons.user, size: 40, color: AppTheme.mutedForeground),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  context.watch<AuthRepository>().displayName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text('Level 1 Athlete', style: TextStyle(color: AppTheme.primary, fontSize: 14)),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              const SizedBox(height: 16),
              
              Consumer<WorkoutRepository>(
                builder: (context, repo, child) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StatBox(
                              label: 'Workouts',
                              value: '${repo.workoutsThisWeek}', // This might need updating to reflect toggle?
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatBox(
                              label: 'Volume',
                              value: '${(repo.totalVolume / 1000).toStringAsFixed(1)}k',
                              unit: 'kg',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      const Text('Muscle Distribution', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _MuscleDistributionChart(data: repo.getRadarStats(_isWeekly)),
                      
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('$_selectedMetric Trend', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
                      
                      const SizedBox(height: 24),
                      const Text('Workout Frequency', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _FrequencyChart(data: repo.getAggregatedStats(_isWeekly, 'Volume')), 
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 24),
              SecondaryButton(
                label: 'Exercises Library',
                icon: LucideIcons.bookOpen,
                onPressed: () => context.push('/exercises'),
              ),

              const SizedBox(height: 32),
              const Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              _SettingsItem(
                icon: LucideIcons.settings,
                label: 'General',
                onTap: () {},
              ),
               const SizedBox(height: 8),
              _SettingsItem(
                icon: LucideIcons.bell,
                label: 'Notifications',
                onTap: () {},
              ),
               const SizedBox(height: 8),
              _SettingsItem(
                icon: LucideIcons.moon,
                label: 'Dark Mode',
                trailing: Switch(
                  value: true,
                  onChanged: (val) {},
                  activeThumbColor: AppTheme.primary,
                ),
              ),
              
              const SizedBox(height: 24),
              SecondaryButton(
                label: 'Sign Out',
                icon: LucideIcons.logOut,
                onPressed: () async {
                  await context.read<AuthRepository>().signOut();
                },
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text('Version 1.0.0', style: TextStyle(color: AppTheme.mutedForeground, fontSize: 12)),
              ),
            ],
          ),
        ),
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

class _MuscleDistributionChart extends StatelessWidget {
  final List<double> data;

  const _MuscleDistributionChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || data.every((e) => e == 0)) {
      return const _EmptyChart();
    }
    
    // Find max value for scaling
    double maxValue = 5.0; // Minimal scale
    for (var val in data) { if (val > maxValue) maxValue = val; }

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
                ticksTextStyle: const TextStyle(color: Colors.transparent), // Hide numbers
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
                  return FlSpot(entry.key.toDouble(), (entry.value['value'] ?? 0) > 0 ? 1 : 0); // Placeholder for frequency
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

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return FitnessCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // Slimmer
      onTap: onTap,
       child: SizedBox(
        height: 48,
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.foreground),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
            if (trailing != null) trailing! else const Icon(LucideIcons.chevronRight, size: 20, color: AppTheme.mutedForeground),
          ],
        ),
      ),
    );
  }
}
