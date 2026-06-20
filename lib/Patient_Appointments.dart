import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/appointment_model.dart';
import 'services/appointment_service.dart';

class PatientAppointmentsScreen extends StatefulWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  State<PatientAppointmentsScreen> createState() => _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState extends State<PatientAppointmentsScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  final String _currentUserId = Supabase.instance.client.auth.currentUser!.id;
  List<AppointmentModel> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    try {
      final data = await _appointmentService.getPatientAppointments(_currentUserId);
      setState(() {
        _appointments = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D6CDF),
        title: Text("My Appointments", style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAppointments,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _appointments.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: _appointments.length,
                    itemBuilder: (context, index) {
                      final appt = _appointments[index];
                      return _buildApptCard(appt);
                    },
                  ),
      ),
    );
  }

  Widget _buildApptCard(AppointmentModel appt) {
    Color statusColor = Colors.orange;
    if (appt.status == 'confirmed') statusColor = Colors.green;
    if (appt.status == 'declined') statusColor = Colors.red;

    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Dr. ${appt.doctorName}",
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    appt.status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 10.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14.sp, color: Colors.grey),
                SizedBox(width: 8.w),
                Text("${appt.date.day}/${appt.date.month}/${appt.date.year}", style: TextStyle(color: Colors.grey[700])),
              ],
            ),
            SizedBox(height: 5.h),
            Row(
              children: [
                Icon(Icons.access_time, size: 14.sp, color: Colors.grey),
                SizedBox(width: 8.w),
                Text(appt.timeSlot, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, size: 60.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text("No appointments found", style: TextStyle(color: Colors.grey, fontSize: 16.sp)),
        ],
      ),
    );
  }
}
