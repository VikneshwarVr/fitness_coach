import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
                  Icon(LucideIcons.gripVertical, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
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
                    icon: Icon(LucideIcons.moreVertical, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(
                      LucideIcons.timer, 
                      size: 20, 
                      color: restTime > 0 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant
                    ),
                    onPressed: onRestTimeTap,
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
                Expanded(child: Text('kg', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12), textAlign: TextAlign.center)),
                Expanded(child: Text('Reps', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12), textAlign: TextAlign.center)),
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
              onDismissed: (_) => provider.removeSet(exerciseIndex, setIndex),
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
                        prev != null ? '${prev.weight}kg × ${prev.reps}' : '-',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ),
                    // Weight
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: TextFormField(
                          key: ValueKey('weight_${set.id}'),
                          initialValue: set.weight > 0 ? '${set.weight}' : '',
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            border: const OutlineInputBorder(borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                    ),
                    // Reps
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: TextFormField(
                          key: ValueKey('reps_${set.id}'),
                          initialValue: set.reps > 0 ? '${set.reps}' : '',
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            border: const OutlineInputBorder(borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                          provider.toggleSetCompletion(exerciseIndex, setIndex);
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
}
