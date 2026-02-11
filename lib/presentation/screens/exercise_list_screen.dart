import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/constants/exercise_data.dart';
import '../components/fitness_card.dart';
import 'exercise_detail_screen.dart';

class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  String _searchQuery = '';
  final List<Map<String, String>> _allExercises = ExerciseData.exercises;

  List<Map<String, String>> get _filteredExercises {
    if (_searchQuery.isEmpty) return _allExercises;
    return _allExercises.where((e) {
      final name = e['name']?.toLowerCase() ?? '';
      final tag = e['tag']?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || tag.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Exercise Library'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search exercises or muscle groups...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.mutedForeground),
                filled: true,
                fillColor: AppTheme.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: const TextStyle(color: AppTheme.foreground),
            ),
          ),
          Expanded(
            child: ListView.builder(
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: AppTheme.foreground,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  exercise['tag'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              exercise['tag'] ?? '',
                              style: const TextStyle(
                                color: AppTheme.primary,
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
