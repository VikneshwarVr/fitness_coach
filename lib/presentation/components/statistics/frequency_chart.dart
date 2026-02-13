import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme.dart';
import '../fitness_card.dart';
import 'empty_chart.dart';

class FrequencyChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const FrequencyChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const EmptyChart();

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
