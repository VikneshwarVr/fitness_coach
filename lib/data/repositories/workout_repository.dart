import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workout.dart';
import '../constants/exercise_data.dart';
import '../../core/utils/stats_utils.dart';
import '../../core/services/cache_service.dart';

class WorkoutRepository extends ChangeNotifier {
  final SupabaseClient _supabase;

  WorkoutRepository([SupabaseClient? client]) : _supabase = client ?? Supabase.instance.client {
    _loadFromCache();
  }

  List<Workout> _workouts = [];
  List<Workout> get workouts => _workouts;

  void _loadFromCache() {
    _workouts = CacheService.getCachedWorkouts();
    _globalWorkoutsForStats = CacheService.getCachedStats();
    if (_workouts.isNotEmpty || _globalWorkoutsForStats.isNotEmpty) {
      _calculateOverviewStats();
    }
  }

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

  // Pagination state
  int _pageSize = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  // Lightweight metadata for ALL workouts (dates, volumes, etc.)
  List<Map<String, dynamic>> _globalWorkoutsForStats = [];
  
  // Cached calculated stats
  int _workoutsThisWeek = 0;
  int _totalVolumeStats = 0;
  int _streak = 0; // Day streak
  int _weekStreak = 0;
  int _restDays = 0;
  Map<String, List<Workout>> _workoutsByDate = {};

  Future<void> loadWorkouts({bool refresh = false}) async {
    if (_isLoadingMore) return;
    
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      if (refresh) {
        _hasMore = true;
        _isLoadingMore = false;
        // Also refresh global stats metadata
        await _loadGlobalStats();
      }

      if (!_hasMore) return;
      
      _isLoadingMore = true;
      if (_workouts.isNotEmpty && refresh) {
         // If refreshing and we have cached data, don't clear yet, just show loading
      } else if (_workouts.isNotEmpty) {
        notifyListeners();
      }

      final from = refresh ? 0 : _workouts.length;
      // For the first load, we fetch more (50) to ensure Stats screens (30 days) are populated accurately.
      final currentBatchSize = (refresh || _workouts.isEmpty) ? 50 : _pageSize;
      final to = from + currentBatchSize - 1;

      final data = await _supabase
          .from('workouts')
          .select('*, workout_exercises(*, workout_sets(*))')
          .eq('user_id', userId)
          .order('date', ascending: false)
          .range(from, to);
      
      final newWorkouts = (data as List).map((workoutJson) {
        final exercises = (workoutJson['workout_exercises'] as List).map((excJson) {
          final sets = (excJson['workout_sets'] as List).map((setJson) {
            return ExerciseSet(
              id: setJson['id'].toString(),
              weight: setJson['weight']?.toInt() ?? 0,
              reps: setJson['reps']?.toInt() ?? 0,
              distance: (setJson['distance'] as num?)?.toDouble(),
              durationSeconds: setJson['duration_seconds']?.toInt(),
              completed: setJson['completed'] ?? false,
            );
          }).toList();
          
          return ExerciseSession(
            id: excJson['id'].toString(),
            exerciseId: excJson['id'].toString(),
            name: excJson['exercise_name'],
            category: ExerciseData.getCategory(excJson['exercise_name']),
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
          mode: workoutJson['mode'] ?? 'gym',
          exercises: exercises,
        );
      }).toList();

      if (newWorkouts.length < currentBatchSize) {
        _hasMore = false;
      }

      if (refresh) {
        _workouts = newWorkouts;
      } else {
        _workouts.addAll(newWorkouts);
      }
      
      // Update Cache
      await CacheService.cacheWorkouts(_workouts);
      
      // Ensure global metadata is loaded (it provides the foundation for all stats/calendar)
      if (_globalWorkoutsForStats.isEmpty || refresh) {
        await _loadGlobalStats();
      }
      
      _calculateOverviewStats();
      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadNextPage() async {
    if (!_hasMore || _isLoadingMore) return;
    await loadWorkouts();
  }

  Future<void> _loadGlobalStats() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Fetch ONLY what's needed for streaks, volume charts, and calendar indicators
      final data = await _supabase
          .from('workouts')
          .select('id, date, total_volume, name, duration')
          .eq('user_id', userId)
          .order('date', ascending: false);
      
      _globalWorkoutsForStats = (data as List).cast<Map<String, dynamic>>();
      
      // Update Cache
      await CacheService.cacheStats(_globalWorkoutsForStats);
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
        'mode': workout.mode,
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
              'distance': entry.value.distance,
              'duration_seconds': entry.value.durationSeconds,
              'completed': entry.value.completed,
              'order_index': entry.key,
            }).toList(),
          );
        }
      }

      await loadWorkouts(refresh: true);
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
        'mode': workout.mode,
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
              'distance': entry.value.distance,
              'duration_seconds': entry.value.durationSeconds,
              'completed': entry.value.completed,
              'order_index': entry.key,
            }).toList(),
          );
        }
      }

      await loadWorkouts(refresh: true);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteWorkout(String id) async {
    try {
      await _supabase.from('workouts').delete().eq('id', id);
      await loadWorkouts(refresh: true);
    } catch (e) {
      rethrow;
    }
  }

  // Stats helpers
  int get workoutsThisWeek => _workoutsThisWeek;
  int get workoutsLast30Days => _globalWorkoutsForStats.where((w) {
    final date = DateTime.parse(w['date']);
    return date.isAfter(DateTime.now().subtract(const Duration(days: 30)));
  }).length;
  
  int get totalVolume => _totalVolumeStats;
  int get streak => _streak;
  int get weekStreak => _weekStreak;
  int get restDays => _restDays;
  Map<String, List<Workout>> get workoutsByDate => _workoutsByDate;
  List<Workout> get allWorkoutsMetadata => _workoutsByDate.values.expand((x) => x).toList();

  // Caches for expensive stats
  final Map<String, List<double>> _radarStatsCache = {};
  final Map<String, List<Map<String, dynamic>>> _aggregatedStatsCache = {};

  List<double> getRadarStats(bool isWeekly) {
    final key = isWeekly ? 'weekly' : 'monthly';
    if (!_radarStatsCache.containsKey(key)) {
      _radarStatsCache[key] = StatsUtils.getRadarStats(_workouts, isWeekly: isWeekly);
    }
    return _radarStatsCache[key]!;
  }

  List<Map<String, dynamic>> getAggregatedStats(bool isWeekly, String metric) {
    final key = '${isWeekly ? 'weekly' : 'monthly'}_$metric';
    if (!_aggregatedStatsCache.containsKey(key)) {
      // Optimization: use global stats for volume chart (complete data)
      if (metric == 'Volume') {
        _aggregatedStatsCache[key] = _getAggregatedVolumeFromGlobal(isWeekly);
      } else {
        _aggregatedStatsCache[key] = StatsUtils.getAggregatedStats(_workouts, isWeekly: isWeekly, metric: metric);
      }
    }
    return _aggregatedStatsCache[key]!;
  }

  List<Map<String, dynamic>> _getAggregatedVolumeFromGlobal(bool isWeekly) {
    final count = isWeekly ? 7 : 4;
    final stats = List.generate(count, (index) => {
      'label': isWeekly ? _getDayLabel(index) : 'Week ${index + 1}',
      'value': 0.0
    });

    final now = DateTime.now();
    final limit = isWeekly ? now.subtract(const Duration(days: 7)) : now.subtract(const Duration(days: 30));

    for (var w in _globalWorkoutsForStats) {
      final date = DateTime.parse(w['date']);
      if (date.isBefore(limit)) continue;

      int index;
      if (isWeekly) {
        index = date.weekday - 1;
      } else {
        final daysAgo = now.difference(date).inDays;
        index = (3 - (daysAgo / 7).floor()).clamp(0, 3);
      }

      final val = (w['total_volume'] as num).toDouble() / 1000.0;
      stats[index]['value'] = (stats[index]['value'] as double) + val;
    }
    return stats;
  }

  String _getDayLabel(int weekdayIndex) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[weekdayIndex];
  }

  void _calculateOverviewStats() {
    _radarStatsCache.clear();
    _aggregatedStatsCache.clear();

    if (_globalWorkoutsForStats.isEmpty) {
      _workoutsThisWeek = 0;
      _totalVolumeStats = 0;
      _streak = 0;
      _weekStreak = 0;
      _restDays = 0;
      _workoutsByDate = {};
      return;
    }

    final now = DateTime.now();
    final todayNormalized = DateTime(now.year, now.month, now.day);
    
    // Map existing loaded workouts for quick lookup
    final Map<String, List<Workout>> loadedWorkoutsMap = {};
    for (var w in _workouts) {
      final key = _getDateKey(w.date);
      loadedWorkoutsMap.putIfAbsent(key, () => []).add(w);
    }

    // Process global stats
    _workoutsByDate = {};
    _totalVolumeStats = 0;
    
    final sortedDates = <DateTime>[];

    for (var w in _globalWorkoutsForStats) {
      final date = DateTime.parse(w['date']);
      final vol = (w['total_volume'] as num?)?.toInt() ?? 0;
      final key = _getDateKey(date);
      
      _totalVolumeStats += vol;
      sortedDates.add(date);

      // Merge real workouts with minimal placeholders
      if (loadedWorkoutsMap.containsKey(key)) {
        _workoutsByDate[key] = loadedWorkoutsMap[key]!;
      } else {
        _workoutsByDate.putIfAbsent(key, () => []).add(
          Workout(
            id: w['id'], 
            name: w['name'] ?? '', 
            date: date, 
            duration: w['duration'] ?? 0, 
            totalVolume: vol, 
            exercises: []
          )
        );
      }
    }

    sortedDates.sort((a, b) => b.compareTo(a));

    // 2. Workouts This Week
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfMonday = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    _workoutsThisWeek = sortedDates.where((d) => d.isAfter(startOfMonday) || d.isAtSameMomentAs(startOfMonday)).length;

    // 3. Day Streak
    _streak = _computeDayStreakFromDates(sortedDates, todayNormalized);

    // 4. Week Streak
    _weekStreak = _computeWeekStreakFromDates(sortedDates, todayNormalized);

    // 5. Rest Days
    final lastWorkoutDate = sortedDates[0];
    final lastWorkoutNormalized = DateTime(lastWorkoutDate.year, lastWorkoutDate.month, lastWorkoutDate.day);
    _restDays = todayNormalized.difference(lastWorkoutNormalized).inDays;
  }

  int _computeDayStreakFromDates(List<DateTime> sortedDates, DateTime todayNormalized) {
    final workoutDates = sortedDates.map((d) => DateTime(d.year, d.month, d.day)).toSet();
    int streak = 0;
    DateTime current = todayNormalized;
    if (!workoutDates.contains(current)) {
      current = current.subtract(const Duration(days: 1));
    }
    while (workoutDates.contains(current)) {
      streak++;
      current = current.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int _computeWeekStreakFromDates(List<DateTime> sortedDates, DateTime todayNormalized) {
    final weeksWithWorkouts = <String, bool>{};
    for (var d in sortedDates) {
      weeksWithWorkouts[_getWeekKey(d)] = true;
    }
    int streak = 0;
    DateTime currentWeekDate = todayNormalized;
    while (true) {
      final weekKey = _getWeekKey(currentWeekDate);
      if (weeksWithWorkouts.containsKey(weekKey)) {
        streak++;
        currentWeekDate = currentWeekDate.subtract(const Duration(days: 7));
      } else {
        break;
      }
    }
    return streak;
  }

  String _getWeekKey(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday % 7));
    return '${startOfWeek.year}-${startOfWeek.month.toString().padLeft(2, '0')}-${startOfWeek.day.toString().padLeft(2, '0')}';
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, double> getMuscleGroupStats(bool isWeekly) {
    return StatsUtils.getMuscleGroupDistribution(_workouts, isWeekly: isWeekly);
  }

  /// Fetch PRs for a specific exercise directly from Supabase
  Future<Map<String, double>> getExercisePRs(String exerciseName) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return {
        'heaviestWeight': 0.0,
        'best1RM': 0.0,
        'bestSetVolume': 0.0,
        'bestSessionVolume': 0.0,
      };
    }

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
        'maxReps': (data['max_reps'] as num?)?.toDouble() ?? 0.0,
        'maxDistance': (data['max_distance'] as num?)?.toDouble() ?? 0.0,
        'maxDuration': (data['max_duration'] as num?)?.toDouble() ?? 0.0,
      };
    } catch (e) {
      return {
        'heaviestWeight': 0.0,
        'best1RM': 0.0,
        'bestSetVolume': 0.0,
        'bestSessionVolume': 0.0,
        'maxReps': 0.0,
        'maxDistance': 0.0,
        'maxDuration': 0.0,
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
          distance: (setJson['distance'] as num?)?.toDouble(),
          durationSeconds: setJson['duration_seconds']?.toInt(),
          completed: setJson['completed'] ?? false,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
