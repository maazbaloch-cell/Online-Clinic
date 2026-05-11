import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'doctor_model.dart';

class DoctorDetailPage extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailPage({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    ImageProvider backgroundImage;

    // Image logic with fallback
    if (doctor.imagePath != null && doctor.imagePath!.isNotEmpty) {
      backgroundImage = kIsWeb 
          ? NetworkImage(doctor.imagePath!) 
          : FileImage(File(doctor.imagePath!)) as ImageProvider;
    } else if (doctor.networkImageUrl != null && doctor.networkImageUrl!.isNotEmpty) {
      backgroundImage = NetworkImage(doctor.networkImageUrl!);
    } else {
      backgroundImage = const NetworkImage('https://via.placeholder.com/300x400?text=No+Image');
    }

    return Scaffold(
      backgroundColor: const Color(0xFF2D6CDF),
      body: SafeArea(
        child: Column(
          children: [
            // Top Image Section
            Stack(
              children: [
                SizedBox(
                  height: 250.h,
                  width: double.infinity,
                  child: Image(
                    image: backgroundImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.person, size: 80.sp, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  top: 10.h,
                  left: 10.w,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
            
            // Details Section
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.r),
                    topRight: Radius.circular(30.r),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 25.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        doctor.fullName.isNotEmpty ? doctor.fullName : "Unknown Doctor",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2D6CDF),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        doctor.specialty.isNotEmpty ? doctor.specialty : "General Physician",
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      
                      // Divider
                      Container(
                        height: 2.h,
                        width: 40.w,
                        color: const Color(0xFF2D6CDF).withOpacity(0.2),
                      ),
                      SizedBox(height: 20.h),
                      
                      Text(
                        'Personal Appointment',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Schedule your session with ${doctor.fullName}. ${doctor.qualification}. \nFee: Rs ${doctor.fee} \nTiming: ${doctor.workingTime}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[700],
                          height: 1.6,
                        ),
                      ),
                      
                      SizedBox(height: 30.h),

                      // Appointment Button
                      _buildButton(
                        context: context,
                        label: 'Take Appointment',
                        onPressed: () => context.push('/appointment', extra: doctor),
                        isPrimary: true,
                      ),
                      
                      SizedBox(height: 12.h),

                      // Chat Button
                      _buildButton(
                        context: context,
                        label: 'Chat with Doctor',
                        onPressed: () => context.push('/chat', extra: {
                          'name': doctor.fullName,
                          'image': doctor.imagePath ?? doctor.networkImageUrl,
                        }),
                        icon: Icons.chat_bubble_outline_rounded,
                      ),

                      SizedBox(height: 12.h),

                      // Video Call Button
                      _buildButton(
                        context: context,
                        label: 'Video Call with Doctor',
                        onPressed: () {
                          // For now, joining a default channel based on doctor's name
                          String channelName = doctor.firstName.toLowerCase().replaceAll(' ', '_');
                          context.push('/call/$channelName');
                        },
                        icon: Icons.videocam_outlined,
                      ),
                      
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    bool isPrimary = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: isPrimary 
        ? ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D6CDF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
              elevation: 0,
            ),
            onPressed: onPressed,
            child: Text(label, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600)),
          )
        : OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2D6CDF), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
            ),
            onPressed: onPressed,
            icon: Icon(icon, size: 20.sp, color: const Color(0xFF2D6CDF)),
            label: Text(label, style: TextStyle(color: const Color(0xFF2D6CDF), fontSize: 16.sp, fontWeight: FontWeight.w600)),
          ),
    );
  }
}
