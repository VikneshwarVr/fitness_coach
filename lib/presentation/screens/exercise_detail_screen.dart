import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/providers/settings_provider.dart';
import '../../data/constants/exercise_data.dart';
import '../../data/repositories/workout_repository.dart';
import '../components/fitness_card.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final String exerciseName;

  const ExerciseDetailScreen({super.key, required this.exerciseName});

  @override
  Widget build(BuildContext context) {
    final distribution = ExerciseData.detailedMuscles[exerciseName] ?? {};
    
    // Determine primary and secondary muscles
    String primaryMuscle = 'Unknown';
    List<String> secondaryMuscles = [];
    
    if (distribution.isNotEmpty) {
      final sortedEntries = distribution.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      primaryMuscle = sortedEntries.first.key;
      secondaryMuscles = sortedEntries.skip(1).map((e) => e.key).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(exerciseName),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Muscle Distribution Section
            const Text('Muscles Worked', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            FitnessCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MuscleInfo(
                    label: 'Primary',
                    muscles: [primaryMuscle],
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  if (secondaryMuscles.isNotEmpty) ...[
                    const Divider(height: 24),
                    _MuscleInfo(
                      label: 'Secondary',
                      muscles: secondaryMuscles,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Personal Records Section
            const Text('Personal Records', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Consumer<WorkoutRepository>(
              builder: (context, repo, _) {
                return FutureBuilder<Map<String, double>>(
                  future: repo.getExercisePRs(exerciseName),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final prs = snapshot.data ?? {
                      'heaviestWeight': 0.0,
                      'best1RM': 0.0,
                      'bestSetVolume': 0.0,
                      'bestSessionVolume': 0.0,
                    };

                    final settings = context.read<SettingsProvider>();
                    final label = settings.unitLabel;

                    return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _PRCard(
                          label: 'Heaviest Weight',
                          value: settings.formatWeight(prs['heaviestWeight']!, showUnit: false),
                          unit: label,
                          icon: LucideIcons.dumbbell,
                        ),
                        _PRCard(
                          label: 'Best 1RM',
                          value: settings.formatWeight(prs['best1RM']!, showUnit: false),
                          unit: label,
                          icon: LucideIcons.trophy,
                        ),
                        _PRCard(
                          label: 'Best Set Volume',
                          value: settings.formatWeight(prs['bestSetVolume']!, showUnit: false),
                          unit: label,
                          icon: LucideIcons.barChart,
                        ),
                        _PRCard(
                          label: 'Best Session Volume',
                          value: settings.formatWeight(prs['bestSessionVolume']!, showUnit: false),
                          unit: label,
                          icon: LucideIcons.layers,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _MuscleInfo extends StatelessWidget {
  final String label;
  final List<String> muscles;
  final Color color;

  const _MuscleInfo({
    required this.label,
    required this.muscles,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: muscles.map((m) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Text(
              m,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          )).toList(),
        ),
      ],
    );
  }
}

class _PRCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;

  const _PRCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FitnessCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
