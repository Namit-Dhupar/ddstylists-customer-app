import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';
import 'chat_screen.dart';

/// Conversations list screen
class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock conversations
    final conversations = [
      _ConversationData(
        name: 'Amara Chen',
        image: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
        lastMessage: 'Love the navy blazer! That would pair beautifully...',
        time: '10:06 AM',
        unread: 2,
      ),
      _ConversationData(
        name: 'Priya Sharma',
        image: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
        lastMessage: 'Your outfit for the corporate event is ready!',
        time: 'Yesterday',
        unread: 0,
      ),
      _ConversationData(
        name: 'James Wright',
        image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
        lastMessage: 'Let me put together some sustainable options...',
        time: 'Mon',
        unread: 0,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Messages', style: GoogleFonts.playfairDisplay(
                fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.gold,
                fontStyle: FontStyle.italic,
              )),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Chat with your stylists', style: TextStyle(color: AppColors.greyLight, fontSize: 13)),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: conversations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, color: AppColors.greyDark, size: 64),
                        const SizedBox(height: 16),
                        const Text('No conversations yet', style: TextStyle(color: Colors.white, fontSize: 18)),
                        const SizedBox(height: 8),
                        const Text('Book a stylist to start chatting', style: TextStyle(color: AppColors.greyLight, fontSize: 14)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final conv = conversations[index];
                      return _ConversationTile(
                        conversation: conv,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              conversationId: 'conv_$index',
                              otherUserName: conv.name,
                              otherUserImage: conv.image,
                            ),
                          ));
                        },
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final _ConversationData conversation;
  final VoidCallback onTap;

  const _ConversationTile({required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(conversation.image),
            backgroundColor: AppColors.cardDark,
          ),
          if (conversation.unread > 0)
            Positioned(
              right: 0, top: 0,
              child: Container(
                width: 20, height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('${conversation.unread}', style: const TextStyle(
                    color: AppColors.black, fontSize: 11, fontWeight: FontWeight.bold,
                  )),
                ),
              ),
            ),
        ],
      ),
      title: Text(conversation.name, style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: conversation.unread > 0 ? FontWeight.bold : FontWeight.w500,
      )),
      subtitle: Text(
        conversation.lastMessage,
        style: TextStyle(
          color: conversation.unread > 0 ? Colors.white70 : AppColors.greyLight,
          fontSize: 13,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(conversation.time, style: TextStyle(
            color: conversation.unread > 0 ? AppColors.gold : AppColors.greyMid,
            fontSize: 12,
          )),
        ],
      ),
    );
  }
}

class _ConversationData {
  final String name;
  final String image;
  final String lastMessage;
  final String time;
  final int unread;

  _ConversationData({
    required this.name,
    required this.image,
    required this.lastMessage,
    required this.time,
    required this.unread,
  });
}
