import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Patient extends StatefulWidget {
  const Patient({super.key});

  @override
  State<Patient> createState() => _PatientState();
}

class _PatientState extends State<Patient> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;
  bool _isLoading = false;
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _selectedGender;
  bool _showErrors = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    _cnicController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  Future<void> _submit() async {
    setState(() {
      _showErrors = true;
    });

    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Supabase Auth Signup
      final AuthResponse res = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'role': 'patient',
          'age': _ageController.text,
          'city': _cityController.text,
          'gender': _selectedGender,
        },
      );

      if (res.user != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful! Please check your email for confirmation.')),
          );
          context.pushReplacement('/signin');
        }
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message), backgroundColor: Colors.red),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unexpected error occurred'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.r)),
      errorMaxLines: 1,
    );
  }

  String? _validateRequired(String? value) {
    if (!_showErrors) return null;
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            reverse: true,
            padding: EdgeInsets.only(bottom: 40.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Setup Patient Profile', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 20.h),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80.r,
                        height: 80.r,
                        decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
                        child: ClipOval(
                          child: _pickedImage != null
                              ? (kIsWeb 
                                  ? Image.network(_pickedImage!.path, width: 80.r, height: 80.r, fit: BoxFit.cover)
                                  : Image.file(File(_pickedImage!.path), width: 80.r, height: 80.r, fit: BoxFit.cover))
                              : const Icon(Icons.person, size: 40, color: Colors.grey),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextButton.icon(onPressed: _pickImage, icon: const Icon(Icons.camera_alt_outlined), label: const Text('Upload Photo')),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_labelWithStar('First Name'), SizedBox(height: 5.h), TextFormField(controller: _firstNameController, decoration: _inputDecoration('John'), validator: _validateRequired)])),
                    SizedBox(width: 12.w),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_labelWithStar('Last Name'), SizedBox(height: 5.h), TextFormField(controller: _lastNameController, decoration: _inputDecoration('Doe'), validator: _validateRequired)])),
                  ],
                ),
                SizedBox(height: 12.h),
                _labelWithStar('Email'),
                SizedBox(height: 5.h),
                TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: _inputDecoration('example@mail.com'), validator: (val) {
                  if (!_showErrors) return null;
                  if (val == null || val.isEmpty) return 'Required';
                  if (!val.contains('@')) return 'Invalid email';
                  return null;
                }),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_labelWithStar('Password'), SizedBox(height: 5.h), TextFormField(controller: _passwordController, obscureText: _obscurePassword, decoration: _inputDecoration('********', suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscurePassword = !_obscurePassword))), validator: (val) {
                      if (!_showErrors) return null;
                      if (val == null || val.length < 6) return 'Min 6 characters';
                      return null;
                    })])),
                    SizedBox(width: 12.w),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_labelWithStar('Confirm Password'), SizedBox(height: 5.h), TextFormField(controller: _confirmPasswordController, obscureText: _obscureConfirmPassword, decoration: _inputDecoration('********', suffixIcon: IconButton(icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword))), validator: (val) {
                      if (!_showErrors) return null;
                      if (val == null || val.isEmpty) return 'Required';
                      if (val != _passwordController.text) return 'Not Match';
                      return null;
                    })])),
                  ],
                ),
                SizedBox(height: 12.h),
                _labelWithStar('Age'),
                SizedBox(height: 5.h),
                TextFormField(controller: _ageController, keyboardType: TextInputType.number, decoration: _inputDecoration('Enter Age'), validator: _validateRequired),
                SizedBox(height: 12.h),
                _labelWithStar('CNIC'),
                SizedBox(height: 5.h),
                TextFormField(controller: _cnicController, keyboardType: TextInputType.number, decoration: _inputDecoration('12345-1234567-1'), validator: _validateRequired),
                SizedBox(height: 12.h),
                _labelWithStar('Gender'),
                SizedBox(height: 5.h),
                DropdownButtonFormField<String>(decoration: _inputDecoration('Select Gender'), items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(), onChanged: (val) => setState(() => _selectedGender = val), validator: (val) {
                  if (!_showErrors) return null;
                  return val == null ? 'Required' : null;
                }),
                SizedBox(height: 12.h),
                _labelWithStar('City'),
                SizedBox(height: 5.h),
                TextFormField(controller: _cityController, decoration: _inputDecoration('Enter City'), validator: _validateRequired),
                SizedBox(height: 12.h),
                _labelWithStar('Address'),
                SizedBox(height: 5.h),
                TextFormField(controller: _addressController, maxLines: 2, decoration: _inputDecoration('Enter Full Address'), validator: _validateRequired),
                SizedBox(height: 25.h),
                GestureDetector(onTap: _submit, child: Container(height: 44.h, width: double.infinity, decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.r), color: Colors.blue), child: const Center(child: Text('Setup Your Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))),
                SizedBox(height: 15.h),
                Center(child: GestureDetector(onTap: () => context.push('/signin'), child: Text.rich(TextSpan(text: "Already have an Account? ", style: const TextStyle(color: Colors.black), children: [TextSpan(text: 'Sign in', style: const TextStyle(color: Colors.blue))])))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _labelWithStar(String text) {
    return RichText(text: TextSpan(text: text, style: const TextStyle(color: Colors.black, fontSize: 14), children: const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))]));
  }
}
