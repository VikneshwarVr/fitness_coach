class ExerciseData {
  static const List<Map<String, String>> exercises = [
    // Chest
    {'name': 'Bench Press', 'tag': 'Chest'},
    {'name': 'Incline Bench Press', 'tag': 'Chest'},
    {'name': 'Decline Bench Press', 'tag': 'Chest'},
    {'name': 'Dumbbell Bench Press', 'tag': 'Chest'},
    {'name': 'Incline Dumbbell Press', 'tag': 'Chest'},
    {'name': 'Decline Dumbbell Press', 'tag': 'Chest'},
    {'name': 'Chest Fly (Dumbbell)', 'tag': 'Chest'},
    {'name': 'Cable Fly', 'tag': 'Chest'},
    {'name': 'Machine Chest Press', 'tag': 'Chest'},
    {'name': 'Push-ups', 'tag': 'Chest', 'type': 'reps'},
    {'name': 'Weighted Push-ups', 'tag': 'Chest', 'type': 'strength'},
    {'name': 'Pec Deck', 'tag': 'Chest'},
    {'name': 'Single-arm Cable Press', 'tag': 'Chest'},
    {'name': 'Smith Machine Bench Press', 'tag': 'Chest'},
    {'name': 'Machine Fly', 'tag': 'Chest'},
    {'name': 'Svend Press', 'tag': 'Chest'},
    {'name': 'Incline Cable Fly', 'tag': 'Chest'},
    {'name': 'Decline Cable Fly', 'tag': 'Chest'},

    // Back
    {'name': 'Pull-ups', 'tag': 'Back', 'type': 'reps'},
    {'name': 'Chin-ups', 'tag': 'Back', 'type': 'reps'},
    {'name': 'Lat Pulldown', 'tag': 'Back'},
    {'name': 'Wide-Grip Lat Pulldown', 'tag': 'Back'},
    {'name': 'Close-Grip Lat Pulldown', 'tag': 'Back'},
    {'name': 'Barbell Row', 'tag': 'Back'},
    {'name': 'Dumbbell Row', 'tag': 'Back'},
    {'name': 'T-Bar Row', 'tag': 'Back'},
    {'name': 'Seated Cable Row', 'tag': 'Back'},
    {'name': 'Inverted Row', 'tag': 'Back'},
    {'name': 'Deadlift', 'tag': 'Back'},
    {'name': 'Rack Pull', 'tag': 'Back'},
    {'name': 'Straight-arm Pulldown', 'tag': 'Back'},
    {'name': 'Face Pull', 'tag': 'Back'},
    {'name': 'Back Extension', 'tag': 'Back'},
    {'name': 'Pendlay Row', 'tag': 'Back'},
    {'name': 'Meadows Row', 'tag': 'Back'},
    {'name': 'Single-arm Lat Pulldown', 'tag': 'Back'},
    {'name': 'Chest Supported Row', 'tag': 'Back'},
    {'name': 'Good Morning', 'tag': 'Back'},

    // Shoulders
    {'name': 'Overhead Press', 'tag': 'Shoulders'},
    {'name': 'Seated Dumbbell Press', 'tag': 'Shoulders'},
    {'name': 'Arnold Press', 'tag': 'Shoulders'},
    {'name': 'Lateral Raise', 'tag': 'Shoulders'},
    {'name': 'Cable Lateral Raise', 'tag': 'Shoulders'},
    {'name': 'Front Raise', 'tag': 'Shoulders'},
    {'name': 'Rear Delt Fly', 'tag': 'Shoulders'},
    {'name': 'Reverse Pec Deck', 'tag': 'Shoulders'},
    {'name': 'Upright Row', 'tag': 'Shoulders'},
    {'name': 'Landmine Press', 'tag': 'Shoulders'},
    {'name': 'Y-Raise', 'tag': 'Shoulders'},
    {'name': 'Machine Shoulder Press', 'tag': 'Shoulders'},
    {'name': 'Cable Front Raise', 'tag': 'Shoulders'},
    {'name': 'Dumbbell Front Raise', 'tag': 'Shoulders'},
    {'name': 'Behind-the-Neck Press', 'tag': 'Shoulders'},
    {'name': 'Bent-Over Dumbbell Raise', 'tag': 'Shoulders'},
    {'name': 'Pike Push-up', 'tag': 'Shoulders', 'type': 'reps'},
    {'name': 'Arnold Press', 'tag': 'Shoulders'},
    {'name': 'Cable Face Pull', 'tag': 'Shoulders'},
    {'name': 'Dumbbell Lateral Raise', 'tag': 'Shoulders'},
    {'name': 'Machine Lateral Raise', 'tag': 'Shoulders'},
    {'name': 'Single-arm Overhead Press', 'tag': 'Shoulders'},

    // Biceps
    {'name': 'Barbell Curl', 'tag': 'Biceps'},
    {'name': 'EZ-Bar Curl', 'tag': 'Biceps'},
    {'name': 'Dumbbell Curl', 'tag': 'Biceps'},
    {'name': 'Hammer Curl', 'tag': 'Biceps'},
    {'name': 'Preacher Curl', 'tag': 'Biceps'},
    {'name': 'Cable Curl', 'tag': 'Biceps'},
    {'name': 'Concentration Curl', 'tag': 'Biceps'},
    {'name': 'Incline Dumbbell Curl', 'tag': 'Biceps'},
    {'name': 'Reverse Curl', 'tag': 'Biceps'},
    {'name': 'Spider Curl', 'tag': 'Biceps'},
    {'name': 'Zottman Curl', 'tag': 'Biceps'},
    {'name': 'Cable Hammer Curl', 'tag': 'Biceps'},
    {'name': 'Dumbbell Preacher Curl', 'tag': 'Biceps'},
    {'name': 'Cross-Body Hammer Curl', 'tag': 'Biceps'},
    {'name': 'Machine Preacher Curl', 'tag': 'Biceps'},

    // Triceps
    {'name': 'Tricep Pushdown', 'tag': 'Triceps'},
    {'name': 'Rope Pushdown', 'tag': 'Triceps'},
    {'name': 'Skull Crushers', 'tag': 'Triceps'},
    {'name': 'Overhead Tricep Extension', 'tag': 'Triceps'},
    {'name': 'Dips', 'tag': 'Triceps', 'type': 'reps'},
    {'name': 'Bench Dips', 'tag': 'Triceps', 'type': 'reps'},
    {'name': 'Close-Grip Bench Press', 'tag': 'Triceps'},
    {'name': 'Cable Overhead Extension', 'tag': 'Triceps'},
    {'name': 'Single-arm Pushdown', 'tag': 'Triceps'},
    {'name': 'Tricep Kickback', 'tag': 'Triceps'},
    {'name': 'Dumbbell Skull Crusher', 'tag': 'Triceps'},
    {'name': 'Cable Rope Overhead Extension', 'tag': 'Triceps'},
    {'name': 'Machine Tricep Dip', 'tag': 'Triceps'},
    {'name': 'JM Press', 'tag': 'Triceps'},

    // Legs
    {'name': 'Back Squat', 'tag': 'Legs'},
    {'name': 'Front Squat', 'tag': 'Legs'},
    {'name': 'Goblet Squat', 'tag': 'Legs'},
    {'name': 'Leg Press', 'tag': 'Legs'},
    {'name': 'Hack Squat', 'tag': 'Legs'},
    {'name': 'Bulgarian Split Squat', 'tag': 'Legs'},
    {'name': 'Walking Lunges', 'tag': 'Legs', 'type': 'distance_meters'},
    {'name': 'Reverse Lunges', 'tag': 'Legs', 'type': 'reps'},
    {'name': 'Weighted Walking Lunges', 'tag': 'Legs', 'type': 'weighted_distance_meters'},
    {'name': 'Step-ups', 'tag': 'Legs', 'type': 'reps'},
    {'name': 'Leg Extension', 'tag': 'Legs'},
    {'name': 'Leg Curl', 'tag': 'Legs'},
    {'name': 'Romanian Deadlift', 'tag': 'Legs'},
    {'name': 'Stiff-Leg Deadlift', 'tag': 'Legs'},
    {'name': 'Glute Bridge', 'tag': 'Legs', 'type': 'reps'},
    {'name': 'Hip Thrust', 'tag': 'Legs'},
    {'name': 'Cable Kickback', 'tag': 'Legs'},
    {'name': 'Sumo Deadlift', 'tag': 'Legs'},
    {'name': 'Trap Bar Deadlift', 'tag': 'Legs'},
    {'name': 'Smith Machine Squat', 'tag': 'Legs'},
    {'name': 'Pistol Squat', 'tag': 'Legs'},
    {'name': 'Nordic Curl', 'tag': 'Legs'},
    {'name': 'Jefferson Squat', 'tag': 'Legs'},


    // Calves
    {'name': 'Standing Calf Raise', 'tag': 'Calves'},
    {'name': 'Seated Calf Raise', 'tag': 'Calves'},
    {'name': 'Single-leg Calf Raise', 'tag': 'Calves'},
    {'name': 'Leg Press Calf Raise', 'tag': 'Calves'},

    // Core / Abs
    {'name': 'Plank', 'tag': 'Core', 'type': 'timed'},
    {'name': 'Side Plank', 'tag': 'Core', 'type': 'timed'},
    {'name': 'Crunch', 'tag': 'Core', 'type': 'reps'},
    {'name': 'Sit-ups', 'tag': 'Core', 'type': 'reps'},
    {'name': 'Hanging Leg Raise', 'tag': 'Core', 'type': 'reps'},
    {'name': 'Lying Leg Raise', 'tag': 'Core', 'type': 'reps'},
    {'name': 'Cable Crunch', 'tag': 'Core'},
    {'name': 'Russian Twist', 'tag': 'Core', 'type': 'reps'},
    {'name': 'Mountain Climbers', 'tag': 'Core', 'type': 'reps'},
    {'name': 'Bicycle Crunch', 'tag': 'Core', 'type': 'reps'},
    {'name': 'Ab Wheel Rollout', 'tag': 'Core', 'type': 'reps'},
    {'name': 'Toe Touches', 'tag': 'Core', 'type': 'reps'},
    {'name': 'Dead Bug', 'tag': 'Core', 'type': 'reps'},
    {'name': 'Bird Dog', 'tag': 'Core', 'type': 'reps'},
    {'name': 'Hollow Hold', 'tag': 'Core', 'type': 'timed'},


    // Cardio
    {'name': 'Running', 'tag': 'Cardio', 'type': 'cardio'},
    {'name': 'Treadmill Walk', 'tag': 'Cardio', 'type': 'cardio'},
    {'name': 'Cycling', 'tag': 'Cardio', 'type': 'cardio'},
    {'name': 'Stationary Bike', 'tag': 'Cardio', 'type': 'cardio'},
    {'name': 'Jump Rope', 'tag': 'Cardio', 'type': 'cardio'},
    {'name': 'Rowing Machine', 'tag': 'Cardio', 'type': 'cardio'},
    {'name': 'Elliptical', 'tag': 'Cardio', 'type': 'cardio'},
    {'name': 'Stair Climber', 'tag': 'Cardio', 'type': 'cardio'},
    {'name': 'HIIT', 'tag': 'Cardio', 'type': 'cardio'},

    // Functional / Full-Body
    {'name': 'Burpees', 'tag': 'Full Body', 'type': 'reps'},
    {'name': 'Kettlebell Swing', 'tag': 'Full Body'},
    {'name': 'Farmer’s Carry', 'tag': 'Full Body', 'type': 'distance_time_meters'},
    {'name': 'Battle Ropes', 'tag': 'Full Body', 'type': 'timed'},
    {'name': 'Sled Push', 'tag': 'Full Body', 'type': 'distance_meters'},
    {'name': 'Medicine Ball Slam', 'tag': 'Full Body', 'type': 'reps'},
    {'name': 'Clean and Press', 'tag': 'Full Body'},
    {'name': 'Snatch', 'tag': 'Full Body'},
  ];
  static const Map<String, Map<String, int>> detailedMuscles = {
    // Chest
    'Bench Press': {'Chest': 60, 'Triceps': 30, 'Shoulders': 10},
    'Incline Bench Press': {'Chest': 50, 'Triceps': 25, 'Shoulders': 25},
    'Decline Bench Press': {'Chest': 55, 'Triceps': 25, 'Shoulders': 20},
    'Dumbbell Bench Press': {'Chest': 60, 'Triceps': 30, 'Shoulders': 10},
    'Incline Dumbbell Press': {'Chest': 50, 'Triceps': 25, 'Shoulders': 25},
    'Decline Dumbbell Press': {'Chest': 55, 'Triceps': 25, 'Shoulders': 20},
    'Chest Fly (Dumbbell)': {'Chest': 80, 'Shoulders': 20},
    'Cable Fly': {'Chest': 80, 'Shoulders': 20},
    'Machine Chest Press': {'Chest': 60, 'Triceps': 30, 'Shoulders': 10},
    'Push-ups': {'Chest': 60, 'Triceps': 30, 'Shoulders': 10},
    'Weighted Push-ups': {'Chest': 60, 'Triceps': 30, 'Shoulders': 10},
    'Pec Deck': {'Chest': 80, 'Shoulders': 20},
    'Single-arm Cable Press': {'Chest': 60, 'Triceps': 30, 'Shoulders': 10},

    // Back
    'Pull-ups': {'Lats': 50, 'Biceps': 30, 'Shoulders': 20},
    'Chin-ups': {'Lats': 50, 'Biceps': 35, 'Shoulders': 15},
    'Lat Pulldown': {'Lats': 60, 'Biceps': 30, 'Shoulders': 10},
    'Wide-Grip Lat Pulldown': {'Lats': 65, 'Biceps': 25, 'Shoulders': 10},
    'Close-Grip Lat Pulldown': {'Lats': 55, 'Biceps': 35, 'Shoulders': 10},
    'Barbell Row': {'Upper Back': 40, 'Lats': 40, 'Biceps': 20},
    'Dumbbell Row': {'Upper Back': 40, 'Lats': 40, 'Biceps': 20},
    'T-Bar Row': {'Upper Back': 40, 'Lats': 40, 'Biceps': 20},
    'Seated Cable Row': {'Upper Back': 40, 'Lats': 40, 'Biceps': 20},
    'Inverted Row': {'Upper Back': 40, 'Lats': 40, 'Biceps': 20},
    'Deadlift': {'Lower Back': 30, 'Glutes': 30, 'Hamstrings': 20, 'Forearms': 20},
    'Rack Pull': {'Lower Back': 40, 'Glutes': 30, 'Hamstrings': 20, 'Forearms': 10},
    'Straight-arm Pulldown': {'Lats': 70, 'Forearms': 30},
    'Face Pull': {'Rear Delts': 40, 'Traps': 30, 'Biceps': 30},
    'Back Extension': {'Lower Back': 70, 'Glutes': 20, 'Hamstrings': 10},

    // Shoulders
    'Overhead Press': {'Shoulders': 60, 'Triceps': 25, 'Chest': 15},
    'Seated Dumbbell Press': {'Shoulders': 60, 'Triceps': 25, 'Chest': 15},
    'Arnold Press': {'Shoulders': 60, 'Triceps': 30, 'Chest': 10},
    'Lateral Raise': {'Side Delts': 90, 'Traps': 10},
    'Cable Lateral Raise': {'Side Delts': 90, 'Traps': 10},
    'Front Raise': {'Front Delts': 90, 'Traps': 10},
    'Rear Delt Fly': {'Rear Delts': 80, 'Upper Back': 20},
    'Reverse Pec Deck': {'Rear Delts': 80, 'Upper Back': 20},
    'Upright Row': {'Shoulders': 60, 'Traps': 30, 'Biceps': 10},
    'Landmine Press': {'Shoulders': 60, 'Chest': 25, 'Triceps': 15},
    'Y-Raise': {'Rear Delts': 80, 'Upper Back': 20},

    // Biceps
    'Barbell Curl': {'Biceps': 75, 'Forearms': 25},
    'EZ-Bar Curl': {'Biceps': 70, 'Forearms': 30},
    'Dumbbell Curl': {'Biceps': 70, 'Forearms': 30},
    'Hammer Curl': {'Biceps': 40, 'Forearms': 60},
    'Preacher Curl': {'Biceps': 80, 'Forearms': 20},
    'Cable Curl': {'Biceps': 75, 'Forearms': 25},
    'Concentration Curl': {'Biceps': 85, 'Forearms': 15},
    'Incline Dumbbell Curl': {'Biceps': 80, 'Forearms': 20},
    'Reverse Curl': {'Forearms': 70, 'Biceps': 30},
    'Spider Curl': {'Biceps': 85, 'Forearms': 15},

    // Triceps
    'Tricep Pushdown': {'Triceps': 100},
    'Rope Pushdown': {'Triceps': 100},
    'Skull Crushers': {'Triceps': 100},
    'Overhead Tricep Extension': {'Triceps': 100},
    'Dips': {'Chest': 40, 'Triceps': 60},
    'Bench Dips': {'Chest': 40, 'Triceps': 60},
    'Close-Grip Bench Press': {'Chest': 50, 'Triceps': 50},
    'Cable Overhead Extension': {'Triceps': 100},
    'Single-arm Pushdown': {'Triceps': 100},

    // Legs
    'Back Squat': {'Quadriceps': 50, 'Glutes': 30, 'Hamstrings': 15, 'Lower Back': 5},
    'Front Squat': {'Quadriceps': 60, 'Glutes': 25, 'Hamstrings': 10, 'Lower Back': 5},
    'Goblet Squat': {'Quadriceps': 60, 'Glutes': 30, 'Hamstrings': 10},
    'Leg Press': {'Quadriceps': 70, 'Glutes': 20, 'Hamstrings': 10},
    'Hack Squat': {'Quadriceps': 70, 'Glutes': 20, 'Hamstrings': 10},
    'Bulgarian Split Squat': {'Quadriceps': 50, 'Glutes': 40, 'Hamstrings': 10},
    'Walking Lunges': {'Quadriceps': 50, 'Glutes': 40, 'Hamstrings': 10},
    'Reverse Lunges': {'Quadriceps': 50, 'Glutes': 40, 'Hamstrings': 10},
    'Step-ups': {'Quadriceps': 50, 'Glutes': 40, 'Hamstrings': 10},
    'Leg Extension': {'Quadriceps': 100},
    'Leg Curl': {'Hamstrings': 100},
    'Romanian Deadlift': {'Hamstrings': 50, 'Glutes': 40, 'Lower Back': 10},
    'Stiff-Leg Deadlift': {'Hamstrings': 50, 'Glutes': 40, 'Lower Back': 10},
    'Glute Bridge': {'Glutes': 80, 'Hamstrings': 20},
    'Hip Thrust': {'Glutes': 80, 'Hamstrings': 20},
    'Cable Kickback': {'Glutes': 80, 'Hamstrings': 20},
    'Sumo Deadlift': {'Quadriceps': 40, 'Glutes': 40, 'Hamstrings': 15, 'Lower Back': 5},

    // Calves
    'Standing Calf Raise': {'Calves': 100},
    'Seated Calf Raise': {'Calves': 100},
    'Single-leg Calf Raise': {'Calves': 100},
    'Leg Press Calf Raise': {'Calves': 100},

    // Core / Abs
    'Plank': {'Abdominals': 70, 'Lower Back': 30},
    'Side Plank': {'Obliques': 70, 'Abdominals': 30},
    'Crunch': {'Abdominals': 100},
    'Sit-ups': {'Abdominals': 100},
    'Hanging Leg Raise': {'Abdominals': 70, 'Hip Flexors': 30},
    'Lying Leg Raise': {'Abdominals': 70, 'Hip Flexors': 30},
    'Cable Crunch': {'Abdominals': 100},
    'Russian Twist': {'Abdominals': 60, 'Obliques': 40},
    'Mountain Climbers': {'Abdominals': 50, 'Hip Flexors': 30, 'Cardio': 20},
    'Bicycle Crunch': {'Abdominals': 60, 'Obliques': 40},
    'Ab Wheel Rollout': {'Abdominals': 70, 'Lower Back': 30},
    'Toe Touches': {'Abdominals': 100},

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

    // Full Body / Functional
    'Burpees': {'Full Body': 100},
    'Kettlebell Swing': {'Glutes': 40, 'Hamstrings': 30, 'Shoulders': 15, 'Core': 15},
    'Farmer’s Carry': {'Forearms': 40, 'Shoulders': 30, 'Core': 30},
    'Battle Ropes': {'Shoulders': 40, 'Arms': 30, 'Core': 20, 'Cardio': 10},
    'Sled Push': {'Legs': 40, 'Glutes': 30, 'Shoulders': 20, 'Core': 10},
    'Medicine Ball Slam': {'Shoulders': 40, 'Core': 40, 'Arms': 20},
    'Clean and Press': {'Legs': 30, 'Glutes': 20, 'Shoulders': 30, 'Arms': 20},
    'Snatch': {'Legs': 30, 'Glutes': 20, 'Shoulders': 30, 'Arms': 20},
  };

  static String getCategory(String name) {
    final exerciseData = exercises.firstWhere(
      (e) => e['name'] == name,
      orElse: () => {'tag': 'Strength', 'type': 'strength'},
    );

    final type = exerciseData['type'] ?? (exerciseData['tag'] == 'Cardio' ? 'cardio' : 'strength');

    if (type == 'cardio') {
      return 'Cardio';
    } else if (type == 'timed') {
      return 'Timed';
    } else if (type == 'reps') {
      return 'Bodyweight';
    } else if (type == 'distance') {
      return 'Distance';
    } else if (type == 'distance_meters') {
      return 'DistanceMeters';
    } else if (type == 'weighted_distance_meters') {
      return 'WeightedDistanceMeters';
    } else if (type == 'distance_time_meters') {
      return 'DistanceTimeMeters';
    }
    return 'Strength';
  }
}
