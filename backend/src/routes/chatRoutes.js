const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');
const { requireAuth } = require('../middlewares/authMiddleware');

router.use(requireAuth);

router.get('/conversations', chatController.getConversations);
router.post('/conversations', chatController.getOrCreateConversation);
router.get('/:conversationId/messages', chatController.getMessages);

module.exports = router;
