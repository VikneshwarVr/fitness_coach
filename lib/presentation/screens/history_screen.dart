import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../data/repositories/workout_repository.dart';
import '../components/fitness_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutRepository>().loadWorkouts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text('Workout History', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<WorkoutRepository>().loadWorkouts(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Consumer<WorkoutRepository>(
                  builder: (context, repo, child) {
                    if (repo.workouts.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'No workouts requested yet.\nStart a workout to see your history.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.mutedForeground),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: repo.workouts.map((workout) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: FitnessCard(
                            onTap: () => context.push('/workout-details/${workout.id}'),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        workout.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('E, MMM d').format(workout.date),
                                        style: const TextStyle(
                                          color: AppTheme.mutedForeground,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Text(
                                            '${workout.exercises.length} exercises',
                                            style: const TextStyle(
                                              color: AppTheme.mutedForeground,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 8),
                                            child: Text('•', style: TextStyle(color: AppTheme.mutedForeground)),
                                          ),
                                          Text(
                                            '${workout.duration} min',
                                            style: const TextStyle(
                                              color: AppTheme.mutedForeground,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 8),
                                            child: Text('•', style: TextStyle(color: AppTheme.mutedForeground)),
                                          ),
                                          Text(
                                            workout.totalVolume >= 1000 
                                              ? '${(workout.totalVolume / 1000).toStringAsFixed(1)}k kg'
                                              : '${workout.totalVolume} kg',
                                            style: const TextStyle(
                                              color: AppTheme.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  LucideIcons.chevronRight,
                                  color: AppTheme.mutedForeground,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

