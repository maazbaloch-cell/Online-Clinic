import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:untitled29/Dashboard.dart';
import 'package:untitled29/DoctorDashboard.dart';
import 'package:untitled29/Splash_Screen.dart';
import 'package:untitled29/Getstarted.dart';
import 'package:untitled29/Introduction_screen.dart';
import 'package:untitled29/Forget_password.dart';
import 'package:untitled29/Otp_file.dart';
import 'package:untitled29/Doctorinfo.dart';
import 'package:untitled29/Appointment.dart';
import 'package:untitled29/doctor_model.dart';
import 'package:untitled29/Patient_detail.dart';
import 'package:untitled29/chat.dart';
import 'package:untitled29/Payment.dart';
import 'package:untitled29/video_call.dart';
import 'package:untitled29/call_screen.dart';
import 'package:untitled29/billing_screen.dart';
import 'package:untitled29/models/Patient_model.dart';
import 'package:untitled29/auth/signin_screen.dart';
import 'package:untitled29/auth/signup_selector.dart';
import 'package:untitled29/auth/patient_signup_screen.dart';
import 'package:untitled29/auth/doctor_signup_screen.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/intro', builder: (context, state) => const IntroScreenDemo()),
    GoRoute(path: '/getstarted', builder: (context, state) => const Getstarted()),
    GoRoute(path: '/signin', builder: (context, state) => const SigninScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupSelector()),
    
    // Explicit Signup Routes
    GoRoute(path: '/patient-signup', builder: (context, state) => const PatientSignupScreen()),
    GoRoute(path: '/doctor-signup', builder: (context, state) => const DoctorSignupScreen()),
    
    GoRoute(path: '/dashboard', builder: (context, state) => const Dashboard()),
    GoRoute(path: '/doctor-dashboard', builder: (context, state) => const DoctorDashboard()),
    
    GoRoute(
      path: '/doctor-detail',
      builder: (context, state) {
        final doctor = state.extra is Doctor ? state.extra as Doctor : CurrentDoctor.getDummyDoctors()[0];
        return DoctorDetailPage(doctor: doctor);
      },
    ),
    GoRoute(
      path: '/appointment',
      builder: (context, state) {
        final doctor = state.extra is Doctor ? state.extra as Doctor : CurrentDoctor.getDummyDoctors()[0];
        return DoctorAppointmentScreen(doctor: doctor);
      },
    ),
    GoRoute(
      path: '/payment',
      builder: (context, state) {
        if (state.extra is Challan) {
          return PaymentPage(doctor: CurrentDoctor.getDummyDoctors()[0], challan: state.extra as Challan);
        } else if (state.extra is Doctor) {
          return PaymentPage(doctor: state.extra as Doctor);
        }
        return PaymentPage(doctor: CurrentDoctor.getDummyDoctors()[0]);
      },
    ),
    GoRoute(
      path: '/billing',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>? ?? {'name': 'Patient', 'id': null};
        return BillingScreen(patientName: args['name'], patientId: args['id']);
      },
    ),
    GoRoute(path: '/video-call', builder: (context, state) => const CreateChannelPage()),
    GoRoute(
      path: '/call/:channel',
      builder: (context, state) => CallPage(channelName: state.pathParameters['channel'] ?? 'test_room'),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>? ?? {'id': '', 'name': 'User', 'image': null};
        return ChatScreen(
          receiverId: args['id'] ?? '',
          receiverName: args['name'] ?? 'User',
          receiverImage: args['image'],
        );
      },
    ),
  ],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(url: dotenv.env['SUPABASE_URL']!, anonKey: dotenv.env['SUPABASE_ANON_KEY']!);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Online Clinic',
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true),
        routerConfig: _router,
      ),
    );
  }
}
