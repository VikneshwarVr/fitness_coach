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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<WorkoutRepository>().loadWorkouts(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                            onTap: () => context.push('/workout-details/${workout.id}'),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (workout.photoUrl != null && workout.photoUrl!.isNotEmpty) ...[
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          workout.photoUrl!,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Container(
                                              width: 40,
                                              height: 40,
                                              color: AppTheme.card,
                                              child: Center(
                                                child: SizedBox(
                                                  width: 15,
                                                  height: 15,
                                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                                                ),
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: 40,
                                              height: 40,
                                              color: AppTheme.card,
                                              child: Icon(LucideIcons.imageOff, size: 16, color: AppTheme.mutedForeground),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                    Expanded(
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
                                          const SizedBox(height: 4),
                                          Text(
                                            workout.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(color: AppTheme.border),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: _StatColumn(
                                        label: 'Volume',
                                        value: workout.totalVolume >= 1000 
                                          ? '${(workout.totalVolume / 1000).toStringAsFixed(1)}k kg'
                                          : '${workout.totalVolume} kg',
                                      ),
                                    ),
                                    Expanded(
                                      child: _StatColumn(
                                        label: 'Exercises',
                                        value: '${workout.exercises.length}',
                                      ),
                                    ),
                                    const Expanded(
                                      child: _StatColumn(
                                        label: 'Best Set',
                                        value: '-', // Placeholder for complex calc
                                      ),
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
