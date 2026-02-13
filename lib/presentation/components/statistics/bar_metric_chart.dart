import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme.dart';
import '../fitness_card.dart';
import 'empty_chart.dart';

class BarMetricChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String metric;

  const BarMetricChart({super.key, required this.data, required this.metric});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const EmptyChart();

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
