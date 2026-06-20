import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  final _client = Supabase.instance.client;

  Future<void> createAppointment(AppointmentModel appointment) async {
    try {
      await _client.from('appointments').insert(appointment.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AppointmentModel>> getPatientAppointments(String patientId) async {
    try {
      final response = await _client
          .from('appointments')
          .select()
          .eq('patient_id', patientId)
          .order('date', ascending: true);
      
      return (response as List).map((json) => AppointmentModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AppointmentModel>> getDoctorAppointments(String doctorId) async {
    try {
      final response = await _client
          .from('appointments')
          .select()
          .eq('doctor_id', doctorId)
          .order('created_at', ascending: false);
      
      return (response as List).map((json) => AppointmentModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await _client
          .from('appointments')
          .update({'status': status})
          .eq('id', appointmentId);
    } catch (e) {
      rethrow;
    }
  }
}
