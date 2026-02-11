import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../data/repositories/workout_repository.dart';
import '../components/fitness_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Workout History', style: Theme.of(context).textTheme.headlineSmall),
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
                          onTap: () => context.go('/workout/details/${workout.id}'),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('MMM d, yyyy').format(workout.date),
                                    style: const TextStyle(
                                      color: AppTheme.mutedForeground,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '${workout.duration} min',
                                    style: const TextStyle(
                                      color: AppTheme.mutedForeground,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                workout.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 12),
                              const Divider(color: AppTheme.border),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _StatColumn(
                                    label: 'Volume',
                                    value: '${(workout.totalVolume / 1000).toStringAsFixed(1)}k kg',
                                  ),
                                  _StatColumn(
                                    label: 'Exercises',
                                    value: '${workout.exercises.length}',
                                  ),
                                  _StatColumn(
                                    label: 'Best Set',
                                    value: '-', // Placeholder for complex calc
                                  ),
                                ],
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
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.mutedForeground)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
