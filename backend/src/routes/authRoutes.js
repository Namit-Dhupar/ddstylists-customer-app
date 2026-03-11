const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { requireAuth } = require('../middlewares/authMiddleware');

// Public routes
router.post('/register', authController.register);
router.post('/login', authController.login);
router.post('/social', authController.socialLogin);

// Protected routes
router.get('/me', requireAuth, authController.getMe);

module.exports = router;
