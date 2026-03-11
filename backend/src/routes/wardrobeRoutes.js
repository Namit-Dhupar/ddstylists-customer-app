const express = require('express');
const router = express.Router();
const multer = require('multer');
const wardrobeController = require('../controllers/wardrobeController');
const { requireAuth } = require('../middlewares/authMiddleware');

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/'),
  filename: (req, file, cb) => cb(null, `wardrobe_${req.user.id}_${Date.now()}_${file.originalname}`),
});
const upload = multer({ storage, limits: { fileSize: 10 * 1024 * 1024 } }); // 10MB

router.use(requireAuth);

router.get('/', wardrobeController.listItems);
router.post('/', upload.single('image'), wardrobeController.addItem);
router.delete('/:id', wardrobeController.deleteItem);

module.exports = router;
