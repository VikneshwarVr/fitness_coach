import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/settings_provider.dart';
import '../../data/constants/exercise_data.dart';
import '../components/fitness_card.dart';
import 'exercise_detail_screen.dart';

class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  String _selectedTag = 'All';
  String _searchQuery = '';

  List<String> get _tags {
    final settings = Provider.of<SettingsProvider>(context);
    final exercises = ExerciseData.getExercisesForMode(settings.workoutMode);
    final tags = exercises.map((e) => e['tag']!).toSet().toList();
    tags.sort();
    return ['All', ...tags];
  }

  List<Map<String, String>> get _filteredExercises {
    final settings = Provider.of<SettingsProvider>(context);
    final allExercises = ExerciseData.getExercisesForMode(settings.workoutMode);

    return allExercises.where((e) {
      final matchesTag = _selectedTag == 'All' || e['tag'] == _selectedTag;
      final name = e['name']?.toLowerCase() ?? '';
      final tag = e['tag']?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      final matchesSearch =
          query.isEmpty || name.contains(query) || tag.contains(query);
      return matchesTag && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Library'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: const InputDecoration(
                hintText: 'Search exercises or muscle groups...',
              ),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: _tags.map((tag) {
                final isSelected = _selectedTag == tag;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedTag = tag);
                    },
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                    selectedColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _filteredExercises.isEmpty
                ? Center(
                    child: Text(
                      'No exercises found',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredExercises.length,
              itemBuilder: (context, index) {
                final exercise = _filteredExercises[index];
                final exerciseName = exercise['name'] ?? '';
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExerciseDetailScreen(exerciseName: exerciseName),
                      ),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: FitnessCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exerciseName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  exercise['tag'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              exercise['tag'] ?? '',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

