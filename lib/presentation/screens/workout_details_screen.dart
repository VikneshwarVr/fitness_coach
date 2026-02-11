import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../data/repositories/workout_repository.dart';
import '../../data/models/workout.dart';
import '../components/fitness_card.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  final String workoutId;

  const WorkoutDetailsScreen({super.key, required this.workoutId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Details', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<WorkoutRepository>(
        builder: (context, repo, child) {
          // Find the workout in the repository
          final workout = repo.workouts.where((w) => w.id == workoutId).firstOrNull;

          if (workout == null) {
            return const Center(
              child: Text('Workout not found', style: TextStyle(color: AppTheme.mutedForeground)),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with Name and Date
                Text(
                  workout.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, MMM d, yyyy • hh:mm a').format(workout.date),
                  style: const TextStyle(color: AppTheme.mutedForeground, fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Stats Row
                Row(
                  children: [
                    Expanded(child: _SummaryStat(
                      label: 'Duration',
                      value: '${workout.duration}m',
                      icon: LucideIcons.clock,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _SummaryStat(
                      label: 'Volume',
                      value: workout.totalVolume >= 1000 
                        ? '${(workout.totalVolume / 1000).toStringAsFixed(1)}k'
                        : '${workout.totalVolume}',
                      subValue: 'kg',
                      icon: LucideIcons.trendingUp,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _SummaryStat(
                      label: 'Exercises',
                      value: '${workout.exercises.length}',
                      icon: LucideIcons.dumbbell,
                    )),
                  ],
                ),
                
                const SizedBox(height: 32),
                const Text('Exercises', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),

                // Exercises List
                ...workout.exercises.map((exercise) => _ExerciseDetailCard(exercise: exercise)),
                
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ExerciseDetailCard extends StatelessWidget {
  final ExerciseSession exercise;

  const _ExerciseDetailCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: FitnessCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              exercise.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary),
            ),
            const SizedBox(height: 12),
            
            // Sets Header
            const Row(
              children: [
                SizedBox(width: 30, child: Text('SET', style: TextStyle(fontSize: 10, color: AppTheme.mutedForeground, fontWeight: FontWeight.bold))),
                Expanded(child: Center(child: Text('WEIGHT', style: TextStyle(fontSize: 10, color: AppTheme.mutedForeground, fontWeight: FontWeight.bold)))),
                Expanded(child: Center(child: Text('REPS', style: TextStyle(fontSize: 10, color: AppTheme.mutedForeground, fontWeight: FontWeight.bold)))),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: AppTheme.border),
            const SizedBox(height: 8),

            // Sets List
            ...exercise.sets.asMap().entries.map((entry) {
              final index = entry.key;
              final set = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 30, 
                      child: Text('${index + 1}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.mutedForeground))
                    ),
                    Expanded(child: Center(child: Text('${set.weight} kg', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)))),
                    Expanded(child: Center(child: Text('${set.reps}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)))),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final String? subValue;
  final IconData icon;

  const _SummaryStat({
    required this.label,
    required this.value,
    this.subValue,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FitnessCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppTheme.primary),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.mutedForeground)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              if (subValue != null) ...[
                const SizedBox(width: 1),
                Text(subValue!, style: const TextStyle(fontSize: 10, color: AppTheme.mutedForeground)),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
