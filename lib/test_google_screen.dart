import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestGoogleScreen extends StatefulWidget {
  const TestGoogleScreen({super.key});

  @override
  State<TestGoogleScreen> createState() => _TestGoogleScreenState();
}

class _TestGoogleScreenState extends State<TestGoogleScreen> {
  bool _loading = false;
  String _log = '';

  void _append(String text) {
    setState(() {
      _log += '$text\n';
    });
    debugPrint(text);
  }

  Future<void> _testGoogleSignIn() async {
    _append('STEP 1: BUTTON PRESSED');
    if (_loading) {
      _append('STEP 1.1: ALREADY LOADING, RETURN');
      return;
    }

    setState(() => _loading = true);

    try {
      _append('STEP 2: READING CLIENT ID');
      final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
      _append('STEP 3: webClientId = $webClientId');

      if (webClientId.isEmpty) {
        throw 'GOOGLE_WEB_CLIENT_ID missing in .env';
      }

      _append('STEP 4: CREATING GoogleSignIn');
      final googleSignIn = GoogleSignIn(
        clientId: kIsWeb ? webClientId : null,
        // Web par serverClientId allowed nahi
        serverClientId: kIsWeb ? null : webClientId,
      );
      _append('STEP 5: GoogleSignIn CREATED');

      _append('STEP 6: googleSignIn.signIn() CALL');
      final user = await googleSignIn.signIn();
      _append('STEP 7: googleUser = $user');

      if (user == null) {
        _append('STEP 8: User cancelled or popup closed');
        setState(() => _loading = false);
        return;
      }

      _append('STEP 9: FETCHING TOKENS');
      final auth = await user.authentication;
      _append('STEP 10: idToken = ${auth.idToken}');
      _append('STEP 11: accessToken = ${auth.accessToken}');

      if (auth.idToken == null) {
        throw 'ID token is null';
      }

      _append('STEP 12: CALLING supabase.auth.signInWithIdToken');
      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: auth.idToken!,
        accessToken: auth.accessToken,
      );
      _append('STEP 13: Supabase signInWithIdToken SUCCESS');
    } catch (e, st) {
      _append('ERROR: $e');
      _append('STACKTRACE: $st');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Google Sign-In')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _loading ? null : _testGoogleSignIn,
              child: Text(_loading ? 'Loading...' : 'Test Google Sign-In'),
            ),
            const SizedBox(height: 16),
            const Text('Log:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _log,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}