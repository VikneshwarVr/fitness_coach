import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

part 'workout.g.dart';

@HiveType(typeId: 0)
class Workout {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final DateTime date;
  @HiveField(3)
  final int duration; // in minutes
  @HiveField(4)
  final int totalVolume; // in kg
  @HiveField(5)
  final String? photoUrl;
  @HiveField(6)
  final String mode; // 'gym' or 'home'
  @HiveField(7)
  final List<ExerciseSession> exercises;

  Workout({
    required this.id,
    required this.name,
    required this.date,
    required this.duration,
    required this.totalVolume,
    this.photoUrl,
    this.mode = 'gym',
    required this.exercises,
  });

  factory Workout.create({
    required String name,
    required int duration,
    List<ExerciseSession>? exercises,
    String mode = 'gym',
  }) {
    return Workout(
      id: const Uuid().v4(),
      name: name,
      date: DateTime.now(),
      duration: duration,
      totalVolume: exercises?.fold(0, (sum, e) => sum! + e.volume) ?? 0,
      photoUrl: null,
      mode: mode,
      exercises: exercises ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'duration': duration,
      'totalVolume': totalVolume,
      'photo_url': photoUrl,
      'mode': mode,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      duration: json['duration'] ?? 0,
      totalVolume: json['totalVolume'] ?? json['total_volume'] ?? 0,
      photoUrl: json['photo_url'],
      mode: json['mode'] ?? 'gym',
      exercises: (json['exercises'] as List)
          .map((e) => ExerciseSession.fromJson(e))
          .toList(),
    );
  }
}

@HiveType(typeId: 1)
class ExerciseSession {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String exerciseId;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String category; // 'Strength' or 'Cardio'
  @HiveField(4)
  final List<ExerciseSet> sets;

  ExerciseSession({
    required this.id,
    required this.exerciseId,
    required this.name,
    this.category = 'Strength',
    required this.sets,
  });

  int get volume => category == 'Cardio' 
    ? 0 
    : sets.fold(0, (sum, set) => sum + (set.weight * set.reps));

  Map<String, dynamic> toJson() => {
    'id': id,
    'exerciseId': exerciseId,
    'name': name,
    'category': category,
    'sets': sets.map((s) => s.toJson()).toList(),
  };

  factory ExerciseSession.fromJson(Map<String, dynamic> json) {
    return ExerciseSession(
      id: json['id']?.toString() ?? '',
      exerciseId: json['exerciseId']?.toString() ?? json['exercise_id']?.toString() ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? 'Strength',
      sets: (json['sets'] as List).map((s) => ExerciseSet.fromJson(s)).toList(),
    );
  }
}

@HiveType(typeId: 2)
class ExerciseSet {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final int weight;
  @HiveField(2)
  final int reps;
  @HiveField(3)
  final double? distance; // in km
  @HiveField(4)
  final int? durationSeconds;
  @HiveField(5)
  final bool completed;

  ExerciseSet({
    required this.id,
    required this.weight,
    required this.reps,
    this.distance,
    this.durationSeconds,
    required this.completed,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'weight': weight,
    'reps': reps,
    'distance': distance,
    'duration_seconds': durationSeconds,
    'completed': completed,
  };

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      id: json['id']?.toString() ?? '',
      weight: json['weight']?.toInt() ?? 0,
      reps: json['reps']?.toInt() ?? 0,
      distance: (json['distance'] as num?)?.toDouble(),
      durationSeconds: json['duration_seconds']?.toInt(),
      completed: json['completed'] ?? false,
    );
  }
}
