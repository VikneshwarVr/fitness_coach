const express = require('express');
const router = express.Router();
const routineController = require('../controllers/routineController');
const authenticate = require('../middleware/auth');

router.use(authenticate);

router.get('/', routineController.getAllRoutines);
router.post('/', routineController.createRoutine);
router.put('/:id', routineController.updateRoutine);
router.delete('/:id', routineController.deleteRoutine);

module.exports = router;
