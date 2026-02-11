import 'package:uuid/uuid.dart';

class Workout {
  final String id;
  final String name;
  final DateTime date;
  final int duration; // in minutes
  final int totalVolume; // in kg
  final List<ExerciseSession> exercises;

  Workout({
    required this.id,
    required this.name,
    required this.date,
    required this.duration,
    required this.totalVolume,
    required this.exercises,
  });

  factory Workout.create({
    required String name,
    required int duration,
    List<ExerciseSession>? exercises,
  }) {
    return Workout(
      id: const Uuid().v4(),
      name: name,
      date: DateTime.now(),
      duration: duration,
      totalVolume: exercises?.fold(0, (sum, e) => sum! + e.volume) ?? 0,
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
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      name: json['name'],
      date: DateTime.parse(json['date']),
      duration: json['duration'],
      totalVolume: json['totalVolume'],
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
  final List<ExerciseSet> sets;

  ExerciseSession({
    required this.id,
    required this.exerciseId,
    required this.name,
    required this.sets,
  });

  int get volume => sets.fold(0, (sum, set) => sum + (set.weight * set.reps));

  Map<String, dynamic> toJson() => {
    'id': id,
    'exerciseId': exerciseId,
    'name': name,
    'sets': sets.map((s) => s.toJson()).toList(),
  };

  factory ExerciseSession.fromJson(Map<String, dynamic> json) {
    return ExerciseSession(
      id: json['id'],
      exerciseId: json['exerciseId'],
      name: json['name'],
      sets: (json['sets'] as List).map((s) => ExerciseSet.fromJson(s)).toList(),
    );
  }
}

class ExerciseSet {
  final String id;
  final int weight;
  final int reps;
  final bool completed;

  ExerciseSet({
    required this.id,
    required this.weight,
    required this.reps,
    required this.completed,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'weight': weight,
    'reps': reps,
    'completed': completed,
  };

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      id: json['id'],
      weight: json['weight'],
      reps: json['reps'],
      completed: json['completed'],
    );
  }
}
