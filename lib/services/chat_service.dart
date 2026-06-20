import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_model.dart';

class ChatService {
  final _client = Supabase.instance.client;

  // Send Message
  Future<void> sendMessage(MessageModel message) async {
    try {
      await _client.from('messages').insert(message.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // Get Messages Stream for a specific conversation
  Stream<List<MessageModel>> getMessagesStream(String userId, String otherId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((data) {
          return data
              .map((json) => MessageModel.fromJson(json))
              .where((msg) =>
                  (msg.senderId == userId && msg.receiverId == otherId) ||
                  (msg.senderId == otherId && msg.receiverId == userId))
              .toList();
        });
  }

  // Get list of all people the user has chatted with
  Future<List<Map<String, dynamic>>> getRecentChats(String userId) async {
    try {
      // This query gets unique contacts by looking at sender and receiver
      final response = await _client
          .from('messages')
          .select('sender_id, receiver_id, content, created_at, profiles!messages_sender_id_fkey(first_name, last_name, role), receiver:profiles!messages_receiver_id_fkey(first_name, last_name, role)')
          .or('sender_id.eq.$userId,receiver_id.eq.$userId')
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> chats = [];
      final Set<String> seenIds = {};

      for (var item in response as List) {
        final otherId = item['sender_id'] == userId ? item['receiver_id'] : item['sender_id'];
        
        if (!seenIds.contains(otherId)) {
          seenIds.add(otherId);
          final otherProfile = item['sender_id'] == userId ? item['receiver'] : item['profiles'];
          
          chats.add({
            'other_id': otherId,
            'other_name': "${otherProfile['first_name']} ${otherProfile['last_name']}",
            'last_message': item['content'],
            'time': item['created_at'],
          });
        }
      }
      return chats;
    } catch (e) {
      return [];
    }
  }
}
