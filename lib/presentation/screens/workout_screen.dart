
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../data/models/routine.dart';
import '../../data/providers/workout_provider.dart';
import '../components/fitness_card.dart';
import '../components/buttons.dart';

class WorkoutScreen extends StatefulWidget {
  final Routine? initialRoutine;

  const WorkoutScreen({super.key, this.initialRoutine});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule the start after the frame to avoid build conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WorkoutProvider>();
      // Only start if not active, or if we explicitly passed a routine to start
      // For now, if passed routine, assume restart or new.
      // If no routine, it might be just navigation back to active workout.
      if (!provider.isWorkoutActive || widget.initialRoutine != null) {
         if (widget.initialRoutine != null || !provider.isWorkoutActive) {
             provider.startWorkout(routine: widget.initialRoutine);
         }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(LucideIcons.x),
              onPressed: () {
                 // TODO: Prompt to cancel or just saving draft?
                 // For now just back.
                context.go('/');
              },
            ),
            title: Text(provider.workoutName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: Icon(provider.isPlaying ? LucideIcons.pause : LucideIcons.play),
                onPressed: provider.toggleTimer,
              ),
              TextButton(
                onPressed: () {
                  context.read<WorkoutProvider>().pauseTimer();
                  context.push('/workout/finish');
                },
                child: const Text('Finish', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          body: provider.exercises.isEmpty 
          ? Center(
              child: PrimaryButton(
                label: 'Add First Exercise',
                icon: LucideIcons.plus,
                onPressed: () async {
                   final result = await context.push<String>('/workout/add');
                   if (result != null) {
                     provider.addExercise(result);
                   }
                },
              ),
            )
          : Column(
              children: [
                // Stats Panel
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FitnessCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatItem(
                            icon: LucideIcons.clock,
                            label: 'Duration',
                            value: provider.formattedTime,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppTheme.border,
                        ),
                        Expanded(
                          child: _StatItem(
                            icon: LucideIcons.trendingUp,
                            label: 'Volume',
                            value: provider.totalVolume >= 1000
                                ? '${(provider.totalVolume / 1000).toStringAsFixed(1)}k'
                                : '${provider.totalVolume}',
                            unit: 'kg',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppTheme.border,
                        ),
                        Expanded(
                          child: _StatItem(
                            icon: LucideIcons.layers,
                            label: 'Sets',
                            value: '${provider.totalSets}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Exercise List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.exercises.length + 1,
                    itemBuilder: (context, index) {
                      if (index == provider.exercises.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: PrimaryButton(
                            label: 'Add Exercise',
                            icon: LucideIcons.plus,
                            onPressed: () async {
                               final result = await context.push<String>('/workout/add');
                               if (result != null) {
                                 provider.addExercise(result);
                               }
                            },
                          ),
                        );
                      }

              final exercise = provider.exercises[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: FitnessCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(exercise.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(LucideIcons.moreVertical, size: 20, color: AppTheme.mutedForeground),
                            onPressed: () {}, // Options
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                       Table(
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        columnWidths: const {
                          0: FixedColumnWidth(40),
                          1: FlexColumnWidth(),
                          2: FlexColumnWidth(),
                          3: FixedColumnWidth(40),
                        },
                        children: [
                          const TableRow(
                            children: [
                              Text('Set', style: TextStyle(color: AppTheme.mutedForeground, fontSize: 12), textAlign: TextAlign.center),
                              Text('kg', style: TextStyle(color: AppTheme.mutedForeground, fontSize: 12), textAlign: TextAlign.center),
                              Text('Reps', style: TextStyle(color: AppTheme.mutedForeground, fontSize: 12), textAlign: TextAlign.center),
                              SizedBox(),
                            ],
                          ),
                          ...exercise.sets.asMap().entries.map((entry) {
                            final setIndex = entry.key;
                            final set = entry.value;
                            return TableRow(
                              key: ValueKey('${exercise.id}_$setIndex'),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppTheme.muted,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text('${setIndex + 1}', style: const TextStyle(fontSize: 12)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: TextFormField(
                                    key: ValueKey('weight_${exercise.id}_$setIndex'),
                                    initialValue: set.weight > 0 ? '${set.weight}' : '',
                                    decoration: const InputDecoration(
                                      filled: true,
                                      fillColor: AppTheme.input,
                                      border: OutlineInputBorder(borderSide: BorderSide.none),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      isDense: true,
                                    ),
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 14),
                                    onChanged: (val) {
                                      final weight = int.tryParse(val) ?? 0;
                                      provider.updateSet(index, setIndex, weight: weight);
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: TextFormField(
                                    key: ValueKey('reps_${exercise.id}_$setIndex'),
                                    initialValue: set.reps > 0 ? '${set.reps}' : '',
                                    decoration: const InputDecoration(
                                      filled: true,
                                      fillColor: AppTheme.input,
                                      border: OutlineInputBorder(borderSide: BorderSide.none),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      isDense: true,
                                    ),
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 14),
                                    onChanged: (val) {
                                      final reps = int.tryParse(val) ?? 0;
                                      provider.updateSet(index, setIndex, reps: reps);
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    set.completed ? LucideIcons.checkSquare : LucideIcons.square,
                                    color: set.completed ? AppTheme.primary : AppTheme.mutedForeground,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    provider.toggleSetCompletion(index, setIndex);
                                  },
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          icon: const Icon(LucideIcons.plus, size: 16),
                          label: const Text('Add Set'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                          ),
                          onPressed: () => provider.addSet(index),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
              ],
            ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? unit;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppTheme.primary),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.mutedForeground)),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              if (unit != null) ...[
                const SizedBox(width: 2),
                Text(unit!, style: const TextStyle(fontSize: 10, color: AppTheme.mutedForeground)),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
