const express = require('express');
const router = express.Router();
const stylistController = require('../controllers/stylistController');
const { requireAuth } = require('../middlewares/authMiddleware');

// Public routes
router.get('/', stylistController.listStylists);
router.get('/categories', stylistController.getCategories);
router.get('/:id', stylistController.getStylist);
router.get('/:id/reviews', stylistController.getReviews);

// Protected routes
router.post('/:id/reviews', requireAuth, stylistController.addReview);

module.exports = router;
