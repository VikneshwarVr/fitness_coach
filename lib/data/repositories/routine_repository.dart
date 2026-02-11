import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/routine.dart';

class RoutineRepository extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  final List<Routine> _defaultRoutines = [
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
    final user = _supabase.auth.currentUser;
    
    // We fetch routines that are NOT custom (defaults in DB if any) OR belong to current user
    try {
      final response = await _supabase
          .from('routines')
          .select('*, routine_exercises(exercise_name)')
          .or('is_custom.eq.false,user_id.eq.${user?.id ?? "null"}');
      
      final List<dynamic> data = response as List<dynamic>;
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
    } catch (e) {
      debugPrint('Error loading routines from Supabase: $e');
    }
  }

  Future<void> addRoutine(Routine routine) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 1. Insert Routine
      final routineResponse = await _supabase.from('routines').insert({
        'id': routine.id,
        'user_id': user.id,
        'name': routine.name,
        'description': routine.description,
        'level': routine.level,
        'duration': routine.duration,
        'is_custom': true,
      }).select().single();

      // 2. Insert Exercises
      final List<Map<String, dynamic>> exercisesData = [];
      for (int i = 0; i < routine.exerciseNames.length; i++) {
        exercisesData.add({
          'routine_id': routineResponse['id'],
          'exercise_name': routine.exerciseNames[i],
          'order_index': i,
        });
      }
      
      await _supabase.from('routine_exercises').insert(exercisesData);
      
      _customRoutines.add(routine);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding routine to Supabase: $e');
    }
  }

  Future<void> deleteRoutine(String id) async {
    try {
      await _supabase.from('routines').delete().eq('id', id);
      _customRoutines.removeWhere((r) => r.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting routine from Supabase: $e');
    }
  }
}
