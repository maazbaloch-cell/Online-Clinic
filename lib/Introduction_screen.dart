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
          body: "Discover verified doctors and book appointments instantly. 24/7 availability guaranteed.",
          image: Padding(
            padding: EdgeInsets.only(top: 50.h),
            child: Container(
              width: 300.r,
              height: 300.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3.w),
                color: Colors.white,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/doctor.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: 100.sp, color: Colors.blue),
                ),
              ),
            ),
          ),
          decoration: _pageDecoration(),
        ),
        PageViewModel(
          title: "Expert Care, Anytime. Anywhere",
          body: "AI‑powered scheduling with real‑time availability. Sterile rooms. Instant confirmation.",
          image: Padding(
            padding: EdgeInsets.only(top: 50.h),
            child: Container(
              width: 300.r,
              height: 300.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3.w),
                color: Colors.white,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/doctors.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.local_hospital, size: 100.sp, color: Colors.blue),
                ),
              ),
            ),
          ),
          decoration: _pageDecoration(),
        ),
        PageViewModel(
          title: "Smarter Healthcare Begins Here",
          body: "Experience seamless booking, real‑time updates, and secure consultations designed around your comfort.",
          image: Icon(Icons.medical_information, color: Colors.white, size: 150.sp),
          decoration: _pageDecoration(),
        ),
      ],
      showSkipButton: true,
      skip: Text("Skip", style: TextStyle(color: Colors.white, fontSize: 16.sp)),
      next: Icon(Icons.chevron_right, color: Colors.white, size: 24.sp),
      onSkip: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Getstarted())),
      onDone: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Getstarted())),
      showNextButton: true,
      showDoneButton: true,
      done: Text("Done", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
      dotsDecorator: const DotsDecorator(
        activeColor: Colors.white,
        color: Colors.white24,
      ),
    );
  }

  PageDecoration _pageDecoration() {
    return PageDecoration(
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 26.sp, fontWeight: FontWeight.bold),
      bodyTextStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp, color: Colors.white),
      imagePadding: EdgeInsets.zero,
    );
  }
}
