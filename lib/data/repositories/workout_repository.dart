import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../models/workout.dart';
import '../../core/utils/stats_utils.dart';

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

  Map<String, double> getMuscleGroupStats(bool isWeekly) {
    return StatsUtils.getMuscleGroupDistribution(_workouts, isWeekly: isWeekly);
  }

  List<double> getRadarStats(bool isWeekly) {
    return StatsUtils.getRadarStats(_workouts, isWeekly: isWeekly);
  }

  List<Map<String, dynamic>> getAggregatedStats(bool isWeekly, String metric) {
    return StatsUtils.getAggregatedStats(_workouts, isWeekly: isWeekly, metric: metric);
  }

  Map<String, double> getExercisePRs(String exerciseName) {
    double heaviestWeight = 0;
    double best1RM = 0;
    double bestSetVolume = 0;
    double bestSessionVolume = 0;

    for (var workout in _workouts) {
      double currentSessionVolume = 0;
      bool hasExercise = false;

      for (var session in workout.exercises) {
        if (session.name.trim().toLowerCase() == exerciseName.trim().toLowerCase()) {
          hasExercise = true;
          for (var set in session.sets) {
            if (set.completed) {
              if (set.weight.toDouble() > heaviestWeight) heaviestWeight = set.weight.toDouble();
              
              double setVolume = (set.weight * set.reps).toDouble();
              if (setVolume > bestSetVolume) bestSetVolume = setVolume;
              
              // Epley formula: weight * (1 + reps / 30.0)
              double oneRM = set.weight * (1 + set.reps / 30.0);
              if (oneRM > best1RM) best1RM = oneRM;
              
              currentSessionVolume += setVolume;
            }
          }
        }
      }
      
      if (hasExercise && currentSessionVolume > bestSessionVolume) {
        bestSessionVolume = currentSessionVolume;
      }
    }

    return {
      'heaviestWeight': heaviestWeight,
      'best1RM': best1RM,
      'bestSetVolume': bestSetVolume,
      'bestSessionVolume': bestSessionVolume,
    };
  }

  List<ExerciseSet> getPreviousSets(String exerciseName) {
    // Sort workouts by date descending
    final sortedWorkouts = List<Workout>.from(_workouts)
      ..sort((a, b) => b.date.compareTo(a.date));

    for (var workout in sortedWorkouts) {
      for (var session in workout.exercises) {
        if (session.name.trim().toLowerCase() == exerciseName.trim().toLowerCase()) {
          // Found the most recent session for this exercise
          return session.sets;
        }
      }
    }
    return [];
  }
}
