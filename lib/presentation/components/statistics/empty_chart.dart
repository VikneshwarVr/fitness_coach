import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../fitness_card.dart';

class EmptyChart extends StatelessWidget {
  const EmptyChart({super.key});

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
