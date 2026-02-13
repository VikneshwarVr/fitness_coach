import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../data/models/workout.dart';
import '../fitness_card.dart';

class WeeklyView extends StatelessWidget {
  final List<DateTime> days;
  final List<Workout> Function(DateTime) getWorkoutsForDate;

  const WeeklyView({
    super.key,
    required this.days,
    required this.getWorkoutsForDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: days.map((date) {
        final dayWorkouts = getWorkoutsForDate(date);
        final isToday = DateFormat('yyyy-MM-dd').format(date) == 
                        DateFormat('yyyy-MM-dd').format(DateTime.now());
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FitnessCard(
            padding: const EdgeInsets.all(16),
            border: isToday ? Border.all(color: Colors.orange, width: 2) : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('EEEE').format(date), 
                             style: const TextStyle(color: AppTheme.mutedForeground, fontSize: 12)),
                        Text(DateFormat('MMMM d').format(date), 
                             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    if (dayWorkouts.isNotEmpty)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text('${dayWorkouts.length}', 
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
                if (dayWorkouts.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...dayWorkouts.map((w) => InkWell(
                    onTap: () => context.push('/workout-details/${w.id}'),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.muted.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(w.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text('${w.exercises.length} exercises • ${w.duration} min', 
                                     style: const TextStyle(color: AppTheme.mutedForeground, fontSize: 12)),
                              ],
                            ),
                          ),
                          const Icon(LucideIcons.chevronRight, size: 16, color: AppTheme.mutedForeground),
                        ],
                      ),
                    ),
                  )),
                ] else ...[
                  const SizedBox(height: 8),
                  const Text('Rest day', style: TextStyle(color: AppTheme.mutedForeground, fontSize: 14)),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
