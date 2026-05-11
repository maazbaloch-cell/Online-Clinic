import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CreateChannelPage extends StatefulWidget {
  const CreateChannelPage({super.key});

  @override
  State<CreateChannelPage> createState() => _CreateChannelPageState();
}

class _CreateChannelPageState extends State<CreateChannelPage> {
  final TextEditingController _channelController = TextEditingController();
  bool _isValidateError = false;

  @override
  void dispose() {
    _channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Video Conference",
          style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40.h),
              Container(
                height: 180.h,
                width: 180.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D6CDF).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.video_camera_back_rounded,
                  size: 80.sp,
                  color: const Color(0xFF2D6CDF),
                ),
              ),
              SizedBox(height: 30.h),
              Text(
                "Start a Video Call",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F1F2E),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                "Enter a channel name to start or join a video conference with your doctor.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              SizedBox(height: 40.h),
              
              TextField(
                controller: _channelController,
                decoration: InputDecoration(
                  hintText: 'Channel Name (e.g. clinic_room)',
                  errorText: _isValidateError ? 'Channel name is mandatory' : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                    borderSide: const BorderSide(color: Color(0xFF2D6CDF)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                    borderSide: const BorderSide(color: Color(0xFF2D6CDF), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: const Icon(Icons.meeting_room_rounded, color: Color(0xFF2D6CDF)),
                ),
              ),
              SizedBox(height: 30.h),

              SizedBox(
                width: double.infinity,
                height: 55.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D6CDF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    elevation: 5,
                    shadowColor: const Color(0xFF2D6CDF).withOpacity(0.3),
                  ),
                  onPressed: onJoin,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Join Meeting",
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(width: 10.w),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onJoin() {
    setState(() {
      _channelController.text.isEmpty ? _isValidateError = true : _isValidateError = false;
    });
    if (_channelController.text.isNotEmpty) {
      context.push('/call/${_channelController.text.trim()}');
    }
  }
}
