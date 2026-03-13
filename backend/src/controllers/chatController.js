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

/**
 * DELETE /api/chat/conversations/:id
 */
exports.deleteConversation = async (req, res) => {
  try {
    const conversation = await Conversation.findOne({
      _id: req.params.id,
      participants: req.user.id,
    });
    if (!conversation) {
      return res.status(404).json({ error: 'Conversation not found.' });
    }

    // Delete all messages in the conversation
    await Message.deleteMany({ conversationId: conversation._id });
    // Delete the conversation
    await Conversation.findByIdAndDelete(conversation._id);

    return res.status(200).json({ message: 'Conversation deleted.' });
  } catch (error) {
    console.error('DeleteConversation Error:', error);
    return res.status(500).json({ error: 'Failed to delete conversation.' });
  }
};

/**
 * POST /api/chat/:conversationId/messages
 * Send a message (text or image)
 */
exports.sendMessage = async (req, res) => {
  try {
    const { conversationId } = req.params;
    const { receiverId, text, type = 'text' } = req.body;

    if (!receiverId) {
      return res.status(400).json({ error: 'receiverId is required.' });
    }

    let imageUrl = '';
    if (req.file) {
      imageUrl = `/uploads/${req.file.filename}`;
    } else if (req.body.imageUrl) {
      imageUrl = req.body.imageUrl;
    }

    const message = await Message.create({
      conversationId,
      senderId: req.user.id,
      receiverId,
      text: text || '',
      type: imageUrl ? 'image' : type,
      imageUrl,
    });

    // Update conversation metadata
    await Conversation.findByIdAndUpdate(conversationId, {
      lastMessage: text || (imageUrl ? '📷 Image' : ''),
      lastMessageAt: new Date(),
    });

    return res.status(201).json({ message: 'Message sent', data: message });
  } catch (error) {
    console.error('SendMessage Error:', error);
    return res.status(500).json({ error: 'Failed to send message.' });
  }
};
