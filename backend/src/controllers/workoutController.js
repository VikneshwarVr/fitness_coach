const supabaseGlobal = require('../config/supabase');
const { createClient } = require('@supabase/supabase-js');

const getClient = (token) => {
    return createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY, {
        global: { headers: { Authorization: `Bearer ${token}` } }
    });
};

// Helper: update exercise_prs table based on a workout's exercises/sets
const updateExercisePRsForWorkout = async (supabase, userId, exercises = []) => {
    if (!exercises || exercises.length === 0) return;

    // Aggregate stats for this workout per exercise
    const sessionStats = {};

    for (const exercise of exercises) {
        const name = exercise.name;
        if (!name || !exercise.sets) continue;

        if (!sessionStats[name]) {
            sessionStats[name] = {
                heaviestWeight: 0,
                best1RM: 0,
                bestSetVolume: 0,
                bestSessionVolume: 0,
                sessionVolume: 0
            };
        }

        for (const set of exercise.sets) {
            if (!set.completed) continue;

            const weight = Number(set.weight || 0);
            const reps = Number(set.reps || 0);
            if (weight <= 0 || reps <= 0) continue;

            const volume = weight * reps;
            const oneRM = weight * (1 + reps / 30.0);

            if (weight > sessionStats[name].heaviestWeight) {
                sessionStats[name].heaviestWeight = weight;
            }
            if (oneRM > sessionStats[name].best1RM) {
                sessionStats[name].best1RM = oneRM;
            }
            if (volume > sessionStats[name].bestSetVolume) {
                sessionStats[name].bestSetVolume = volume;
            }

            sessionStats[name].sessionVolume += volume;
        }

        // After processing all sets for this exercise in this workout
        if (sessionStats[name].sessionVolume > sessionStats[name].bestSessionVolume) {
            sessionStats[name].bestSessionVolume = sessionStats[name].sessionVolume;
        }
    }

    // Merge with existing PRs in DB
    for (const [exerciseName, stats] of Object.entries(sessionStats)) {
        if (
            stats.heaviestWeight === 0 &&
            stats.best1RM === 0 &&
            stats.bestSetVolume === 0 &&
            stats.bestSessionVolume === 0
        ) {
            continue; // nothing meaningful to update
        }

        const { data: existing, error: fetchError } = await supabase
            .from('exercise_prs')
            .select('*')
            .eq('user_id', userId)
            .eq('exercise_name', exerciseName)
            .maybeSingle();

        if (fetchError) {
            console.error('Fetch exercise_prs error:', fetchError);
            continue;
        }

        const newRow = {
            user_id: userId,
            exercise_name: exerciseName,
            heaviest_weight: stats.heaviestWeight,
            best_1rm: stats.best1RM,
            best_set_volume: stats.bestSetVolume,
            best_session_volume: stats.bestSessionVolume
        };

        if (existing) {
            newRow.heaviest_weight = Math.max(
                Number(existing.heaviest_weight || 0),
                stats.heaviestWeight
            );
            newRow.best_1rm = Math.max(
                Number(existing.best_1rm || 0),
                stats.best1RM
            );
            newRow.best_set_volume = Math.max(
                Number(existing.best_set_volume || 0),
                stats.bestSetVolume
            );
            newRow.best_session_volume = Math.max(
                Number(existing.best_session_volume || 0),
                stats.bestSessionVolume
            );
        }

        const { error: upsertError } = await supabase
            .from('exercise_prs')
            .upsert(newRow, { onConflict: 'user_id,exercise_name' });

        if (upsertError) {
            console.error('Upsert exercise_prs error:', upsertError);
        }
    }
};

/**
 * @openapi
 * /workouts:
 *   get:
 *     summary: Get all workouts for the authenticated user
 *     tags: [Workouts]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of workouts
 *       401:
 *         description: Unauthorized
 */
exports.getAllWorkouts = async (req, res) => {
    const supabase = getClient(req.userToken);
    const { from, to } = req.query;

    try {
        let query = supabase
            .from('workouts')
            .select('*, workout_exercises(*, workout_sets(*))')
            .eq('user_id', req.user.id)
            .order('date', { ascending: false });

        if (from) {
            query = query.gte('date', from);
        }
        if (to) {
            query = query.lte('date', to);
        }

        const { data, error } = await query;

        if (error) throw error;
        res.json(data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

/**
 * @openapi
 * /workouts/recent:
 *   get:
 *     summary: Get recent workouts for the authenticated user
 *     tags: [Workouts]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *         required: false
 *     responses:
 *       200:
 *         description: List of recent workouts
 */
exports.getRecentWorkouts = async (req, res) => {
    const supabase = getClient(req.userToken);
    const limit = parseInt(req.query.limit || '3', 10);

    try {
        const { data, error } = await supabase
            .from('workouts')
            .select('*, workout_exercises(*, workout_sets(*))')
            .eq('user_id', req.user.id)
            .order('date', { ascending: false })
            .limit(limit);

        if (error) throw error;
        res.json(data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

/**
 * @openapi
 * /workouts:
 *   post:
 *     summary: Add a new workout
 *     tags: [Workouts]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               date:
 *                 type: string
 *               duration:
 *                 type: number
 *               total_volume:
 *                 type: number
 *               exercises:
 *                 type: array
 *                 items:
 *                   type: object
 *     responses:
 *       201:
 *         description: Workout created
 *       500:
 *         description: Server error
 */
exports.addWorkout = async (req, res) => {
    const { name, date, duration, total_volume, exercises } = req.body;

    const supabase = getClient(req.userToken);
    try {
        // 1. Insert Workout
        const { data: workout, error: workoutError } = await supabase
            .from('workouts')
            .insert({
                user_id: req.user.id,
                name,
                date,
                duration,
                total_volume
            })
            .select()
            .single();

        if (workoutError) throw workoutError;

        // 2. Insert Exercises & Sets
        if (exercises && exercises.length > 0) {
            for (let i = 0; i < exercises.length; i++) {
                const exercise = exercises[i];
                const { data: exerciseData, error: exerciseError } = await supabase
                    .from('workout_exercises')
                    .insert({
                        workout_id: workout.id,
                        exercise_name: exercise.name,
                        order_index: i
                    })
                    .select()
                    .single();

                if (exerciseError) throw exerciseError;

                if (exercise.sets && exercise.sets.length > 0) {
                    const setsData = exercise.sets.map((set, index) => ({
                        workout_exercise_id: exerciseData.id,
                        weight: set.weight,
                        reps: set.reps,
                        completed: set.completed,
                        order_index: index
                    }));

                    const { error: setsError } = await supabase
                        .from('workout_sets')
                        .insert(setsData);

                    if (setsError) throw setsError;
                }
            }
        }

        // 3. Update exercise PRs for this workout
        await updateExercisePRsForWorkout(supabase, req.user.id, exercises);

        res.status(201).json(workout);
    } catch (error) {
        console.error('Create Workout Error:', error);
        res.status(500).json({
            error: error.message,
            details: error.details,
            hint: error.hint
        });
    }
};

/**
 * @openapi
 * /workouts/{id}:
 *   put:
 *     summary: Update an existing workout
 *     tags: [Workouts]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *     responses:
 *       200:
 *         description: Workout updated
 *       404:
 *         description: Workout not found
 */
exports.updateWorkout = async (req, res) => {
    const { id } = req.params;
    const { name, date, duration, total_volume, exercises } = req.body;
    const supabase = getClient(req.userToken);

    try {
        // 1. Update Workout Meta
        const { data: workout, error: updateError } = await supabase
            .from('workouts')
            .update({ name, date, duration, total_volume })
            .eq('id', id)
            .eq('user_id', req.user.id)
            .select()
            .single();

        if (updateError) throw updateError;
        if (!workout) return res.status(404).json({ error: 'Workout not found' });

        // 2. Clear existing exercises (cascades to sets)
        const { error: deleteError } = await supabase
            .from('workout_exercises')
            .delete()
            .eq('workout_id', id);

        if (deleteError) throw deleteError;

        // 3. Re-insert Exercises & Sets
        if (exercises && exercises.length > 0) {
            for (let i = 0; i < exercises.length; i++) {
                const exercise = exercises[i];
                const { data: exerciseData, error: exerciseError } = await supabase
                    .from('workout_exercises')
                    .insert({
                        workout_id: workout.id,
                        exercise_name: exercise.name,
                        order_index: i
                    })
                    .select()
                    .single();

                if (exerciseError) throw exerciseError;

                if (exercise.sets && exercise.sets.length > 0) {
                    const setsData = exercise.sets.map((set, index) => ({
                        workout_exercise_id: exerciseData.id,
                        weight: set.weight,
                        reps: set.reps,
                        completed: set.completed,
                        order_index: index
                    }));

                    const { error: setsError } = await supabase
                        .from('workout_sets')
                        .insert(setsData);

                    if (setsError) throw setsError;
                }
            }
        }

        // 4. Update exercise PRs for this (possibly edited) workout
        await updateExercisePRsForWorkout(supabase, req.user.id, exercises);

        res.json(workout);
    } catch (error) {
        console.error('Update Workout Error:', error);
        res.status(500).json({ error: error.message });
    }
};

/**
 * @openapi
 * /workouts/{id}:
 *   delete:
 *     summary: Delete a workout
 *     tags: [Workouts]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       204:
 *         description: Workout deleted
 *       404:
 *         description: Workout not found
 */
exports.deleteWorkout = async (req, res) => {
    const { id } = req.params;
    const supabase = getClient(req.userToken);

    try {
        const { error } = await supabase
            .from('workouts')
            .delete()
            .eq('id', id)
            .eq('user_id', req.user.id);

        if (error) throw error;
        res.status(204).send();
    } catch (error) {
        console.error('Delete Workout Error:', error);
        res.status(500).json({ error: error.message });
    }
};
