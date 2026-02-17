import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/repositories/workout_repository.dart';
import '../../data/providers/settings_provider.dart';
import '../components/fitness_card.dart';
import '../../core/utils/responsive_utils.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutRepository>().loadWorkouts(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<WorkoutRepository>().loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Workout History', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: Responsive.sp(context, 20))
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<WorkoutRepository>().loadWorkouts(refresh: true),
          child: Consumer<WorkoutRepository>(
            builder: (context, repo, child) {
              if (repo.workouts.isEmpty && !repo.isLoadingMore) {
                return Stack(
                  children: [
                    ListView(), // Required for RefreshIndicator to work
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'No workouts requested yet.\nStart a workout to see your history.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(Responsive.p(context, 16)),
                itemCount: repo.workouts.length + (repo.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == repo.workouts.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final workout = repo.workouts[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: Responsive.h(context, 12)),
                    child: FitnessCard(
                      onTap: () => context.push('/workout-details/${workout.id}'),
                      padding: EdgeInsets.all(Responsive.p(context, 16)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  workout.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: Responsive.sp(context, 16),
                                  ),
                                ),
                                SizedBox(height: Responsive.h(context, 4)),
                                Text(
                                  DateFormat('MMM d, yyyy • HH:mm').format(workout.date),
                                  style: TextStyle(
                                    fontSize: Responsive.sp(context, 12),
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Text(
                                      '${workout.exercises.length} exercises',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text('•', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                    ),
                                    Text(
                                      '${workout.duration} min',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text('•', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                    ),
                                    Consumer<SettingsProvider>(
                                      builder: (context, settings, child) {
                                        final label = settings.unitLabel;
                                        final displayVolume = settings.convertToDisplay(workout.totalVolume);
                                        final valueString = displayVolume >= 1000 
                                          ? '${(displayVolume / 1000).toStringAsFixed(1)}k $label'
                                          : '${displayVolume.toStringAsFixed(0)} $label';
                                        
                                        return Text(
                                          valueString,
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            LucideIcons.chevronRight,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

