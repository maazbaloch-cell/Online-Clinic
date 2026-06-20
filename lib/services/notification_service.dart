import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

class NotificationService {
  final _client = Supabase.instance.client;

  // Stream of notifications for the current user
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at')
        .map((data) => data.map((json) => NotificationModel.fromJson(json)).toList().reversed.toList());
  }

  // Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      rethrow;
    }
  }

  // Create a new notification (backend trigger equivalent for demo/manual use)
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _client.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'body': body,
        'type': type,
        'data': data,
      });
    } catch (e) {
      rethrow;
    }
  }
}
