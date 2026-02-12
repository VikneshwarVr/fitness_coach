const express = require('express');
const router = express.Router();
const exercisePrController = require('../controllers/exercisePrController');
const authenticate = require('../middleware/auth');

router.use(authenticate);

router.get('/', exercisePrController.getAllExercisePRs);
router.get('/:exerciseName/history', exercisePrController.getExercisePRHistory);
router.get('/:exerciseName', exercisePrController.getExercisePR);
router.post('/', exercisePrController.upsertExercisePR);

module.exports = router;

