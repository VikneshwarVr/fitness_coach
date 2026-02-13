import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../fitness_card.dart';

class WorkoutStatsPanel extends StatelessWidget {
  final String duration;
  final int totalVolume;
  final int totalSets;

  const WorkoutStatsPanel({
    super.key,
    required this.duration,
    required this.totalVolume,
    required this.totalSets,
  });

  @override
  Widget build(BuildContext context) {
    return FitnessCard(
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: LucideIcons.clock,
              label: 'Duration',
              value: duration,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Theme.of(context).colorScheme.outline,
          ),
          Expanded(
            child: _StatItem(
              icon: LucideIcons.trendingUp,
              label: 'Volume',
              value: totalVolume >= 1000
                  ? '${(totalVolume / 1000).toStringAsFixed(1)}k'
                  : '$totalVolume',
              unit: 'kg',
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Theme.of(context).colorScheme.outline,
          ),
          Expanded(
            child: _StatItem(
              icon: LucideIcons.layers,
              label: 'Sets',
              value: '$totalSets',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? unit;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              if (unit != null) ...[
                const SizedBox(width: 2),
                Text(unit!, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
