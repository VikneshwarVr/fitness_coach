import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../data/providers/settings_provider.dart';
import '../../data/constants/exercise_data.dart';
import '../../data/repositories/workout_repository.dart';
import '../components/fitness_card.dart';
import '../../core/utils/responsive_utils.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final String exerciseName;

  const ExerciseDetailScreen({super.key, required this.exerciseName});

  @override
  Widget build(BuildContext context) {
    final distribution = ExerciseData.detailedMuscles[exerciseName] ?? {};
    
    // Determine primary and secondary muscles
    String primaryMuscle = 'Unknown';
    List<String> secondaryMuscles = [];
    
    if (distribution.isNotEmpty) {
      final sortedEntries = distribution.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      primaryMuscle = sortedEntries.first.key;
      secondaryMuscles = sortedEntries.skip(1).map((e) => e.key).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(exerciseName),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.p(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Muscle Distribution Section
            Text(
              'Muscles Worked', 
              style: TextStyle(fontSize: Responsive.sp(context, 18), fontWeight: FontWeight.bold)
            ),
            SizedBox(height: Responsive.h(context, 12)),
            FitnessCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MuscleInfo(
                    label: 'Primary',
                    muscles: [primaryMuscle],
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  if (secondaryMuscles.isNotEmpty) ...[
                    Divider(height: Responsive.h(context, 24)),
                    _MuscleInfo(
                      label: 'Secondary',
                      muscles: secondaryMuscles,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
            ),
            
            SizedBox(height: Responsive.h(context, 24)),
            
            // Personal Records Section
            Text(
              'Personal Records', 
              style: TextStyle(fontSize: Responsive.sp(context, 18), fontWeight: FontWeight.bold)
            ),
            SizedBox(height: Responsive.h(context, 12)),
            Consumer<WorkoutRepository>(
              builder: (context, repo, _) {
                return FutureBuilder<Map<String, double>>(
                  future: repo.getExercisePRs(exerciseName),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final prs = snapshot.data ?? {
                      'heaviestWeight': 0.0,
                      'best1RM': 0.0,
                      'bestSetVolume': 0.0,
                      'bestSessionVolume': 0.0,
                    };

                    final settings = context.read<SettingsProvider>();
                    final label = settings.unitLabel;

                    final category = ExerciseData.getCategory(exerciseName);
                    List<Widget> prCards = [];

                    String formatDuration(double s) {
                      if (s <= 0) return '-';
                      int sec = s.toInt();
                      int h = sec ~/ 3600;
                      int m = (sec % 3600) ~/ 60;
                      int leftSec = sec % 60;
                      if (h > 0) return '${h}h ${m}m';
                      if (m > 0) return '${m}m ${leftSec}s';
                      return '${leftSec}s';
                    }

                    if (category == 'Cardio' || category == 'Distance') {
                      double dist = prs['maxDistance'] ?? 0;
                      prCards.add(_PRCard(
                        label: 'Max Distance',
                        value: dist.toStringAsFixed(2),
                        unit: 'km',
                        icon: LucideIcons.map,
                      ));
                      if (category == 'Cardio') {
                         prCards.add(_PRCard(
                          label: 'Max Duration',
                          value: formatDuration(prs['maxDuration'] ?? 0),
                          unit: '',
                          icon: LucideIcons.timer,
                        ));
                      }
                    } else if (category == 'DistanceMeters' || category == 'DistanceTimeMeters') {
                      double dist = prs['maxDistance'] ?? 0;
                      prCards.add(_PRCard(
                        label: 'Max Distance',
                        value: dist.toStringAsFixed(1),
                        unit: 'm',
                        icon: LucideIcons.map,
                      ));
                       if (category == 'DistanceTimeMeters') {
                          prCards.add(_PRCard(
                            label: 'Max Duration',
                            value: formatDuration(prs['maxDuration'] ?? 0),
                            unit: '',
                            icon: LucideIcons.timer,
                          ));
                       }
                    } else if (category == 'WeightedDistanceMeters') {
                       double dist = prs['maxDistance'] ?? 0;
                       prCards.add(_PRCard(
                        label: 'Max Distance',
                        value: dist.toStringAsFixed(1),
                        unit: 'm',
                        icon: LucideIcons.map,
                      ));
                      prCards.add(_PRCard(
                          label: 'Heaviest Weight',
                          value: settings.formatWeight(prs['heaviestWeight']!, showUnit: false),
                          unit: label,
                          icon: LucideIcons.dumbbell,
                      ));
                    } else if (category == 'Timed') {
                      prCards.add(_PRCard(
                        label: 'Max Duration',
                        value: formatDuration(prs['maxDuration'] ?? 0),
                        unit: '',
                        icon: LucideIcons.timer,
                      ));
                    } else if (category == 'Bodyweight') {
                      prCards.add(_PRCard(
                        label: 'Max Reps',
                        value: (prs['maxReps'] ?? 0).toStringAsFixed(0),
                        unit: 'reps',
                        icon: LucideIcons.repeat,
                      ));
                      if ((prs['heaviestWeight'] ?? 0) > 0) {
                        prCards.add(_PRCard(
                          label: 'Heaviest Weight',
                          value: settings.formatWeight(prs['heaviestWeight']!, showUnit: false),
                          unit: label,
                          icon: LucideIcons.dumbbell,
                        ));
                      }
                    } else {
                      // Strength / Default
                      prCards.add(_PRCard(
                        label: 'Heaviest Weight',
                        value: settings.formatWeight(prs['heaviestWeight']!, showUnit: false),
                        unit: label,
                        icon: LucideIcons.dumbbell,
                      ));
                      prCards.add(_PRCard(
                        label: 'Best 1RM',
                        value: settings.formatWeight(prs['best1RM']!, showUnit: false),
                        unit: label,
                        icon: LucideIcons.trophy,
                      ));
                      prCards.add(_PRCard(
                        label: 'Best Set Volume',
                        value: settings.formatWeight(prs['bestSetVolume']!, showUnit: false),
                        unit: label,
                        icon: LucideIcons.barChart,
                      ));
                    }

                    if (prCards.isEmpty) {
                      return const SizedBox(height: 50, child: Center(child: Text('No records yet')));
                    }

                    return GridView.count(
                      crossAxisCount: Responsive.isMobile(context) ? 2 : 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: Responsive.p(context, 12),
                      crossAxisSpacing: Responsive.p(context, 12),
                      childAspectRatio: Responsive.isMobile(context) ? 1.5 : 1.8,
                      children: prCards,
                    );
                  },
                );
              },
            ),
            
            SizedBox(height: Responsive.h(context, 24)),

            // Progress History Chart
            Text(
              'Progress History', 
              style: TextStyle(fontSize: Responsive.sp(context, 18), fontWeight: FontWeight.bold)
            ),
            SizedBox(height: Responsive.h(context, 12)),
            _ProgressChart(exerciseName: exerciseName),
            
            SizedBox(height: Responsive.h(context, 32)),
          ],
        ),
      ),
    );
  }
}

class _MuscleInfo extends StatelessWidget {
  final String label;
  final List<String> muscles;
  final Color color;

  const _MuscleInfo({
    required this.label,
    required this.muscles,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: Responsive.sp(context, 12), color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: Responsive.h(context, 8)),
        Wrap(
          spacing: Responsive.p(context, 8),
          runSpacing: Responsive.p(context, 8),
          children: muscles.map((m) => Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.p(context, 12), 
              vertical: Responsive.p(context, 6)
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Text(
              m,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: Responsive.sp(context, 13)),
            ),
          )).toList(),
        ),
      ],
    );
  }
}

class _PRCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;

  const _PRCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FitnessCard(
      padding: EdgeInsets.all(Responsive.p(context, 12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: Responsive.sp(context, 14), color: Theme.of(context).colorScheme.primary),
              SizedBox(width: Responsive.w(context, 6)),
              Text(
                label, 
                style: TextStyle(fontSize: Responsive.sp(context, 10), color: Theme.of(context).colorScheme.onSurfaceVariant)
              ),
            ],
          ),
          SizedBox(height: Responsive.h(context, 8)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 18), // Slightly smaller for long values
                    fontWeight: FontWeight.bold, 
                    color: Theme.of(context).colorScheme.onSurface
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: Responsive.w(context, 4)),
              Text(
                unit,
                style: TextStyle(fontSize: Responsive.sp(context, 11), color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressChart extends StatelessWidget {
  final String exerciseName;

  const _ProgressChart({required this.exerciseName});

  @override
  Widget build(BuildContext context) {
    return FitnessCard(
      padding: EdgeInsets.fromLTRB(
        Responsive.p(context, 16), 
        Responsive.p(context, 24), 
        Responsive.p(context, 24), 
        Responsive.p(context, 16)
      ),
      child: SizedBox(
        height: Responsive.h(context, 220),
        child: Consumer<WorkoutRepository>(
          builder: (context, repo, _) {
            return FutureBuilder<List<ProgressPoint>>(
              future: repo.getExerciseProgressHistory(exerciseName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final points = snapshot.data ?? [];
                if (points.isEmpty) {
                  return const Center(child: Text('No history yet'));
                }

                // Prepare fl_chart data
                final category = ExerciseData.getCategory(exerciseName);
                final settings = context.read<SettingsProvider>();
                
                String unit = 'kg';
                if (category == 'Cardio' || category == 'Distance') unit = 'km';
                else if (category == 'DistanceMeters' || category == 'WeightedDistanceMeters' || category == 'DistanceTimeMeters') unit = 'm';
                else if (category == 'Timed') unit = 's';
                else if (category == 'Bodyweight') unit = 'reps';
                else unit = settings.unitLabel;

                final chartPoints = points.asMap().entries.map((e) {
                  return FlSpot(e.key.toDouble(), e.value.value);
                }).toList();

                double minY = points.map((p) => p.value).reduce((a, b) => a < b ? a : b);
                double maxY = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
                
                // Add some padding to Y axis
                double yRange = maxY - minY;
                if (yRange == 0) yRange = maxY * 0.2;
                if (yRange == 0) yRange = 10;
                
                double drawMinY = (minY - yRange * 0.1).clamp(0.0, double.infinity);
                double drawMaxY = maxY + yRange * 0.1;

                return LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          interval: (points.length / 5).clamp(1.0, double.infinity),
                          getTitlesWidget: (value, meta) {
                            int idx = value.toInt();
                            if (idx < 0 || idx >= points.length) return const SizedBox.shrink();
                            
                            // Only show first, middle, last if many points
                            if (points.length > 5 && idx % (points.length ~/ 3) != 0 && idx != points.length - 1) {
                               return const SizedBox.shrink();
                            }

                            final date = points[idx].date;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('MMM d').format(date),
                                style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        axisNameWidget: Text(
                          unit,
                          style: TextStyle(
                            fontSize: Responsive.sp(context, 10),
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        axisNameSize: Responsive.p(context, 16),
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: Responsive.p(context, 32),
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toStringAsFixed(0),
                              style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minY: drawMinY,
                    maxY: drawMaxY,
                    lineBarsData: [
                      LineChartBarData(
                        spots: chartPoints,
                        isCurved: true,
                        color: Theme.of(context).colorScheme.primary,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                            radius: 4,
                            color: Theme.of(context).colorScheme.primary,
                            strokeWidth: 2,
                            strokeColor: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                              Theme.of(context).colorScheme.primary.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (spot) => Theme.of(context).colorScheme.surfaceContainerHighest,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final date = points[spot.spotIndex].date;
                            return LineTooltipItem(
                              '${DateFormat('MMM d').format(date)}\n${spot.y.toStringAsFixed(1)} $unit',
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
