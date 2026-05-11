import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:untitled29/services/auth_service.dart';
import 'package:untitled29/doctor_model.dart';

class Getstarted extends StatefulWidget {
  const Getstarted({super.key});

  @override
  State<Getstarted> createState() => _GetstartedState();
}

class _GetstartedState extends State<Getstarted> {
  final _authService = AuthService();
  final supabase = Supabase.instance.client;
  bool _isLoading = false;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn && data.session != null) {
        _handleNavigation(data.session!.user);
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handleNavigation(User user) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      String? role = await _authService.getUserRole(user.id);
      role ??= user.userMetadata?['role'];
      if (role == null) {
        if (mounted) {
          role = await _showRoleSelectionDialog();
          if (role != null) {
            await supabase.from('profiles').upsert({
              'id': user.id,
              'email': user.email,
              'role': role,
              'first_name': user.userMetadata?['full_name']?.split(' ').first ?? 'User',
              'last_name': user.userMetadata?['full_name']?.split(' ').last ?? '',
            });
          }
        }
      }
      if (mounted) {
        setState(() => _isLoading = false);
        if (role == 'doctor') {
          CurrentDoctor.current = CurrentDoctor.getDummyDoctors()[0]; 
          context.go('/doctor-dashboard');
        } else if (role == 'patient') {
          context.go('/dashboard');
        } else if (role != null) {
        } else {
          context.go('/signup');
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String?> _showRoleSelectionDialog() async {
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Account Category', textAlign: TextAlign.center),
        content: const Text('Please select if you are a Doctor or a Patient to continue.'),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () => Navigator.pop(context, 'doctor'),
            child: const Text('Doctor', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () => Navigator.pop(context, 'patient'),
            child: const Text('Patient', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _continueWithGoogle() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    
    try {
      if (kIsWeb) {
        await supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: kIsWeb ? null : 'io.supabase.flutter://callback',
        );
      } else {
        final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? "";
        final GoogleSignIn googleSignIn = GoogleSignIn(serverClientId: webClientId);
        final GoogleSignInAccount? user = await googleSignIn.signIn();
        
        if (user == null) {
          setState(() => _isLoading = false);
          return;
        }

        final auth = await user.authentication;
        if (auth.idToken == null) throw 'No ID Token found.';

        await supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: auth.idToken!,
          accessToken: auth.accessToken,
        );
      }
    } catch (e) {
      debugPrint("Google Login Error: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Lets Create', style: TextStyle(fontSize: 40.sp, color: Colors.blue, fontWeight: FontWeight.bold)),
              SizedBox(width: 10.w),
              Icon(Icons.health_and_safety, size: 50.sp, color: Colors.blue),
            ],
          ),
          SizedBox(height: 80.h),
          _buildButton('Sign in', Colors.transparent, Colors.blue, () => context.push('/signin')),
          SizedBox(height: 15.h),
          _buildButton('Sign up', Colors.blue, Colors.white, () => context.push('/signup')),
          SizedBox(height: 25.h),
          const Text('OR', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          SizedBox(height: 25.h),
          GestureDetector(
            onTap: _continueWithGoogle,
            child: Container(
              height: 48.h,
              width: 300.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.blue),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/google.png', height: 20.h, width: 20.w, fit: BoxFit.contain),
                  SizedBox(width: 10.w),
                  Text('Continue with Google', style: TextStyle(color: Colors.black, fontSize: 15.sp)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, Color bgColor, Color textColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.h,
        width: 300.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: bgColor,
          border: Border.all(color: Colors.blue),
        ),
        child: Center(
          child: Text(text, style: TextStyle(color: textColor, fontSize: 16.sp, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
