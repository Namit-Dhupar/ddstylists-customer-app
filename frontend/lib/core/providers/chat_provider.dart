import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../network/api_config.dart';
import 'auth_provider.dart';

class Conversation {
  final String id;
  final String otherUserName;
  final String otherUserImage;
  final String lastMessage;
  final String time;
  final int unreadCount;

  Conversation({
    required this.id,
    required this.otherUserName,
    required this.otherUserImage,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
  });

  factory Conversation.fromJson(Map<String, dynamic> json, String currentUserId) {
    // Basic mapping, expecting populated participants in backend
    final participants = json['participants'] as List? ?? [];
    final otherUser = participants.firstWhere((p) => p['_id'] != currentUserId, orElse: () => <String, dynamic>{});
    
    return Conversation(
      id: json['_id'] ?? '',
      otherUserName: otherUser['firstName'] != null ? '${otherUser['firstName']} ${otherUser['lastName']}' : 'Unknown User',
      otherUserImage: otherUser['profileImage'] ?? '',
      lastMessage: json['lastMessage']?['content'] ?? 'No messages yet',
      time: 'Recently', // Normally formatted date
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}

class ChatMessage {
  final String id;
  final String content;
  final bool isImage;
  final String? imageUrl;
  final String senderId;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isImage,
    this.imageUrl,
    required this.senderId,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] ?? '',
      content: json['content'] ?? '',
      isImage: json['messageType'] == 'image',
      imageUrl: json['imageUrl'],
      senderId: json['senderId'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

// Conversation list provider
final conversationsProvider = FutureProvider<List<Conversation>>((ref) async {
  try {
    final dio = ApiConfig.createDio();
    final response = await dio.get('/chat/conversations');
    final authState = ref.watch(authProvider);
    final userId = authState.user?['_id'] ?? '';
    
    final List<dynamic> data = response.data['conversations'] ?? [];
    return data.map((json) => Conversation.fromJson(json, userId)).toList();
  } catch (_) {
    return [];
  }
});

// Conversations active manipulation provider for deletes
final chatActionProvider = Provider((ref) => ChatActions(ref));

class ChatActions {
  final Ref ref;
  ChatActions(this.ref);

  Future<bool> deleteConversation(String id) async {
    try {
      final dio = ApiConfig.createDio();
      await dio.delete('/chat/conversations/$id');
      ref.invalidate(conversationsProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> sendMessage(String conversationId, String content, {String? imagePath}) async {
    try {
      final dio = ApiConfig.createDio();
      final Map<String, dynamic> body = { 'content': content };
      
      if (imagePath != null) {
        body['image'] = await MultipartFile.fromFile(imagePath);
      }
      
      final formData = FormData.fromMap(body);
      await dio.post('/chat/$conversationId/messages', data: formData);
      ref.invalidate(messagesProvider(conversationId));
      ref.invalidate(conversationsProvider);
      return true;
    } catch (e) {
      return false;
    }
  }
}

// Messages provider for a specific conversation
final messagesProvider = FutureProvider.family<List<ChatMessage>, String>((ref, conversationId) async {
  try {
    final dio = ApiConfig.createDio();
    final response = await dio.get('/chat/$conversationId/messages');
    final List<dynamic> data = response.data['messages'] ?? [];
    return data.map((json) => ChatMessage.fromJson(json)).toList();
  } catch (_) {
    return [];
  }
});

// Optional socket connection to receive live updates
final socketProvider = Provider((ref) {
  final service = ChatSocketService(ref);
  ref.onDispose(() => service.disconnect());
  return service;
});

class ChatSocketService {
  IO.Socket? socket;
  final Ref ref;

  ChatSocketService(this.ref);

  Future<void> connect() async {
    final token = await ApiConfig.getToken();
    if (token == null) return;
    
    // Convert API URL to base URL (e.g., https://api.my-stylist.com/api -> https://api.my-stylist.com)
    final baseUrl = ApiConfig.baseUrl.replaceAll('/api', '');
    
    socket = IO.io(baseUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .setAuth({'token': token})
      .build()
    );

    socket?.onConnect((_) {
      print('Socket Connected');
    });

    socket?.on('newMessage', (data) {
      final convId = data['conversationId'];
      if (convId != null) {
        ref.invalidate(messagesProvider(convId));
        ref.invalidate(conversationsProvider);
      }
    });
  }

  void disconnect() {
    socket?.disconnect();
    socket = null;
  }
}
