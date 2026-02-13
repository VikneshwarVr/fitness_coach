import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../data/models/workout.dart';

class MonthlyView extends StatelessWidget {
  final DateTime currentDate;
  final List<DateTime> days;
  final List<Workout> Function(DateTime) getWorkoutsForDate;
  final Function(DateTime) onDateTap;

  const MonthlyView({
    super.key,
    required this.currentDate,
    required this.days,
    required this.getWorkoutsForDate,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Headers
        Row(
          children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((d) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(d, textAlign: TextAlign.center, 
                        style: const TextStyle(color: AppTheme.mutedForeground, fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          )).toList(),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: 42,
          itemBuilder: (context, index) {
            final date = days[index];
            final workouts = getWorkoutsForDate(date);
            final isCurrentMonth = date.month == currentDate.month;
            final isToday = DateFormat('yyyy-MM-dd').format(date) == 
                            DateFormat('yyyy-MM-dd').format(DateTime.now());

            return Opacity(
              opacity: isCurrentMonth ? 1.0 : 0.2,
              child: GestureDetector(
                onTap: () {
                  if (workouts.length == 1) {
                    context.push('/workout-details/${workouts[0].id}');
                  } else {
                    onDateTap(date);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: workouts.isNotEmpty ? Colors.orange.withValues(alpha: 0.15) : AppTheme.muted.withValues(alpha: 0.1),
                    border: Border.all(
                      color: isToday ? Colors.orange : (workouts.isNotEmpty ? Colors.orange.withValues(alpha: 0.3) : Colors.transparent),
                      width: isToday ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${date.day}', 
                           style: TextStyle(
                             fontSize: 12, 
                             fontWeight: workouts.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                             color: workouts.isNotEmpty ? Colors.orange : (isCurrentMonth ? null : AppTheme.mutedForeground)
                           )),
                      if (workouts.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                          child: Center(
                            child: Text('${workouts.length}', 
                                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
