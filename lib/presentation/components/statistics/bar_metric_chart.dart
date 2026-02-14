import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/settings_provider.dart';
import '../fitness_card.dart';
import 'empty_chart.dart';

class BarMetricChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String metric;

  const BarMetricChart({super.key, required this.data, required this.metric});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const EmptyChart();

    final settings = context.watch<SettingsProvider>();
    final displayData = data.map((d) {
      final val = (d['value'] as num).toDouble();
      if (metric == 'Volume') {
        return {
          ...d,
          'value': settings.convertToDisplay(val * 1000) / 1000, 
        };
      } else if (metric == 'Duration') {
        // Convert minutes to hours
        return {
          ...d,
          'value': val / 60.0,
        };
      }
      return d;
    }).toList();

    double maxY = 0;
    for (var item in displayData) {
      final val = (item['value'] as num).toDouble();
      if (val > maxY) maxY = val;
    }
    if (maxY == 0) maxY = 10;
    
    // Add buffer
    maxY = maxY * 1.2;
    
    // Calculate nice interval
    double interval = maxY / 4;
    if (interval == 0) interval = 1;

    return FitnessCard(
      padding: const EdgeInsets.fromLTRB(8, 24, 16, 16), // Less left padding as titles take space
      child: SizedBox(
        height: 250,
        child: BarChart(
          BarChartData(
            maxY: maxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: interval,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= displayData.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        displayData[index]['label'] as String,
                        style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    );
                  },
                  reservedSize: 30,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50, // Increased for units
                  interval: interval,
                  getTitlesWidget: (value, meta) {
                    if (value == 0) return const SizedBox();
                    
                    String text;
                    if (metric == 'Volume') {
                       text = '${value.toStringAsFixed(value < 10 ? 1 : 0)}k ${settings.unitLabel}';
                    } else if (metric == 'Duration') {
                      text = '${value.toStringAsFixed(1)} hr';
                    } else if (metric == 'Reps') {
                       if (value >= 1000) {
                         text = '${(value / 1000).toStringAsFixed(1)}k reps';
                       } else {
                         text = '${value.toStringAsFixed(0)} reps';
                       }
                    } else if (metric == 'Sets') {
                      text = '${value.toStringAsFixed(0)} sets';
                    } else {
                      text = value.toStringAsFixed(0);
                    }
                    
                    return Text(
                      text,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 9,
                      ),
                      textAlign: TextAlign.right,
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom: BorderSide(color: Theme.of(context).colorScheme.outline),
                left: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            barGroups: displayData.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: (entry.value['value'] as num).toDouble(),
                    color: Theme.of(context).colorScheme.primary,
                    width: 16,
                    borderRadius: BorderRadius.zero,
                  ),
                ],
              );
            }).toList(),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => Theme.of(context).colorScheme.surfaceContainer,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  String text;
                  final val = rod.toY;
                  if (metric == 'Volume') {
                     text = '${val.toStringAsFixed(2)}k ${settings.unitLabel}';
                  } else if (metric == 'Duration') {
                    text = '${val.toStringAsFixed(2)} hrs';
                  } else if (metric == 'Reps') {
                    text = '${val.toStringAsFixed(0)} reps';
                  } else if (metric == 'Sets') {
                    text = '${val.toStringAsFixed(0)} sets';
                  } else {
                    text = val.toStringAsFixed(1);
                  }

                  return BarTooltipItem(
                    text,
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
