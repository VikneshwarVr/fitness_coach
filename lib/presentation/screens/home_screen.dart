import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../components/fitness_card.dart';
import '../components/buttons.dart';
import '../components/mode_toggle.dart';
import '../../data/repositories/routine_repository.dart';
import '../../data/repositories/workout_repository.dart';
import '../../data/providers/workout_provider.dart';
import '../../data/providers/settings_provider.dart';
import '../../core/utils/responsive_utils.dart';

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
      context.read<WorkoutRepository>().loadWorkouts(refresh: true);
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
            padding: EdgeInsets.all(Responsive.p(context, 16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _AICoachBanner(),
                SizedBox(height: Responsive.h(context, 24)),
                const _Header(),
                SizedBox(height: Responsive.h(context, 24)),
                const _QuickStats(),
                SizedBox(height: Responsive.h(context, 24)),
                PrimaryButton(
                  label: 'Start Empty Workout',
                  icon: LucideIcons.plus,
                  onPressed: () {
                     final settings = context.read<SettingsProvider>();
                     final mode = settings.workoutMode == WorkoutMode.home ? 'home' : 'gym';
                     context.read<WorkoutProvider>().startWorkout(
                       defaultRestTime: settings.defaultRestTimer,
                       mode: mode,
                     ); 
                     context.go('/workout');
                  },
                ),
                SizedBox(height: Responsive.h(context, 12)),
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
                    SizedBox(width: Responsive.w(context, 12)),
                    Expanded(
                      child: SecondaryButton(
                        label: 'Exercises',
                        icon: LucideIcons.library,
                        onPressed: () => context.push('/exercises'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(context, 24)),
                const _RecentWorkoutsSection(),
                SizedBox(height: Responsive.h(context, 24)),
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
              padding: EdgeInsets.all(Responsive.p(context, 16)),
              child: Row(
                children: [
                  Container(
                    height: Responsive.h(context, 40),
                    width: Responsive.w(context, 40),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outline)),
                    ),
                    child: Icon(LucideIcons.sparkles, color: Colors.white, size: Responsive.sp(context, 20)),
                  ),
                  SizedBox(width: Responsive.w(context, 12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'AI Coach', 
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: Responsive.sp(context, 16),
                              )
                            ),
                            SizedBox(width: Responsive.w(context, 8)),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: Responsive.p(context, 8), vertical: Responsive.p(context, 2)),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Coming Soon', 
                                style: TextStyle(
                                  fontSize: Responsive.sp(context, 10), 
                                  color: Theme.of(context).colorScheme.onSurfaceVariant, 
                                  fontWeight: FontWeight.bold
                                )
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Responsive.h(context, 4)),
                        Text(
                          'Get personalized workout recommendations and form tips powered by AI',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: Responsive.sp(context, 12),
                          ),
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
                icon: Icon(LucideIcons.x, size: Responsive.sp(context, 16)),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center, // Align center vertically
      children: [
        Expanded( // Wrap text in Expanded to prevent overflow
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back!', 
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: Responsive.sp(context, 20),
                )
              ),
              SizedBox(height: Responsive.h(context, 4)),
              Text(
                'Ready to crush your workout?', 
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: Responsive.sp(context, 14),
                )
              ),
            ],
          ),
        ),
        SizedBox(width: Responsive.w(context, 16)),
        const ModeToggle(),
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
            SizedBox(width: Responsive.w(context, 12)),
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
            SizedBox(width: Responsive.w(context, 12)),
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
      padding: EdgeInsets.all(Responsive.p(context, 12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon, 
                size: Responsive.sp(context, 14), 
                color: iconColor ?? Theme.of(context).colorScheme.onSurfaceVariant
              ),
              SizedBox(width: Responsive.w(context, 6)),
              Expanded(
                child: Text(
                  label, 
                  style: TextStyle(fontSize: Responsive.sp(context, 9), color: Theme.of(context).colorScheme.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(context, 8)),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value, 
              style: TextStyle(fontSize: Responsive.sp(context, 18), fontWeight: FontWeight.bold)
            ),
          ),
          Text(
            subLabel, 
            style: TextStyle(fontSize: Responsive.sp(context, 9), color: Theme.of(context).colorScheme.onSurfaceVariant), 
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
            Text(
              'Recent Workouts', 
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: Responsive.sp(context, 18),
              )
            ),
            TextButton(
              onPressed: () => context.push('/history'),
              child: Text(
                'View All', 
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: Responsive.sp(context, 14))
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.h(context, 12)),
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
                padding: EdgeInsets.only(bottom: Responsive.h(context, 12)),
                child: FitnessCard(
                  onTap: () => context.push('/workout-details/${workout.id}'),
                  child: Row(
                    children: [
                      if (workout.photoUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            workout.photoUrl!,
                            width: Responsive.w(context, 48),
                            height: Responsive.h(context, 48),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: Responsive.w(context, 48),
                              height: Responsive.h(context, 48),
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: Icon(LucideIcons.image, size: Responsive.sp(context, 20), color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          ),
                        ),
                        SizedBox(width: Responsive.w(context, 12)),
                      ],
                      Expanded(
                        child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workout.name, 
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: Responsive.sp(context, 14))
                            ),
                            SizedBox(height: Responsive.h(context, 4)),
                            Text(
                              '${workout.exercises.length} exercises • ${workout.duration} min',
                              style: TextStyle(fontSize: Responsive.sp(context, 12), color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: Responsive.w(context, 8)),
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
                              Text(
                                'Volume', 
                                style: TextStyle(
                                  fontSize: Responsive.sp(context, 11), 
                                  color: const Color(0xFF737373)
                                )
                              ),
                              Text(
                                valueString,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: Responsive.sp(context, 13)),
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
      padding: EdgeInsets.all(Responsive.p(context, 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 Tip of the Day', 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: Responsive.sp(context, 14))
          ),
          SizedBox(height: Responsive.h(context, 8)),
          Text(
            'Progressive overload is key! Try to increase weight or reps each week for consistent gains.',
            style: TextStyle(fontSize: Responsive.sp(context, 12), color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
