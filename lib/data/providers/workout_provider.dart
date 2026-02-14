import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/workout.dart';
import '../models/routine.dart';
import '../repositories/workout_repository.dart';
import '../constants/exercise_data.dart';

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
  final Map<String, Map<String, double>> _historicalPRs = {};

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
  
  // Set Timer State (for Plank, etc.)
  Timer? _setTimer;
  String? _activeTimingExerciseId;
  String? _activeTimingSetId;

  // Getters
  int get secondsElapsed => _secondsElapsed;
  bool get isPlaying => _isPlaying;
  bool get isWorkoutActive => _isWorkoutActive;
  bool get isEditingRoutine => _isEditingRoutine;
  String get workoutName => _workoutName;
  String? get editingWorkoutId => _editingWorkoutId;
  String? get activeTimingSetId => _activeTimingSetId;
  String? get activeTimingExerciseId => _activeTimingExerciseId;
  bool get isAnySetTiming => _setTimer != null;
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
          // Only count volume for strength exercises
          if (ex.category == 'Strength') {
            volume += (set.weight * set.reps);
          } else if (ex.category == 'WeightedDistanceMeters') {
             // For now, we can treat distance as "reps" for volume? 
             // Or just ignore. The user didn't ask for volume calc change.
             // Let's safe-guard it.
             // If we want to track volume for weighted lunges, it's usually weight * distance.
             // But distance is in meters (large number compared to reps).
             // Let's leave volume as 0 for now for these new types to be safe.
          }
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
  Future<void> startWorkout({Routine? routine, int defaultRestTime = 0}) async {
    if (_isWorkoutActive) return;

    _resetState();
    _isWorkoutActive = true;
    _isPlaying = true; // Use timer for actual workouts
    _isEditingRoutine = false;
    _workoutName = routine?.name ?? 'Log Workout';

    if (routine != null) {
      for (final routineExercise in routine.exercises) {
        final exerciseName = routineExercise.name;
        final category = routineExercise.category;
        
        // Initialize rest time with default if not already set
        if (defaultRestTime > 0) {
          _exerciseRestTimes[exerciseName] = defaultRestTime;
        }
        
        // Load previous sets and PRs from backend
        _previousSets[exerciseName] = await _workoutRepository.getPreviousSets(exerciseName);
        _historicalPRs[exerciseName] = await _workoutRepository.getExercisePRs(exerciseName);

        // Map RoutineExercise -> ExerciseSession
        // If the routine has sets defined (editing mode saved them), use them.
        // Otherwise use previous history or default.
        
        List<ExerciseSet> sessSets = [];
        if (routineExercise.sets.isNotEmpty) {
           sessSets = routineExercise.sets.map((s) => ExerciseSet(
             id: _uuid.v4(), // New session ID
             weight: s.weight,
             reps: s.reps,
             distance: s.distance,
             durationSeconds: s.durationSeconds,
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
            exerciseId: routineExercise.id,
            name: exerciseName,
            category: category,
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
         distance: s.distance,
         durationSeconds: s.durationSeconds,
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
         exerciseId: routineExercise.id,
         name: routineExercise.name,
         category: routineExercise.category,
         sets: sessSets,
       ));
    }
    notifyListeners();
  }

  // Extract data back to Routine format
  List<RoutineExercise> getRoutineExercises() {
    return _exercises.map((ex) {
      final List<RoutineSet> routineSets = ex.sets.map((s) => RoutineSet(
          id: const Uuid().v4(),
          weight: s.weight,
          reps: s.reps,
          distance: s.distance,
          durationSeconds: s.durationSeconds,
        )).toList();

      return RoutineExercise(
        id: const Uuid().v4(), // or keep original? doesnt matter much for new save
        name: ex.name,
        category: ex.category,
        sets: routineSets,
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
        distance: s.distance,
        durationSeconds: s.durationSeconds,
        completed: s.completed,
      )).toList();

      _exercises.add(ExerciseSession(
        id: ex.id,
        exerciseId: ex.exerciseId,
        name: ex.name,
        category: ex.category,
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
    _historicalPRs.clear();
    _exercisesWithPRs.clear();
    _totalPRCount = 0;
    _achievedPRTypes.clear();
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
    _timer?.cancel();
    _restTimer?.cancel();
    _setTimer?.cancel();
    _activeTimingSetId = null;
    _activeTimingExerciseId = null;
    _secondsElapsed = 0;
    _isPlaying = false;
    _isWorkoutActive = false;
    _isEditingRoutine = false;
    _exercises.clear();
    _previousSets.clear();
    _sessionBests.clear();
    _exercisesWithPRs.clear();
    _totalPRCount = 0;
    _achievedPRTypes.clear();
    _cachedTotalVolume = 0;
    _cachedTotalSets = 0;
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
  Future<void> addExercises(List<String> names, {int defaultRestTime = 0}) async {
    for (final name in names) {
      await _addOneExercise(name, defaultRestTime: defaultRestTime);
    }
    notifyListeners();
  }

  Future<void> addExercise(String name, {int defaultRestTime = 0}) async {
    await _addOneExercise(name, defaultRestTime: defaultRestTime);
    notifyListeners();
  }

  Future<void> _addOneExercise(String name, {int defaultRestTime = 0}) async {
    if (!_isEditingRoutine) {
        _previousSets[name] = await _workoutRepository.getPreviousSets(name);
        _historicalPRs[name] = await _workoutRepository.getExercisePRs(name);
        
        if (defaultRestTime > 0) {
           _exerciseRestTimes[name] = defaultRestTime;
        }
    }
    
    final prevSets = _previousSets[name] ?? [];
    
    // Look up category from ExerciseData
    final exerciseData = ExerciseData.exercises.firstWhere(
      (e) => e['name'] == name,
      orElse: () => {'tag': 'Strength', 'type': 'strength'},
    );
    
    // Determine category based on type or tag
    String category = 'Strength';
    final type = exerciseData['type'] ?? (exerciseData['tag'] == 'Cardio' ? 'cardio' : 'strength');
    
    if (type == 'cardio') {
      category = 'Cardio';
    } else if (type == 'timed') {
      category = 'Timed';
    } else if (type == 'reps') {
      category = 'Bodyweight';
    } else if (type == 'distance') {
      category = 'Distance';
    } else if (type == 'distance_meters') {
      category = 'DistanceMeters';
    } else if (type == 'weighted_distance_meters') {
      category = 'WeightedDistanceMeters';
    } else if (type == 'distance_time_meters') {
      category = 'DistanceTimeMeters';
    }

    final exercise = ExerciseSession(
      id: const Uuid().v4(),
      exerciseId: const Uuid().v4(),
      name: name,
      category: category,
      sets: prevSets.isNotEmpty 
        ? prevSets.map((s) => ExerciseSet(
            id: const Uuid().v4(),
            weight: s.weight,
            reps: s.reps,
            distance: s.distance,
            durationSeconds: s.durationSeconds,
            completed: false,
          )).toList()
        : [ExerciseSet(
            id: const Uuid().v4(), 
            weight: 0, 
            reps: 0, 
            distance: (category == 'Cardio' || category == 'Distance' || category == 'DistanceMeters' || category == 'WeightedDistanceMeters' || category == 'DistanceTimeMeters') ? 0.0 : null,
            durationSeconds: (category == 'Cardio' || category == 'Timed' || category == 'DistanceTimeMeters') ? 0 : null,
            completed: false
          )],
    );
    _exercises.add(exercise);
  }

  void addSet(int exerciseIndex) {
    if (exerciseIndex >= 0 && exerciseIndex < _exercises.length) {
      final exercise = _exercises[exerciseIndex];
      final prevSets = _previousSets[exercise.name] ?? [];
      final nextSetIndex = exercise.sets.length;
      
      int weight = 0;
      int reps = 0;
      double distance = 0.0;
      int durationSeconds = 0;

      if (nextSetIndex < prevSets.length) {
        // Use matching set from previous session
        weight = prevSets[nextSetIndex].weight;
        reps = prevSets[nextSetIndex].reps;
        distance = prevSets[nextSetIndex].distance ?? 0.0;
        durationSeconds = prevSets[nextSetIndex].durationSeconds ?? 0;
      } else if (exercise.sets.isNotEmpty) {
        // Fallback to the last set of the current session
        weight = exercise.sets.last.weight;
        reps = exercise.sets.last.reps;
        distance = exercise.sets.last.distance ?? 0.0;
        durationSeconds = exercise.sets.last.durationSeconds ?? 0;
      }

      exercise.sets.add(
        ExerciseSet(
          id: _uuid.v4(), 
          weight: weight, 
          reps: reps, 
          distance: distance,
          durationSeconds: durationSeconds,
          completed: false
        ),
      );
      notifyListeners();
    }
  }

  void updateSet(String exerciseId, String setId, {int? weight, int? reps, double? distance, int? durationSeconds, bool? completed}) {
    final exerciseIndex = _exercises.indexWhere((e) => e.id == exerciseId);
    if (exerciseIndex != -1) {
      final exercise = _exercises[exerciseIndex];
      final setIndex = exercise.sets.indexWhere((s) => s.id == setId);
      if (setIndex != -1) {
        final oldSet = exercise.sets[setIndex];
        
        final newSet = ExerciseSet(
          id: oldSet.id,
          weight: weight ?? oldSet.weight,
          reps: reps ?? oldSet.reps,
          distance: distance ?? oldSet.distance,
          durationSeconds: durationSeconds ?? oldSet.durationSeconds,
          completed: completed ?? oldSet.completed,
        );
        exercise.sets[setIndex] = newSet;
        _recalculateStats(); // Recalculate stats if a set was updated
        notifyListeners();
      }
    }
  }

  void removeSet(String exerciseId, String setId) {
    final exerciseIndex = _exercises.indexWhere((e) => e.id == exerciseId);
    if (exerciseIndex != -1) {
      final exercise = _exercises[exerciseIndex];
      final setIndex = exercise.sets.indexWhere((s) => s.id == setId);
      if (setIndex != -1) {
        exercise.sets.removeAt(setIndex);
        _recalculateStats();
        notifyListeners();
      }
    }
  }

  void reorderExercise(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final ExerciseSession item = _exercises.removeAt(oldIndex);
    _exercises.insert(newIndex, item);
    notifyListeners();
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

  Future<void> toggleSetCompletion(String exerciseId, String setId) async {
    final exerciseIndex = _exercises.indexWhere((e) => e.id == exerciseId);
    if (exerciseIndex != -1) {
      final exercise = _exercises[exerciseIndex];
      final setIndex = exercise.sets.indexWhere((s) => s.id == setId);
      if (setIndex != -1) {
        final oldSet = exercise.sets[setIndex];
        final newSet = ExerciseSet(
          id: oldSet.id,
          weight: oldSet.weight,
          reps: oldSet.reps,
          distance: oldSet.distance,
          durationSeconds: oldSet.durationSeconds,
          completed: !oldSet.completed,
        );
        exercise.sets[setIndex] = newSet;
        _recalculateStats();

        if (newSet.completed) {
          await _checkForPRs(exercise.name, newSet);
          
          // Trigger Rest Timer if configured
          final restTime = _exerciseRestTimes[exercise.name] ?? 0;
          if (restTime > 0) {
            _startRestTimer(restTime);
          }
        }
        
        notifyListeners();
      }
    }
  }

  Future<void> _checkForPRs(String exerciseName, ExerciseSet set) async {
    // 1. Use cached Historical Bests
    final historicalPRs = _historicalPRs[exerciseName] ?? {
      'heaviestWeight': 0.0,
      'best1RM': 0.0,
      'bestSetVolume': 0.0,
      'bestSessionVolume': 0.0,
    };
    
    // 2. Initialize Session Bests for this exercise if not exists
    _sessionBests.putIfAbsent(exerciseName, () => {
      'heaviestWeight': historicalPRs['heaviestWeight'] ?? 0.0,
      'best1RM': historicalPRs['best1RM'] ?? 0.0,
      'bestSetVolume': historicalPRs['bestSetVolume'] ?? 0.0,
    });

    final currentBests = _sessionBests[exerciseName]!;
    
    // 3. Calculate current set stats
    final weight = set.weight.toDouble();
    if (weight <= 0) return; // Don't trigger PR for empty weight

    final oneRM = weight * (1 + set.reps / 30.0);
    final volume = (weight * set.reps).toDouble();

    // 4. Compare and notify
    int delayMs = 0;
    
    _achievedPRTypes.putIfAbsent(exerciseName, () => {});
    final sessionAchieved = _achievedPRTypes[exerciseName]!;
    
    // Weight PR
    // Trigger if > current best and (historical exists or this is first session)
    if (weight > currentBests['heaviestWeight']!) {
      final isFirstTime = (historicalPRs['heaviestWeight'] ?? 0.0) == 0;
      currentBests['heaviestWeight'] = weight;
      _exercisesWithPRs.add(exerciseName);
      
      Future.delayed(Duration(milliseconds: delayMs), () {
        _prStreamController.add(PREvent(
          exerciseName, 
          isFirstTime ? 'First Heavy Set' : 'Heaviest Weight', 
          weight
        ));
      });
      delayMs += 3500;

      if (!sessionAchieved.contains('weight')) {
        sessionAchieved.add('weight');
        _totalPRCount++;
      }
    }
    
    // 1RM PR
    if (oneRM > currentBests['best1RM']!) {
      final isFirstTime = (historicalPRs['best1RM'] ?? 0.0) == 0;
      currentBests['best1RM'] = oneRM;
      _exercisesWithPRs.add(exerciseName);
      
      Future.delayed(Duration(milliseconds: delayMs), () {
        _prStreamController.add(PREvent(
          exerciseName, 
          isFirstTime ? 'First 1RM Calc' : 'Best 1RM', 
          oneRM
        ));
      });
      delayMs += 3500;

      if (!sessionAchieved.contains('1rm')) {
        sessionAchieved.add('1rm');
        _totalPRCount++;
      }
    }

    // Volume PR
    if (volume > currentBests['bestSetVolume']!) {
      final isFirstTime = (historicalPRs['bestSetVolume'] ?? 0.0) == 0;
      currentBests['bestSetVolume'] = volume;
      _exercisesWithPRs.add(exerciseName);
      
      Future.delayed(Duration(milliseconds: delayMs), () {
        _prStreamController.add(PREvent(
          exerciseName, 
          isFirstTime ? 'First Set Volume' : 'Best Set Volume', 
          volume
        ));
      });

      if (!sessionAchieved.contains('volume')) {
        sessionAchieved.add('volume');
        _totalPRCount++;
      }
    }
  }

  // Set Timer Methods
  void toggleSetTimer(String exerciseId, String setId) {
    if (_activeTimingSetId == setId) {
      stopSetTimer();
    } else {
      startSetTimer(exerciseId, setId);
    }
  }

  void startSetTimer(String exerciseId, String setId) {
    _setTimer?.cancel();
    _activeTimingExerciseId = exerciseId;
    _activeTimingSetId = setId;
    
    _setTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final exerciseIndex = _exercises.indexWhere((e) => e.id == exerciseId);
      if (exerciseIndex != -1) {
        final exercise = _exercises[exerciseIndex];
        final setIndex = exercise.sets.indexWhere((s) => s.id == setId);
        if (setIndex != -1) {
          final oldSet = exercise.sets[setIndex];
          exercise.sets[setIndex] = ExerciseSet(
            id: oldSet.id,
            weight: oldSet.weight,
            reps: oldSet.reps,
            distance: oldSet.distance,
            durationSeconds: (oldSet.durationSeconds ?? 0) + 1,
            completed: oldSet.completed,
          );
          notifyListeners();
        } else {
          stopSetTimer();
        }
      } else {
        stopSetTimer();
      }
    });
    notifyListeners();
  }

  void stopSetTimer() {
    _setTimer?.cancel();
    _setTimer = null;
    _activeTimingExerciseId = null;
    _activeTimingSetId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restTimer?.cancel();
    _setTimer?.cancel();
    _prStreamController.close();
    super.dispose();
  }
}

class PREvent {
  final String exerciseName;
  final String type;
  final double value;

  PREvent(this.exerciseName, this.type, this.value);
}
