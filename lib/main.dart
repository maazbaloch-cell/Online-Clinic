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
import 'package:untitled29/test_google_screen.dart';
import 'package:untitled29/auth/signin_screen.dart';
import 'package:untitled29/auth/signup_selector.dart';
import 'package:untitled29/auth/patient_signup_screen.dart';
import 'package:untitled29/auth/doctor_signup_screen.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/test-google',
      builder: (context, state) => const TestGoogleScreen(),
    ),
    GoRoute(
      path: '/intro',
      builder: (context, state) => const IntroScreenDemo(),
    ),
    GoRoute(
      path: '/getstarted',
      builder: (context, state) => const Getstarted(),
    ),
    GoRoute(
      path: '/signin',
      builder: (context, state) => const SigninScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupSelector(),
    ),
    GoRoute(
      path: '/patient-signup',
      builder: (context, state) => const PatientSignupScreen(),
    ),
    GoRoute(
      path: '/doctor-signup',
      builder: (context, state) => const DoctorSignupScreen(),
    ),
    GoRoute(
      path: '/forget-password',
      builder: (context, state) => const ForgetPassword(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) => const Otp(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const Dashboard(),
    ),
    GoRoute(
      path: '/doctor-dashboard',
      builder: (context, state) => const DoctorDashboard(),
    ),
    GoRoute(
      path: '/doctor-detail',
      builder: (context, state) {
        if (state.extra == null || state.extra is! Doctor) {
          return DoctorDetailPage(doctor: CurrentDoctor.current!);
        }
        return DoctorDetailPage(doctor: state.extra as Doctor);
      },
    ),
    GoRoute(
      path: '/appointment',
      builder: (context, state) {
        if (state.extra == null || state.extra is! Doctor) {
          return DoctorAppointmentScreen(doctor: CurrentDoctor.current!);
        }
        return DoctorAppointmentScreen(doctor: state.extra as Doctor);
      },
    ),
    GoRoute(
      path: '/payment',
      builder: (context, state) {
        if (state.extra is Challan) {
          return PaymentPage(
            doctor: CurrentDoctor.current!,
            challan: state.extra as Challan,
          );
        } else if (state.extra is Doctor) {
          return PaymentPage(doctor: state.extra as Doctor);
        } else {
          return PaymentPage(doctor: CurrentDoctor.current!);
        }
      },
    ),
    GoRoute(
      path: '/billing',
      builder: (context, state) {
        final name = (state.extra is String) ? state.extra as String : "Ali Khan";
        return BillingScreen(patientName: name);
      },
    ),
    GoRoute(
      path: '/video-call',
      builder: (context, state) => const CreateChannelPage(),
    ),
    GoRoute(
      path: '/call/:channel',
      builder: (context, state) => CallPage(channelName: state.pathParameters['channel']!),
    ),
    GoRoute(
      path: '/patient-detail',
      builder: (context, state) {
        if (state.extra == null || state.extra is! PatientModel) {
          return Scaffold(
            body: PatientInfoPage(
              patient: PatientModel(
                name: 'Guest Patient',
                age: 25,
                email: 'guest@mail.com',
                city: 'Karachi',
                password: '',
                cnic: '',
                gender: 'Male',
                address: '',
              ),
            ),
          );
        }
        return PatientInfoPage(patient: state.extra as PatientModel);
      },
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) {
        final Map<String, dynamic> args = (state.extra != null && state.extra is Map<String, dynamic>)
            ? state.extra as Map<String, dynamic>
            : {'id': '', 'name': 'User', 'image': null};
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
  final supabaseUrl = dotenv.env['SUPABASE_URL']!;
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
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
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Doctor App',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
                useMaterial3: true,
              ),
              routerConfig: _router,
            ),
          ),
        );
      },
    );
  }
}
