import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled29/Getstarted.dart';

class IntroScreenDemo extends StatelessWidget {
  const IntroScreenDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      globalBackgroundColor: Colors.blue,
      pages: [
        PageViewModel(
          title: "Your Health is Our Commitment",
          body:
          "Discover verified doctors and book appointments instantly. 24/7 availability guaranteed.",
          image: Padding(
            padding: EdgeInsets.only(top: 50.h),
            child: Container(
              width: 250.w,
              height: 200.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.w),
              ),
              child: CircleAvatar(
                radius: 90.r,
                backgroundColor: Colors.white,
                backgroundImage: const AssetImage('assets/doctor.png'),
              ),
            ),
          ),
          decoration: PageDecoration(
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
            ),
            bodyTextStyle: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              color: Colors.white,
            ),
          ),
        ),
        PageViewModel(
          title: "Expert Care, Anytime. Anywhere",
          body:
          "AI‑powered scheduling with real‑time availability. Sterile rooms. Instant confirmation.",
          image: Padding(
            padding: EdgeInsets.only(top: 50.h),
            child: Container(
              width: 250.w,
              height: 200.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.w),
              ),
              child: CircleAvatar(
                radius: 90.r,
                backgroundColor: Colors.white,
                backgroundImage: const AssetImage('assets/theter.jpg'),
              ),
            ),
          ),
          decoration: PageDecoration(
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
            ),
            bodyTextStyle: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              color: Colors.white,
            ),
          ),
        ),
        PageViewModel(
          title: "Smarter Healthcare Begins Here",
          body:
          "Experience seamless booking, real‑time updates, and secure consultations designed around your comfort.",
          image: Icon(
            Icons.medical_information,
            color: Colors.white,
            size: 100.sp,
          ),
          footer: Padding(
            padding: EdgeInsets.only(top: 70.h, left: 20.w, right: 20.w),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Getstarted()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15.h),
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Get Started',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          decoration: PageDecoration(
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
            ),
            imagePadding: EdgeInsets.only(top: 60.h),
            bodyTextStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
              color: Colors.white,
            ),
          ),
        ),
      ],
      showSkipButton: true,
      skip: Text(
        "Skip",
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.sp,
        ),
      ),
      next: Icon(
        Icons.chevron_right,
        color: Colors.white,
        size: 24.sp,
      ),
      onSkip: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Getstarted()),
        );
      },
      baseBtnStyle: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      showNextButton: true,
      showDoneButton: false,
    );
  }
}
