import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';
import '../../core/providers/chat_provider.dart';
import 'chat_screen.dart';

/// Conversations list screen
class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key});

  @override
  ConsumerState<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(socketProvider).connect();
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(conversationsProvider);

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
              child: conversationsAsync.when(
                data: (conversations) {
                  if (conversations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.chat_bubble_outline, color: AppColors.greyDark, size: 64),
                          const SizedBox(height: 16),
                          const Text('No conversations yet', style: TextStyle(color: Colors.white, fontSize: 18)),
                          const SizedBox(height: 8),
                          const Text('Book a stylist to start chatting', style: TextStyle(color: AppColors.greyLight, fontSize: 14)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final conv = conversations[index];
                      return _ConversationTile(
                        conversation: conv,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              conversationId: conv.id,
                              otherUserName: conv.otherUserName,
                              otherUserImage: conv.otherUserImage,
                            ),
                          ));
                        },
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: AppColors.cardDark,
                              title: const Text('Delete Chat?', style: TextStyle(color: Colors.white)),
                              content: Text('Delete conversation with ${conv.otherUserName}? This cannot be undone.', style: const TextStyle(color: AppColors.greyLight)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cancel', style: TextStyle(color: AppColors.greyMid)),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            )
                          ).then((confirm) {
                            if (confirm == true) {
                              ref.read(chatActionProvider).deleteConversation(conv.id);
                            }
                          });
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
                error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ConversationTile({
    required this.conversation,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(conversation.otherUserImage),
            backgroundColor: AppColors.cardDark,
            onBackgroundImageError: (_, __) {},
          ),
          if (conversation.unreadCount > 0)
            Positioned(
              right: 0, top: 0,
              child: Container(
                width: 20, height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('${conversation.unreadCount}', style: const TextStyle(
                    color: AppColors.black, fontSize: 11, fontWeight: FontWeight.bold,
                  )),
                ),
              ),
            ),
        ],
      ),
      title: Text(conversation.otherUserName, style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: conversation.unreadCount > 0 ? FontWeight.bold : FontWeight.w500,
      )),
      subtitle: Text(
        conversation.lastMessage,
        style: TextStyle(
          color: conversation.unreadCount > 0 ? Colors.white70 : AppColors.greyLight,
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
            color: conversation.unreadCount > 0 ? AppColors.gold : AppColors.greyMid,
            fontSize: 12,
          )),
        ],
      ),
    );
  }
}
