import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/routine.dart';

class RoutineRepository extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  final List<Routine> _defaultRoutines = [
    // ... (same as before - kept hardcoded for defaults)
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

  List<Routine> get defaultRoutines => _defaultRoutines;
  List<Routine> get customRoutines => _customRoutines;
  List<Routine> get routines => [..._defaultRoutines, ..._customRoutines];
  
  Future<void> loadRoutines() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = await _supabase
          .from('routines')
          .select('*, routine_exercises(*)')
          .eq('is_custom', true)
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      _customRoutines = (data as List).map((json) {
        List<RoutineExercise> exercises = [];
        if (json['routine_exercises'] != null) {
          exercises = (json['routine_exercises'] as List).map((e) {
            final setsData = e['sets'] as List? ?? [];
            final sets = setsData.map((s) => RoutineSet(
              id: s['id']?.toString() ?? '',
              weight: s['weight']?.toInt() ?? 0,
              reps: s['reps']?.toInt() ?? 0,
            )).toList();

            return RoutineExercise(
              id: e['id']?.toString() ?? '',
              name: e['exercise_name'] ?? '',
              category: e['category'] ?? 'Strength',
              sets: sets,
            );
          }).toList();
        }

        return Routine(
          id: json['id'].toString(),
          name: json['name'],
          description: json['description'] ?? '',
          exercises: exercises,
          level: json['level'] ?? 'Intermediate',
          duration: json['duration'] ?? 45,
          isCustom: true,
          mode: json['mode'] ?? 'gym',
        );
      }).toList();
      
      notifyListeners();
    } catch (e) {
      // Error logging removed
    }
  }

  Future<void> addRoutine(Routine routine) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // 1. Insert routine
      final response = await _supabase.from('routines').insert({
        'name': routine.name,
        'description': routine.description,
        'level': routine.level,
        'duration': routine.duration,
        'is_custom': true,
        'mode': routine.mode,
        'user_id': userId,
      }).select().single();

      final routineId = response['id'];

      // 2. Insert exercises and their sets
      for (var i = 0; i < routine.exercises.length; i++) {
        final exercise = routine.exercises[i];
        await _supabase.from('routine_exercises').insert({
          'routine_id': routineId,
          'exercise_name': exercise.name,
          'category': exercise.category,
          'order_index': i,
          'sets': exercise.sets.map((s) => s.toJson()).toList(),
        });
      }

      await loadRoutines();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteRoutine(String id) async {
    try {
      // Supabase cascade delete should handle child records if configured in DB
      await _supabase.from('routines').delete().eq('id', id);
      _customRoutines.removeWhere((r) => r.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateRoutine(Routine routine) async {
    try {
      // 1. Update routine header
      await _supabase.from('routines').update({
        'name': routine.name,
        'description': routine.description,
        'level': routine.level,
        'duration': routine.duration,
        'mode': routine.mode,
      }).eq('id', routine.id);

      // 2. Simplify update: Delete current exercises and re-insert 
      // (Alternatively, perform complex diffing)
      await _supabase.from('routine_exercises').delete().eq('routine_id', routine.id);
      
      // 3. Re-insert exercises and sets (same as addRoutine)
      for (var i = 0; i < routine.exercises.length; i++) {
        final exercise = routine.exercises[i];
        await _supabase.from('routine_exercises').insert({
          'routine_id': routine.id,
          'exercise_name': exercise.name,
          'category': exercise.category,
          'order_index': i,
          'sets': exercise.sets.map((s) => s.toJson()).toList(),
        });
      }

      await loadRoutines();
    } catch (e) {
      rethrow;
    }
  }
}


