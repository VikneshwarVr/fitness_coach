import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/routine.dart';
import '../../data/providers/workout_provider.dart';
import '../components/buttons.dart';
import '../components/workout/workout_stats_panel.dart';
import '../components/workout/pr_notification.dart';
import '../components/workout/rest_timer_overlay.dart';
import '../components/workout/exercise_list_item.dart';

class WorkoutScreen extends StatefulWidget {
  final Routine? initialRoutine;
  final bool isEditing; 
  final bool isEditingLog; 

  const WorkoutScreen({
    super.key, 
    this.initialRoutine, 
    this.isEditing = false,
    this.isEditingLog = false,
  });

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  StreamSubscription<PREvent>? _prSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WorkoutProvider>();
      
      _prSubscription = provider.prEvents.listen((event) {
        if (!mounted) return;
        _showTopPRNotification(context, event);
      });

      if (widget.isEditing && widget.initialRoutine != null) {
         provider.loadRoutineForEditing(widget.initialRoutine!);
      } else if (widget.isEditingLog) {
         // Do nothing
      } else {
        if (!provider.isWorkoutActive || widget.initialRoutine != null) {
           if (widget.initialRoutine != null || !provider.isWorkoutActive) {
               provider.startWorkout(routine: widget.initialRoutine);
           }
        }
      }
    });
  }

  @override
  void dispose() {
    _prSubscription?.cancel();
    super.dispose();
  }

  void _showTopPRNotification(BuildContext context, PREvent event) {
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        return PRNotification(
          event: event,
          onDismiss: () => overlayEntry.remove(),
        );
      },
    );

    Overlay.of(context).insert(overlayEntry);
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
                 if (widget.isEditing || widget.isEditingLog) {
                   context.pop();
                 } else {
                   context.go('/');
                 }
              },
            ),
            title: Text(
              widget.isEditing ? 'Edit Routine' : (widget.isEditingLog ? 'Edit Workout' : provider.workoutName), 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            actions: [
              if (!widget.isEditing && !widget.isEditingLog)
                IconButton(
                  icon: Icon(provider.isPlaying ? LucideIcons.pause : LucideIcons.play),
                  onPressed: provider.toggleTimer,
                ),
              TextButton(
                onPressed: () {
                  if (widget.isEditing) {
                    final exercises = provider.getRoutineExercises();
                    context.pop(exercises);
                    return;
                  }

                  if (provider.totalVolume <= 0) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Empty Workout?'),
                        content: const Text('You haven\'t recorded any volume yet. Please add at least one set with weight before finishing.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Got it', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                          ),
                        ],
                      ),
                    );
                    return;
                  }

                  if (widget.isEditingLog) {
                    if (provider.editingWorkoutId != null) {
                      context.push('/workout/finish/${provider.editingWorkoutId}');
                    }
                  } else {
                    context.read<WorkoutProvider>().pauseTimer();
                    context.push('/workout/finish/new');
                  }
                },
                child: Text(
                  widget.isEditing ? 'Save' : (widget.isEditingLog ? 'Save Updates' : 'Finish'), 
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)
                ),
              ),
            ],
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                Column(
                  children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: WorkoutStatsPanel(
                      duration: widget.isEditing ? '--' : provider.formattedTime,
                      totalVolume: provider.totalVolume,
                      totalSets: provider.totalSets,
                    ),
                  ),
                  Expanded(
                    child: provider.exercises.isEmpty
                        ? Center(
                            child: PrimaryButton(
                              label: 'Add First Exercise',
                              icon: LucideIcons.plus,
                              onPressed: () async {
                                final existingNames = provider.exercises.map((e) => e.name).toList();
                                final result = await context.push<Object?>(
                                  '/workout/add', 
                                  extra: {
                                    'isMultiSelect': true,
                                    'initialSelectedExercises': existingNames,
                                  },
                                );
                                if (result != null) {
                                  if (result is List<String>) {
                                    provider.addExercises(result);
                                  } else if (result is String) {
                                    provider.addExercise(result);
                                  }
                                }
                              },
                            ),
                          )
                        : ReorderableListView(
                            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
                            onReorder: provider.reorderExercise,
                            footer: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: PrimaryButton(
                                label: 'Add Exercise',
                                icon: LucideIcons.plus,
                                onPressed: () async {
                                  final existingNames = provider.exercises.map((e) => e.name).toList();
                                  final result = await context.push<Object?>(
                                    '/workout/add', 
                                    extra: {
                                      'isMultiSelect': true,
                                      'initialSelectedExercises': existingNames,
                                    },
                                  );
                                  if (result != null) {
                                    if (result is List<String>) {
                                      provider.addExercises(result);
                                    } else if (result is String) {
                                      provider.addExercise(result);
                                    }
                                  }
                                },
                              ),
                            ),
                            children: provider.exercises.asMap().entries.map((entry) {
                              final index = entry.key;
                              final exercise = entry.value;
                              return Padding(
                                key: ValueKey(exercise.id),
                                padding: const EdgeInsets.only(bottom: 16),
                                child: ExerciseListItem(
                                  exercise: exercise,
                                  exerciseIndex: index,
                                  previousSets: provider.previousSets[exercise.name] ?? [],
                                  hasPR: provider.getExerciseHasPR(exercise.name),
                                  restTime: provider.getRestTime(exercise.name),
                                  provider: provider,
                                  onRestTimeTap: () => _showRestTimePicker(context, provider, exercise.name),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                  ],
                ),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: RestTimerOverlay(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRestTimePicker(BuildContext context, WorkoutProvider provider, String exerciseId) {
    final currentSeconds = provider.getRestTime(exerciseId);
    final options = <int>[0];
    for (int i = 15; i <= 300; i += 15) {
      options.add(i);
    }

    int selectedIndex = options.indexOf(currentSeconds);
    if (selectedIndex == -1) selectedIndex = 0;

    if (Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => Container(
          height: 250,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                CupertinoNavigationBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  border: null,
                  leading: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  middle: Text('Rest Timer', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                  trailing: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Done'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 32,
                    scrollController: FixedExtentScrollController(initialItem: selectedIndex),
                    onSelectedItemChanged: (index) {
                      provider.setRestTime(exerciseId, options[index]);
                    },
                    children: options.map((seconds) {
                      return Center(
                        child: Text(
                          seconds == 0 ? 'Off' : _formatRestTime(seconds),
                          style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Rest Timer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final seconds = options[index];
                    final isSelected = seconds == currentSeconds;
                    return ListTile(
                      title: Text(seconds == 0 ? 'Off' : _formatRestTime(seconds)),
                      trailing: isSelected ? Icon(LucideIcons.check, color: Theme.of(context).colorScheme.primary) : null,
                      onTap: () {
                        provider.setRestTime(exerciseId, seconds);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    }
  }

  String _formatRestTime(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return remainingSeconds > 0 ? '$minutes min $remainingSeconds s' : '$minutes min';
  }
}
