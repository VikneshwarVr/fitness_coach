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
  bool _isEditingRoutine = false; // New flag
  String _workoutName = 'Evening Workout';
  String? _editingWorkoutId; // ID of the workout being edited (if any)
  DateTime? _editingWorkoutDate; // Original date of the workout being edited
  final List<ExerciseSession> _exercises = [];
  String? _workoutPhotoPath; // Local path to selected photo
  
  // Previous session data for current exercises
  final Map<String, List<ExerciseSet>> _previousSets = {};

  // Stream for PR events
  final _prStreamController = StreamController<PREvent>.broadcast();
  Stream<PREvent> get prEvents => _prStreamController.stream;

  // Session PR tracking (to avoid duplicate notifications for the same exercise in one session)
  final Map<String, Map<String, double>> _sessionBests = {};
  
  // Track which exercises have achieved PRs and count total PRs
  final Set<String> _exercisesWithPRs = {}; // For badge display
  int _totalPRCount = 0; // Total count of all PRs (can be multiple per exercise)
  
  // Track which PR types have already been achieved for each exercise in this session
  final Map<String, Set<String>> _achievedPRTypes = {}; // key: exerciseName, value: Set of PR types ('weight', '1rm', 'volume')
  
  // Cached stats (recalculated only when sets are completed/uncompleted)
  int _cachedTotalVolume = 0;
  int _cachedTotalSets = 0;

  // Rest Timer State
  final Map<String, int> _exerciseRestTimes = {}; // key: exerciseId (name), value: seconds
  Timer? _restTimer;
  int _currentRestSeconds = 0;
  int _totalRestSeconds = 0;
  bool _isRestTimerRunning = false;

  // Getters
  int get secondsElapsed => _secondsElapsed;
  bool get isPlaying => _isPlaying;
  bool get isWorkoutActive => _isWorkoutActive;
  bool get isEditingRoutine => _isEditingRoutine;
  String get workoutName => _workoutName;
  String? get editingWorkoutId => _editingWorkoutId;
  DateTime? get editingWorkoutDate => _editingWorkoutDate;
  String? get workoutPhotoPath => _workoutPhotoPath;
  List<ExerciseSession> get exercises => List.unmodifiable(_exercises);
  Map<String, List<ExerciseSet>> get previousSets => Map.unmodifiable(_previousSets);
  int get totalPRsAchieved => _totalPRCount;
  
  // Rest Timer Getters
  bool get isRestTimerRunning => _isRestTimerRunning;
  int get currentRestSeconds => _currentRestSeconds;
  int get totalRestSeconds => _totalRestSeconds;
  double get restTimerProgress => _totalRestSeconds > 0 ? _currentRestSeconds / _totalRestSeconds : 0.0;
  
  bool get isLiveWorkout => _isWorkoutActive && !_isEditingRoutine && _editingWorkoutId == null;
  
  int getRestTime(String exerciseId) => _exerciseRestTimes[exerciseId] ?? 0;
  
  bool getExerciseHasPR(String exerciseName) => _exercisesWithPRs.contains(exerciseName);

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
  Future<void> startWorkout({Routine? routine}) async {
    if (_isWorkoutActive) return;

    _resetState();
    _isWorkoutActive = true;
    _isPlaying = true; // Use timer for actual workouts
    _isEditingRoutine = false;
    _workoutName = routine?.name ?? 'Log Workout';

    if (routine != null) {
      for (final routineExercise in routine.exercises) {
        final exerciseName = routineExercise.name;
        
        // Load previous sets for this exercise from backend
        _previousSets[exerciseName] = await _workoutRepository.getPreviousSets(exerciseName);

        // Map RoutineExercise -> ExerciseSession
        // If the routine has sets defined (editing mode saved them), use them.
        // Otherwise use previous history or default.
        
        List<ExerciseSet> sessSets = [];
        if (routineExercise.sets.isNotEmpty) {
           sessSets = routineExercise.sets.map((s) => ExerciseSet(
             id: _uuid.v4(), // New session ID
             weight: s.weight,
             reps: s.reps,
             completed: false,
           )).toList();
        } else {
           // Fallback logic (history or default)
           final prevSets = _previousSets[exerciseName] ?? [];
           final initialWeight = prevSets.isNotEmpty ? prevSets[0].weight : 0;
           final initialReps = prevSets.isNotEmpty ? prevSets[0].reps : 0;
           
           sessSets.add(ExerciseSet(
             id: _uuid.v4(),
             weight: initialWeight,
             reps: initialReps,
             completed: false,
           ));
        }

        _exercises.add(
          ExerciseSession(
            id: _uuid.v4(),
            exerciseId: exerciseName, // Using name as ID for now
            name: exerciseName,
            sets: sessSets,
          ),
        );
      }
    }
    
    _startTimer();
    notifyListeners();
  }

  // Called when entering "Editor Mode" from Create Routine screen
  void loadRoutineForEditing(Routine routine) {
    _resetState();
    _isWorkoutActive = true;
    _isPlaying = false; // NO TIMER
    _isEditingRoutine = true; 
    _workoutName = routine.name.isEmpty ? 'New Routine' : routine.name;

    for (final routineExercise in routine.exercises) {
       // Just load what is in the routine, literally.
       final sessSets = routineExercise.sets.map((s) => ExerciseSet(
         id: _uuid.v4(),
         weight: s.weight,
         reps: s.reps,
         completed: false, // Completion checkmarks don't mean "done" in editor, maybe just "valid"? or ignored?
                           // Actually in editor we might not show checkboxes? Or check = "include"?
                           // For now let's keep them false.
       )).toList();

       // If no sets, add one empty one so it shows up?
       if (sessSets.isEmpty) {
         sessSets.add(ExerciseSet(id: _uuid.v4(), weight: 0, reps: 0, completed: false));
       }

       _exercises.add(ExerciseSession(
         id: _uuid.v4(),
         exerciseId: routineExercise.name,
         name: routineExercise.name,
         sets: sessSets,
       ));
    }
    notifyListeners();
  }

  // Extract data back to Routine format
  List<RoutineExercise> getRoutineExercises() {
    return _exercises.map((ex) {
      return RoutineExercise(
        id: const Uuid().v4(), // or keep original? doesnt matter much for new save
        name: ex.name,
        sets: ex.sets.map((s) => RoutineSet(
          id: const Uuid().v4(),
          weight: s.weight,
          reps: s.reps,
        )).toList(),
      );
    }).toList();
  }

  // Renamed to addWorkout as it now takes final details
  Future<void> addWorkout({String? name, String? description}) async {
    stopTimer();
    
    String? photoUrl;
    if (_workoutPhotoPath != null) {
      photoUrl = await _workoutRepository.uploadWorkoutPhoto(_workoutPhotoPath!);
    }
    
    if (name != null) {
      // Save the workout
      final workout = Workout(
        id: _uuid.v4(),
        name: name,
        date: DateTime.now(),
        duration: (_secondsElapsed / 60).ceil(), // Convert seconds to minutes
        totalVolume: _cachedTotalVolume,
        photoUrl: photoUrl,
        exercises: _exercises,
      );
      await _workoutRepository.addWorkout(workout);
    }
    
    _resetToInitial();
    notifyListeners();
  }

  Future<void> saveUpdate({required String id, required String name}) async {
    
    String? photoUrl;
    if (_workoutPhotoPath != null) {
      if (_workoutPhotoPath!.startsWith('http')) {
        photoUrl = _workoutPhotoPath; // Keep existing cloud URL
      } else {
        photoUrl = await _workoutRepository.uploadWorkoutPhoto(_workoutPhotoPath!);
      }
    }

    final workout = Workout(
      id: id,
      name: name,
      date: _editingWorkoutDate ?? DateTime.now(), // Preserve original date or use now
      duration: (_secondsElapsed / 60).ceil(),
      totalVolume: _cachedTotalVolume,
      photoUrl: photoUrl,
      exercises: _exercises,
    );
    
    await _workoutRepository.updateWorkout(workout);
    _resetToInitial();
    notifyListeners();
  }

  void setWorkoutPhoto(String? path) {
    _workoutPhotoPath = path;
    notifyListeners();
  }

  void loadWorkoutForEditing(Workout workout) {
    _isWorkoutActive = true;
    _isPlaying = false; // Don't start timer automatically
    _isEditingRoutine = false; // This is workout editing, not routine editing
    _workoutName = workout.name;
    _editingWorkoutId = workout.id;
    _editingWorkoutDate = workout.date;
    _workoutPhotoPath = workout.photoUrl;
    _secondsElapsed = workout.duration * 60;
    _exercises.clear();
    // Deep copy exercises to avoid mutating the original workout in the repo
    for (final ex in workout.exercises) {
      final newSets = ex.sets.map((s) => ExerciseSet(
        id: s.id, // Keep ID to track updates? Or new ID? 
                  // If we want to update existing sets, keep ID. 
                  // If we treat it as new sets replacing old, new ID?
                  // Generally for "editing" we want to keep IDs if possible to match? 
                  // Actually ExerciseSet ID doesn't matter much unless we sync with backend.
                  // But let's keep it safe.
        weight: s.weight,
        reps: s.reps,
        completed: s.completed,
      )).toList();

      _exercises.add(ExerciseSession(
        id: ex.id,
        exerciseId: ex.exerciseId,
        name: ex.name,
        sets: newSets,
      ));
    }
    _recalculateStats();
    notifyListeners();
  }

  void _resetToInitial() {
    // Reset state
    _exercises.clear();
    _secondsElapsed = 0;
    _isPlaying = false;
    _isWorkoutActive = false;
    _isEditingRoutine = false;
    _workoutName = 'Evening Workout';
    _editingWorkoutId = null;
    _editingWorkoutDate = null;
    _cachedTotalVolume = 0;
    _cachedTotalSets = 0;
    _workoutPhotoPath = null;
    _sessionBests.clear();
  }

  void cancelWorkout() {
    _resetToInitial(); // simple implementation
    stopTimer();
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
    _isEditingRoutine = false;
    _editingWorkoutId = null;
    _editingWorkoutDate = null;
  }

  void toggleTimer() {
    if (_isEditingRoutine) return; // Cannot toggle timer in routine edit mode
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    if (_isEditingRoutine) return; // Do not start timer if editing routine

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPlaying && _isWorkoutActive) {
        _secondsElapsed++;
        notifyListeners();
      }
    });
  }

  // Exercise Management
  Future<void> addExercises(List<String> names) async {
    for (final name in names) {
      await _addOneExercise(name);
    }
    notifyListeners();
  }

  Future<void> addExercise(String name) async {
    await _addOneExercise(name);
    notifyListeners();
  }

  Future<void> _addOneExercise(String name) async {
    if (!_isEditingRoutine) {
        _previousSets[name] = await _workoutRepository.getPreviousSets(name);
    }
    
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
  
  // Rest Timer Logic
  void setRestTime(String exerciseId, int seconds) {
    _exerciseRestTimes[exerciseId] = seconds;
    notifyListeners();
  }

  void _startRestTimer(int seconds) {
    _restTimer?.cancel();
    _totalRestSeconds = seconds;
    _currentRestSeconds = seconds;
    _isRestTimerRunning = true;
    notifyListeners();

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentRestSeconds > 0) {
        _currentRestSeconds--;
        notifyListeners();
      } else {
        stopRestTimer();
      }
    });
  }

  void stopRestTimer() {
    _restTimer?.cancel();
    _restTimer = null;
    _isRestTimerRunning = false;
    _currentRestSeconds = 0;
    _totalRestSeconds = 0;
    notifyListeners();
  }

  void adjustRestTimer(int seconds) {
    if (!_isRestTimerRunning) return;
    _currentRestSeconds += seconds;
    if (_currentRestSeconds < 0) _currentRestSeconds = 0;
    // Optionally update total if we want the progress bar to adapt? 
    // Usually adding time extends the duration, so total might stay same or increase?
    // Let's just keep total same for progress context, or update it if current > total.
    if (_currentRestSeconds > _totalRestSeconds) {
       _totalRestSeconds = _currentRestSeconds;
    }
    notifyListeners();
  }

  Future<void> toggleSetCompletion(int exerciseIndex, int setIndex) async {
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
           await _checkForPRs(_exercises[exerciseIndex].name, newSet);
           
           // Trigger Rest Timer if configured
           final restTime = _exerciseRestTimes[_exercises[exerciseIndex].name] ?? 0;
           if (restTime > 0) {
             _startRestTimer(restTime);
           }
         }
         
         notifyListeners();
       }
     }
  }

  Future<void> _checkForPRs(String exerciseName, ExerciseSet set) async {
    // 1. Get Historical Bests from backend
    final historicalPRs = await _workoutRepository.getExercisePRs(exerciseName);
    
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

    // 4. Compare and notify (only if there's a previous non-zero value)
    // Add delays between notifications so they don't overlap
    int delayMs = 0;
    
    // Track types achieved in this session to prevent duplicates
    _achievedPRTypes.putIfAbsent(exerciseName, () => {});
    final sessionAchieved = _achievedPRTypes[exerciseName]!;
    
    final historicalWeight = historicalPRs['heaviestWeight'] ?? 0.0;
    if (weight > currentBests['heaviestWeight']! && historicalWeight > 0) {
      currentBests['heaviestWeight'] = weight;
      _exercisesWithPRs.add(exerciseName); // Mark exercise as having PR for badge
      
      // Notify for Every improvement (even within same session)
      Future.delayed(Duration(milliseconds: delayMs), () {
        _prStreamController.add(PREvent(exerciseName, 'Heaviest Weight', weight, 'kg'));
      });
      delayMs += 3500;

      // But only count ONCE per session for the final summary
      if (!sessionAchieved.contains('weight')) {
        sessionAchieved.add('weight');
        _totalPRCount++;
      }
    }
    
    final historical1RM = historicalPRs['best1RM'] ?? 0.0;
    if (oneRM > currentBests['best1RM']! && historical1RM > 0) {
      currentBests['best1RM'] = oneRM;
      _exercisesWithPRs.add(exerciseName);
      
      Future.delayed(Duration(milliseconds: delayMs), () {
        _prStreamController.add(PREvent(exerciseName, 'Best 1RM', oneRM, 'kg'));
      });
      delayMs += 3500;

      if (!sessionAchieved.contains('1rm')) {
        sessionAchieved.add('1rm');
        _totalPRCount++;
      }
    }

    final historicalVolume = historicalPRs['bestSetVolume'] ?? 0.0;
    if (volume > currentBests['bestSetVolume']! && historicalVolume > 0) {
      currentBests['bestSetVolume'] = volume;
      _exercisesWithPRs.add(exerciseName);
      
      Future.delayed(Duration(milliseconds: delayMs), () {
        _prStreamController.add(PREvent(exerciseName, 'Best Set Volume', volume, 'kg'));
      });

      if (!sessionAchieved.contains('volume')) {
        sessionAchieved.add('volume');
        _totalPRCount++;
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restTimer?.cancel();
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
