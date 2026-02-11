import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../models/routine.dart';

class RoutineRepository extends ChangeNotifier {
  final List<Routine> _defaultRoutines = [
    // ... (same as before)
    Routine.create(
      name: 'Full Body Power',
      description: 'Compound movements for maximum strength.',
      exerciseNames: ['Squat', 'Bench Press', 'Deadlift', 'Overhead Press', 'Pull Ups'],
      level: 'Advanced',
      duration: 60,
    ),
    Routine.create(
      name: 'Upper Body Hypertrophy',
      description: 'Focus on chest, back, and arms.',
      exerciseNames: ['Bench Press', 'Incline Dumbbell Press', 'Barbell Row', 'Lat Pulldown', 'Bicep Curls', 'Tricep Extensions'],
      level: 'Intermediate',
      duration: 50,
    ),
    Routine.create(
      name: 'Lower Body Focus',
      description: 'Legs and glutes intensive workout.',
      exerciseNames: ['Squat', 'Romanian Deadlift', 'Leg Press', 'Lunges', 'Calf Raises'],
      level: 'Intermediate',
      duration: 55,
    ),
    Routine.create(
      name: 'Core Blaster',
      description: 'Quick core workout for stability.',
      exerciseNames: ['Plank', 'Crunches', 'Leg Raises', 'Russian Twists'],
      level: 'Beginner',
      duration: 20,
    ),
    Routine.create(
      name: 'Cardio Intervals',
      description: 'HIIT session to burn calories.',
      exerciseNames: ['Jump Rope', 'Burpees', 'Mountain Climbers', 'High Knees'],
      level: 'Beginner',
      duration: 30,
    ),
  ];

  List<Routine> _customRoutines = [];

  List<Routine> get routines => [..._defaultRoutines, ..._customRoutines];
  
  Future<void> loadRoutines() async {
    try {
      final response = await ApiClient.get('/routines');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _customRoutines = data.where((json) => json['is_custom'] == true).map((json) {
          final exercises = (json['routine_exercises'] as List)
              .map((e) => e['exercise_name'] as String)
              .toList();
          
          return Routine(
            id: json['id'],
            name: json['name'],
            description: json['description'] ?? '',
            exerciseNames: exercises,
            level: json['level'] ?? 'Intermediate',
            duration: json['duration'] ?? 45,
            isCustom: true,
          );
        }).toList();
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading routines: $e');
    }
  }

  Future<void> addRoutine(Routine routine) async {
    try {
      final routineData = {
        'name': routine.name,
        'description': routine.description,
        'level': routine.level,
        'duration': routine.duration,
        'exerciseNames': routine.exerciseNames,
      };

      final response = await ApiClient.post('/routines', routineData);

      if (response.statusCode == 201) {
        await loadRoutines();
      }
    } catch (e) {
      debugPrint('Error adding routine: $e');
    }
  }

  Future<void> deleteRoutine(String id) async {
    try {
      final response = await ApiClient.delete('/routines/$id');
      if (response.statusCode == 204) {
        _customRoutines.removeWhere((r) => r.id == id);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting routine: $e');
    }
  }
}


