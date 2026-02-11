import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workout.dart';

class WorkoutRepository extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<Workout> _workouts = [];

  List<Workout> get workouts => _workouts;

  Future<void> loadWorkouts() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await _supabase
          .from('workouts')
          .select('*, workout_exercises(*, workout_sets(*))')
          .eq('user_id', user.id)
          .order('date', ascending: false);
      
      final List<dynamic> data = response as List<dynamic>;
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
            exerciseId: excJson['id'], // We don't have a separate exercise meta ID yet
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
    } catch (e) {
      debugPrint('Error loading workouts from Supabase: $e');
    }
  }

  Future<void> addWorkout(Workout workout) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return;
    }

    try {
      // 1. Insert Workout
      final workoutData = await _supabase.from('workouts').insert({
        'id': workout.id,
        'user_id': user.id,
        'name': workout.name,
        'date': workout.date.toIso8601String(),
        'duration': workout.duration,
        'total_volume': workout.totalVolume,
      }).select().single();

      // 2. Insert Exercises & Sets
      for (int i = 0; i < workout.exercises.length; i++) {
        final exercise = workout.exercises[i];
        final exerciseData = await _supabase.from('workout_exercises').insert({
          'id': exercise.id,
          'workout_id': workoutData['id'],
          'exercise_name': exercise.name,
          'order_index': i,
        }).select().single();

        final setsData = exercise.sets.asMap().entries.map((entry) {
          final index = entry.key;
          final set = entry.value;
          return {
            'workout_exercise_id': exerciseData['id'],
            'weight': set.weight,
            'reps': set.reps,
            'completed': set.completed,
            'order_index': index,
          };
        }).toList();

        await _supabase.from('workout_sets').insert(setsData);
      }

      _workouts.insert(0, workout);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding workout to Supabase: $e');
      rethrow;
    }
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
