import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../components/fitness_card.dart';
import '../components/buttons.dart';
import '../../data/repositories/routine_repository.dart';
import '../../data/repositories/workout_repository.dart';
import '../../data/providers/workout_provider.dart';
import '../../data/providers/settings_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when home screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutRepository>().loadWorkouts();
      context.read<RoutineRepository>().loadRoutines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<WorkoutRepository>().loadWorkouts();
            await context.read<RoutineRepository>().loadRoutines();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _AICoachBanner(),
                const SizedBox(height: 24),
                const _Header(),
                const SizedBox(height: 24),
                const _QuickStats(),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Start Empty Workout',
                  icon: LucideIcons.plus,
                  onPressed: () {
                     final settings = context.read<SettingsProvider>();
                     context.read<WorkoutProvider>().startWorkout(defaultRestTime: settings.defaultRestTimer); 
                     context.go('/workout');
                  },
                ),
                const SizedBox(height: 12),
                // Quick Actions
                Row(
                  children: [
                     Expanded(
                      child: SecondaryButton(
                        label: 'My Routines',
                        icon: LucideIcons.folderOpen,
                        onPressed: () => context.go('/routines'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SecondaryButton(
                        label: 'Exercises',
                        icon: LucideIcons.library,
                        onPressed: () => context.push('/exercises'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _RecentWorkoutsSection(),
                const SizedBox(height: 24),
                const _QuickTips(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AICoachBanner extends StatefulWidget {
  const _AICoachBanner();

  @override
  State<_AICoachBanner> createState() => _AICoachBannerState();
}

class _AICoachBannerState extends State<_AICoachBanner> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return FitnessCard(
      color: Colors.transparent, // Gradient background simulation
      // In Flutter, gradients are part of BoxDecoration. We'd need to extend FitnessCard or wrap it.
      // For MVP simplicity, we'll use a Container with decoration here instead of custom FitnessCard if we want exact gradient.
      // But let's try to wrap FitnessCard content or adjust FitnessCard to accept gradient.
      // Since FitnessCard takes color, let's just make a custom container here for the gradient look.
      
      // Overriding FitnessCard for this specific gradient look
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFEA580C).withValues(alpha: 0.2), // orange-600/20
              const Color(0xFFD97706).withValues(alpha: 0.2), // amber-600/20
            ],
          ),
          border: Border.all(color: const Color(0xFFEA580C).withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
             // Background blur effect would require BackdropFilter or custom painter, skipping for MVP perfection
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outline)),
                    ),
                    child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('AI Coach', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('Coming Soon', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Get personalized workout recommendations and form tips powered by AI',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(LucideIcons.x, size: 16),
                onPressed: () => setState(() => _visible = false),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome back!', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text('Ready to crush your workout?', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _QuickStats extends StatelessWidget {
  const _QuickStats();

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutRepository>(
      builder: (context, repo, child) {
        return Row(
          children: [
            Expanded(child: _StatCard(
              icon: LucideIcons.calendar,
              label: 'This Week',
              value: '${repo.workoutsThisWeek}',
              subLabel: 'workouts',
            )),
            const SizedBox(width: 12),
            Expanded(
              child: Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  final label = settings.unitLabel;
                  final displayVolume = settings.convertToDisplay(repo.totalVolume);
                  return _StatCard(
                    icon: LucideIcons.trendingUp,
                    label: 'Volume',
                    value: '${(displayVolume / 1000).toStringAsFixed(1)}k',
                    subLabel: '$label lifted',
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
             Expanded(child: _StatCard(
              icon: LucideIcons.flame,
              label: 'Streak',
              value: '${repo.streak}',
              subLabel: 'days',
              iconColor: const Color(0xFFF97316), // orange-500
            )),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subLabel;
  final Color? iconColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subLabel,
    this.iconColor,
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
              Icon(icon, size: 16, color: iconColor ?? Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label, 
                  style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Text(
            subLabel, 
            style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant), 
            overflow: TextOverflow.ellipsis, 
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

class _RecentWorkoutsSection extends StatelessWidget {
  const _RecentWorkoutsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Workouts', style: Theme.of(context).textTheme.titleLarge),
            TextButton(
              onPressed: () => context.push('/history'),
              child: Text('View All', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 14)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Consumer<WorkoutRepository>(
          builder: (context, repo, child) {
            final workouts = repo.workouts.take(3).toList();
            
            if (workouts.isEmpty) {
              return FitnessCard(
                child: Center(
                  child: Column(
                    children: [
                      Text('No workouts yet', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text('Start your first workout to see it here', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: workouts.map((workout) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FitnessCard(
                  onTap: () => context.push('/workout-details/${workout.id}'),
                  child: Row(
                    children: [
                      if (workout.photoUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            workout.photoUrl!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 48,
                              height: 48,
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: Icon(LucideIcons.image, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(workout.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              '${workout.exercises.length} exercises • ${workout.duration} min',
                              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                       Consumer<SettingsProvider>(
                        builder: (context, settings, child) {
                          final label = settings.unitLabel;
                          final displayVolume = settings.convertToDisplay(workout.totalVolume);
                          final valueString = displayVolume >= 1000 
                            ? '${(displayVolume / 1000).toStringAsFixed(1)}k $label'
                            : '${displayVolume.toStringAsFixed(0)} $label';
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Volume', style: TextStyle(fontSize: 12, color: Color(0xFF737373))),
                              Text(
                                valueString,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _QuickTips extends StatelessWidget {
  const _QuickTips();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFEA580C).withValues(alpha: 0.1),
            const Color(0xFFDC2626).withValues(alpha: 0.1), // red-600/10
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFEA580C).withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡 Tip of the Day', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Progressive overload is key! Try to increase weight or reps each week for consistent gains.',
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
