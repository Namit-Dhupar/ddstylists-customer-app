const express = require('express');
const router = express.Router();
const agoraController = require('../controllers/agoraController');
const { requireAuth } = require('../middlewares/authMiddleware');

// Token endpoint
router.post('/token', requireAuth, agoraController.generateToken);

// Cloud Recording endpoints
router.post('/record/start', requireAuth, agoraController.startRecording);
router.post('/record/stop', requireAuth, agoraController.stopRecording);

module.exports = router;
