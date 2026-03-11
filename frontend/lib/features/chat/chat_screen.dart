import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';

/// Chat screen — real-time messaging UI
/// Socket.io will be connected once backend is running
class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserName;
  final String otherUserImage;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUserName,
    required this.otherUserImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Load mock messages
    _messages.addAll([
      _ChatMessage(text: 'Hi! I saw your wardrobe and I have some great ideas for your upcoming event.', isMe: false, time: '10:00 AM'),
      _ChatMessage(text: 'That sounds amazing! I have a wedding next month and need help with outfits.', isMe: true, time: '10:02 AM'),
      _ChatMessage(text: 'Perfect! I specialise in wedding styling. Let me check your wardrobe items and suggest some combinations.', isMe: false, time: '10:03 AM'),
      _ChatMessage(text: 'I\'ve uploaded some new pieces recently. Have a look!', isMe: true, time: '10:05 AM'),
      _ChatMessage(text: 'Love the navy blazer! That would pair beautifully with the cream trousers for the reception.', isMe: false, time: '10:06 AM'),
    ]);
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isMe: true,
        time: '${TimeOfDay.now().format(context)}',
      ));
      _messageController.clear();
    });

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Simulate reply
    setState(() => _isTyping = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_ChatMessage(
            text: 'That\'s a great choice! Let me prepare some outfit boards for you. 👗',
            isMe: false,
            time: '${TimeOfDay.now().format(context)}',
          ));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.cardDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(widget.otherUserImage),
              backgroundColor: AppColors.greyDark,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.otherUserName, style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600,
                )),
                Text(
                  _isTyping ? 'typing...' : 'Online',
                  style: TextStyle(
                    color: _isTyping ? AppColors.gold : AppColors.greyLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: AppColors.gold),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Video call — Agora integration ready, add keys to .env')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          // Input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.cardDark,
              border: Border(top: BorderSide(color: AppColors.cardBorder)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: AppColors.greyMid),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.black,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: AppColors.greyMid),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 44, height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: AppColors.black, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isMe ? AppColors.gold : AppColors.cardDark,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: message.isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: message.isMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
          border: message.isMe ? null : Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isMe ? AppColors.black : Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.time,
              style: TextStyle(
                color: message.isMe ? AppColors.black.withOpacity( 0.5) : AppColors.greyMid,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 600 + i * 200),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.greyMid.withOpacity( 0.4 + value * 0.6),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isMe;
  final String time;

  _ChatMessage({required this.text, required this.isMe, required this.time});
}
