const express = require('express');
const router = express.Router();
const agoraController = require('../controllers/agoraController');
const { requireAuth } = require('../middlewares/authMiddleware');

router.post('/token', requireAuth, agoraController.generateToken);
router.post('/recording/start', requireAuth, agoraController.startRecording);
router.post('/recording/stop', requireAuth, agoraController.stopRecording);

module.exports = router;
