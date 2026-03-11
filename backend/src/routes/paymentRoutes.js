const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');
const { requireAuth } = require('../middlewares/authMiddleware');

// POST /api/checkout/process
router.post('/process', requireAuth, paymentController.processCheckout);

module.exports = router;
