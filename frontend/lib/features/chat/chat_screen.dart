import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_theme.dart';
import '../../core/providers/chat_provider.dart';
import '../../core/providers/auth_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
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
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  bool _isSending = false;

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    final success = await ref.read(chatActionProvider).sendMessage(widget.conversationId, text);
    if (success) {
      _messageController.clear();
      _scrollToBottom();
    }
    setState(() => _isSending = false);
  }

  Future<void> _sendImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _isSending = true);
    final success = await ref.read(chatActionProvider).sendMessage(
      widget.conversationId,
      'Sent an image',
      imagePath: image.path, // Sending multipart file
    );
    if (success) {
      _scrollToBottom();
    }
    setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentUserId = authState.user?['_id'] ?? '';
    final messagesAsync = ref.watch(messagesProvider(widget.conversationId));

    // Wait until items are laid out to scroll
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

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
              onBackgroundImageError: (_, __) {},
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.otherUserName, style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600,
                )),
                const Text(
                  'Connected', 
                  style: TextStyle(color: AppColors.gold, fontSize: 12),
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
                const SnackBar(content: Text('Video call — integration ready')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(child: Text('No messages yet', style: TextStyle(color: AppColors.greyMid)));
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return _buildMessageBubble(msg, currentUserId);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
              error: (e, _) => const Center(child: Text('Failed to load messages', style: TextStyle(color: Colors.red))),
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
                    onPressed: _isSending ? null : _sendImage,
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
                  _isSending 
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold)),
                      )
                    : GestureDetector(
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

  Widget _buildMessageBubble(ChatMessage message, String currentUserId) {
    final isMe = message.senderId == currentUserId;
    final timeStr = DateFormat('jm').format(message.createdAt.toLocal());

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? AppColors.gold : AppColors.cardDark,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
          border: isMe ? null : Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.isImage && message.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  message.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white54),
                ),
              ),
            if (message.isImage) const SizedBox(height: 8),
            if (message.content.isNotEmpty)
              Text(
                message.content,
                style: TextStyle(
                  color: isMe ? AppColors.black : Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              timeStr,
              style: TextStyle(
                color: isMe ? AppColors.black.withOpacity(0.5) : AppColors.greyMid,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
