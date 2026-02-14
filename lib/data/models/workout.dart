import 'package:uuid/uuid.dart';

class Workout {
  final String id;
  final String name;
  final DateTime date;
  final int duration; // in minutes
  final int totalVolume; // in kg
  final String? photoUrl;
  final String mode; // 'gym' or 'home'
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

class ExerciseSession {
  final String id;
  final String exerciseId;
  final String name;
  final String category; // 'Strength' or 'Cardio'
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

class ExerciseSet {
  final String id;
  final int weight;
  final int reps;
  final double? distance; // in km
  final int? durationSeconds;
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
