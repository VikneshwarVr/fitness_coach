import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../fitness_card.dart';
import 'empty_chart.dart';

class MuscleDistributionChart extends StatelessWidget {
  final List<double> data;

  const MuscleDistributionChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || data.every((e) => e == 0)) {
      return const EmptyChart();
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
                    fillColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    borderColor: Theme.of(context).colorScheme.primary,
                    entryRadius: 3,
                    dataEntries: data.map((e) => RadarEntry(value: e)).toList(),
                  ),
                ],
                radarBackgroundColor: Colors.transparent,
                borderData: FlBorderData(show: false),
                radarBorderData: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
                radarShape: RadarShape.polygon,
                getTitle: (index, angle) {
                  const labels = ['Back', 'Chest', 'Core', 'Shoulders', 'Arms', 'Legs'];
                  return RadarChartTitle(
                    text: labels[index],
                    angle: angle,
                  );
                },
                titleTextStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10),
                tickCount: 5,
                ticksTextStyle: const TextStyle(color: Colors.transparent),
                gridBorderData: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
