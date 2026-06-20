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
            padding: EdgeInsets.only(top: 60.h),
            child: CircleAvatar(
              radius: 120.r,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 115.r,
                backgroundImage: const AssetImage('assets/Doctor.jpg'),
                backgroundColor: Colors.white,
              ),
            ),
          ),
          decoration: _pageDecoration(),
        ),
        PageViewModel(
          title: "Expert Care, Anytime. Anywhere",
          body: "AI‑powered scheduling with real‑time availability. Sterile rooms. Instant confirmation.",
          image: Padding(
            padding: EdgeInsets.only(top: 60.h),
            child: CircleAvatar(
              radius: 120.r,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 115.r,
                backgroundImage: const AssetImage('assets/doctor.png'),
                backgroundColor: Colors.white,
              ),
            ),
          ),
          decoration: _pageDecoration(),
        ),
        PageViewModel(
          title: "Smarter Healthcare Begins Here",
          body: "Experience seamless booking, real‑time updates, and secure consultations designed around your comfort.",
          image: Padding(
            padding: EdgeInsets.only(top: 60.h),
            child: CircleAvatar(
              radius: 120.r,
              backgroundColor: Colors.white,
              child: Icon(Icons.medical_information, color: Colors.blue, size: 100.sp),
            ),
          ),
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
