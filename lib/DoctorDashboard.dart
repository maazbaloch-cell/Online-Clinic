import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'doctor_model.dart';
import 'models/appointment_model.dart';
import 'services/auth_service.dart';
import 'services/doctor_service.dart';
import 'services/appointment_service.dart';
import 'Inbox_screen.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final _authService = AuthService();
  final _doctorService = DoctorService();
  final _appointmentService = AppointmentService();
  
  Doctor? doctor;
  List<AppointmentModel> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final doctorData = await _doctorService.getDoctorById(user.id);
        final appointmentsData = await _appointmentService.getDoctorAppointments(user.id);
        
        setState(() {
          doctor = doctorData;
          _appointments = appointmentsData;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateStatus(String id, String newStatus) async {
    try {
      await _appointmentService.updateAppointmentStatus(id, newStatus);
      _loadDashboardData(); // Refresh list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Appointment $newStatus"), backgroundColor: newStatus == 'confirmed' ? Colors.green : Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) context.go('/signin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Column(
          children: [
            _buildHeader(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Recent Appointments", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                  Text("${_appointments.length} Total", style: TextStyle(color: Colors.blue, fontSize: 13.sp, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Expanded(
              child: _appointments.isEmpty 
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    itemCount: _appointments.length,
                    itemBuilder: (context, index) {
                      final appt = _appointments[index];
                      return _buildAppointmentCard(appt);
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 50.h, bottom: 30.h),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40.r), 
          bottomRight: Radius.circular(40.r)
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InboxScreen())),
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  onPressed: _logout,
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 60.r, 
            backgroundColor: Colors.white24,
            backgroundImage: doctor?.networkImageUrl != null ? NetworkImage(doctor!.networkImageUrl!) : null,
            child: doctor?.networkImageUrl == null ? Icon(Icons.person, size: 50.sp, color: Colors.white) : null,
          ),
          SizedBox(height: 12.h),
          Text(doctor?.fullName ?? 'Doctor', style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
          Text(doctor?.specialty ?? 'Specialist', style: TextStyle(color: Colors.white70, fontSize: 16.sp)),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appt) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 25.r,
                backgroundColor: Colors.blue[50],
                child: Text(appt.patientName[0], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              ),
              title: Text(appt.patientName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${appt.date.day}/${appt.date.month} at ${appt.timeSlot}"),
              trailing: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: appt.status == 'pending' ? Colors.orange[50] : (appt.status == 'confirmed' ? Colors.green[50] : Colors.red[50]),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  appt.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.sp, 
                    color: appt.status == 'pending' ? Colors.orange : (appt.status == 'confirmed' ? Colors.green : Colors.red),
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
            if (appt.status == 'pending')
              Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateStatus(appt.id!, 'declined'),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                        child: const Text("Decline"),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateStatus(appt.id!, 'confirmed'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        child: const Text("Accept"),
                      ),
                    ),
                  ],
                ),
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
          Icon(Icons.event_busy, size: 60.sp, color: Colors.grey[300]),
          SizedBox(height: 10.h),
          Text("No appointments yet", style: TextStyle(color: Colors.grey, fontSize: 16.sp)),
        ],
      ),
    );
  }
}
