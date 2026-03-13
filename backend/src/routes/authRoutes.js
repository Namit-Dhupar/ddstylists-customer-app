const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { requireAuth } = require('../middlewares/authMiddleware');

// Public routes
router.post('/register', authController.register);
router.post('/login', authController.login);
router.post('/social', authController.socialLogin);
router.get('/check-username', authController.checkUsername);
router.post('/forgot-password', authController.forgotPassword);

// Protected routes
router.get('/me', requireAuth, authController.getMe);
router.put('/change-password', requireAuth, authController.changePassword);

module.exports = router;

