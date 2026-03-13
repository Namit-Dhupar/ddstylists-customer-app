const express = require('express');
const router = express.Router();
const multer = require('multer');
const chatController = require('../controllers/chatController');
const { requireAuth } = require('../middlewares/authMiddleware');

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/'),
  filename: (req, file, cb) => cb(null, `chat_${req.user.id}_${Date.now()}_${file.originalname}`),
});
const upload = multer({ storage, limits: { fileSize: 10 * 1024 * 1024 } });

router.use(requireAuth);

router.get('/conversations', chatController.getConversations);
router.post('/conversations', chatController.getOrCreateConversation);
router.delete('/conversations/:id', chatController.deleteConversation);
router.get('/:conversationId/messages', chatController.getMessages);
router.post('/:conversationId/messages', upload.single('image'), chatController.sendMessage);

module.exports = router;
