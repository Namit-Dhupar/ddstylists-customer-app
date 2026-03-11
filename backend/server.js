require('dotenv').config();
const http = require('http');
const app = require('./src/app');
const mongoose = require('mongoose');
const jwt = require('jsonwebtoken');

const PORT = process.env.PORT || 5000;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/ddstylists';

// Create HTTP server
const server = http.createServer(app);

// Socket.io setup
const { Server } = require('socket.io');
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

// Socket.io JWT authentication middleware
io.use((socket, next) => {
  const token = socket.handshake.auth?.token || socket.handshake.query?.token;
  if (!token) {
    return next(new Error('Authentication required'));
  }
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'super_secret_jwt_key_here');
    socket.userId = decoded.id;
    next();
  } catch (err) {
    return next(new Error('Invalid token'));
  }
});

// Import models for chat
const Message = require('./src/models/Message');
const Conversation = require('./src/models/Conversation');

// Socket.io event handlers
io.on('connection', (socket) => {
  console.log(`User connected: ${socket.userId}`);

  // Join user's personal room for direct messages
  socket.join(socket.userId);

  // Join a conversation room
  socket.on('joinRoom', (conversationId) => {
    socket.join(conversationId);
    console.log(`User ${socket.userId} joined room ${conversationId}`);
  });

  // Leave a conversation room
  socket.on('leaveRoom', (conversationId) => {
    socket.leave(conversationId);
  });

  // Send message
  socket.on('sendMessage', async (data) => {
    try {
      const { conversationId, receiverId, text, type = 'text', imageUrl } = data;

      const message = await Message.create({
        conversationId,
        senderId: socket.userId,
        receiverId,
        text,
        type,
        imageUrl,
      });

      // Update conversation
      await Conversation.findByIdAndUpdate(conversationId, {
        lastMessage: text || (type === 'image' ? '📷 Image' : ''),
        lastMessageAt: new Date(),
        [`unreadCount.${receiverId}`]: await Message.countDocuments({
          conversationId, receiverId, read: false,
        }),
      });

      // Emit to conversation room
      io.to(conversationId).emit('newMessage', message);

      // Also emit to receiver's personal room (for notification)
      io.to(receiverId).emit('messageNotification', {
        conversationId,
        senderId: socket.userId,
        text: text || '📷 Image',
      });
    } catch (err) {
      console.error('sendMessage error:', err);
      socket.emit('error', { message: 'Failed to send message' });
    }
  });

  // Typing indicator
  socket.on('typing', ({ conversationId }) => {
    socket.to(conversationId).emit('userTyping', { userId: socket.userId });
  });

  socket.on('stopTyping', ({ conversationId }) => {
    socket.to(conversationId).emit('userStoppedTyping', { userId: socket.userId });
  });

  // Mark messages as read
  socket.on('markRead', async ({ conversationId }) => {
    try {
      await Message.updateMany(
        { conversationId, receiverId: socket.userId, read: false },
        { read: true }
      );
      await Conversation.findByIdAndUpdate(conversationId, {
        [`unreadCount.${socket.userId}`]: 0,
      });
      socket.to(conversationId).emit('messagesRead', { userId: socket.userId });
    } catch (err) {
      console.error('markRead error:', err);
    }
  });

  socket.on('disconnect', () => {
    console.log(`User disconnected: ${socket.userId}`);
  });
});

// Connect to MongoDB and start server
mongoose.connect(MONGO_URI)
  .then(() => {
    console.log('Connected to MongoDB');
    server.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
      console.log(`Socket.io ready on port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error('Failed to connect to MongoDB:', err);
    process.exit(1);
  });
