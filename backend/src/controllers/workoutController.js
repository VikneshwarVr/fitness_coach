const supabaseGlobal = require('../config/supabase');
const { createClient } = require('@supabase/supabase-js');

const getClient = (token) => {
    return createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY, {
        global: { headers: { Authorization: `Bearer ${token}` } }
    });
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
    try {
        const { data, error } = await supabase
            .from('workouts')
            .select('*, workout_exercises(*, workout_sets(*))')
            .eq('user_id', req.user.id)
            .order('date', { ascending: false });

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
