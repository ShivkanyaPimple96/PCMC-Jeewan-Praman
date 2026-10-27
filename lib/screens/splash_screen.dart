import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/api_config.dart';
import '../config/app_theme.dart';
import '../config/routes.dart';
import '../providers/kyc_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final provider = context.read<KycProvider>();
    await provider.fetchFinancialYear();
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.start);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo from API
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                ApiConfig.logoUrl,
                width: 110,
                height: 110,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.account_balance,
                      size: 56, color: AppTheme.primaryBlue),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'पिंपरी चिंचवड महानगरपालिका',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'निवृत्ती वेतनधारक हयातीचे प्रमाणपत्र',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
