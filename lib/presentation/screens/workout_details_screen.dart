import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../data/repositories/workout_repository.dart';
import '../../data/models/workout.dart';
import '../../data/providers/workout_provider.dart';
import '../components/fitness_card.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  final String workoutId;

  const WorkoutDetailsScreen({super.key, required this.workoutId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Details', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Consumer<WorkoutRepository>(
            builder: (context, repo, child) {
              final workout = repo.workouts.where((w) => w.id == workoutId).firstOrNull;
              if (workout == null) return const SizedBox();
              
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.edit2, size: 20),
                    onPressed: () {
                      context.read<WorkoutProvider>().loadWorkoutForEditing(workout);
                      context.push('/workout/edit-log');
                    },
                    tooltip: 'Edit Workout',
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.trash2, size: 20, color: Colors.red),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Workout?'),
                          content: const Text('Are you sure you want to delete this workout history?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true && context.mounted) {
                        await context.read<WorkoutRepository>().deleteWorkout(workoutId);
                        if (context.mounted) context.pop();
                      }
                    },
                    tooltip: 'Delete Workout',
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<WorkoutRepository>(
        builder: (context, repo, child) {
          final workout = repo.workouts.where((w) => w.id == workoutId).firstOrNull;

          if (workout == null) {
            return const Center(
              child: Text('Workout not found', style: TextStyle(color: AppTheme.mutedForeground)),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Workout Header Info
                Text(
                  workout.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, MMM d, yyyy • hh:mm a').format(workout.date),
                  style: const TextStyle(color: AppTheme.mutedForeground, fontSize: 13),
                ),
                const SizedBox(height: 20),

                // Stats Summary Cards (Horizontal)
                Row(
                  children: [
                    Expanded(
                      child: _SummaryStatCard(
                        icon: LucideIcons.calendar,
                        label: 'Duration',
                        value: '${workout.duration}',
                        unit: 'min',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryStatCard(
                        icon: LucideIcons.trendingUp,
                        label: 'Total Volume',
                        value: workout.totalVolume >= 1000 
                          ? (workout.totalVolume / 1000).toStringAsFixed(1)
                          : '${workout.totalVolume}',
                        unit: workout.totalVolume >= 1000 ? 'k kg' : 'kg',
                        valueColor: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (workout.photoUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      workout.photoUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                const Text('Exercises', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // Exercises List
                ...workout.exercises.map((exercise) => _ExerciseDetailItem(exercise: exercise)),
                
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color? valueColor;

  const _SummaryStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return FitnessCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppTheme.mutedForeground),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.mutedForeground)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? AppTheme.foreground,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(fontSize: 12, color: AppTheme.mutedForeground),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExerciseDetailItem extends StatelessWidget {
  final ExerciseSession exercise;

  const _ExerciseDetailItem({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final completedSets = exercise.sets.where((s) => s.completed).toList();
    final exerciseVolume = exercise.volume;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    exercise.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Text(
                  '${completedSets.length} sets',
                  style: const TextStyle(fontSize: 12, color: AppTheme.mutedForeground),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Sets Details Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.muted.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  ...completedSets.asMap().entries.map((entry) {
                    final index = entry.key;
                    final set = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Set ${index + 1}',
                            style: const TextStyle(fontSize: 13, color: AppTheme.mutedForeground),
                          ),
                          Row(
                            children: [
                              Text(
                                '${set.weight} kg',
                                style: const TextStyle(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '×',
                                style: TextStyle(fontSize: 13, color: AppTheme.mutedForeground),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${set.reps} reps',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                  // Total Exercise Volume Footer
                  const SizedBox(height: 8),
                  const Divider(color: AppTheme.border, height: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Volume',
                        style: TextStyle(fontSize: 11, color: AppTheme.mutedForeground),
                      ),
                      Text(
                        '$exerciseVolume kg',
                        style: const TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
