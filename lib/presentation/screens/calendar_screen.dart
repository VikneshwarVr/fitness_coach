import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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

  @override
  void initState() {
    super.initState();
    // No need for local calculation anymore, data is in repository
  }

  List<Workout> _getWorkoutsForDate(DateTime date) {
    final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return context.read<WorkoutRepository>().workoutsByDate[key] ?? [];
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
    return Consumer<WorkoutRepository>(
      builder: (context, repo, child) {
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
                          Text('Week Streak', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('${repo.weekStreak}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      Text('consecutive weeks', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10)),
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
                        Text('Rest Days', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('${repo.restDays}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    Text('since last workout', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildViewModeTabs() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outline)),
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
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
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
          workouts: context.read<WorkoutRepository>().allWorkoutsMetadata,
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
