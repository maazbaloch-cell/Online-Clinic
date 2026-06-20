import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'services/auth_service.dart';

class Patient extends StatefulWidget {
  const Patient({super.key});

  @override
  State<Patient> createState() => _PatientState();
}

class _PatientState extends State<Patient> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
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

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _pickedImage = image);
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: 'patient',
        userData: {
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'age': _ageController.text.trim(),
          'city': _cityController.text.trim(),
          'gender': _selectedGender ?? 'Not Specified',
          'cnic': _cnicController.text.trim(),
          'address': _addressController.text.trim(),
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Please check your email.'), backgroundColor: Colors.green),
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
                const Text('Setup Patient Profile', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
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
                    Expanded(child: _buildField('First Name', _firstNameController, 'John')),
                    SizedBox(width: 12.w),
                    Expanded(child: _buildField('Last Name', _lastNameController, 'Doe')),
                  ],
                ),
                SizedBox(height: 12.h),
                _buildField('Email', _emailController, 'example@mail.com', keyboardType: TextInputType.emailAddress),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(child: _buildPasswordField('Password', _passwordController, _obscurePassword, () => setState(() => _obscurePassword = !_obscurePassword))),
                    SizedBox(width: 12.w),
                    Expanded(child: _buildPasswordField('Confirm Password', _confirmPasswordController, _obscureConfirmPassword, () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword))),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(child: _buildField('Age', _ageController, '25', keyboardType: TextInputType.number)),
                    SizedBox(width: 12.w),
                    Expanded(child: _buildField('City', _cityController, 'Karachi')),
                  ],
                ),
                SizedBox(height: 12.h),
                _labelWithStar('Gender'),
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration('Select Gender'),
                  items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (val) => setState(() => _selectedGender = val),
                  validator: (val) => val == null ? 'Required' : null,
                ),
                SizedBox(height: 25.h),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: Size(double.infinity, 48.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r))),
                  child: const Text('Create Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
