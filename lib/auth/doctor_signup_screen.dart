import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:untitled29/services/auth_service.dart';

class DoctorSignupScreen extends StatefulWidget {
  const DoctorSignupScreen({super.key});

  @override
  State<DoctorSignupScreen> createState() => _DoctorSignupScreenState();
}

class _DoctorSignupScreenState extends State<DoctorSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _isLoading = false;

  final TextEditingController _firstNameCtrl = TextEditingController();
  final TextEditingController _lastNameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();
  final TextEditingController _medicalSpecialtyCtrl = TextEditingController();
  final TextEditingController _qualificationCtrl = TextEditingController();
  final TextEditingController _feeCtrl = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  dynamic _selectedLicenseYears;
  DateTime? _selectedDob;

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  @override
  void dispose() {
    _firstNameCtrl.dispose(); _lastNameCtrl.dispose(); _emailCtrl.dispose();
    _passwordCtrl.dispose(); _confirmPasswordCtrl.dispose();
    _medicalSpecialtyCtrl.dispose(); _qualificationCtrl.dispose(); _feeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _pickedImage = image);
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_selectedDob == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Date of Birth')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await _authService.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        role: 'doctor',
        userData: {
          'first_name': _firstNameCtrl.text.trim(),
          'last_name': _lastNameCtrl.text.trim(),
          'specialty': _medicalSpecialtyCtrl.text.trim(),
          'qualification': _qualificationCtrl.text.trim(),
          'fee': _feeCtrl.text.trim(),
          'license_years': _selectedLicenseYears?.name ?? '1 year',
        },
      );

      if (res.user != null) {
        await _authService.signOut();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Doctor Profile Created! Please Sign In.'), backgroundColor: Colors.green),
          );
          context.go('/signin');
        }
      }
    } on AuthException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unexpected error occurred'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint, 
      isDense: true, 
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h), 
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.r))
    );
  }

  Widget _labelWithStar(String text) {
    return RichText(text: TextSpan(text: text, style: const TextStyle(color: Colors.black, fontSize: 14), children: const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => context.pop())),
      backgroundColor: Colors.white,
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 40.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Doctor Registration', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.blue)),
                SizedBox(height: 20.h),
                
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80.r, height: 80.r,
                        decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
                        child: ClipOval(
                          child: _pickedImage != null 
                            ? (kIsWeb ? Image.network(_pickedImage!.path, fit: BoxFit.cover) : Image.file(File(_pickedImage!.path), fit: BoxFit.cover)) 
                            : const Icon(Icons.person, size: 40, color: Colors.grey)
                        ),
                      ),
                      TextButton.icon(onPressed: _pickImage, icon: const Icon(Icons.camera_alt_outlined), label: const Text('Upload Photo')),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                Row(
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_labelWithStar('First Name'), SizedBox(height: 5.h), TextFormField(controller: _firstNameCtrl, decoration: _inputDecoration('Faizan'), validator: (v) => v!.isEmpty ? 'Required' : null)])),
                    SizedBox(width: 10.w),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_labelWithStar('Last Name'), SizedBox(height: 5.h), TextFormField(controller: _lastNameCtrl, decoration: _inputDecoration('Ansari'), validator: (v) => v!.isEmpty ? 'Required' : null)])),
                  ],
                ),
                SizedBox(height: 12.h),
                _labelWithStar('Email'),
                SizedBox(height: 5.h),
                TextFormField(controller: _emailCtrl, decoration: _inputDecoration('example@mail.com'), validator: (v) => v!.isEmpty ? 'Required' : null),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_labelWithStar('Password'), SizedBox(height: 5.h), TextFormField(controller: _passwordCtrl, obscureText: _obscurePassword, decoration: _inputDecoration('********', suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscurePassword = !_obscurePassword))), validator: (v) => v!.length < 6 ? 'Min 6 chars' : null)])),
                    SizedBox(width: 10.w),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_labelWithStar('Confirm Password'), SizedBox(height: 5.h), TextFormField(controller: _confirmPasswordCtrl, obscureText: _obscureConfirmPassword, decoration: _inputDecoration('********', suffixIcon: IconButton(icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword))), validator: (v) => v != _passwordCtrl.text ? 'Not Match' : null)])),
                  ],
                ),
                SizedBox(height: 12.h),
                _labelWithStar('Date of Birth'),
                SizedBox(height: 5.h),
                DateTimeFormField(decoration: _inputDecoration('Enter Date'), mode: DateTimeFieldPickerMode.date, onChanged: (DateTime? value) => _selectedDob = value, validator: (val) => (_selectedDob == null) ? 'Required' : null),
                SizedBox(height: 12.h),
                _labelWithStar('Medical Specialty'),
                SizedBox(height: 5.h),
                TextFormField(controller: _medicalSpecialtyCtrl, decoration: _inputDecoration('Specialty'), validator: (v) => v!.isEmpty ? 'Required' : null),
                SizedBox(height: 12.h),
                _labelWithStar('Qualification'),
                SizedBox(height: 5.h),
                TextFormField(controller: _qualificationCtrl, decoration: _inputDecoration('MBBS, FCPS, etc.')),
                SizedBox(height: 12.h),
                _labelWithStar('Experience'),
                SizedBox(height: 5.h),
                DropDownTextField(
                  clearOption: false,
                  textFieldDecoration: _inputDecoration('Select Year'),
                  dropDownList: const [DropDownValueModel(name: '1 year', value: 1), DropDownValueModel(name: '2 years', value: 2), DropDownValueModel(name: '5+ years', value: 5)],
                  onChanged: (v) => setState(() => _selectedLicenseYears = v),
                ),
                SizedBox(height: 12.h),
                _labelWithStar('Consultation Fee (USD)'),
                SizedBox(height: 5.h),
                TextFormField(controller: _feeCtrl, keyboardType: TextInputType.number, decoration: _inputDecoration('20'), validator: (v) => v!.isEmpty ? 'Required' : null),
                SizedBox(height: 30.h),
                SizedBox(width: double.infinity, height: 48.h, child: ElevatedButton(onPressed: _submit, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r))), child: const Text('Register Doctor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
