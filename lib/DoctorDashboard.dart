import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/Patient_model.dart';
import 'doctor_model.dart';
import 'services/auth_service.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final _authService = AuthService();
  Doctor? doctor;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  void _loadDoctorData() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        // Build Doctor object with all required parameters to fix the error
        doctor = Doctor(
          firstName: user.userMetadata?['first_name'] ?? 'Doctor',
          lastName: user.userMetadata?['last_name'] ?? '',
          specialty: user.userMetadata?['specialty'] ?? 'Specialist',
          qualification: user.userMetadata?['qualification'] ?? 'MBBS',
          rating: 0.0,
          reviews: 0,
          fee: int.tryParse(user.userMetadata?['fee']?.toString() ?? '0') ?? 0,
          workingTime: '09:00 AM - 05:00 PM',
          imagePath: null,
        );
        CurrentDoctor.current = doctor;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) context.go('/signin');
  }

  ImageProvider _buildDoctorImage(Doctor? doc) {
    if (doc != null && doc.imagePath != null && doc.imagePath!.isNotEmpty) {
      return kIsWeb 
          ? const NetworkImage('https://via.placeholder.com/150') 
          : FileImage(File(doc.imagePath!)) as ImageProvider;
    }
    return const AssetImage("assets/Doctor.jpg");
  }

  @override
  Widget build(BuildContext context) {
    final patients = PatientModel.patients;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 40.h, bottom: 20.h),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.r), 
                bottomRight: Radius.circular(30.r)
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, color: Colors.white),
                        onPressed: _logout,
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 50.r,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 47.r,
                    backgroundImage: _buildDoctorImage(doctor),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  doctor?.fullName ?? 'Doctor Dashboard', 
                  style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)
                ),
                Text(
                  doctor?.specialty ?? 'Specialist', 
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14.sp)
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Recent Patients", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final patient = patients[index];
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.only(bottom: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10.w),
                    leading: CircleAvatar(
                      radius: 25.r,
                      backgroundColor: Colors.blue[50],
                      child: Icon(Icons.person, color: Colors.blue[300]),
                    ),
                    title: Text(patient.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${patient.age} Years • ${patient.gender}"),
                    trailing: ElevatedButton(
                      onPressed: () => context.push('/patient-detail', extra: patient),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r))
                      ),
                      child: const Text("View", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
