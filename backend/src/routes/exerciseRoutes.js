const express = require('express');
const router = express.Router();
const exerciseController = require('../controllers/exerciseController');
const authenticate = require('../middleware/auth');

router.use(authenticate);

router.get('/:name/last-session', exerciseController.getLastSession);

module.exports = router;

