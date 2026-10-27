import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_theme.dart';
import 'config/routes.dart';
import 'providers/kyc_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/start_screen.dart';
import 'screens/ppo_entry_screen.dart';
import 'screens/pensioner_details_screen.dart';
import 'screens/aadhaar_verification_screen.dart';
import 'screens/aadhaar_upload_screen.dart';
import 'screens/photo_capture_screen.dart';
import 'screens/video_capture_screen.dart';
import 'screens/declaration_screen.dart';
import 'screens/success_screen.dart';
import 'screens/view_certificate_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PCMCLifeCertificateApp());
}

class PCMCLifeCertificateApp extends StatelessWidget {
  const PCMCLifeCertificateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => KycProvider(),
      child: MaterialApp(
        title: 'PCMC Life Certificate',
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.start,
        routes: {
          // AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.start: (_) => const StartScreen(),
          AppRoutes.ppoEntry: (_) => const PpoEntryScreen(),
          AppRoutes.pensionerDetails: (_) => const PensionerDetailsScreen(),
          AppRoutes.aadhaarVerification: (_) =>
              const AadhaarVerificationScreen(),
          AppRoutes.aadhaarUpload: (_) => const AadhaarUploadScreen(),
          AppRoutes.photoCapture: (_) => const PhotoCaptureScreen(),
          AppRoutes.videoCapture: (_) => const VideoCaptureScreen(),
          AppRoutes.declaration: (_) => const DeclarationScreen(),
          AppRoutes.success: (_) => const SuccessScreen(),
          AppRoutes.viewCertificate: (_) => const ViewCertificateScreen(),
        },
      ),
    );
  }
}
