import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final _client = Supabase.instance.client;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String role,
    required Map<String, dynamic> userData,
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
          'fee': userData['fee'] ?? 0,
          'license_years': userData['license_years'] ?? 0,
        });
      } else {
        await _client.from('patients').upsert({
          'id': userId,
          'age': userData['age'] ?? 0,
          'city': userData['city'] ?? '',
          'gender': userData['gender'] ?? '',
        });
      }
    }
    return response;
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web: Use OAuth redirect which is most reliable and avoids "No ID Token" issues
        await _client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: kIsWeb ? null : 'io.supabase.flutter://callback',
        );
      } else {
        // Mobile: Use ID Token
        final webId = dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
        final GoogleSignIn googleSignIn = GoogleSignIn(serverClientId: webId);
        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) return;

        final googleAuth = await googleUser.authentication;
        if (googleAuth.idToken == null) throw 'Missing ID Token';

        await _client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: googleAuth.idToken!,
          accessToken: googleAuth.accessToken,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getUserRole(String userId) async {
    try {
      // 1. Check Profiles table
      final res = await _client.from('profiles').select('role').eq('id', userId).maybeSingle();
      if (res != null && res['role'] != null) return res['role'] as String;

      // 2. Check Auth Metadata
      final user = _client.auth.currentUser;
      if (user != null && user.id == userId) {
        final role = user.userMetadata?['role'];
        if (role != null) return role as String;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await _client.auth.signOut();
  }
}
