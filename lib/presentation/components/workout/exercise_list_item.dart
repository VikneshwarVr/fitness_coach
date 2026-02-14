import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../data/models/workout.dart';
import '../../../data/providers/workout_provider.dart';
import '../../../data/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../fitness_card.dart';

class ExerciseListItem extends StatelessWidget {
  final ExerciseSession exercise;
  final int exerciseIndex;
  final List<ExerciseSet> previousSets;
  final bool hasPR;
  final int restTime;
  final WorkoutProvider provider;
  final VoidCallback onRestTimeTap;

  const ExerciseListItem({
    super.key,
    required this.exercise,
    required this.exerciseIndex,
    required this.previousSets,
    required this.hasPR,
    required this.restTime,
    required this.provider,
    required this.onRestTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.read<SettingsProvider>();
    final unit = settingsProvider.unitLabel;

    return FitnessCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(LucideIcons.gripVertical, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        exercise.name, 
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasPR) ...[
                      const SizedBox(width: 8),
                      const Icon(LucideIcons.medal, size: 20, color: Color(0xFFFFD700)),
                    ],
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(LucideIcons.moreVertical, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    onPressed: () {},
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                  IconButton(
                    icon: Icon(
                      LucideIcons.timer, 
                      size: 20, 
                      color: restTime > 0 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant
                    ),
                    onPressed: onRestTimeTap,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                SizedBox(width: 40, child: Text('Set', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12), textAlign: TextAlign.center)),
                Expanded(child: Text('Previous', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12), textAlign: TextAlign.center)),
                if (exercise.category == 'Cardio') ...[
                  Expanded(child: Text('KM', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12), textAlign: TextAlign.center)),
                  Expanded(child: Text('Time', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12), textAlign: TextAlign.center)),
                ] else if (exercise.category == 'Timed') ...[
                  Expanded(flex: 2, child: Text('Time', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12), textAlign: TextAlign.center)),
                ] else if (exercise.category == 'Bodyweight') ...[
                  Expanded(flex: 2, child: Text('Reps', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12), textAlign: TextAlign.center)),
                ] else if (exercise.category == 'Distance') ...[
                  Expanded(flex: 2, child: Text('KM', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12), textAlign: TextAlign.center)),
                ] else if (exercise.category == 'DistanceMeters') ...[
                  Expanded(flex: 2, child: Text('Meters', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12), textAlign: TextAlign.center)),
                ] else if (exercise.category == 'WeightedDistanceMeters') ...[
                  Expanded(child: Text(unit, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12), textAlign: TextAlign.center)),
                  Expanded(child: Text('Meters', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12), textAlign: TextAlign.center)),
                ] else if (exercise.category == 'DistanceTimeMeters') ...[
                   Expanded(child: Text('Meters', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12), textAlign: TextAlign.center)),
                   Expanded(child: Text('Time', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12), textAlign: TextAlign.center)),
                ] else ...[
                  Expanded(child: Text(unit, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12), textAlign: TextAlign.center)),
                  Expanded(child: Text('Reps', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12), textAlign: TextAlign.center)),
                ],
                const SizedBox(width: 40),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Set Rows
          ...exercise.sets.asMap().entries.map((entry) {
            final setIndex = entry.key;
            final set = entry.value;
            final prev = setIndex < previousSets.length ? previousSets[setIndex] : null;
            
            return Dismissible(
              key: ValueKey(set.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => provider.removeSet(exercise.id, set.id),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(LucideIcons.trash2, color: Colors.red, size: 20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Row(
                  children: [
                    // Set Number
                    SizedBox(
                      width: 40,
                      child: Center(
                        child: Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: Text('${setIndex + 1}', style: const TextStyle(fontSize: 12)),
                        ),
                      ),
                    ),
                    // Previous
                    Expanded(
                      child: Text(
                        _formatPrevious(prev, settingsProvider),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ),
                    // KG / KM / Hide for Timed/Bodyweight
                    if (exercise.category != 'Timed' && exercise.category != 'Bodyweight' && exercise.category != 'Distance' && exercise.category != 'DistanceMeters')
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: TextFormField(
                            key: ValueKey('${(exercise.category == 'Cardio' || exercise.category == 'DistanceTimeMeters') ? 'dist' : 'weight'}_${set.id}'),
                            initialValue: _getInitialValue(set, settingsProvider),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                              border: const OutlineInputBorder(borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              isDense: true,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                            onChanged: (val) {
                              if (exercise.category == 'Cardio' || exercise.category == 'DistanceTimeMeters') {
                                final dist = double.tryParse(val) ?? 0.0;
                                provider.updateSet(exercise.id, set.id, distance: dist);
                              } else {
                                final weightValue = double.tryParse(val) ?? 0;
                                final weightInKg = settingsProvider.convertToKg(weightValue).round();
                                provider.updateSet(exercise.id, set.id, weight: weightInKg);
                              }
                            },
                          ),
                        ),
                      )
                    else if (exercise.category == 'Distance' || exercise.category == 'DistanceMeters')
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: TextFormField(
                            key: ValueKey('dist_only_${set.id}'),
                            initialValue: _getInitialValue(set, settingsProvider),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                              border: const OutlineInputBorder(borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              isDense: true,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                            onChanged: (val) {
                              final dist = double.tryParse(val) ?? 0.0;
                              provider.updateSet(exercise.id, set.id, distance: dist);
                            },
                          ),
                        ),
                      ),
                    // Reps / Time / Sec Distance
                    if (exercise.category != 'Distance' && exercise.category != 'DistanceMeters')
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: (exercise.category == 'Timed' || exercise.category == 'Cardio' || exercise.category == 'DistanceTimeMeters')
                            ? Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _showDurationPicker(context, set),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(4),
                                          border: provider.activeTimingSetId == set.id 
                                            ? Border.all(color: AppTheme.primary, width: 1.5) 
                                            : null,
                                        ),
                                        child: Text(
                                          _getTimeOrRepsInitialValue(set).isEmpty ? '0:00' : _getTimeOrRepsInitialValue(set),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: provider.activeTimingSetId == set.id ? FontWeight.bold : FontWeight.normal,
                                            color: provider.activeTimingSetId == set.id ? AppTheme.primary : null,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (exercise.category == 'Timed') ...[
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: Icon(
                                          provider.activeTimingSetId == set.id ? LucideIcons.stopCircle : LucideIcons.playCircle,
                                          size: 24,
                                          color: provider.activeTimingSetId == set.id ? Colors.red : AppTheme.primary,
                                        ),
                                        onPressed: () => provider.toggleSetTimer(exercise.id, set.id),
                                      ),
                                    ),
                                  ],
                                ],
                              )
                            : TextFormField(
                                key: ValueKey('${exercise.category == 'WeightedDistanceMeters' ? 'dist' : 'reps'}_${set.id}'),
                                initialValue: _getInitialValueForSecondColumn(set),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  isDense: true,
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14),
                                onChanged: (val) {
                                  if (exercise.category == 'WeightedDistanceMeters') {
                                    final dist = double.tryParse(val) ?? 0.0;
                                    provider.updateSet(exercise.id, set.id, distance: dist);
                                  } else {
                                    final reps = int.tryParse(val) ?? 0;
                                    provider.updateSet(exercise.id, set.id, reps: reps);
                                  }
                                },
                              ),
                        ),
                      ),
                    // Completion Toggle
                    SizedBox(
                      width: 40,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          set.completed ? LucideIcons.checkSquare : LucideIcons.square,
                          color: set.completed ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        onPressed: () {
                          provider.toggleSetCompletion(exercise.id, set.id);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Add Set'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              ),
              onPressed: () => provider.addSet(exerciseIndex),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitialValueForSecondColumn(ExerciseSet set) {
    if (exercise.category == 'WeightedDistanceMeters') {
      return (set.distance ?? 0.0) > 0 ? (set.distance!).toStringAsFixed(1) : '';
    }
    return set.reps > 0 ? '${set.reps}' : '';
  }

  String _formatPrevious(ExerciseSet? prev, SettingsProvider settings) {
    if (prev == null) return '-';
    if (exercise.category == 'Cardio') {
      final dist = prev.distance ?? 0.0;
      final time = _formatDuration(prev.durationSeconds ?? 0);
      return '${dist.toStringAsFixed(1)}km × $time';
    } else if (exercise.category == 'Timed') {
      return _formatDuration(prev.durationSeconds ?? 0);
    } else if (exercise.category == 'Bodyweight') {
      return '${prev.reps} reps';
    } else if (exercise.category == 'Distance') {
      return '${(prev.distance ?? 0.0).toStringAsFixed(1)}km';
    } else if (exercise.category == 'DistanceMeters') {
      return '${(prev.distance ?? 0.0).toStringAsFixed(1)}m';
    } else if (exercise.category == 'WeightedDistanceMeters') {
      return '${settings.formatWeight(prev.weight)} × ${(prev.distance ?? 0.0).toStringAsFixed(1)}m';
    } else if (exercise.category == 'DistanceTimeMeters') {
      final time = _formatDuration(prev.durationSeconds ?? 0);
      return '${(prev.distance ?? 0.0).toStringAsFixed(1)}m × $time';
    }
    return '${settings.formatWeight(prev.weight)} × ${prev.reps}';
  }

  String _getInitialValue(ExerciseSet set, SettingsProvider settings) {
    if (exercise.category == 'Cardio' || exercise.category == 'Distance' || 
        exercise.category == 'DistanceMeters' || exercise.category == 'DistanceTimeMeters') {
      return (set.distance ?? 0.0) > 0 ? set.distance!.toStringAsFixed(1) : '';
    } else if (exercise.category == 'Timed' || exercise.category == 'Bodyweight') {
      return ''; // Not used for these categories
    }
    return set.weight > 0 ? settings.formatWeight(set.weight, showUnit: false) : '';
  }

  String _getTimeOrRepsInitialValue(ExerciseSet set) {
    if (exercise.category == 'Cardio' || exercise.category == 'Timed' || 
        exercise.category == 'DistanceTimeMeters') {
      return (set.durationSeconds ?? 0) > 0 ? _formatDuration(set.durationSeconds!) : '';
    }
    return set.reps > 0 ? '${set.reps}' : '';
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '0:00';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _showDurationPicker(BuildContext context, ExerciseSet set) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    'Set Duration',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hms,
                  initialTimerDuration: Duration(seconds: set.durationSeconds ?? 0),
                  onTimerDurationChanged: (duration) {
                    provider.updateSet(exercise.id, set.id, durationSeconds: duration.inSeconds);
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
