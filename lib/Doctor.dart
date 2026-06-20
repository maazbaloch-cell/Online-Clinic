import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'services/auth_service.dart';

class DoctorScreen extends StatefulWidget {
  const DoctorScreen({super.key});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
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
  final TextEditingController _workingTimeCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  dynamic _selectedLicenseYears;
  DateTime? _selectedDob;

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

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
      await _authService.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        role: 'doctor',
        userData: {
          'first_name': _firstNameCtrl.text.trim(),
          'last_name': _lastNameCtrl.text.trim(),
          'specialty': _medicalSpecialtyCtrl.text.trim(),
          'qualification': _qualificationCtrl.text.trim(),
          'fee': _feeCtrl.text.trim(),
          'license_years': _selectedLicenseYears?.name ?? '',
          'working_time': _workingTimeCtrl.text.trim(),
          'rating': 0.0,
          'reviews': 0,
        },
        imageFile: _pickedImage != null ? File(_pickedImage!.path) : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor Profile Created! Please confirm your email.'), backgroundColor: Colors.green),
        );
        context.pushReplacement('/signin');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Setup Your Profile', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 20.h),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80.r, height: 80.r,
                        decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
                        child: ClipOval(
                          child: _pickedImage != null
                              ? (kIsWeb 
                                  ? Image.network(_pickedImage!.path, width: 80.r, height: 80.r, fit: BoxFit.cover)
                                  : Image.file(File(_pickedImage!.path), width: 80.r, height: 80.r, fit: BoxFit.cover))
                              : const Icon(Icons.person, size: 40, color: Colors.grey),
                        ),
                      ),
                      TextButton.icon(onPressed: _pickImage, icon: const Icon(Icons.camera_alt_outlined), label: const Text('Upload Photo')),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(child: _buildField('First Name', _firstNameCtrl, 'Enter First Name')),
                    SizedBox(width: 12.w),
                    Expanded(child: _buildField('Last Name', _lastNameCtrl, 'Enter Last Name')),
                  ],
                ),
                SizedBox(height: 12.h),
                _buildField('Email', _emailCtrl, 'example@mail.com'),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(child: _buildPasswordField('Password', _passwordCtrl, _obscurePassword, () => setState(() => _obscurePassword = !_obscurePassword))),
                    SizedBox(width: 12.w),
                    Expanded(child: _buildPasswordField('Confirm Password', _confirmPasswordCtrl, _obscureConfirmPassword, () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword))),
                  ],
                ),
                SizedBox(height: 12.h),
                _labelWithStar('Years of License'),
                DropDownTextField(textFieldDecoration: _inputDecoration('Select Year'), dropDownList: const [DropDownValueModel(name: '1 year', value: 1), DropDownValueModel(name: '5+ years', value: 5)], onChanged: (val) => _selectedLicenseYears = val),
                SizedBox(height: 12.h),
                _buildField('Medical Specialty', _medicalSpecialtyCtrl, 'e.g. Cardiologist'),
                SizedBox(height: 12.h),
                _buildField('Qualification', _qualificationCtrl, 'MBBS, FCPS'),
                SizedBox(height: 12.h),
                _buildField('Consultation Fee (Rs)', _feeCtrl, '2000', keyboardType: TextInputType.number),
                SizedBox(height: 25.h),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: Size(double.infinity, 48.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r))),
                  child: const Text('Create Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, String hint, {TextInputType? keyboardType}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_labelWithStar(label), SizedBox(height: 5.h), TextFormField(controller: ctrl, keyboardType: keyboardType, decoration: _inputDecoration(hint), validator: (val) => (val == null || val.isEmpty) ? 'Required' : null)]);
  }

  Widget _buildPasswordField(String label, TextEditingController ctrl, bool obscure, VoidCallback toggle) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_labelWithStar(label), SizedBox(height: 5.h), TextFormField(controller: ctrl, obscureText: obscure, decoration: _inputDecoration('********', suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility), onPressed: toggle)), validator: (val) => (val == null || val.length < 6) ? 'Min 6 chars' : null)]);
  }

  Widget _labelWithStar(String text) {
    return RichText(text: TextSpan(text: text, style: const TextStyle(color: Colors.black, fontSize: 14), children: const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))]));
  }
}
