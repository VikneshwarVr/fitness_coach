const { createClient } = require('@supabase/supabase-js');

const getClient = (token) => {
  return createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: `Bearer ${token}` } }
  });
};

/**
 * @openapi
 * /exercises/{name}/last-session:
 *   get:
 *     summary: Get the most recent session sets for a given exercise
 *     tags: [Exercises]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: name
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Last session sets
 *       404:
 *         description: Not found
 */
exports.getLastSession = async (req, res) => {
  const { name } = req.params;
  const exerciseName = decodeURIComponent(name);
  const supabase = getClient(req.userToken);

  try {
    const { data, error } = await supabase
      .from('workouts')
      .select('date, workout_exercises(id, exercise_name, workout_sets(id, weight, reps, completed, order_index))')
      .eq('user_id', req.user.id)
      .order('date', { ascending: false });

    if (error) throw error;

    for (const w of data) {
      const match = (w.workout_exercises || []).find(
        (ex) => ex.exercise_name.trim().toLowerCase() === exerciseName.trim().toLowerCase()
      );
      if (match) {
        const sets = (match.workout_sets || [])
          .sort((a, b) => (a.order_index ?? 0) - (b.order_index ?? 0))
          .map((s) => ({
            id: s.id,
            weight: s.weight,
            reps: s.reps,
            completed: s.completed,
          }));
        return res.json({ exercise_name: match.exercise_name, sets });
      }
    }

    res.status(404).json({ error: 'No previous session found for this exercise' });
  } catch (err) {
    console.error('Get last session error:', err);
    res.status(500).json({ error: err.message });
  }
};

