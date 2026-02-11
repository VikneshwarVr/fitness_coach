import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/workout.dart';
import '../models/routine.dart';
import '../repositories/workout_repository.dart';

class WorkoutProvider extends ChangeNotifier {
  final WorkoutRepository _workoutRepository;
  final _uuid = const Uuid();
  
  // State
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isPlaying = false;
  bool _isWorkoutActive = false;
  String _workoutName = 'Evening Workout';
  final List<ExerciseSession> _exercises = [];
  
  // Cached stats (recalculated only when sets are completed/uncompleted)
  int _cachedTotalVolume = 0;
  int _cachedTotalSets = 0;

  // Getters
  int get secondsElapsed => _secondsElapsed;
  bool get isPlaying => _isPlaying;
  bool get isWorkoutActive => _isWorkoutActive;
  String get workoutName => _workoutName;
  List<ExerciseSession> get exercises => List.unmodifiable(_exercises);

  int get totalVolume => _cachedTotalVolume;
  int get totalSets => _cachedTotalSets;

  void _recalculateStats() {
    int volume = 0;
    int sets = 0;
    for (var ex in _exercises) {
      for (var set in ex.sets) {
        if (set.completed) {
          volume += (set.weight * set.reps);
          sets++;
        }
      }
    }
    _cachedTotalVolume = volume;
    _cachedTotalSets = sets;
  }

  String get formattedTime {
    final minutes = (_secondsElapsed / 60).floor().toString().padLeft(2, '0');
    final seconds = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  WorkoutProvider(this._workoutRepository);

  // Actions
  void startWorkout({Routine? routine}) {
    if (_isWorkoutActive) return;

    _resetState();
    _isWorkoutActive = true;
    _isPlaying = true;
    _workoutName = routine?.name ?? 'Log Workout';

    if (routine != null) {
      for (final exerciseName in routine.exerciseNames) {
        _exercises.add(ExerciseSession(
          id: _uuid.v4(),
          exerciseId: exerciseName,
          name: exerciseName,
          sets: [
            ExerciseSet(id: _uuid.v4(), weight: 0, reps: 0, completed: false),
          ],
        ));
      }
    } else {
      // Default empty workout
      if (_exercises.isEmpty) {
        _exercises.add(ExerciseSession(
          id: _uuid.v4(),
          exerciseId: 'Squat',
          name: 'Squat',
          sets: [
             ExerciseSet(id: _uuid.v4(), weight: 0, reps: 0, completed: false),
          ],
        ));
      }
    }
    
    _startTimer();
    notifyListeners();
  }

  // Renamed to saveWorkout as it now takes final details
  Future<void> finishWorkout({String? name, String? description}) async {
    debugPrint('WorkoutProvider: finishWorkout called with name: $name');
    stopTimer();
    
    if (name != null) {
      // Save the workout
      final workout = Workout(
        id: _uuid.v4(),
        name: name,
        date: DateTime.now(),
        duration: (_secondsElapsed / 60).ceil(), // Convert seconds to minutes
        totalVolume: _cachedTotalVolume,
        exercises: _exercises,
      );
      await _workoutRepository.addWorkout(workout);
    }
    
    // Reset state
    _exercises.clear();
    _secondsElapsed = 0;
    _isPlaying = false;
    _isWorkoutActive = false;
    _workoutName = 'Evening Workout';
    _cachedTotalVolume = 0;
    _cachedTotalSets = 0;
    notifyListeners();
  }

  void cancelWorkout() {
    // Cancel without saving
    stopTimer();
    _exercises.clear();
    _secondsElapsed = 0;
    _isPlaying = false;
    _isWorkoutActive = false;
    _workoutName = 'Evening Workout';
    _cachedTotalVolume = 0;
    _cachedTotalSets = 0;
    notifyListeners();
  }

  void pauseTimer() {
    _isPlaying = false;
    notifyListeners();
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _resetState() {
    _secondsElapsed = 0;
    _exercises.clear();
    _workoutName = 'Log Workout';
  }

  void toggleTimer() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPlaying && _isWorkoutActive) {
        _secondsElapsed++;
        notifyListeners();
      }
    });
  }

  // Exercise Management
  void addExercise(String name) {
    _exercises.add(ExerciseSession(
      id: _uuid.v4(),
      exerciseId: name,
      name: name,
      sets: [
        ExerciseSet(id: _uuid.v4(), weight: 0, reps: 0, completed: false),
      ],
    ));
    notifyListeners();
  }

  void addSet(int exerciseIndex) {
    if (exerciseIndex >= 0 && exerciseIndex < _exercises.length) {
      _exercises[exerciseIndex].sets.add(
        ExerciseSet(id: _uuid.v4(), weight: 0, reps: 0, completed: false),
      );
      notifyListeners();
    }
  }

  void updateSet(int exerciseIndex, int setIndex, {int? weight, int? reps, bool? completed}) {
    if (exerciseIndex >= 0 && exerciseIndex < _exercises.length) {
       final sets = _exercises[exerciseIndex].sets;
       if (setIndex >= 0 && setIndex < sets.length) {
         final oldSet = sets[setIndex];
         final newSet = ExerciseSet(
           id: oldSet.id,
           weight: weight ?? oldSet.weight,
           reps: reps ?? oldSet.reps,
           completed: completed ?? oldSet.completed,
         );
         sets[setIndex] = newSet;
         notifyListeners();
       }
    }
  }
  
  void toggleSetCompletion(int exerciseIndex, int setIndex) {
     if (exerciseIndex >= 0 && exerciseIndex < _exercises.length) {
       final sets = _exercises[exerciseIndex].sets;
       if (setIndex >= 0 && setIndex < sets.length) {
         final oldSet = sets[setIndex];
         final newSet = ExerciseSet(
           id: oldSet.id,
           weight: oldSet.weight,
           reps: oldSet.reps,
           completed: !oldSet.completed,
         );
         sets[setIndex] = newSet;
         _recalculateStats(); // Recalculate volume and sets when completion changes
         notifyListeners();
       }
     }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
