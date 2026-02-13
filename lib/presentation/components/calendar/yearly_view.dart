import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../data/models/workout.dart';
import '../fitness_card.dart';

class YearlyView extends StatelessWidget {
  final DateTime currentDate;
  final List<Workout> workouts;
  final Function(DateTime) onMonthTap;

  const YearlyView({
    super.key,
    required this.currentDate,
    required this.workouts,
    required this.onMonthTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final monthDate = DateTime(currentDate.year, index + 1, 1);
        final monthWorkouts = workouts.where((w) => 
          w.date.year == currentDate.year && w.date.month == index + 1).toList();
        
        final daysInMonth = DateTime(currentDate.year, index + 2, 0).day;
        final workoutDays = monthWorkouts.map((w) => w.date.day).toSet();

        return FitnessCard(
          padding: const EdgeInsets.all(12),
          onTap: () => onMonthTap(monthDate),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat('MMM').format(monthDate), 
                   style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: Center(
                  child: Wrap(
                    spacing: 2,
                    runSpacing: 2,
                    children: List.generate(daysInMonth, (d) {
                      final reached = workoutDays.contains(d + 1);
                      return Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: reached ? Colors.orange : AppTheme.muted.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text('${monthWorkouts.length} workouts', 
                   style: const TextStyle(color: AppTheme.mutedForeground, fontSize: 10)),
            ],
          ),
        );
      },
    );
  }
}
