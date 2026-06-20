import 'package:supabase_flutter/supabase_flutter.dart';

class CallService {
  final _client = Supabase.instance.client;

  // Call record save karne ke liye database mein
  Future<void> logCall({
    required String channelName,
    required String doctorId,
    required String patientId,
  }) async {
    try {
      await _client.from('calls').insert({
        'channel_name': channelName,
        'doctor_id': doctorId,
        'patient_id': patientId,
        'status': 'started',
      });
    } catch (e) {
      print("Error logging call: $e");
    }
  }

  // Call end hone par status update karne ke liye
  Future<void> endCall(String channelName) async {
    try {
      await _client
          .from('calls')
          .update({'status': 'ended', 'ended_at': DateTime.now().toIso8601String()})
          .eq('channel_name', channelName)
          .eq('status', 'started');
    } catch (e) {
      print("Error ending call: $e");
    }
  }
}
