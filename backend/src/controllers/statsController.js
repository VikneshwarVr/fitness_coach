const { createClient } = require('@supabase/supabase-js');

const getClient = (token) => {
  return createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: `Bearer ${token}` } }
  });
};

const muscleGroups = ['Back', 'Chest', 'Core', 'Shoulders', 'Arms', 'Legs'];

// Full mapping copied from StatsUtils.majorCategories (Dart) to keep backend stats consistent
const majorCategories = {
  // Chest
  'Bench Press': { Chest: 60, Arms: 30, Shoulders: 10 },
  'Incline Bench Press': { Chest: 50, Arms: 25, Shoulders: 25 },
  'Decline Bench Press': { Chest: 55, Arms: 25, Shoulders: 20 },
  'Dumbbell Bench Press': { Chest: 60, Arms: 30, Shoulders: 10 },
  'Incline Dumbbell Press': { Chest: 50, Arms: 25, Shoulders: 25 },
  'Decline Dumbbell Press': { Chest: 55, Arms: 25, Shoulders: 20 },
  'Chest Fly (Dumbbell)': { Chest: 80, Shoulders: 20 },
  'Cable Fly': { Chest: 80, Shoulders: 20 },
  'Machine Chest Press': { Chest: 60, Arms: 30, Shoulders: 10 },
  'Push-ups': { Chest: 60, Arms: 30, Shoulders: 10 },
  'Weighted Push-ups': { Chest: 60, Arms: 30, Shoulders: 10 },
  'Pec Deck': { Chest: 80, Shoulders: 20 },
  'Single-arm Cable Press': { Chest: 60, Arms: 30, Shoulders: 10 },

  // Back
  'Pull-ups': { Back: 60, Arms: 30, Shoulders: 10 },
  'Chin-ups': { Back: 55, Arms: 35, Shoulders: 10 },
  'Lat Pulldown': { Back: 60, Arms: 30, Shoulders: 10 },
  'Wide-Grip Lat Pulldown': { Back: 65, Arms: 25, Shoulders: 10 },
  'Close-Grip Lat Pulldown': { Back: 55, Arms: 35, Shoulders: 10 },
  'Barbell Row': { Back: 60, Arms: 25, Shoulders: 15 },
  'Dumbbell Row': { Back: 60, Arms: 25, Shoulders: 15 },
  'T-Bar Row': { Back: 60, Arms: 25, Shoulders: 15 },
  'Seated Cable Row': { Back: 60, Arms: 25, Shoulders: 15 },
  'Inverted Row': { Back: 60, Arms: 25, Shoulders: 15 },
  'Deadlift': { Back: 50, Legs: 30, Glutes: 20 },
  'Rack Pull': { Back: 60, Legs: 20, Glutes: 20 },
  'Straight-arm Pulldown': { Back: 70, Arms: 30 },
  'Face Pull': { Back: 40, Shoulders: 40, Arms: 20 },
  'Back Extension': { Back: 70, Glutes: 20, Legs: 10 },

  // Shoulders
  'Overhead Press': { Shoulders: 60, Arms: 25, Chest: 15 },
  'Seated Dumbbell Press': { Shoulders: 60, Arms: 25, Chest: 15 },
  'Arnold Press': { Shoulders: 60, Arms: 30, Chest: 10 },
  'Lateral Raise': { Shoulders: 90, Arms: 10 },
  'Cable Lateral Raise': { Shoulders: 90, Arms: 10 },
  'Front Raise': { Shoulders: 90, Arms: 10 },
  'Rear Delt Fly': { Shoulders: 80, Back: 20 },
  'Reverse Pec Deck': { Shoulders: 80, Back: 20 },
  'Upright Row': { Shoulders: 60, Arms: 30, Back: 10 },
  'Landmine Press': { Shoulders: 60, Chest: 25, Arms: 15 },
  'Y-Raise': { Shoulders: 80, Back: 20 },

  // Biceps
  'Barbell Curl': { Arms: 100 },
  'EZ-Bar Curl': { Arms: 100 },
  'Dumbbell Curl': { Arms: 100 },
  'Hammer Curl': { Arms: 100 },
  'Preacher Curl': { Arms: 100 },
  'Cable Curl': { Arms: 100 },
  'Concentration Curl': { Arms: 100 },
  'Incline Dumbbell Curl': { Arms: 100 },
  'Reverse Curl': { Arms: 100 },
  'Spider Curl': { Arms: 100 },

  // Triceps
  'Tricep Pushdown': { Arms: 100 },
  'Rope Pushdown': { Arms: 100 },
  'Skull Crushers': { Arms: 100 },
  'Overhead Tricep Extension': { Arms: 100 },
  'Dips': { Chest: 40, Arms: 60 },
  'Bench Dips': { Chest: 40, Arms: 60 },
  'Close-Grip Bench Press': { Chest: 50, Arms: 50 },
  'Cable Overhead Extension': { Arms: 100 },
  'Single-arm Pushdown': { Arms: 100 },

  // Legs
  'Back Squat': { Legs: 70, Glutes: 20, Back: 10 },
  'Front Squat': { Legs: 70, Glutes: 20, Back: 10 },
  'Goblet Squat': { Legs: 70, Glutes: 20, Back: 10 },
  'Leg Press': { Legs: 80, Glutes: 15, Back: 5 },
  'Hack Squat': { Legs: 80, Glutes: 15, Back: 5 },
  'Bulgarian Split Squat': { Legs: 75, Glutes: 20, Balance: 5 },
  'Walking Lunges': { Legs: 70, Glutes: 25, Balance: 5 },
  'Reverse Lunges': { Legs: 70, Glutes: 25, Balance: 5 },
  'Step-ups': { Legs: 70, Glutes: 25, Balance: 5 },
  'Leg Extension': { Legs: 100 },
  'Leg Curl': { Legs: 100 },
  'Romanian Deadlift': { Legs: 60, Glutes: 30, Back: 10 },
  'Stiff-Leg Deadlift': { Legs: 60, Glutes: 30, Back: 10 },
  'Glute Bridge': { Glutes: 80, Legs: 20 },
  'Hip Thrust': { Glutes: 80, Legs: 20 },
  'Cable Kickback': { Glutes: 80, Legs: 20 },
  'Sumo Deadlift': { Legs: 50, Glutes: 40, Back: 10 },

  // Calves
  'Standing Calf Raise': { Legs: 100 },
  'Seated Calf Raise': { Legs: 100 },
  'Single-leg Calf Raise': { Legs: 100 },
  'Leg Press Calf Raise': { Legs: 100 },

  // Core / Abs
  'Plank': { Core: 100 },
  'Side Plank': { Core: 100 },
  'Crunch': { Core: 100 },
  'Sit-ups': { Core: 100 },
  'Hanging Leg Raise': { Core: 100 },
  'Lying Leg Raise': { Core: 100 },
  'Cable Crunch': { Core: 100 },
  'Russian Twist': { Core: 100 },
  'Mountain Climbers': { Core: 100 },
  'Bicycle Crunch': { Core: 100 },
  'Ab Wheel Rollout': { Core: 100 },
  'Toe Touches': { Core: 100 },

  // Cardio
  'Running': { Cardio: 100 },
  'Treadmill Walk': { Cardio: 100 },
  'Cycling': { Cardio: 100 },
  'Stationary Bike': { Cardio: 100 },
  'Jump Rope': { Cardio: 100 },
  'Rowing Machine': { Cardio: 100 },
  'Elliptical': { Cardio: 100 },
  'Stair Climber': { Cardio: 100 },
  'HIIT': { Cardio: 100 },
  'Swimming': { Cardio: 100 },

  // Full Body
  'Burpees': { 'Full Body': 100 },
  'Kettlebell Swing': { 'Full Body': 100 },
  "Farmer\u2019s Carry": { 'Full Body': 100 },
  'Battle Ropes': { 'Full Body': 100 },
  'Sled Push': { 'Full Body': 100 },
  'Medicine Ball Slam': { 'Full Body': 100 },
  'Clean and Press': { 'Full Body': 100 },
  'Snatch': { 'Full Body': 100 },
};

const normalize = (name) => name.trim().toLowerCase();

const filterWorkoutsByRange = (workouts, range) => {
  const now = new Date();
  const limit =
    range === 'month'
      ? new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000)
      : new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
  return workouts.filter((w) => new Date(w.date) > limit);
};

const computeStreak = (dates) => {
  if (!dates.length) return 0;
  const days = Array.from(
    new Set(
      dates.map((d) => {
        const dt = new Date(d);
        return dt.toISOString().slice(0, 10);
      })
    )
  ).sort();

  const today = new Date().toISOString().slice(0, 10);
  let streak = 0;
  let current = new Date(today);

  while (true) {
    const key = current.toISOString().slice(0, 10);
    if (!days.includes(key)) break;
    streak += 1;
    current.setDate(current.getDate() - 1);
  }
  return streak;
};

/**
 * @openapi
 * /stats/overview:
 *   get:
 *     summary: Get overview stats for the authenticated user
 *     tags: [Stats]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Overview stats
 */
exports.getOverview = async (req, res) => {
  const supabase = getClient(req.userToken);
  try {
    const { data, error } = await supabase
      .from('workouts')
      .select('id, date, total_volume, duration')
      .eq('user_id', req.user.id)
      .order('date', { ascending: false });

    if (error) throw error;

    const now = new Date();
    const startOfWeek = new Date(now);
    startOfWeek.setDate(now.getDate() - (now.getDay() === 0 ? 6 : now.getDay() - 1));

    const workoutsThisWeek = data.filter(
      (w) => new Date(w.date) >= startOfWeek
    ).length;

    const totalVolume = data.reduce(
      (sum, w) => sum + (w.total_volume || 0),
      0
    );

    const streak = computeStreak(data.map((w) => w.date));

    res.json({
      workoutsThisWeek,
      totalVolume,
      streak,
    });
  } catch (err) {
    console.error('Stats overview error:', err);
    res.status(500).json({ error: err.message });
  }
};

/**
 * @openapi
 * /stats/muscle-distribution:
 *   get:
 *     summary: Get muscle group distribution
 *     tags: [Stats]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: range
 *         schema:
 *           type: string
 *           enum: [week, month]
 *         required: false
 *         description: Time range (default week)
 *     responses:
 *       200:
 *         description: Muscle distribution map
 */
exports.getMuscleDistribution = async (req, res) => {
  const range = req.query.range === 'month' ? 'month' : 'week';
  const supabase = getClient(req.userToken);

  try {
    const { data, error } = await supabase
      .from('workouts')
      .select('date, workout_exercises(id, exercise_name, workout_sets(id))')
      .eq('user_id', req.user.id);

    if (error) throw error;

    const normalizedMap = {};
    Object.entries(majorCategories).forEach(([key, value]) => {
      normalizedMap[normalize(key)] = value;
    });

    const filtered = filterWorkoutsByRange(data, range);
    const distribution = {};

    for (const w of filtered) {
      for (const ex of w.workout_exercises || []) {
        const dist = normalizedMap[normalize(ex.exercise_name)];
        if (!dist) continue;
        const setCount = (ex.workout_sets || []).length;
        Object.entries(dist).forEach(([mg, percentage]) => {
          distribution[mg] =
            (distribution[mg] || 0) + (setCount * percentage) / 100.0;
        });
      }
    }

    res.json(distribution);
  } catch (err) {
    console.error('Muscle distribution error:', err);
    res.status(500).json({ error: err.message });
  }
};

/**
 * @openapi
 * /stats/aggregated:
 *   get:
 *     summary: Get aggregated stats for charts
 *     tags: [Stats]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: metric
 *         schema:
 *           type: string
 *           enum: [Volume, Reps, Sets, Duration]
 *         required: true
 *       - in: query
 *         name: range
 *         schema:
 *           type: string
 *           enum: [week, month]
 *         required: false
 *         description: Time range (default week)
 *     responses:
 *       200:
 *         description: Aggregated stats array
 */
exports.getAggregatedStats = async (req, res) => {
  const metric = req.query.metric || 'Volume';
  const range = req.query.range === 'month' ? 'month' : 'week';

  const supabase = getClient(req.userToken);
  try {
    const { data, error } = await supabase
      .from('workouts')
      .select('date, total_volume, duration, workout_exercises(id, workout_sets(weight, reps))')
      .eq('user_id', req.user.id);

    if (error) throw error;

    const filtered = filterWorkoutsByRange(data, range);
    const count = range === 'month' ? 4 : 7;
    const stats = Array.from({ length: count }).map((_, index) => ({
      label:
        range === 'month'
          ? `Week ${index + 1}`
          : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index],
      value: 0.0,
    }));

    const now = new Date();

    for (const w of filtered) {
      const d = new Date(w.date);
      let index;
      if (range === 'week') {
        index = (d.getDay() + 6) % 7; // convert Sun=0 to 6, Mon=1 to 0, etc.
      } else {
        const daysAgo = Math.floor((now - d) / (1000 * 60 * 60 * 24));
        index = Math.max(0, Math.min(3, 3 - Math.floor(daysAgo / 7)));
      }

      let val = 0;
      switch (metric) {
        case 'Volume':
          val = (w.total_volume || 0) / 1000.0;
          break;
        case 'Reps':
          val = (w.workout_exercises || []).reduce((sum, ex) => {
            return (
              sum +
              (ex.workout_sets || []).reduce(
                (s, set) => s + (set.reps || 0),
                0
              )
            );
          }, 0);
          break;
        case 'Sets':
          val = (w.workout_exercises || []).reduce(
            (sum, ex) => sum + (ex.workout_sets || []).length,
            0
          );
          break;
        case 'Duration':
          val = w.duration || 0;
          break;
      }

      stats[index].value += val;
    }

    res.json(stats);
  } catch (err) {
    console.error('Aggregated stats error:', err);
    res.status(500).json({ error: err.message });
  }
};

