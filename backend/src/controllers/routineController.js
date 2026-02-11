const supabaseGlobal = require('../config/supabase');
const { createClient } = require('@supabase/supabase-js');

const getClient = (token) => {
    return createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY, {
        global: { headers: { Authorization: `Bearer ${token}` } }
    });
};

/**
 * @openapi
 * /routines:
 *   get:
 *     summary: Get all routines (default + user's custom)
 *     tags: [Routines]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of routines
 */
exports.getAllRoutines = async (req, res) => {
    const supabase = getClient(req.userToken);
    try {
        const { data, error } = await supabase
            .from('routines')
            .select('*, routine_exercises(exercise_name)')
            .or(`is_custom.eq.false,user_id.eq.${req.user.id}`);

        if (error) throw error;
        res.json(data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

/**
 * @openapi
 * /routines:
 *   post:
 *     summary: Create a new custom routine
 *     tags: [Routines]
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
 *               description:
 *                 type: string
 *               level:
 *                 type: string
 *               duration:
 *                 type: number
 *               exerciseNames:
 *                 type: array
 *                 items:
 *                   type: string
 *     responses:
 *       201:
 *         description: Routine created
 */
exports.createRoutine = async (req, res) => {
    const { name, description, level, duration, exerciseNames } = req.body;

    const supabase = getClient(req.userToken);
    try {
        // 1. Insert Routine
        const { data: routine, error: routineError } = await supabase
            .from('routines')
            .insert({
                user_id: req.user.id,
                name,
                description,
                level,
                duration,
                is_custom: true
            })
            .select()
            .single();

        if (routineError) throw routineError;

        // 2. Insert Exercises
        if (exerciseNames && exerciseNames.length > 0) {
            const exercisesData = exerciseNames.map((name, index) => ({
                routine_id: routine.id,
                exercise_name: name,
                order_index: index
            }));

            const { error: exercisesError } = await supabase
                .from('routine_exercises')
                .insert(exercisesData);

            if (exercisesError) throw exercisesError;
        }

        res.status(201).json(routine);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

/**
 * @openapi
 * /routines/{id}:
 *   delete:
 *     summary: Delete a custom routine
 *     tags: [Routines]
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
 *         description: Routine deleted
 */
exports.deleteRoutine = async (req, res) => {
    const { id } = req.params;
    const supabase = getClient(req.userToken);
    try {
        const { error } = await supabase
            .from('routines')
            .delete()
            .eq('id', id)
            .eq('user_id', req.user.id);

        if (error) throw error;
        res.status(204).send();
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
