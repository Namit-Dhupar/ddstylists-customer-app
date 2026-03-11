const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');
const { requireAuth } = require('../middlewares/authMiddleware');

router.post('/process', requireAuth, paymentController.processCheckout);
router.post('/verify', requireAuth, paymentController.verifyPayment);

// Stripe webhook needs raw body
router.post('/webhook', express.raw({ type: 'application/json' }), paymentController.stripeWebhook);

module.exports = router;
