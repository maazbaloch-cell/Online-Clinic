import 'package:supabase_flutter/supabase_flutter.dart';
import '../doctor_model.dart';

class DoctorService {
  final _client = Supabase.instance.client;

  Future<List<Doctor>> getAllDoctors() async {
    try {
      // Fetching from doctors table and joining with profiles table
      final response = await _client
          .from('doctors')
          .select('*, profiles(*)');
      
      return (response as List).map((json) => Doctor.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateDoctorProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _client.from('doctors').upsert({
        'id': userId,
        ...data,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<Doctor?> getDoctorById(String userId) async {
    try {
      final response = await _client
          .from('doctors')
          .select('*, profiles(*)')
          .eq('id', userId)
          .maybeSingle();
      
      if (response == null) return null;
      return Doctor.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
