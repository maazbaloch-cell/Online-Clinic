import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'doctor_model.dart';
import 'chat.dart';

class DoctorDetailPage extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailPage({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    ImageProvider backgroundImage;

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
                        doctor.fullName,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800, color: const Color(0xFF2D6CDF)),
                      ),
                      Text(
                        doctor.specialty,
                        style: TextStyle(fontSize: 15.sp, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Schedule your session with ${doctor.fullName}. \nFee: Rs ${doctor.fee}',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey[700], height: 1.6),
                      ),
                      SizedBox(height: 30.h),
                      _buildButton(
                        context: context,
                        label: 'Take Appointment',
                        onPressed: () => context.push('/appointment', extra: doctor),
                        isPrimary: true,
                      ),
                      SizedBox(height: 12.h),
                      _buildButton(
                        context: context,
                        label: 'Chat with Doctor',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                receiverId: doctor.id ?? '',
                                receiverName: doctor.fullName,
                                receiverImage: doctor.networkImageUrl,
                              ),
                            ),
                          );
                        },
                        icon: Icons.chat_bubble_outline_rounded,
                      ),
                      SizedBox(height: 12.h),
                      _buildButton(
                        context: context,
                        label: 'Video Call with Doctor',
                        onPressed: () {
                          String channelName = doctor.id ?? 'default_room';
                          context.push('/call/$channelName');
                        },
                        icon: Icons.videocam_outlined,
                      ),
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

  Widget _buildButton({required BuildContext context, required String label, required VoidCallback onPressed, IconData? icon, bool isPrimary = false}) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: isPrimary 
        ? ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D6CDF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r))),
            onPressed: onPressed,
            child: Text(label, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600)),
          )
        : OutlinedButton.icon(
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF2D6CDF), width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r))),
            onPressed: onPressed,
            icon: Icon(icon, size: 20.sp, color: const Color(0xFF2D6CDF)),
            label: Text(label, style: TextStyle(color: const Color(0xFF2D6CDF), fontSize: 16.sp, fontWeight: FontWeight.w600)),
          ),
    );
  }
}
