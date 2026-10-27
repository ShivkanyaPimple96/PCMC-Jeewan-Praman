import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../config/routes.dart';
import '../widgets/green_button.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Exact WebApp match: modal overlay with white card
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: const Color(0x8C000000), // rgba(0,0,0,0.55)
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 40,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Green check icon — exact WebApp
                  const Icon(
                    Icons.check_circle,
                    size: 64,
                    color: AppTheme.green,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Success',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),

                  // English text — exact WebApp
                  const Text(
                    'You have successfully completed the process for your life certificate. Your life certificate is currently under verification. You will receive your certificate soon. Thank you for your patience.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Marathi text — exact WebApp
                  const Text(
                    'तुम्ही तुमच्या जीवन प्रमाणपत्राची प्रक्रिया यशस्वीपणे पूर्ण केली आहे. तुमचे जीवन प्रमाणपत्र सध्या पडताळणीखाली आहे. तुम्हाला तुमचे प्रमाणपत्र लवकरच मिळेल. तुमच्या संयमाबद्दल धन्यवाद.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),

                  // OK button — green pill, right-aligned like WebApp
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 120,
                      child: GreenButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.pensionerDetails,
                            (route) => false,
                          );
                        },
                        child: const Text('OK',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
