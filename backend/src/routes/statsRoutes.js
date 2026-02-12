const express = require('express');
const router = express.Router();
const statsController = require('../controllers/statsController');
const authenticate = require('../middleware/auth');

router.use(authenticate);

router.get('/overview', statsController.getOverview);
router.get('/muscle-distribution', statsController.getMuscleDistribution);
router.get('/aggregated', statsController.getAggregatedStats);

module.exports = router;

