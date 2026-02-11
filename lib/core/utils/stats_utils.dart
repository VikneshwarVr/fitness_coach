import '../../data/models/workout.dart';

class StatsUtils {
  static const Map<String, Map<String, int>> majorCategories = {
    // Chest
    'Bench Press': {'Chest': 60, 'Arms': 30, 'Shoulders': 10},
    'Incline Bench Press': {'Chest': 50, 'Arms': 25, 'Shoulders': 25},
    'Decline Bench Press': {'Chest': 55, 'Arms': 25, 'Shoulders': 20},
    'Dumbbell Bench Press': {'Chest': 60, 'Arms': 30, 'Shoulders': 10},
    'Incline Dumbbell Press': {'Chest': 50, 'Arms': 25, 'Shoulders': 25},
    'Decline Dumbbell Press': {'Chest': 55, 'Arms': 25, 'Shoulders': 20},
    'Chest Fly (Dumbbell)': {'Chest': 80, 'Shoulders': 20},
    'Cable Fly': {'Chest': 80, 'Shoulders': 20},
    'Machine Chest Press': {'Chest': 60, 'Arms': 30, 'Shoulders': 10},
    'Push-ups': {'Chest': 60, 'Arms': 30, 'Shoulders': 10},
    'Weighted Push-ups': {'Chest': 60, 'Arms': 30, 'Shoulders': 10},
    'Pec Deck': {'Chest': 80, 'Shoulders': 20},
    'Single-arm Cable Press': {'Chest': 60, 'Arms': 30, 'Shoulders': 10},

    // Back
    'Pull-ups': {'Back': 60, 'Arms': 30, 'Shoulders': 10},
    'Chin-ups': {'Back': 55, 'Arms': 35, 'Shoulders': 10},
    'Lat Pulldown': {'Back': 60, 'Arms': 30, 'Shoulders': 10},
    'Wide-Grip Lat Pulldown': {'Back': 65, 'Arms': 25, 'Shoulders': 10},
    'Close-Grip Lat Pulldown': {'Back': 55, 'Arms': 35, 'Shoulders': 10},
    'Barbell Row': {'Back': 60, 'Arms': 25, 'Shoulders': 15},
    'Dumbbell Row': {'Back': 60, 'Arms': 25, 'Shoulders': 15},
    'T-Bar Row': {'Back': 60, 'Arms': 25, 'Shoulders': 15},
    'Seated Cable Row': {'Back': 60, 'Arms': 25, 'Shoulders': 15},
    'Inverted Row': {'Back': 60, 'Arms': 25, 'Shoulders': 15},
    'Deadlift': {'Back': 50, 'Legs': 30, 'Glutes': 20},
    'Rack Pull': {'Back': 60, 'Legs': 20, 'Glutes': 20},
    'Straight-arm Pulldown': {'Back': 70, 'Arms': 30},
    'Face Pull': {'Back': 40, 'Shoulders': 40, 'Arms': 20},
    'Back Extension': {'Back': 70, 'Glutes': 20, 'Legs': 10},

    // Shoulders
    'Overhead Press': {'Shoulders': 60, 'Arms': 25, 'Chest': 15},
    'Seated Dumbbell Press': {'Shoulders': 60, 'Arms': 25, 'Chest': 15},
    'Arnold Press': {'Shoulders': 60, 'Arms': 30, 'Chest': 10},
    'Lateral Raise': {'Shoulders': 90, 'Arms': 10},
    'Cable Lateral Raise': {'Shoulders': 90, 'Arms': 10},
    'Front Raise': {'Shoulders': 90, 'Arms': 10},
    'Rear Delt Fly': {'Shoulders': 80, 'Back': 20},
    'Reverse Pec Deck': {'Shoulders': 80, 'Back': 20},
    'Upright Row': {'Shoulders': 60, 'Arms': 30, 'Back': 10},
    'Landmine Press': {'Shoulders': 60, 'Chest': 25, 'Arms': 15},
    'Y-Raise': {'Shoulders': 80, 'Back': 20},

    // Biceps
    'Barbell Curl': {'Arms': 100},
    'EZ-Bar Curl': {'Arms': 100},
    'Dumbbell Curl': {'Arms': 100},
    'Hammer Curl': {'Arms': 100},
    'Preacher Curl': {'Arms': 100},
    'Cable Curl': {'Arms': 100},
    'Concentration Curl': {'Arms': 100},
    'Incline Dumbbell Curl': {'Arms': 100},
    'Reverse Curl': {'Arms': 100},
    'Spider Curl': {'Arms': 100},

    // Triceps
    'Tricep Pushdown': {'Arms': 100},
    'Rope Pushdown': {'Arms': 100},
    'Skull Crushers': {'Arms': 100},
    'Overhead Tricep Extension': {'Arms': 100},
    'Dips': {'Chest': 40, 'Arms': 60},
    'Bench Dips': {'Chest': 40, 'Arms': 60},
    'Close-Grip Bench Press': {'Chest': 50, 'Arms': 50},
    'Cable Overhead Extension': {'Arms': 100},
    'Single-arm Pushdown': {'Arms': 100},

    // Legs
    'Back Squat': {'Legs': 70, 'Glutes': 20, 'Back': 10},
    'Front Squat': {'Legs': 70, 'Glutes': 20, 'Back': 10},
    'Goblet Squat': {'Legs': 70, 'Glutes': 20, 'Back': 10},
    'Leg Press': {'Legs': 80, 'Glutes': 15, 'Back': 5},
    'Hack Squat': {'Legs': 80, 'Glutes': 15, 'Back': 5},
    'Bulgarian Split Squat': {'Legs': 75, 'Glutes': 20, 'Balance': 5},
    'Walking Lunges': {'Legs': 70, 'Glutes': 25, 'Balance': 5},
    'Reverse Lunges': {'Legs': 70, 'Glutes': 25, 'Balance': 5},
    'Step-ups': {'Legs': 70, 'Glutes': 25, 'Balance': 5},
    'Leg Extension': {'Legs': 100},
    'Leg Curl': {'Legs': 100},
    'Romanian Deadlift': {'Legs': 60, 'Glutes': 30, 'Back': 10},
    'Stiff-Leg Deadlift': {'Legs': 60, 'Glutes': 30, 'Back': 10},
    'Glute Bridge': {'Glutes': 80, 'Legs': 20},
    'Hip Thrust': {'Glutes': 80, 'Legs': 20},
    'Cable Kickback': {'Glutes': 80, 'Legs': 20},
    'Sumo Deadlift': {'Legs': 50, 'Glutes': 40, 'Back': 10},

    // Calves
    'Standing Calf Raise': {'Legs': 100},
    'Seated Calf Raise': {'Legs': 100},
    'Single-leg Calf Raise': {'Legs': 100},
    'Leg Press Calf Raise': {'Legs': 100},

    // Core / Abs
    'Plank': {'Core': 100},
    'Side Plank': {'Core': 100},
    'Crunch': {'Core': 100},
    'Sit-ups': {'Core': 100},
    'Hanging Leg Raise': {'Core': 100},
    'Lying Leg Raise': {'Core': 100},
    'Cable Crunch': {'Core': 100},
    'Russian Twist': {'Core': 100},
    'Mountain Climbers': {'Core': 100},
    'Bicycle Crunch': {'Core': 100},
    'Ab Wheel Rollout': {'Core': 100},
    'Toe Touches': {'Core': 100},

    // Cardio
    'Running': {'Cardio': 100},
    'Treadmill Walk': {'Cardio': 100},
    'Cycling': {'Cardio': 100},
    'Stationary Bike': {'Cardio': 100},
    'Jump Rope': {'Cardio': 100},
    'Rowing Machine': {'Cardio': 100},
    'Elliptical': {'Cardio': 100},
    'Stair Climber': {'Cardio': 100},
    'HIIT': {'Cardio': 100},
    'Swimming': {'Cardio': 100},

    // Full Body
    'Burpees': {'Full Body': 100},
    'Kettlebell Swing': {'Full Body': 100},
    'Farmer’s Carry': {'Full Body': 100},
    'Battle Ropes': {'Full Body': 100},
    'Sled Push': {'Full Body': 100},
    'Medicine Ball Slam': {'Full Body': 100},
    'Clean and Press': {'Full Body': 100},
    'Snatch': {'Full Body': 100},
  };

  static const List<String> muscleGroups = ['Back', 'Chest', 'Core', 'Shoulders', 'Arms', 'Legs'];

  static String _normalize(String name) => name.trim().toLowerCase();

  static List<double> getRadarStats(List<Workout> workouts, {bool isWeekly = true}) {
    final filteredWorkouts = _filterWorkouts(workouts, isWeekly);
    final d = <String, double>{};

    final normalizedMap = majorCategories.map((key, value) => MapEntry(_normalize(key), value));

    for (var w in filteredWorkouts) {
      for (var s in w.exercises) {
        final dist = normalizedMap[_normalize(s.name)];
        if (dist != null) {
          final setCount = s.sets.length;
          dist.forEach((targetMg, percentage) {
            String mg = targetMg;
            if (mg == 'Glutes' || mg == 'Calves') mg = 'Legs';
            if (muscleGroups.contains(mg)) {
              d[mg] = (d[mg] ?? 0) + (setCount * percentage / 100.0);
            }
          });
        }
      }
    }

    return muscleGroups.map((mg) => d[mg] ?? 0.0).toList();
  }

  static Map<String, double> getMuscleGroupDistribution(List<Workout> workouts, {bool isWeekly = true}) {
    final filteredWorkouts = _filterWorkouts(workouts, isWeekly);
    final distribution = <String, double>{};
    final normalizedMap = majorCategories.map((key, value) => MapEntry(_normalize(key), value));

    for (var workout in filteredWorkouts) {
      for (var session in workout.exercises) {
        final dist = normalizedMap[_normalize(session.name)];
        if (dist != null) {
          final setCount = session.sets.length;
          dist.forEach((mg, percentage) {
            distribution[mg] = (distribution[mg] ?? 0) + (setCount * percentage / 100.0);
          });
        }
      }
    }

    return distribution;
  }

  static List<Map<String, dynamic>> getAggregatedStats(
    List<Workout> workouts, {
    bool isWeekly = true,
    required String metric,
  }) {
    final filteredWorkouts = _filterWorkouts(workouts, isWeekly);
    final count = isWeekly ? 7 : 4;
    final stats = List.generate(count, (index) => {
      'label': isWeekly ? _getDayLabel(index) : 'Week ${index + 1}',
      'value': 0.0
    });

    final now = DateTime.now();

    for (var workout in filteredWorkouts) {
      int index;
      if (isWeekly) {
        index = workout.date.weekday - 1;
      } else {
        final daysAgo = now.difference(workout.date).inDays;
        index = (3 - (daysAgo / 7).floor()).clamp(0, 3);
      }

      double val = 0;
      switch (metric) {
        case 'Volume':
          val = workout.totalVolume / 1000.0;
          break;
        case 'Reps':
          val = workout.exercises.fold(0.0, (sum, e) => sum + e.sets.fold(0, (sSum, s) => sSum + s.reps));
          break;
        case 'Sets':
          val = workout.exercises.fold(0.0, (sum, e) => sum + e.sets.length);
          break;
        case 'Duration':
          val = workout.duration.toDouble();
          break;
      }
      stats[index]['value'] = (stats[index]['value'] as double) + val;
    }
    return stats;
  }

  static List<Workout> _filterWorkouts(List<Workout> workouts, bool isWeekly) {
    final now = DateTime.now();
    final limit = isWeekly ? now.subtract(const Duration(days: 7)) : now.subtract(const Duration(days: 30));
    return workouts.where((w) => w.date.isAfter(limit)).toList();
  }

  static String _getDayLabel(int weekdayIndex) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[weekdayIndex];
  }
}
