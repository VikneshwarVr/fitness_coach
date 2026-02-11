
import 'package:uuid/uuid.dart';

class Routine {
  final String id;
  final String name;
  final String description;
  final List<String> exerciseNames;
  final String level; // Beginner, Intermediate, Advanced
  final int duration; // Estimated duration in minutes
  final bool isCustom; // User-created vs default

  Routine({
    required this.id,
    required this.name,
    required this.description,
    required this.exerciseNames,
    required this.level,
    required this.duration,
    this.isCustom = false,
  });

  factory Routine.create({
    required String name,
    required String description,
    required List<String> exerciseNames,
    String level = 'Intermediate',
    int duration = 45,
    bool isCustom = false,
  }) {
    return Routine(
      id: const Uuid().v4(),
      name: name,
      description: description,
      exerciseNames: exerciseNames,
      level: level,
      duration: duration,
      isCustom: isCustom,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'exerciseNames': exerciseNames,
    'level': level,
    'duration': duration,
    'isCustom': isCustom,
  };

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      exerciseNames: List<String>.from(json['exerciseNames']),
      level: json['level'],
      duration: json['duration'],
      isCustom: json['isCustom'] ?? false,
    );
  }
}
