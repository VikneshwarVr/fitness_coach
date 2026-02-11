import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../models/workout.dart';

class WorkoutRepository extends ChangeNotifier {
  List<Workout> _workouts = [];

  List<Workout> get workouts => _workouts;

  Future<void> loadWorkouts() async {
    try {
      final response = await ApiClient.get('/workouts');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _workouts = data.map((workoutJson) {
          final exercises = (workoutJson['workout_exercises'] as List).map((excJson) {
            final sets = (excJson['workout_sets'] as List).map((setJson) {
              return ExerciseSet(
                id: setJson['id'],
                weight: setJson['weight'],
                reps: setJson['reps'],
                completed: setJson['completed'],
              );
            }).toList();
            
            return ExerciseSession(
              id: excJson['id'],
              exerciseId: excJson['id'],
              name: excJson['exercise_name'],
              sets: sets,
            );
          }).toList();

          return Workout(
            id: workoutJson['id'],
            name: workoutJson['name'],
            date: DateTime.parse(workoutJson['date']),
            duration: workoutJson['duration'],
            totalVolume: workoutJson['total_volume'],
            exercises: exercises,
          );
        }).toList();
        
        notifyListeners();
      } else {
        debugPrint('Error loading workouts: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading workouts: $e');
    }
  }

  Future<void> addWorkout(Workout workout) async {
    try {
      final workoutData = _prepareWorkoutData(workout);
      final response = await ApiClient.post('/workouts', workoutData);

      if (response.statusCode == 201) {
        await loadWorkouts();
      } else {
        debugPrint('Error adding workout: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error adding workout: $e');
      rethrow;
    }
  }

  Future<void> updateWorkout(Workout workout) async {
    try {
      final workoutData = _prepareWorkoutData(workout);
      final response = await ApiClient.put('/workouts/${workout.id}', workoutData);

      if (response.statusCode == 200) {
        await loadWorkouts();
      } else {
        debugPrint('Error updating workout: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error updating workout: $e');
      rethrow;
    }
  }

  Future<void> deleteWorkout(String id) async {
    try {
      final response = await ApiClient.delete('/workouts/$id');

      if (response.statusCode == 204) {
        _workouts.removeWhere((w) => w.id == id);
        notifyListeners();
      } else {
        debugPrint('Error deleting workout: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error deleting workout: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _prepareWorkoutData(Workout workout) {
    return {
      'name': workout.name,
      'date': workout.date.toIso8601String(),
      'duration': workout.duration,
      'total_volume': workout.totalVolume,
      'exercises': workout.exercises.map((exc) => {
        'name': exc.name,
        'sets': exc.sets.map((s) => {
          'weight': s.weight,
          'reps': s.reps,
          'completed': s.completed,
        }).toList(),
      }).toList(),
    };
  }

  // Stats helpers
  int get workoutsThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return _workouts.where((w) => w.date.isAfter(startOfWeek)).length;
  }

  int get totalVolume {
    return _workouts.fold(0, (sum, w) => sum + w.totalVolume);
  }

  int get streak {
    return _workouts.isNotEmpty ? 1 : 0; 
  }
}
