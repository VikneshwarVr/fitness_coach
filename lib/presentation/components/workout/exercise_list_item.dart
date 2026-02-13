import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme.dart';
import '../../../data/models/workout.dart';
import '../../../data/providers/workout_provider.dart';
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
    return FitnessCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(exercise.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (hasPR) ...[
                    const SizedBox(width: 8),
                    const Icon(LucideIcons.medal, size: 20, color: Color(0xFFFFD700)),
                  ],
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.moreVertical, size: 20, color: AppTheme.mutedForeground),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(
                      LucideIcons.timer, 
                      size: 20, 
                      color: restTime > 0 ? AppTheme.primary : AppTheme.mutedForeground
                    ),
                    onPressed: onRestTimeTap,
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
                        decoration: const BoxDecoration(
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
                          provider.updateSet(exerciseIndex, setIndex, weight: weight);
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
                          provider.updateSet(exerciseIndex, setIndex, reps: reps);
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
                        provider.toggleSetCompletion(exerciseIndex, setIndex);
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
              onPressed: () => provider.addSet(exerciseIndex),
            ),
          ),
        ],
      ),
    );
  }
}
