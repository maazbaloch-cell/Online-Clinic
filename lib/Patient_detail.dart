import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'models/Patient_model.dart';

class PatientInfoPage extends StatelessWidget {
  final PatientModel patient;

  const PatientInfoPage({
    super.key,
    required this.patient,
  });

  ImageProvider _getPatientImage() {
    if (patient.imagePath != null && patient.imagePath!.isNotEmpty) {
      return FileImage(File(patient.imagePath!));
    }
    return const NetworkImage('https://via.placeholder.com/150');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 8.w, top: 4.h),
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 22.sp,
                  ),
                  color: const Color(0xFF1F1F1F),
                ),
              ),
              
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Transform.translate(
                      offset: Offset(0, -10.h),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(4.r),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF2D6CDF).withValues(alpha: 0.2), width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 46.r,
                              backgroundColor: const Color(0xFFE6E1FF),
                              backgroundImage: _getPatientImage(),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Patient Info',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2D6CDF),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Detailed information about the patient and communication options.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFF8A8A9D),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 10.h),
                    
                    _InfoField(
                      label: 'Name',
                      value: patient.name,
                      icon: Icons.person_outline_rounded,
                    ),
                    SizedBox(height: 12.h),
                    _InfoField(
                      label: 'Age',
                      value: '${patient.age} Years',
                      icon: Icons.cake_outlined,
                    ),
                    SizedBox(height: 12.h),
                    _InfoField(
                      label: 'Email',
                      value: patient.email,
                      icon: Icons.email_outlined,
                    ),
                    SizedBox(height: 12.h),
                    _InfoField(
                      label: 'City',
                      value: patient.city,
                      icon: Icons.location_on_outlined,
                    ),
                    
                    SizedBox(height: 32.h),
                    
                    SizedBox(
                      width: double.infinity,
                      child: _ActionButton(
                        label: 'Video Call',
                        icon: Icons.video_call_rounded,
                        color: const Color(0xFF2D6CDF),
                        onPressed: () {
                           context.push('/call/test_room');
                        },
                      ),
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      child: _ActionButton(
                        label: 'Chat with Patient',
                        icon: Icons.chat_bubble_outline_rounded,
                        color: const Color(0xFF2D6CDF),
                        onPressed: () {
                          context.push('/chat', extra: {
                            'name': patient.name,
                            'image': patient.imagePath,
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 12.h),
                    
                    // Added Generate Bill Button for Testing
                    SizedBox(
                      width: double.infinity,
                      child: _ActionButton(
                        label: 'Generate Bill',
                        icon: Icons.receipt_long_rounded,
                        color: Colors.green, // Different color to stand out
                        onPressed: () {
                          context.push('/billing', extra: patient.name);
                        },
                      ),
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoField({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: const Color(0xFF2D6CDF).withValues(alpha: 0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 20.sp, color: const Color(0xFF2D6CDF)),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp, 
                    color: const Color(0xFF2D6CDF).withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F1F2E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52.h,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20.sp, color: Colors.white),
        label: Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          elevation: 2,
          shadowColor: color.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
