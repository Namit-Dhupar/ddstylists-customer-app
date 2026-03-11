const Conversation = require('../models/Conversation');
const Message = require('../models/Message');
const Stylist = require('../models/Stylist');

/**
 * GET /api/chat/conversations
 */
exports.getConversations = async (req, res) => {
  try {
    const conversations = await Conversation.find({
      participants: req.user.id,
    })
    .sort({ lastMessageAt: -1 })
    .lean();

    // Enrich with participant info
    const enriched = await Promise.all(conversations.map(async (conv) => {
      const otherId = conv.participants.find(p => p.toString() !== req.user.id);
      let otherUser = null;
      // Try Stylist first, then User
      otherUser = await Stylist.findById(otherId).select('firstName lastName profileImage').lean();
      if (!otherUser) {
        const User = require('../models/User');
        otherUser = await User.findById(otherId).select('firstName lastName profileImage').lean();
      }
      return {
        ...conv,
        otherUser: otherUser || { firstName: 'Unknown', lastName: '' },
        unreadCount: conv.unreadCount?.get?.(req.user.id) || 0,
      };
    }));

    return res.status(200).json({ conversations: enriched });
  } catch (error) {
    console.error('GetConversations Error:', error);
    return res.status(500).json({ error: 'Failed to fetch conversations.' });
  }
};

/**
 * GET /api/chat/:conversationId/messages
 */
exports.getMessages = async (req, res) => {
  try {
    const { page = 1, limit = 50 } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);

    const messages = await Message.find({ conversationId: req.params.conversationId })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    // Mark messages as read
    await Message.updateMany(
      { conversationId: req.params.conversationId, receiverId: req.user.id, read: false },
      { read: true }
    );

    // Reset unread count
    await Conversation.findByIdAndUpdate(req.params.conversationId, {
      [`unreadCount.${req.user.id}`]: 0,
    });

    return res.status(200).json({ messages: messages.reverse() });
  } catch (error) {
    console.error('GetMessages Error:', error);
    return res.status(500).json({ error: 'Failed to fetch messages.' });
  }
};

/**
 * POST /api/chat/conversations
 * Create or get existing conversation between user and stylist
 */
exports.getOrCreateConversation = async (req, res) => {
  try {
    const { stylistId, appointmentId } = req.body;
    if (!stylistId) return res.status(400).json({ error: 'stylistId is required.' });

    let conversation = await Conversation.findOne({
      participants: { $all: [req.user.id, stylistId] },
    });

    if (!conversation) {
      conversation = await Conversation.create({
        participants: [req.user.id, stylistId],
        appointmentId,
      });
    }

    return res.status(200).json({ conversation });
  } catch (error) {
    console.error('GetOrCreateConversation Error:', error);
    return res.status(500).json({ error: 'Failed to create conversation.' });
  }
};
