const express = require('express');
const router = express.Router();
const multer = require('multer');
const userController = require('../controllers/userController');
const { requireAuth } = require('../middlewares/authMiddleware');

// Configure multer for profile image upload
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/'),
  filename: (req, file, cb) => cb(null, `${req.user.id}_${Date.now()}_${file.originalname}`),
});
const upload = multer({ storage, limits: { fileSize: 5 * 1024 * 1024 } }); // 5MB limit

// All routes require auth
router.use(requireAuth);

router.get('/profile', userController.getProfile);
router.put('/profile', userController.updateProfile);
router.put('/profile-image', upload.single('image'), userController.updateProfileImage);
router.put('/favourites/:stylistId', userController.toggleFavourite);

module.exports = router;
