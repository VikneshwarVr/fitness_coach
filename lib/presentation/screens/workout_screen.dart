
import 'dart:io';
import 'package:flutter/cupertino.dart';
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
  final bool isEditing; // For editing routines
  final bool isEditingLog; // For editing past workouts

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
  @override
  void initState() {
    super.initState();
    // Schedule the start after the frame to avoid build conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WorkoutProvider>();
      
      // Listen for PR events
      provider.prEvents.listen((event) {
        if (!mounted) return;
        _showTopPRNotification(context, event);
      });

      if (widget.isEditing && widget.initialRoutine != null) {
         provider.loadRoutineForEditing(widget.initialRoutine!);
      } else if (widget.isEditingLog) {
         // Do nothing, assume provider is already loaded with workout data
      } else {
        // Only start if not active, or if we explicitly passed a routine to start
        if (!provider.isWorkoutActive || widget.initialRoutine != null) {
           if (widget.initialRoutine != null || !provider.isWorkoutActive) {
               provider.startWorkout(routine: widget.initialRoutine);
           }
        }
      }
    });
  }

  void _showTopPRNotification(BuildContext context, PREvent event) {
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        return _TopNotification(
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
                 if (widget.isEditing) {
                   // Just pop without result
                   context.pop();
                 } else if (widget.isEditingLog) {
                   context.pop();
                 } else {
                   // TODO: Prompt to cancel or just saving draft?
                   // For now just back.
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
                    // Return the modified exercises
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
                            child: const Text('Got it', style: TextStyle(color: AppTheme.primary)),
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
                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)
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
                  // Stats Panel - Always Visible (Modified for Editing)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: FitnessCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatItem(
                              icon: LucideIcons.clock,
                              label: 'Duration',
                              value: widget.isEditing ? '--' : provider.formattedTime,
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
                  // Exercise List or Empty State
                  Expanded(
                    child: provider.exercises.isEmpty
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
                        : ListView.builder(
                            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100), // Extra padding for timer
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
                              final previousSets = provider.previousSets[exercise.name] ?? [];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: FitnessCard(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(exercise.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                              if (provider.getExerciseHasPR(exercise.name)) ...[
                                                const SizedBox(width: 8),
                                                const Icon(LucideIcons.medal, size: 20, color: Color(0xFFFFD700)), // Gold medal
                                              ],
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(LucideIcons.moreVertical, size: 20, color: AppTheme.mutedForeground),
                                                onPressed: () {}, // Options
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  LucideIcons.timer, 
                                                  size: 20, 
                                                  color: provider.getRestTime(exercise.name) > 0 ? AppTheme.primary : AppTheme.mutedForeground
                                                ),
                                                onPressed: () => _showRestTimePicker(context, provider, exercise.name),
                                              ),
                                            ],
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
                                          3: FlexColumnWidth(),
                                          4: FixedColumnWidth(40),
                                        },
                                        children: [
                                          const TableRow(
                                            children: [
                                              Text('Set', style: TextStyle(color: AppTheme.mutedForeground, fontSize: 12), textAlign: TextAlign.center),
                                              Text('Previous', style: TextStyle(color: AppTheme.mutedForeground, fontSize: 12), textAlign: TextAlign.center),
                                              Text('kg', style: TextStyle(color: AppTheme.mutedForeground, fontSize: 12), textAlign: TextAlign.center),
                                              Text('Reps', style: TextStyle(color: AppTheme.mutedForeground, fontSize: 12), textAlign: TextAlign.center),
                                              SizedBox(),
                                            ],
                                          ),
                                          ...exercise.sets.asMap().entries.map((entry) {
                                            final setIndex = entry.key;
                                            final set = entry.value;
                                            final prev = setIndex < previousSets.length ? previousSets[setIndex] : null;
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
                                                  child: Text(
                                                    prev != null ? '${prev.weight}kg × ${prev.reps}' : '-',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(fontSize: 12, color: AppTheme.mutedForeground),
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
                                                    textInputAction: TextInputAction.done,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(fontSize: 14),
                                                    onChanged: (val) {
                                                      final weight = int.tryParse(val) ?? 0;
                                                      provider.updateSet(index, setIndex, weight: weight);
                                                    },
                                                    onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
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
                                                    textInputAction: TextInputAction.done,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(fontSize: 14),
                                                    onChanged: (val) {
                                                      final reps = int.tryParse(val) ?? 0;
                                                      provider.updateSet(index, setIndex, reps: reps);
                                                    },
                                                    onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
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
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: _RestTimerOverlay(),
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
    
    // Generate options: Off (0), 15s, 30s, ..., 5m (300s)
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
                  middle: const Text('Rest Timer', style: TextStyle(color: AppTheme.foreground)),
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
                          style: const TextStyle(fontSize: 16, color: AppTheme.foreground),
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
      // Android / Other: Simple List Picker via Modal Bottom Sheet
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: const Text('Rest Timer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final seconds = options[index];
                    final isSelected = seconds == currentSeconds;
                    return ListTile(
                      title: Text(seconds == 0 ? 'Off' : _formatRestTime(seconds)),
                      trailing: isSelected ? const Icon(LucideIcons.check, color: AppTheme.primary) : null,
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

class _TopNotification extends StatefulWidget {
  final PREvent event;
  final VoidCallback onDismiss;

  const _TopNotification({required this.event, required this.onDismiss});

  @override
  State<_TopNotification> createState() => _TopNotificationState();
}

class _TopNotificationState extends State<_TopNotification> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SlideTransition(
            position: _offsetAnimation,
            child: Material(
              color: Colors.transparent,
              child: FitnessCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(LucideIcons.trophy, color: AppTheme.primary, size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'New Personal Record!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.foreground,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.event.exerciseName}: ${widget.event.type} - ${widget.event.value.toStringAsFixed(1)}${widget.event.unit}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }
}

class _RestTimerOverlay extends StatelessWidget {
  const _RestTimerOverlay();

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        if (!provider.isRestTimerRunning) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Rest Time',
                style: TextStyle(fontSize: 12, color: AppTheme.mutedForeground, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   IconButton(
                    icon: const Icon(LucideIcons.minus, color: AppTheme.primary),
                    onPressed: () => provider.adjustRestTimer(-15),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 24),
                     child: Text(
                        _formatTime(provider.currentRestSeconds),
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFeatures: [FontFeature.tabularFigures()]),
                      ),
                   ),
                  IconButton(
                    icon: const Icon(LucideIcons.plus, color: AppTheme.primary),
                    onPressed: () => provider.adjustRestTimer(15),
                     style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: provider.stopRestTimer,
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.mutedForeground,
                  ),
                  child: const Text('Skip Rest'),
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: provider.restTimerProgress,
                  backgroundColor: AppTheme.muted,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
