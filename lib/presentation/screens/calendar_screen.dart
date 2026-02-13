import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../data/models/workout.dart';
import '../../data/repositories/workout_repository.dart';
import '../components/fitness_card.dart';

import '../components/calendar/weekly_view.dart';
import '../components/calendar/monthly_view.dart';
import '../components/calendar/yearly_view.dart';

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
                    Colors.orange.withValues(alpha: 0.15),
                    Colors.red.withValues(alpha: 0.15),
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
        final startOfWeek = _currentDate.subtract(Duration(days: _currentDate.weekday % 7));
        return WeeklyView(
          days: List.generate(7, (i) => startOfWeek.add(Duration(days: i))),
          getWorkoutsForDate: _getWorkoutsForDate,
        );
      case ViewMode.monthly:
        final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
        final startOfGrid = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday % 7));
        return MonthlyView(
          currentDate: _currentDate,
          days: List.generate(42, (i) => startOfGrid.add(Duration(days: i))),
          getWorkoutsForDate: _getWorkoutsForDate,
          onDateTap: (date) {
            setState(() {
              _viewMode = ViewMode.weekly;
              _currentDate = date;
            });
          },
        );
      case ViewMode.yearly:
        return YearlyView(
          currentDate: _currentDate,
          workouts: context.read<WorkoutRepository>().workouts,
          onMonthTap: (date) {
            setState(() {
              _currentDate = date;
              _viewMode = ViewMode.monthly;
            });
          },
        );
    }
  }
}
