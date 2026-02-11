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
  
  // Previous session data for current exercises
  final Map<String, List<ExerciseSet>> _previousSets = {};

  // Stream for PR events
  final _prStreamController = StreamController<PREvent>.broadcast();
  Stream<PREvent> get prEvents => _prStreamController.stream;

  // Session PR tracking (to avoid duplicate notifications for the same exercise in one session)
  final Map<String, Map<String, double>> _sessionBests = {};
  
  // Cached stats (recalculated only when sets are completed/uncompleted)
  int _cachedTotalVolume = 0;
  int _cachedTotalSets = 0;

  // Getters
  int get secondsElapsed => _secondsElapsed;
  bool get isPlaying => _isPlaying;
  bool get isWorkoutActive => _isWorkoutActive;
  String get workoutName => _workoutName;
  List<ExerciseSession> get exercises => List.unmodifiable(_exercises);
  Map<String, List<ExerciseSet>> get previousSets => Map.unmodifiable(_previousSets);

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
        // Load previous sets for this exercise
        _previousSets[exerciseName] = _workoutRepository.getPreviousSets(exerciseName);

        // Pre-fill first set from previous session if available
        final prevSets = _previousSets[exerciseName] ?? [];
        final initialWeight = prevSets.isNotEmpty ? prevSets[0].weight : 0;
        final initialReps = prevSets.isNotEmpty ? prevSets[0].reps : 0;

        _exercises.add(
          ExerciseSession(
            id: _uuid.v4(),
            exerciseId: exerciseName,
            name: exerciseName,
            sets: [
              ExerciseSet(
                id: _uuid.v4(),
                weight: initialWeight,
                reps: initialReps,
                completed: false,
              ),
            ],
          ),
        );
      }
    }
    
    _startTimer();
    notifyListeners();
  }

  // Renamed to addWorkout as it now takes final details
  Future<void> addWorkout({String? name, String? description}) async {
    debugPrint('WorkoutProvider: addWorkout called with name: $name');
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
    
    _resetToInitial();
    notifyListeners();
  }

  Future<void> saveUpdate({required String id, required String name}) async {
    debugPrint('WorkoutProvider: saveUpdate called for id: $id');
    
    final workout = Workout(
      id: id,
      name: name,
      date: DateTime.now(), // Or keep original date? Let's keep original date if we had it
      duration: (_secondsElapsed / 60).ceil(),
      totalVolume: _cachedTotalVolume,
      exercises: _exercises,
    );
    
    await _workoutRepository.updateWorkout(workout);
    _resetToInitial();
    notifyListeners();
  }

  void loadWorkoutForEditing(Workout workout) {
    _isWorkoutActive = true;
    _isPlaying = false; // Don't start timer automatically
    _workoutName = workout.name;
    _secondsElapsed = workout.duration * 60;
    _exercises.clear();
    _exercises.addAll(workout.exercises);
    _recalculateStats();
    notifyListeners();
  }

  void _resetToInitial() {
    // Reset state
    _exercises.clear();
    _secondsElapsed = 0;
    _isPlaying = false;
    _isWorkoutActive = false;
    _workoutName = 'Evening Workout';
    _cachedTotalVolume = 0;
    _cachedTotalSets = 0;
    _sessionBests.clear();
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
    _previousSets[name] = _workoutRepository.getPreviousSets(name);
    
    // Pre-fill first set if previous data exists
    final prevSets = _previousSets[name] ?? [];
    final initialWeight = prevSets.isNotEmpty ? prevSets[0].weight : 0;
    final initialReps = prevSets.isNotEmpty ? prevSets[0].reps : 0;

    _exercises.add(ExerciseSession(
      id: _uuid.v4(),
      exerciseId: name,
      name: name,
      sets: [
        ExerciseSet(
          id: _uuid.v4(), 
          weight: initialWeight, 
          reps: initialReps, 
          completed: false
        ),
      ],
    ));
    notifyListeners();
  }

  void addSet(int exerciseIndex) {
    if (exerciseIndex >= 0 && exerciseIndex < _exercises.length) {
      final exercise = _exercises[exerciseIndex];
      final prevSets = _previousSets[exercise.name] ?? [];
      final nextSetIndex = exercise.sets.length;
      
      int weight = 0;
      int reps = 0;

      if (nextSetIndex < prevSets.length) {
        // Use matching set from previous session
        weight = prevSets[nextSetIndex].weight;
        reps = prevSets[nextSetIndex].reps;
      } else if (exercise.sets.isNotEmpty) {
        // Fallback to the last set of the current session
        weight = exercise.sets.last.weight;
        reps = exercise.sets.last.reps;
      }

      exercise.sets.add(
        ExerciseSet(id: _uuid.v4(), weight: weight, reps: reps, completed: false),
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
         _recalculateStats();

         if (newSet.completed) {
           _checkForPRs(_exercises[exerciseIndex].name, newSet);
         }
         
         notifyListeners();
       }
     }
  }

  void _checkForPRs(String exerciseName, ExerciseSet set) {
    // 1. Get Historical Bests
    final historicalPRs = _workoutRepository.getExercisePRs(exerciseName);
    
    // 2. Initialize Session Bests for this exercise if not exists
    _sessionBests.putIfAbsent(exerciseName, () => {
      'heaviestWeight': historicalPRs['heaviestWeight'] ?? 0.0,
      'best1RM': historicalPRs['best1RM'] ?? 0.0,
      'bestSetVolume': historicalPRs['bestSetVolume'] ?? 0.0,
    });

    final currentBests = _sessionBests[exerciseName]!;
    
    // 3. Calculate current set stats
    final weight = set.weight.toDouble();
    final oneRM = weight * (1 + set.reps / 30.0);
    final volume = (weight * set.reps).toDouble();

    // 4. Compare and notify
    if (weight > currentBests['heaviestWeight']!) {
      currentBests['heaviestWeight'] = weight;
      _prStreamController.add(PREvent(exerciseName, 'Heaviest Weight', weight, 'kg'));
    }
    
    if (oneRM > currentBests['best1RM']!) {
      currentBests['best1RM'] = oneRM;
      _prStreamController.add(PREvent(exerciseName, 'Best 1RM', oneRM, 'kg'));
    }

    if (volume > currentBests['bestSetVolume']!) {
      currentBests['bestSetVolume'] = volume;
      _prStreamController.add(PREvent(exerciseName, 'Best Set Volume', volume, 'kg'));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _prStreamController.close();
    super.dispose();
  }
}

class PREvent {
  final String exerciseName;
  final String type;
  final double value;
  final String unit;

  PREvent(this.exerciseName, this.type, this.value, this.unit);
}
