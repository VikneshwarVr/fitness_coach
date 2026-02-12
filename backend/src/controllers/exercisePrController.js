const { createClient } = require('@supabase/supabase-js');

const getClient = (token) => {
  return createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: `Bearer ${token}` } }
  });
};

/**
 * @openapi
 * /exercise-prs:
 *   get:
 *     summary: Get all exercise PRs for the authenticated user
 *     tags: [ExercisePRs]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of exercise PRs
 *       401:
 *         description: Unauthorized
 */
exports.getAllExercisePRs = async (req, res) => {
  const supabase = getClient(req.userToken);

  try {
    const { data, error } = await supabase
      .from('exercise_prs')
      .select('*')
      .eq('user_id', req.user.id)
      .order('exercise_name', { ascending: true });

    if (error) throw error;

    res.json(data);
  } catch (error) {
    console.error('Get All Exercise PRs Error:', error);
    res.status(500).json({ error: error.message });
  }
};

/**
 * @openapi
 * /exercise-prs/{exerciseName}:
 *   get:
 *     summary: Get PRs for a single exercise
 *     tags: [ExercisePRs]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: exerciseName
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Exercise PRs
 *       404:
 *         description: Not found
 */
exports.getExercisePR = async (req, res) => {
  const { exerciseName } = req.params;
  const supabase = getClient(req.userToken);

  try {
    const { data, error } = await supabase
      .from('exercise_prs')
      .select('*')
      .eq('user_id', req.user.id)
      .eq('exercise_name', decodeURIComponent(exerciseName))
      .maybeSingle();

    if (error) throw error;

    if (!data) {
      return res.status(404).json({ error: 'Exercise PRs not found' });
    }

    res.json(data);
  } catch (error) {
    console.error('Get Exercise PR Error:', error);
    res.status(500).json({ error: error.message });
  }
};

/**
 * @openapi
 * /exercise-prs:
 *   post:
 *     summary: Upsert PRs for an exercise
 *     tags: [ExercisePRs]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               exercise_name:
 *                 type: string
 *               heaviest_weight:
 *                 type: number
 *               best_1rm:
 *                 type: number
 *               best_set_volume:
 *                 type: number
 *               best_session_volume:
 *                 type: number
 *     responses:
 *       200:
 *         description: Upserted PR row
 */
exports.upsertExercisePR = async (req, res) => {
  const { exercise_name, heaviest_weight, best_1rm, best_set_volume, best_session_volume } = req.body;

  if (!exercise_name) {
    return res.status(400).json({ error: 'exercise_name is required' });
  }

  const supabase = getClient(req.userToken);

  try {
    const { data, error } = await supabase
      .from('exercise_prs')
      .upsert(
        {
          user_id: req.user.id,
          exercise_name,
          heaviest_weight: heaviest_weight ?? 0,
          best_1rm: best_1rm ?? 0,
          best_set_volume: best_set_volume ?? 0,
          best_session_volume: best_session_volume ?? 0
        },
        { onConflict: 'user_id,exercise_name' }
      )
      .select()
      .single();

    if (error) throw error;

    res.json(data);
  } catch (error) {
    console.error('Upsert Exercise PR Error:', error);
    res.status(500).json({ error: error.message });
  }
};

/**
 * @openapi
 * /exercise-prs/{exerciseName}/history:
 *   get:
 *     summary: Get time-series PR progression for an exercise
 *     tags: [ExercisePRs]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: exerciseName
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Time-series data
 */
exports.getExercisePRHistory = async (req, res) => {
  const { exerciseName } = req.params;
  const name = decodeURIComponent(exerciseName);
  const supabase = getClient(req.userToken);

  try {
    const { data, error } = await supabase
      .from('workouts')
      .select('date, workout_exercises(exercise_name, workout_sets(weight, reps, completed))')
      .eq('user_id', req.user.id)
      .order('date', { ascending: true });

    if (error) throw error;

    const history = [];

    for (const w of data) {
      let heaviestWeight = 0;
      let best1RM = 0;
      let bestSetVolume = 0;
      let sessionVolume = 0;
      let hasExercise = false;

      for (const ex of w.workout_exercises || []) {
        if (ex.exercise_name.trim().toLowerCase() !== name.trim().toLowerCase()) continue;
        hasExercise = true;

        for (const set of ex.workout_sets || []) {
          if (!set.completed) continue;
          const weight = Number(set.weight || 0);
          const reps = Number(set.reps || 0);
          if (weight <= 0 || reps <= 0) continue;

          const volume = weight * reps;
          const oneRM = weight * (1 + reps / 30.0);

          if (weight > heaviestWeight) heaviestWeight = weight;
          if (oneRM > best1RM) best1RM = oneRM;
          if (volume > bestSetVolume) bestSetVolume = volume;
          sessionVolume += volume;
        }
      }

      if (hasExercise) {
        history.push({
          date: w.date,
          heaviest_weight: heaviestWeight,
          best_1rm: best1RM,
          best_set_volume: bestSetVolume,
          session_volume: sessionVolume,
        });
      }
    }

    res.json(history);
  } catch (err) {
    console.error('Exercise PR history error:', err);
    res.status(500).json({ error: err.message });
  }
};


