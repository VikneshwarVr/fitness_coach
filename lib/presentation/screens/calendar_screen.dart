import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../data/models/workout.dart';
import '../../data/repositories/workout_repository.dart';
import '../components/fitness_card.dart';

enum ViewMode { weekly, monthly, yearly }

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  ViewMode _viewMode = ViewMode.monthly;
  DateTime _currentDate = DateTime.now();
  int _weekStreak = 0;
  int _restDays = 0;

  @override
  void initState() {
    super.initState();
    // Repository.loadWorkouts() is usually called at app start or home screen, 
    // but we ensure it's loaded.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateStats();
    });
  }

  void _calculateStats() {
    final workouts = context.read<WorkoutRepository>().workouts;
    if (workouts.isEmpty) {
      if (mounted) {
        setState(() {
          _weekStreak = 0;
          _restDays = 0;
        });
      }
      return;
    }

    // Sort workouts by date descending
    final sortedWorkouts = [...workouts]..sort((a, b) => b.date.compareTo(a.date));

    // Calculate rest days (days since last workout)
    final lastWorkoutDate = sortedWorkouts[0].date;
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final lastWorkoutNormalized = DateTime(lastWorkoutDate.year, lastWorkoutDate.month, lastWorkoutDate.day);
    
    final daysSinceLastWorkout = todayNormalized.difference(lastWorkoutNormalized).inDays;
    
    // Calculate week streak (consecutive weeks with at least one workout)
    final weeks = <String, bool>{};
    for (var workout in sortedWorkouts) {
      weeks[_getWeekKey(workout.date)] = true;
    }

    int streak = 0;
    DateTime currentWeekDate = todayNormalized;
    
    while (true) {
      final weekKey = _getWeekKey(currentWeekDate);
      if (weeks.containsKey(weekKey)) {
        streak++;
        currentWeekDate = currentWeekDate.subtract(const Duration(days: 7));
      } else {
        break;
      }
    }

    if (mounted) {
      setState(() {
        _restDays = daysSinceLastWorkout;
        _weekStreak = streak;
      });
    }
  }

  String _getWeekKey(DateTime date) {
    // Start of week (Sunday)
    final startOfWeek = date.subtract(Duration(days: date.weekday % 7));
    return DateFormat('yyyy-MM-dd').format(startOfWeek);
  }

  List<Workout> _getWorkoutsForDate(DateTime date) {
    final workouts = context.read<WorkoutRepository>().workouts;
    return workouts.where((w) {
      return w.date.year == date.year &&
             w.date.month == date.month &&
             w.date.day == date.day;
    }).toList();
  }

  void _navigateDate(int direction) {
    setState(() {
      if (_viewMode == ViewMode.weekly) {
        _currentDate = _currentDate.add(Duration(days: direction * 7));
      } else if (_viewMode == ViewMode.monthly) {
        _currentDate = DateTime(_currentDate.year, _currentDate.month + direction, 1);
      } else {
        _currentDate = DateTime(_currentDate.year + direction, _currentDate.month, 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Calendar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStats(),
            const SizedBox(height: 16),
            _buildViewModeTabs(),
            const SizedBox(height: 16),
            _buildNavigation(),
            const SizedBox(height: 16),
            _buildCalendarView(),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: FitnessCard(
            padding: EdgeInsets.zero,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.15),
                    Colors.red.withOpacity(0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.flame, color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Text('Week Streak', style: TextStyle(color: AppTheme.mutedForeground, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('$_weekStreak', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  Text('consecutive weeks', style: TextStyle(color: AppTheme.mutedForeground, fontSize: 10)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FitnessCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.moon, color: Colors.blue, size: 16),
                    const SizedBox(width: 8),
                    Text('Rest Days', style: TextStyle(color: AppTheme.mutedForeground, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('$_restDays', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                Text('since last workout', style: TextStyle(color: AppTheme.mutedForeground, fontSize: 10)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewModeTabs() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          _buildTab('Weekly', ViewMode.weekly),
          _buildTab('Monthly', ViewMode.monthly),
          _buildTab('Yearly', ViewMode.yearly),
        ],
      ),
    );
  }

  Widget _buildTab(String label, ViewMode mode) {
    final isSelected = _viewMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _viewMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.orange : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.orange : AppTheme.mutedForeground,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigation() {
    String title;
    if (_viewMode == ViewMode.yearly) {
      title = DateFormat('yyyy').format(_currentDate);
    } else {
      title = DateFormat('MMMM yyyy').format(_currentDate);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => _navigateDate(-1),
          icon: const Icon(LucideIcons.chevronLeft, size: 20),
        ),
        Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () => setState(() => _currentDate = DateTime.now()),
              child: const Text('Today', style: TextStyle(fontSize: 12, color: Colors.blue)),
            ),
          ],
        ),
        IconButton(
          onPressed: () => _navigateDate(1),
          icon: const Icon(LucideIcons.chevronRight, size: 20),
        ),
      ],
    );
  }

  Widget _buildCalendarView() {
    switch (_viewMode) {
      case ViewMode.weekly:
        return _buildWeeklyView();
      case ViewMode.monthly:
        return _buildMonthlyView();
      case ViewMode.yearly:
        return _buildYearlyView();
    }
  }

  Widget _buildWeeklyView() {
    final startOfWeek = _currentDate.subtract(Duration(days: _currentDate.weekday % 7));
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    return Column(
      children: days.map((date) {
        final dayWorkouts = _getWorkoutsForDate(date);
        final isToday = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(DateTime.now());
        
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
                        Text(DateFormat('EEEE').format(date), style: TextStyle(color: AppTheme.mutedForeground, fontSize: 12)),
                        Text(DateFormat('MMMM d').format(date), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        color: AppTheme.muted.withOpacity(0.3),
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
                                     style: TextStyle(color: AppTheme.mutedForeground, fontSize: 12)),
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
                  Text('Rest day', style: TextStyle(color: AppTheme.mutedForeground, fontSize: 14)),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMonthlyView() {
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final startOfGrid = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday % 7));
    
    final days = List.generate(42, (i) => startOfGrid.add(Duration(days: i)));

    return Column(
      children: [
        // Headers
        Row(
          children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((d) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(d, textAlign: TextAlign.center, 
                        style: TextStyle(color: AppTheme.mutedForeground, fontSize: 12, fontWeight: FontWeight.w500)),
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
            final workouts = _getWorkoutsForDate(date);
            final isCurrentMonth = date.month == _currentDate.month;
            final isToday = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(DateTime.now());

            return Opacity(
              opacity: isCurrentMonth ? 1.0 : 0.2,
              child: GestureDetector(
                onTap: () {
                  if (workouts.isNotEmpty) {
                    if (workouts.length == 1) {
                      context.push('/workout-details/${workouts[0].id}');
                    } else {
                      // If multiple workouts, switch to weekly view to show list
                      setState(() {
                        _viewMode = ViewMode.weekly;
                        _currentDate = date;
                      });
                    }
                  } else {
                    // Switch to weekly view even if empty? 
                    // Let's just switch to weekly view for that date anyway
                    setState(() {
                      _viewMode = ViewMode.weekly;
                      _currentDate = date;
                    });
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: workouts.isNotEmpty ? Colors.orange.withOpacity(0.15) : AppTheme.muted.withOpacity(0.1),
                    border: Border.all(
                      color: isToday ? Colors.orange : (workouts.isNotEmpty ? Colors.orange.withOpacity(0.3) : Colors.transparent),
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

  Widget _buildYearlyView() {
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
        final monthDate = DateTime(_currentDate.year, index + 1, 1);
        final workouts = context.read<WorkoutRepository>().workouts.where((w) => 
          w.date.year == _currentDate.year && w.date.month == index + 1).toList();
        
        final daysInMonth = DateTime(_currentDate.year, index + 2, 0).day;
        final workoutDays = workouts.map((w) => w.date.day).toSet();

        return FitnessCard(
          padding: const EdgeInsets.all(12),
          onTap: () {
            setState(() {
              _currentDate = monthDate;
              _viewMode = ViewMode.monthly;
            });
          },
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
                          color: reached ? Colors.orange : AppTheme.muted.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text('${workouts.length} workouts', style: TextStyle(color: AppTheme.mutedForeground, fontSize: 10)),
            ],
          ),
        );
      },
    );
  }
}
