import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../models/workout.dart';
import '../../core/utils/stats_utils.dart';

class WorkoutRepository extends ChangeNotifier {
  List<Workout> _workouts = [];

  List<Workout> get workouts => _workouts;

  // Cached backend stats
  int _workoutsThisWeek = 0;
  int _totalVolumeStats = 0;
  int _streak = 0;

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

        // Also refresh overview stats from backend
        await _loadOverviewStats();

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
    return _workoutsThisWeek;
  }

  int get totalVolume {
    // Prefer backend-computed total if available, fall back to local sum
    if (_totalVolumeStats > 0) return _totalVolumeStats;
    return _workouts.fold(0, (sum, w) => sum + w.totalVolume);
  }

  int get streak {
    return _streak;
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

  Future<void> _loadOverviewStats() async {
    try {
      final response = await ApiClient.get('/stats/overview');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _workoutsThisWeek = data['workoutsThisWeek'] ?? 0;
        _totalVolumeStats = data['totalVolume'] ?? 0;
        _streak = data['streak'] ?? 0;
      } else {
        debugPrint('Error loading overview stats: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading overview stats: $e');
    }
  }

  /// Fetch PRs for a specific exercise from the backend / Supabase
  Future<Map<String, double>> getExercisePRs(String exerciseName) async {
    try {
      final encodedName = Uri.encodeComponent(exerciseName);
      final response = await ApiClient.get('/exercise-prs/$encodedName');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'heaviestWeight': (data['heaviest_weight'] as num?)?.toDouble() ?? 0.0,
          'best1RM': (data['best_1rm'] as num?)?.toDouble() ?? 0.0,
          'bestSetVolume': (data['best_set_volume'] as num?)?.toDouble() ?? 0.0,
          'bestSessionVolume': (data['best_session_volume'] as num?)?.toDouble() ?? 0.0,
        };
      } else if (response.statusCode == 404) {
        // No PRs yet for this exercise
        return {
          'heaviestWeight': 0.0,
          'best1RM': 0.0,
          'bestSetVolume': 0.0,
          'bestSessionVolume': 0.0,
        };
      } else {
        debugPrint('Error fetching exercise PRs: ${response.statusCode}');
        return {
          'heaviestWeight': 0.0,
          'best1RM': 0.0,
          'bestSetVolume': 0.0,
          'bestSessionVolume': 0.0,
        };
      }
    } catch (e) {
      debugPrint('Error fetching exercise PRs: $e');
      return {
        'heaviestWeight': 0.0,
        'best1RM': 0.0,
        'bestSetVolume': 0.0,
        'bestSessionVolume': 0.0,
      };
    }
  }

  Future<List<ExerciseSet>> getPreviousSets(String exerciseName) async {
    try {
      final encoded = Uri.encodeComponent(exerciseName);
      final response = await ApiClient.get('/exercises/$encoded/last-session');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final setsJson = data['sets'] as List<dynamic>? ?? [];
        return setsJson.map((setJson) {
          return ExerciseSet(
            id: setJson['id'] ?? '',
            weight: setJson['weight'] ?? 0,
            reps: setJson['reps'] ?? 0,
            completed: setJson['completed'] ?? false,
          );
        }).toList();
      } else {
        debugPrint('No previous sets from backend: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching previous sets: $e');
      return [];
    }
  }
}
