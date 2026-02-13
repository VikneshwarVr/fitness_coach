import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../fitness_card.dart';

class StatBox extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;

  const StatBox({super.key, required this.label, required this.value, this.unit});

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
