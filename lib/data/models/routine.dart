import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

part 'routine.g.dart';

@HiveType(typeId: 3)
class RoutineSet {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final int weight;
  @HiveField(2)
  final int reps;
  @HiveField(3)
  final double? distance;
  @HiveField(4)
  final int? durationSeconds;

  RoutineSet({
    required this.id,
    this.weight = 0,
    this.reps = 0,
    this.distance,
    this.durationSeconds,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'weight': weight,
        'reps': reps,
        'distance': distance,
        'duration_seconds': durationSeconds,
      };

  factory RoutineSet.fromJson(Map<String, dynamic> json) {
    return RoutineSet(
      id: json['id']?.toString() ?? const Uuid().v4(),
      weight: json['weight'] ?? 0,
      reps: json['reps'] ?? 0,
      distance: (json['distance'] as num?)?.toDouble(),
      durationSeconds: json['duration_seconds']?.toInt(),
    );
  }
}

@HiveType(typeId: 4)
class RoutineExercise {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String category;
  @HiveField(3)
  final List<RoutineSet> sets;

  RoutineExercise({
    required this.id,
    required this.name,
    this.category = 'Strength',
    required this.sets,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'sets': sets.map((s) => s.toJson()).toList(),
      };

  factory RoutineExercise.fromJson(Map<String, dynamic> json) {
    return RoutineExercise(
      id: json['id']?.toString() ?? const Uuid().v4(),
      name: json['name'] ?? '',
      category: json['category'] ?? 'Strength',
      sets: (json['sets'] as List<dynamic>?)
              ?.map((s) => RoutineSet.fromJson(s))
              .toList() ??
          [],
    );
  }
}

@HiveType(typeId: 5)
class Routine {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final List<RoutineExercise> exercises;
  @HiveField(4)
  final String level; // Beginner, Intermediate, Advanced
  @HiveField(5)
  final int duration; // Estimated duration in minutes
  @HiveField(6)
  final bool isCustom; // User-created vs default
  @HiveField(7)
  final String mode; // 'gym' or 'home'

  // Backward compatibility getter
  List<String> get exerciseNames => exercises.map((e) => e.name).toList();

  Routine({
    required this.id,
    required this.name,
    required this.description,
    required this.exercises,
    required this.level,
    required this.duration,
    this.isCustom = false,
    this.mode = 'gym',
  });

  factory Routine.create({
    required String name,
    required String description,
    required List<String> exerciseNames, // Keep for easy creation
    List<RoutineExercise>? detailedExercises, // Optional detailed sets
    String level = 'Intermediate',
    int duration = 45,
    bool isCustom = false,
    String mode = 'gym',
  }) {
    // If detailed exercises are provided, use them. Otherwise create from names.
    List<RoutineExercise> finalExercises;
    if (detailedExercises != null) {
      finalExercises = detailedExercises;
    } else {
      finalExercises = exerciseNames.map((name) {
        return RoutineExercise(
          id: const Uuid().v4(),
          name: name,
          category: 'Strength', // Default, can be refined by caller
          sets: [
            RoutineSet(id: const Uuid().v4(), weight: 0, reps: 0),
            RoutineSet(id: const Uuid().v4(), weight: 0, reps: 0),
            RoutineSet(id: const Uuid().v4(), weight: 0, reps: 0),
          ],
        );
      }).toList();
    }

    return Routine(
      id: const Uuid().v4(),
      name: name,
      description: description,
      exercises: finalExercises,
      level: level,
      duration: duration,
      isCustom: isCustom,
      mode: mode,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'level': level,
        'duration': duration,
        'isCustom': isCustom,
        'mode': mode,
      };

  factory Routine.fromJson(Map<String, dynamic> json) {
    List<RoutineExercise> exercises = [];
    
    if (json['exercises'] != null) {
      exercises = (json['exercises'] as List)
          .map((e) => RoutineExercise.fromJson(e))
          .toList();
    } else if (json['exerciseNames'] != null) {
      // Handle legacy format
      exercises = (json['exerciseNames'] as List<dynamic>).map((name) {
        return RoutineExercise(
          id: const Uuid().v4(),
          name: name.toString(),
          sets: [], // Empty sets for legacy
        );
      }).toList();
    }

    return Routine(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      exercises: exercises,
      level: json['level'],
      duration: json['duration'],
      isCustom: json['isCustom'] ?? false,
      mode: json['mode'] ?? 'gym',
    );
  }
}
