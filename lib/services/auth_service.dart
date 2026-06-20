import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final _client = Supabase.instance.client;

  Future<String?> uploadImage(File file, String path) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final fullPath = '$path/$fileName';
      
      await _client.storage.from('avatars').upload(fullPath, file);
      
      final String publicUrl = _client.storage.from('avatars').getPublicUrl(fullPath);
      return publicUrl;
    } catch (e) {
      return null;
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String role,
    required Map<String, dynamic> userData,
    File? imageFile,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'role': role,
        'first_name': userData['first_name'],
        'last_name': userData['last_name'],
      },
    );

    if (response.user != null) {
      final userId = response.user!.id;
      String? imageUrl;

      if (imageFile != null) {
        imageUrl = await uploadImage(imageFile, role == 'doctor' ? 'doctors' : 'patients');
      }
      
      await _client.from('profiles').upsert({
        'id': userId,
        'email': email,
        'role': role,
        'first_name': userData['first_name'],
        'last_name': userData['last_name'],
      });

      if (role == 'doctor') {
        await _client.from('doctors').upsert({
          'id': userId,
          'specialty': userData['specialty'] ?? '',
          'qualification': userData['qualification'] ?? '',
          'fee': int.tryParse(userData['fee']?.toString() ?? '0') ?? 0,
          'license_years': userData['license_years'] ?? '',
          'working_time': userData['working_time'] ?? '09:00 AM - 05:00 PM',
          'rating': 0.0,
          'reviews': 0,
          'image_url': imageUrl,
        });
      } else {
        await _client.from('patients').upsert({
          'id': userId,
          'age': int.tryParse(userData['age']?.toString() ?? '0') ?? 0,
          'city': userData['city'] ?? '',
          'gender': userData['gender'] ?? '',
          'image_url': imageUrl,
        });
      }
    }
    return response;
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await _client.auth.signOut();
  }
}
