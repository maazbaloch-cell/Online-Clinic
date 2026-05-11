import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DoctorScreen extends StatefulWidget {
  const DoctorScreen({super.key});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;
  bool _isLoading = false;

  final TextEditingController _firstNameCtrl = TextEditingController();
  final TextEditingController _lastNameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();
  final TextEditingController _medicalSpecialtyCtrl = TextEditingController();
  final TextEditingController _qualificationCtrl = TextEditingController();
  final TextEditingController _ratingCtrl = TextEditingController();
  final TextEditingController _reviewsCtrl = TextEditingController();
  final TextEditingController _feeCtrl = TextEditingController();
  final TextEditingController _workingTimeCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  dynamic _selectedLicenseYears;
  DateTime? _selectedDob;

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  @override
  void dispose() {
    _firstNameCtrl.dispose(); _lastNameCtrl.dispose(); _emailCtrl.dispose(); _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose(); _medicalSpecialtyCtrl.dispose(); _qualificationCtrl.dispose();
    _ratingCtrl.dispose(); _reviewsCtrl.dispose(); _feeCtrl.dispose(); _workingTimeCtrl.dispose();
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
    if (_formKey.currentState?.validate() != true) return;
    if (_selectedDob == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Date of Birth')));
       return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final AuthResponse res = await supabase.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        data: {
          'first_name': _firstNameCtrl.text.trim(),
          'last_name': _lastNameCtrl.text.trim(),
          'role': 'doctor',
          'specialty': _medicalSpecialtyCtrl.text.trim(),
          'qualification': _qualificationCtrl.text.trim(),
          'fee': _feeCtrl.text.trim(),
          'license_years': _selectedLicenseYears?.name,
        },
      );

      if (res.user != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Doctor Profile Created! Please confirm your email.')),
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
    return InputDecoration(hintText: hint, isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h), suffixIcon: suffixIcon, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.r)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.of(context).pop())),
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
                const Text('Setup Your Profile', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
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
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_labelWithStar('First Name'), SizedBox(height: 5.h), TextFormField(controller: _firstNameCtrl, decoration: _inputDecoration('Faizan'), validator: (val) => (val == null || val.isEmpty) ? 'Required' : null)])),
                    SizedBox(width: 12.w),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_labelWithStar('Last Name'), SizedBox(height: 5.h), TextFormField(controller: _lastNameCtrl, decoration: _inputDecoration('Ansari'), validator: (val) => (val == null || val.isEmpty) ? 'Required' : null)])),
                  ],
                ),
                SizedBox(height: 12.h),
                _labelWithStar('Email'),
                SizedBox(height: 5.h),
                TextFormField(controller: _emailCtrl, decoration: _inputDecoration('example@mail.com'), validator: (val) { if (val == null || val.isEmpty) return 'Required'; if (!val.contains('@')) return 'Invalid Email'; return null; }),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_labelWithStar('Password'), SizedBox(height: 5.h), TextFormField(controller: _passwordCtrl, obscureText: _obscurePassword, decoration: _inputDecoration('********', suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscurePassword = !_obscurePassword))), validator: (val) => (val == null || val.length < 6) ? 'Min 6 chars' : null)])),
                    SizedBox(width: 12.w),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_labelWithStar('Confirm Password'), SizedBox(height: 5.h), TextFormField(controller: _confirmPasswordCtrl, obscureText: _obscureConfirmPassword, decoration: _inputDecoration('********', suffixIcon: IconButton(icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword))), validator: (val) => (val != _passwordCtrl.text) ? 'Not Match' : null)])),
                  ],
                ),
                SizedBox(height: 12.h),
                _labelWithStar('Years of Medical License'),
                SizedBox(height: 5.h),
                DropDownTextField(clearOption: false, textFieldDecoration: _inputDecoration('Select Year'), dropDownList: const [DropDownValueModel(name: '1 year', value: 1), DropDownValueModel(name: '2 years', value: 2), DropDownValueModel(name: '5+ years', value: 5)], onChanged: (val) => _selectedLicenseYears = val),
                SizedBox(height: 12.h),
                _labelWithStar('Date of Birth'),
                SizedBox(height: 5.h),
                DateTimeFormField(decoration: _inputDecoration('Enter Date'), mode: DateTimeFieldPickerMode.date, onChanged: (DateTime? value) => _selectedDob = value, validator: (val) => (_selectedDob == null) ? 'Required' : null),
                SizedBox(height: 12.h),
                _labelWithStar('Medical Specialty'),
                SizedBox(height: 5.h),
                TextFormField(controller: _medicalSpecialtyCtrl, decoration: _inputDecoration('Enter Specialty'), validator: (val) => (val == null || val.isEmpty) ? 'Required' : null),
                SizedBox(height: 12.h),
                _labelWithStar('Qualification'),
                SizedBox(height: 5.h),
                TextFormField(controller: _qualificationCtrl, decoration: _inputDecoration('MBBS, FCPS, etc.'), validator: (val) => (val == null || val.isEmpty) ? 'Required' : null),
                SizedBox(height: 12.h),
                _labelWithStar('Working Days & Time'),
                SizedBox(height: 5.h),
                TextFormField(controller: _workingTimeCtrl, decoration: _inputDecoration('Monday–Saturday, 9:00 AM – 5:00 PM'), validator: (val) => (val == null || val.isEmpty) ? 'Required' : null),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_labelWithStar('Rating'), SizedBox(height: 5.h), TextFormField(controller: _ratingCtrl, keyboardType: TextInputType.number, decoration: _inputDecoration('4.8'), validator: (val) => (val == null || val.isEmpty) ? 'Required' : null)])),
                    SizedBox(width: 12.w),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_labelWithStar('Reviews'), SizedBox(height: 5.h), TextFormField(controller: _reviewsCtrl, keyboardType: TextInputType.number, decoration: _inputDecoration('100'), validator: (val) => (val == null || val.isEmpty) ? 'Required' : null)])),
                  ],
                ),
                SizedBox(height: 12.h),
                _labelWithStar('Consultation Fee (USD)'),
                SizedBox(height: 5.h),
                TextFormField(controller: _feeCtrl, keyboardType: TextInputType.number, decoration: _inputDecoration('20'), validator: (val) => (val == null || val.isEmpty) ? 'Required' : null),
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
