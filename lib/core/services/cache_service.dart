import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/workout.dart';
import '../../data/models/routine.dart';

class CacheService {
  static const String workoutBoxName = 'workouts';
  static const String routineBoxName = 'routines';
  static const String statsBoxName = 'global_stats';
  static const String profileBoxName = 'user_profile';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(WorkoutAdapter());
    Hive.registerAdapter(ExerciseSessionAdapter());
    Hive.registerAdapter(ExerciseSetAdapter());
    Hive.registerAdapter(RoutineSetAdapter());
    Hive.registerAdapter(RoutineExerciseAdapter());
    Hive.registerAdapter(RoutineAdapter());

    // Open Boxes
    await Hive.openBox<Workout>(workoutBoxName);
    await Hive.openBox<Routine>(routineBoxName);
    await Hive.openBox<Map>(statsBoxName);
    await Hive.openBox<Map>(profileBoxName);
  }

  // Workouts
  static Box<Workout> get workoutBox => Hive.box<Workout>(workoutBoxName);
  
  static List<Workout> getCachedWorkouts() {
    return workoutBox.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  static Future<void> cacheWorkouts(List<Workout> workouts) async {
    final Map<String, Workout> workoutMap = {for (var w in workouts) w.id: w};
    await workoutBox.putAll(workoutMap);
  }

  // Routines
  static Box<Routine> get routineBox => Hive.box<Routine>(routineBoxName);

  static List<Routine> getCachedRoutines() {
    return routineBox.values.toList();
  }

  static Future<void> cacheRoutines(List<Routine> routines) async {
    final Map<String, Routine> routineMap = {for (var r in routines) r.id: r};
    await routineBox.putAll(routineMap);
  }

  // Global Stats (Metadata for calendar/streaks)
  static Box<Map> get statsBox => Hive.box<Map>(statsBoxName);

  static List<Map<String, dynamic>> getCachedStats() {
    return statsBox.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> cacheStats(List<Map<String, dynamic>> stats) async {
    await statsBox.clear();
    final Map<int, Map> statsMap = {for (int i = 0; i < stats.length; i++) i: stats[i]};
    await statsBox.putAll(statsMap);
  }

  // Profile
  static Box<Map> get profileBox => Hive.box<Map>(profileBoxName);

  static Map<String, dynamic>? getCachedProfile() {
    final data = profileBox.get('current_user');
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  static Future<void> cacheProfile(Map<String, dynamic> profile) async {
    await profileBox.put('current_user', profile);
  }

  static Future<void> clearAll() async {
    await workoutBox.clear();
    await routineBox.clear();
    await statsBox.clear();
    await profileBox.clear();
  }
}
