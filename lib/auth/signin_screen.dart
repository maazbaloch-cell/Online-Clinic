import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:untitled29/services/auth_service.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final supabase = Supabase.instance.client;

  bool _isLoading = false;
  bool _obscureText = true;
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleNavigation(User user) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Fetching role using our AuthService instance
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
          context.go('/doctor-dashboard');
        } else if (role == 'patient') {
          context.go('/dashboard');
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
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;
    
    setState(() => _isLoading = true);
    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on AuthException catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message), backgroundColor: Colors.red),
        );
      }
    } catch (error) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 180.h, child: Image.asset('assets/doctor.png', fit: BoxFit.contain)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 10.h),
                child: Align(alignment: Alignment.centerLeft, child: Text("Sign In", style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.bold, color: Colors.blue))),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w),
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Email", 
                    prefixIcon: const Icon(Icons.email, color: Colors.blue), 
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r))
                  ),
                  validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                ),
              ),
              SizedBox(height: 15.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    hintText: "Password", 
                    prefixIcon: const Icon(Icons.lock, color: Colors.blue), 
                    suffixIcon: IconButton(icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscureText = !_obscureText)), 
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r))
                  ),
                  validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                ),
              ),
              SizedBox(height: 25.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w),
                child: SizedBox(
                  width: double.infinity, 
                  height: 52.h, 
                  child: ElevatedButton(
                    onPressed: _signIn, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r))
                    ), 
                    child: Text("Sign In", style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              SizedBox(height: 15.h),
              const Text("OR", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              SizedBox(height: 15.h),
              
              GestureDetector(
                onTap: _continueWithGoogle,
                child: Container(
                  height: 48.h,
                  width: 300.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: Colors.transparent,
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/google.png', height: 20.h, width: 20.w, fit: BoxFit.contain),
                      SizedBox(width: 8.w),
                      Text('Continue with Google', style: TextStyle(color: Colors.black, fontSize: 14.sp)),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.h),
              Center(child: TextButton(onPressed: () => context.push('/signup'), child: const Text("Don't have an account? Sign up", style: TextStyle(color: Colors.blue)))),
            ],
          ),
        ),
      ),
    );
  }
}
