import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
class Otp extends StatefulWidget {
  const Otp({super.key});
  @override
  State<Otp> createState() => _OtpState();
}
class _OtpState extends State<Otp> {
  int _seconds = 60;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _seconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          _seconds--;
        });
      }
    });
  }

  String get _timeText {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            const Text(
              'Verify OTP',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            OtpTextField(
              numberOfFields: 6,
              borderColor: Colors.grey,
              focusedBorderColor: Colors.blue,
              showFieldAsBox: true,
              obscureText: true,
              fieldWidth: 40,
              borderRadius: BorderRadius.circular(15),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              onCodeChanged: (code) {},
              onSubmit: (code) {},
            ),
            SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                   Padding(
                     padding: const EdgeInsets.only(left: 8.0),
                     child: Text.rich(
                        TextSpan(
                          text: "Didn't receive? ",
                          style: const TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: 'Resend it',
                              style: TextStyle(
                                color: _seconds == 0 ? Colors.blue : Colors.grey,
                                decoration: _seconds == 0
                                    ? TextDecoration.underline
                                    : TextDecoration.none,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  if (_seconds == 0) {
                                    _startTimer();
                                  }
                                },
                            ),
                          ],
                        ),
                      ),
                   ),
                  const SizedBox(width: 100),
                  Text(
                    _timeText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),
            GestureDetector(
              onTap: () {
              },
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blue,
                  border: Border.all(color: Colors.blue),
                ),
                child: const Center(
                  child: Text(
                    'Verify OTP',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
