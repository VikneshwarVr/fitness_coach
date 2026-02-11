const express = require('express');
const router = express.Router();
const workoutController = require('../controllers/workoutController');
const authenticate = require('../middleware/auth');

router.use(authenticate);

router.get('/', workoutController.getAllWorkouts);
router.post('/', workoutController.addWorkout);
router.put('/:id', workoutController.updateWorkout);
router.delete('/:id', workoutController.deleteWorkout);

module.exports = router;
