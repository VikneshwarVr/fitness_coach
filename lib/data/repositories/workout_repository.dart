import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workout.dart';
import '../../core/utils/stats_utils.dart';

class WorkoutRepository extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<Workout> _workouts = [];

  List<Workout> get workouts => _workouts;

  Future<String?> uploadWorkoutPhoto(String localPath) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return null;
      }

      final file = File(localPath);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$userId/$fileName'; // Simplified path if needed, or keep workouts/

      // Upload to bucket
      await _supabase.storage
          .from('post_workout_images')
          .upload(path, file);
      
      // Get public URL
      final publicUrl = _supabase.storage
          .from('post_workout_images')
          .getPublicUrl(path);
      
      return publicUrl;
    } catch (e) {
      return null;
    }
  }

  // Cached backend stats
  int _workoutsThisWeek = 0;
  int _totalVolumeStats = 0;
  int _streak = 0;

  Future<void> loadWorkouts() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = await _supabase
          .from('workouts')
          .select('*, workout_exercises(*, workout_sets(*))')
          .eq('user_id', userId)
          .order('date', ascending: false);
      
      _workouts = (data as List).map((workoutJson) {
        final exercises = (workoutJson['workout_exercises'] as List).map((excJson) {
          final sets = (excJson['workout_sets'] as List).map((setJson) {
            return ExerciseSet(
              id: setJson['id'].toString(),
              weight: setJson['weight']?.toInt() ?? 0,
              reps: setJson['reps']?.toInt() ?? 0,
              completed: setJson['completed'] ?? false,
            );
          }).toList();
          
          return ExerciseSession(
            id: excJson['id'].toString(),
            exerciseId: excJson['id'].toString(),
            name: excJson['exercise_name'],
            sets: sets,
          );
        }).toList();

        return Workout(
          id: workoutJson['id'].toString(),
          name: workoutJson['name'],
          date: DateTime.parse(workoutJson['date']),
          duration: workoutJson['duration'],
          totalVolume: workoutJson['total_volume'],
          photoUrl: workoutJson['photo_url'],
          exercises: exercises,
        );
      }).toList();

      // Refresh overview stats locally
      _calculateOverviewStats();

      notifyListeners();
    } catch (e) {
    }
  }

  Future<void> addWorkout(Workout workout) async {
    try {
      // 1. Insert workout
      final response = await _supabase.from('workouts').insert({
        'name': workout.name,
        'date': workout.date.toIso8601String(),
        'duration': workout.duration,
        'total_volume': workout.totalVolume,
        'photo_url': workout.photoUrl,
        'user_id': _supabase.auth.currentUser?.id,
      }).select().single();

      final workoutId = response['id'];

      // 2. Insert exercises and sets
      for (var i = 0; i < workout.exercises.length; i++) {
        final exc = workout.exercises[i];
        final excResponse = await _supabase.from('workout_exercises').insert({
          'workout_id': workoutId,
          'exercise_name': exc.name,
          'order_index': i,
        }).select().single();

        final excId = excResponse['id'];

        if (exc.sets.isNotEmpty) {
          await _supabase.from('workout_sets').insert(
            exc.sets.asMap().entries.map((entry) => {
              'workout_exercise_id': excId,
              'weight': entry.value.weight,
              'reps': entry.value.reps,
              'completed': entry.value.completed,
              'order_index': entry.key,
            }).toList(),
          );
        }
      }

      await loadWorkouts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateWorkout(Workout workout) async {
    try {
      // 1. Update workout header
      await _supabase.from('workouts').update({
        'name': workout.name,
        'date': workout.date.toIso8601String(),
        'duration': workout.duration,
        'total_volume': workout.totalVolume,
        'photo_url': workout.photoUrl,
      }).eq('id', workout.id);

      // 2. Delete existing exercises (cascade should handle sets if configured, else delete sets first)
      await _supabase.from('workout_exercises').delete().eq('workout_id', workout.id);

      // 3. Re-insert (same as addWorkout logic)
      for (var i = 0; i < workout.exercises.length; i++) {
        final exc = workout.exercises[i];
        final excResponse = await _supabase.from('workout_exercises').insert({
          'workout_id': workout.id,
          'exercise_name': exc.name,
          'order_index': i,
        }).select().single();

        final excId = excResponse['id'];

        if (exc.sets.isNotEmpty) {
          await _supabase.from('workout_sets').insert(
            exc.sets.asMap().entries.map((entry) => {
              'workout_exercise_id': excId,
              'weight': entry.value.weight,
              'reps': entry.value.reps,
              'completed': entry.value.completed,
              'order_index': entry.key,
            }).toList(),
          );
        }
      }

      await loadWorkouts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteWorkout(String id) async {
    try {
      await _supabase.from('workouts').delete().eq('id', id);
      _workouts.removeWhere((w) => w.id == id);
      _calculateOverviewStats();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Stats helpers
  int get workoutsThisWeek => _workoutsThisWeek;
  int get totalVolume => _totalVolumeStats > 0 ? _totalVolumeStats : _workouts.fold(0, (sum, w) => sum + w.totalVolume);
  int get streak => _streak;

  void _calculateOverviewStats() {
    if (_workouts.isEmpty) {
      _workoutsThisWeek = 0;
      _totalVolumeStats = 0;
      _streak = 0;
      return;
    }

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfMonday = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    _workoutsThisWeek = _workouts.where((w) => w.date.isAfter(startOfMonday) || w.date.isAtSameMomentAs(startOfMonday)).length;
    _totalVolumeStats = _workouts.fold(0, (sum, w) => sum + w.totalVolume);
    _streak = _computeStreak(_workouts.map((w) => w.date).toList());
  }

  int _computeStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;
    
    final normalizedDates = dates.map((d) => DateTime(d.year, d.month, d.day)).toSet().toList();
    normalizedDates.sort((a, b) => b.compareTo(a)); // Descending

    int streak = 0;
    DateTime current = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    // If no workout today, check if there was one yesterday to keep streak alive
    if (!normalizedDates.contains(current)) {
      current = current.subtract(const Duration(days: 1));
    }

    while (normalizedDates.contains(current)) {
      streak++;
      current = current.subtract(const Duration(days: 1));
    }

    return streak;
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

  List<Workout> _filterWorkoutsByRange(List<Workout> workouts, String range) {
    final now = DateTime.now();
    final limit = range == 'month' 
        ? now.subtract(const Duration(days: 30))
        : now.subtract(const Duration(days: 7));
    return workouts.where((w) => w.date.isAfter(limit)).toList();
  }

  /// Fetch PRs for a specific exercise directly from Supabase
  Future<Map<String, double>> getExercisePRs(String exerciseName) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return {
      'heaviestWeight': 0.0,
      'best1RM': 0.0,
      'bestSetVolume': 0.0,
      'bestSessionVolume': 0.0,
    };

    try {
      final data = await _supabase
          .from('exercise_prs')
          .select()
          .eq('user_id', userId)
          .eq('exercise_name', exerciseName)
          .maybeSingle();

      if (data == null) {
        return {
          'heaviestWeight': 0.0,
          'best1RM': 0.0,
          'bestSetVolume': 0.0,
          'bestSessionVolume': 0.0,
        };
      }

      return {
        'heaviestWeight': (data['heaviest_weight'] as num?)?.toDouble() ?? 0.0,
        'best1RM': (data['best_1rm'] as num?)?.toDouble() ?? 0.0,
        'bestSetVolume': (data['best_set_volume'] as num?)?.toDouble() ?? 0.0,
        'bestSessionVolume': (data['best_session_volume'] as num?)?.toDouble() ?? 0.0,
      };
    } catch (e) {
      return {
        'heaviestWeight': 0.0,
        'best1RM': 0.0,
        'bestSetVolume': 0.0,
        'bestSessionVolume': 0.0,
      };
    }
  }

  Future<List<ExerciseSet>> getPreviousSets(String exerciseName) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      // Find the last workout exercise with this name
      final data = await _supabase
          .from('workout_exercises')
          .select('*, workout_sets(*), workouts!inner(date, user_id)')
          .eq('workouts.user_id', userId)
          .eq('exercise_name', exerciseName)
          .order('workouts(date)', ascending: false)
          .limit(1)
          .maybeSingle();

      if (data == null) return [];

      final setsJson = data['workout_sets'] as List<dynamic>? ?? [];
      return setsJson.map((setJson) {
        return ExerciseSet(
          id: setJson['id'].toString(),
          weight: setJson['weight']?.toInt() ?? 0,
          reps: setJson['reps']?.toInt() ?? 0,
          completed: setJson['completed'] ?? false,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
