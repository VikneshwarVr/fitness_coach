
import '../providers/settings_provider.dart';

class ExerciseData {
  static const List<Map<String, String>> exercises = [
    // ---------- WARMUP (Home/Both) ----------
    {'name': 'Jumping Jacks', 'tag': 'Warmup', 'type': 'timed', 'mode': 'both'},
    {'name': 'Arm Circles', 'tag': 'Warmup', 'type': 'timed', 'mode': 'both'},
    {'name': 'High Knees', 'tag': 'Warmup', 'type': 'timed', 'mode': 'both'},
    {'name': 'Butt Kicks', 'tag': 'Warmup', 'type': 'timed', 'mode': 'both'},
    {'name': 'Torso Twists', 'tag': 'Warmup', 'type': 'timed', 'mode': 'both'},

    // ---------- CHEST ----------
    {'name': 'Bench Press', 'tag': 'Chest', 'mode': 'gym'},
    {'name': 'Incline Bench Press', 'tag': 'Chest', 'mode': 'gym'},
    {'name': 'Decline Bench Press', 'tag': 'Chest', 'mode': 'gym'},
    {'name': 'Dumbbell Bench Press', 'tag': 'Chest', 'mode': 'gym'},
    {'name': 'Incline Dumbbell Press', 'tag': 'Chest', 'mode': 'gym'},
    {'name': 'Decline Dumbbell Press', 'tag': 'Chest', 'mode': 'gym'},
    {'name': 'Chest Fly (Dumbbell)', 'tag': 'Chest', 'mode': 'gym'},
    {'name': 'Cable Fly', 'tag': 'Chest', 'mode': 'gym'},
    {'name': 'Machine Chest Press', 'tag': 'Chest', 'mode': 'gym'},
    {'name': 'Push-ups', 'tag': 'Chest', 'type': 'reps', 'mode': 'both'},
    {'name': 'Knee Push-ups', 'tag': 'Chest', 'type': 'reps', 'mode': 'home'},
    {'name': 'Decline Push-ups', 'tag': 'Chest', 'type': 'reps', 'mode': 'home'},
    {'name': 'Diamond Push-ups', 'tag': 'Chest', 'type': 'reps', 'mode': 'home'},
    {'name': 'Wall Push-ups', 'tag': 'Chest', 'type': 'reps', 'mode': 'home'},
    {'name': 'Weighted Push-ups', 'tag': 'Chest', 'type': 'strength', 'mode': 'gym'},
    {'name': 'Pec Deck', 'tag': 'Chest', 'mode': 'gym'},
    {'name': 'Single-arm Cable Press', 'tag': 'Chest', 'mode': 'gym'},
    {'name': 'Smith Machine Bench Press', 'tag': 'Chest', 'mode': 'gym'},
    {'name': 'Machine Fly', 'tag': 'Chest', 'mode': 'gym'},
    {'name': 'Svend Press', 'tag': 'Chest', 'mode': 'gym'},
    {'name': 'Incline Cable Fly', 'tag': 'Chest', 'mode': 'gym'},
    {'name': 'Decline Cable Fly', 'tag': 'Chest', 'mode': 'gym'},

    // ---------- BACK ----------
    {'name': 'Pull-ups', 'tag': 'Back', 'type': 'reps', 'mode': 'both'},
    {'name': 'Chin-ups', 'tag': 'Back', 'type': 'reps', 'mode': 'both'},
    {'name': 'Lat Pulldown', 'tag': 'Back', 'mode': 'gym'},
    {'name': 'Wide-Grip Lat Pulldown', 'tag': 'Back', 'mode': 'gym'},
    {'name': 'Close-Grip Lat Pulldown', 'tag': 'Back', 'mode': 'gym'},
    {'name': 'Barbell Row', 'tag': 'Back', 'mode': 'gym'},
    {'name': 'Dumbbell Row', 'tag': 'Back', 'mode': 'gym'},
    {'name': 'T-Bar Row', 'tag': 'Back', 'mode': 'gym'},
    {'name': 'Seated Cable Row', 'tag': 'Back', 'mode': 'gym'},
    {'name': 'Inverted Row', 'tag': 'Back', 'mode': 'both'},
    {'name': 'Deadlift', 'tag': 'Back', 'mode': 'gym'},
    {'name': 'Rack Pull', 'tag': 'Back', 'mode': 'gym'},
    {'name': 'Straight-arm Pulldown', 'tag': 'Back', 'mode': 'gym'},
    {'name': 'Face Pull', 'tag': 'Back', 'mode': 'gym'},
    {'name': 'Back Extension', 'tag': 'Back', 'mode': 'gym'},
    {'name': 'Pendlay Row', 'tag': 'Back', 'mode': 'gym'},
    {'name': 'Meadows Row', 'tag': 'Back', 'mode': 'gym'},
    {'name': 'Single-arm Lat Pulldown', 'tag': 'Back', 'mode': 'gym'},
    {'name': 'Chest Supported Row', 'tag': 'Back', 'mode': 'gym'},
    {'name': 'Good Morning', 'tag': 'Back', 'mode': 'gym'},

    // ---------- SHOULDERS ----------
    {'name': 'Overhead Press', 'tag': 'Shoulders', 'mode': 'gym'},
    {'name': 'Seated Dumbbell Press', 'tag': 'Shoulders', 'mode': 'gym'},
    {'name': 'Arnold Press', 'tag': 'Shoulders', 'mode': 'gym'},
    {'name': 'Lateral Raise', 'tag': 'Shoulders', 'mode': 'gym'},
    {'name': 'Cable Lateral Raise', 'tag': 'Shoulders', 'mode': 'gym'},
    {'name': 'Front Raise', 'tag': 'Shoulders', 'mode': 'gym'},
    {'name': 'Rear Delt Fly', 'tag': 'Shoulders', 'mode': 'gym'},
    {'name': 'Reverse Pec Deck', 'tag': 'Shoulders', 'mode': 'gym'},
    {'name': 'Upright Row', 'tag': 'Shoulders', 'mode': 'gym'},
    {'name': 'Landmine Press', 'tag': 'Shoulders', 'mode': 'gym'},
    {'name': 'Y-Raise', 'tag': 'Shoulders', 'mode': 'gym'},
    {'name': 'Machine Shoulder Press', 'tag': 'Shoulders', 'mode': 'gym'},
    {'name': 'Cable Front Raise', 'tag': 'Shoulders', 'mode': 'gym'},
    {'name': 'Dumbbell Front Raise', 'tag': 'Shoulders', 'mode': 'gym'},
    {'name': 'Behind-the-Neck Press', 'tag': 'Shoulders', 'mode': 'gym'},
    {'name': 'Bent-Over Dumbbell Raise', 'tag': 'Shoulders', 'mode': 'gym'},
    {'name': 'Pike Push-up', 'tag': 'Shoulders', 'type': 'reps', 'mode': 'home'},
    {'name': 'Pike Push-ups', 'tag': 'Shoulders', 'type': 'reps', 'mode': 'home'}, 
    {'name': 'Cable Face Pull', 'tag': 'Shoulders', 'mode': 'gym'},
    {'name': 'Dumbbell Lateral Raise', 'tag': 'Shoulders', 'mode': 'gym'},
    {'name': 'Machine Lateral Raise', 'tag': 'Shoulders', 'mode': 'gym'},
    {'name': 'Single-arm Overhead Press', 'tag': 'Shoulders', 'mode': 'gym'},

    // ---------- BICEPS ----------
    {'name': 'Barbell Curl', 'tag': 'Biceps', 'mode': 'gym'},
    {'name': 'EZ-Bar Curl', 'tag': 'Biceps', 'mode': 'gym'},
    {'name': 'Dumbbell Curl', 'tag': 'Biceps', 'mode': 'gym'},
    {'name': 'Hammer Curl', 'tag': 'Biceps', 'mode': 'gym'},
    {'name': 'Preacher Curl', 'tag': 'Biceps', 'mode': 'gym'},
    {'name': 'Cable Curl', 'tag': 'Biceps', 'mode': 'gym'},
    {'name': 'Concentration Curl', 'tag': 'Biceps', 'mode': 'gym'},
    {'name': 'Incline Dumbbell Curl', 'tag': 'Biceps', 'mode': 'gym'},
    {'name': 'Reverse Curl', 'tag': 'Biceps', 'mode': 'gym'},
    {'name': 'Spider Curl', 'tag': 'Biceps', 'mode': 'gym'},
    {'name': 'Zottman Curl', 'tag': 'Biceps', 'mode': 'gym'},
    {'name': 'Cable Hammer Curl', 'tag': 'Biceps', 'mode': 'gym'},
    {'name': 'Dumbbell Preacher Curl', 'tag': 'Biceps', 'mode': 'gym'},
    {'name': 'Cross-Body Hammer Curl', 'tag': 'Biceps', 'mode': 'gym'},
    {'name': 'Machine Preacher Curl', 'tag': 'Biceps', 'mode': 'gym'},

    // ---------- TRICEPS ----------
    {'name': 'Tricep Pushdown', 'tag': 'Triceps', 'mode': 'gym'},
    {'name': 'Rope Pushdown', 'tag': 'Triceps', 'mode': 'gym'},
    {'name': 'Skull Crushers', 'tag': 'Triceps', 'mode': 'gym'},
    {'name': 'Overhead Tricep Extension', 'tag': 'Triceps', 'mode': 'gym'},
    {'name': 'Dips', 'tag': 'Triceps', 'type': 'reps', 'mode': 'both'},
    {'name': 'Chair Dips', 'tag': 'Triceps', 'type': 'reps', 'mode': 'home'},
    {'name': 'Bench Dips', 'tag': 'Triceps', 'type': 'reps', 'mode': 'home'},
    {'name': 'Close-Grip Bench Press', 'tag': 'Triceps', 'mode': 'gym'},
    {'name': 'Cable Overhead Extension', 'tag': 'Triceps', 'mode': 'gym'},
    {'name': 'Single-arm Pushdown', 'tag': 'Triceps', 'mode': 'gym'},
    {'name': 'Tricep Kickback', 'tag': 'Triceps', 'mode': 'gym'},
    {'name': 'Dumbbell Skull Crusher', 'tag': 'Triceps', 'mode': 'gym'},
    {'name': 'Cable Rope Overhead Extension', 'tag': 'Triceps', 'mode': 'gym'},
    {'name': 'Machine Tricep Dip', 'tag': 'Triceps', 'mode': 'gym'},
    {'name': 'JM Press', 'tag': 'Triceps', 'mode': 'gym'},

    // ---------- LEGS ----------
    {'name': 'Back Squat', 'tag': 'Legs', 'mode': 'gym'},
    {'name': 'Front Squat', 'tag': 'Legs', 'mode': 'gym'},
    {'name': 'Goblet Squat', 'tag': 'Legs', 'mode': 'gym'},
    {'name': 'Leg Press', 'tag': 'Legs', 'mode': 'gym'},
    {'name': 'Hack Squat', 'tag': 'Legs', 'mode': 'gym'},
    {'name': 'Bulgarian Split Squat', 'tag': 'Legs', 'mode': 'gym'},
    {'name': 'Walking Lunges', 'tag': 'Legs', 'type': 'distance_meters', 'mode': 'both'},
    {'name': 'Reverse Lunges', 'tag': 'Legs', 'type': 'reps', 'mode': 'both'},
    {'name': 'Weighted Walking Lunges', 'tag': 'Legs', 'type': 'weighted_distance_meters', 'mode': 'gym'},
    {'name': 'Step-ups', 'tag': 'Legs', 'type': 'reps', 'mode': 'both'},
    {'name': 'Leg Extension', 'tag': 'Legs', 'mode': 'gym'},
    {'name': 'Leg Curl', 'tag': 'Legs', 'mode': 'gym'},
    {'name': 'Romanian Deadlift', 'tag': 'Legs', 'mode': 'gym'},
    {'name': 'Stiff-Leg Deadlift', 'tag': 'Legs', 'mode': 'gym'},
    {'name': 'Glute Bridge', 'tag': 'Legs', 'type': 'reps', 'mode': 'both'},
    {'name': 'Hip Thrust', 'tag': 'Legs', 'mode': 'gym'},
    {'name': 'Cable Kickback', 'tag': 'Legs', 'mode': 'gym'},
    {'name': 'Sumo Deadlift', 'tag': 'Legs', 'mode': 'gym'},
    {'name': 'Trap Bar Deadlift', 'tag': 'Legs', 'mode': 'gym'},
    {'name': 'Smith Machine Squat', 'tag': 'Legs', 'mode': 'gym'},
    {'name': 'Pistol Squat', 'tag': 'Legs', 'mode': 'both'},
    {'name': 'Nordic Curl', 'tag': 'Legs', 'mode': 'both'},
    {'name': 'Jefferson Squat', 'tag': 'Legs', 'mode': 'gym'},
    
    // Home Legs
    {'name': 'Free Squats', 'tag': 'Legs', 'type': 'reps', 'mode': 'home'},
    {'name': 'Half Squats', 'tag': 'Legs', 'type': 'reps', 'mode': 'home'},
    {'name': 'Sumo Squats', 'tag': 'Legs', 'type': 'reps', 'mode': 'home'},
    {'name': 'Pulse Squats', 'tag': 'Legs', 'type': 'reps', 'mode': 'home'},
    {'name': 'Step-back Lunges', 'tag': 'Legs', 'type': 'reps', 'mode': 'home'},
    {'name': 'Lateral Lunges', 'tag': 'Legs', 'type': 'reps', 'mode': 'home'},
    {'name': 'Single-leg Glute Bridge', 'tag': 'Legs', 'type': 'reps', 'mode': 'home'},
    {'name': 'Wall Sit', 'tag': 'Legs', 'type': 'timed', 'mode': 'home'},

    // ---------- CALVES ----------
    {'name': 'Standing Calf Raise', 'tag': 'Calves', 'mode': 'gym'},
    {'name': 'Seated Calf Raise', 'tag': 'Calves', 'mode': 'gym'},
    {'name': 'Single-leg Calf Raise', 'tag': 'Calves', 'mode': 'gym'},
    {'name': 'Leg Press Calf Raise', 'tag': 'Calves', 'mode': 'gym'},
    {'name': 'Calf Raises', 'tag': 'Calves', 'type': 'reps', 'mode': 'home'},

    // ---------- CORE / ABS ----------
    {'name': 'Plank', 'tag': 'Core', 'type': 'timed', 'mode': 'both'},
    {'name': 'Side Plank', 'tag': 'Core', 'type': 'timed', 'mode': 'both'},
    {'name': 'Crunch', 'tag': 'Core', 'type': 'reps', 'mode': 'both'},
    {'name': 'Sit-ups', 'tag': 'Core', 'type': 'reps', 'mode': 'both'},
    {'name': 'Hanging Leg Raise', 'tag': 'Core', 'type': 'reps', 'mode': 'gym'},
    {'name': 'Lying Leg Raise', 'tag': 'Core', 'type': 'reps', 'mode': 'home'},
    {'name': 'Leg Raises', 'tag': 'Core', 'type': 'reps', 'mode': 'home'}, 
    {'name': 'Cable Crunch', 'tag': 'Core', 'mode': 'gym'},
    {'name': 'Russian Twist', 'tag': 'Core', 'type': 'reps', 'mode': 'both'},
    {'name': 'Russian Twists', 'tag': 'Core', 'type': 'reps', 'mode': 'both'},
    {'name': 'Mountain Climbers', 'tag': 'Core', 'type': 'reps', 'mode': 'both'},
    {'name': 'Bicycle Crunch', 'tag': 'Core', 'type': 'reps', 'mode': 'both'},
    {'name': 'Ab Wheel Rollout', 'tag': 'Core', 'type': 'reps', 'mode': 'both'},
    {'name': 'Toe Touches', 'tag': 'Core', 'type': 'reps', 'mode': 'both'},
    {'name': 'Dead Bug', 'tag': 'Core', 'type': 'reps', 'mode': 'both'},
    {'name': 'Bird Dog', 'tag': 'Core', 'type': 'reps', 'mode': 'both'},
    {'name': 'Hollow Hold', 'tag': 'Core', 'type': 'timed', 'mode': 'both'},

    // ---------- CARDIO ----------
    {'name': 'Running', 'tag': 'Cardio', 'type': 'cardio', 'mode': 'both'},
    {'name': 'Treadmill Walk', 'tag': 'Cardio', 'type': 'cardio', 'mode': 'gym'},
    {'name': 'Cycling', 'tag': 'Cardio', 'type': 'cardio', 'mode': 'gym'},
    {'name': 'Stationary Bike', 'tag': 'Cardio', 'type': 'cardio', 'mode': 'gym'},
    {'name': 'Jump Rope', 'tag': 'Cardio', 'type': 'cardio', 'mode': 'both'},
    {'name': 'Rowing Machine', 'tag': 'Cardio', 'type': 'cardio', 'mode': 'gym'},
    {'name': 'Elliptical', 'tag': 'Cardio', 'type': 'cardio', 'mode': 'gym'},
    {'name': 'Stair Climber', 'tag': 'Cardio', 'type': 'cardio', 'mode': 'gym'},
    {'name': 'HIIT', 'tag': 'Cardio', 'type': 'cardio', 'mode': 'both'},
    {'name': 'Swimming', 'tag': 'Cardio', 'type': 'cardio', 'mode': 'both'},
    {'name': 'Running in Place', 'tag': 'Cardio', 'type': 'timed', 'mode': 'home'},
    {'name': 'Jump Rope (No Rope)', 'tag': 'Cardio', 'type': 'timed', 'mode': 'home'},
    {'name': 'Skater Jumps', 'tag': 'Cardio', 'type': 'reps', 'mode': 'home'},
    {'name': 'Standing March', 'tag': 'Cardio', 'type': 'timed', 'mode': 'home'},

    // ---------- FUNCTIONAL / FULL BODY ----------
    {'name': 'Burpees', 'tag': 'Full Body', 'type': 'reps', 'mode': 'both'},
    {'name': 'Kettlebell Swing', 'tag': 'Full Body', 'mode': 'both'},
    {'name': 'Farmer’s Carry', 'tag': 'Full Body', 'type': 'distance_time_meters', 'mode': 'gym'},
    {'name': 'Battle Ropes', 'tag': 'Full Body', 'type': 'timed', 'mode': 'gym'},
    {'name': 'Sled Push', 'tag': 'Full Body', 'type': 'distance_meters', 'mode': 'gym'},
    {'name': 'Medicine Ball Slam', 'tag': 'Full Body', 'type': 'reps', 'mode': 'gym'},
    {'name': 'Clean and Press', 'tag': 'Full Body', 'mode': 'gym'},
    {'name': 'Snatch', 'tag': 'Full Body', 'mode': 'gym'},
    {'name': 'Bear Crawl', 'tag': 'Full Body', 'type': 'timed', 'mode': 'home'},
    {'name': 'Inchworm', 'tag': 'Full Body', 'type': 'reps', 'mode': 'home'},
    {'name': 'Squat to Reach', 'tag': 'Full Body', 'type': 'reps', 'mode': 'home'},

    // ---------- STRETCHES (Home) ----------
    {'name': 'Hamstring Stretch', 'tag': 'Stretch', 'type': 'timed', 'mode': 'home'},
    {'name': 'Quad Stretch', 'tag': 'Stretch', 'type': 'timed', 'mode': 'home'},
    {'name': 'Calf Stretch', 'tag': 'Stretch', 'type': 'timed', 'mode': 'home'},
    {'name': 'Shoulder Stretch', 'tag': 'Stretch', 'type': 'timed', 'mode': 'home'},
    {'name': 'Child’s Pose', 'tag': 'Stretch', 'type': 'timed', 'mode': 'home'},
    {'name': 'Cat-Cow Stretch', 'tag': 'Stretch', 'type': 'timed', 'mode': 'home'},
    {'name': 'Cobra Stretch', 'tag': 'Stretch', 'type': 'timed', 'mode': 'home'},
    {'name': 'Neck Stretch', 'tag': 'Stretch', 'type': 'timed', 'mode': 'home'},
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

  static List<Map<String, String>> getExercisesForMode(WorkoutMode mode) {
    if (mode == WorkoutMode.gym) {
      return exercises.where((e) => e['mode'] == 'gym' || e['mode'] == 'both').toList();
    } else {
      return exercises.where((e) => e['mode'] == 'home' || e['mode'] == 'both').toList();
    }
  }
}
