import 'package:flutter/material.dart';
import 'package:pcmc_jeevan_praman/Services/inAppUpdateService.dart';
import 'package:pcmc_jeevan_praman/Services/location_permission_handler.dart';
import 'package:pcmc_jeevan_praman/Widgets/policy_info_popup.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final InAppUpdateService _updateService = InAppUpdateService();
  bool _isCheckingUpdate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleInitialUpdateCheck();
      _showInitialPolicyPopup();
    });
  }

  @override
  void dispose() {
    _updateService.dispose();
    super.dispose();
  }

  /// Handle initial update check on app launch
  Future<void> _handleInitialUpdateCheck() async {
    if (!mounted) return;

    setState(() => _isCheckingUpdate = true);
    try {
      await _updateService.handleAppUpdate(context);
    } finally {
      if (mounted) setState(() => _isCheckingUpdate = false);
    }
  }

  /// Manual update check triggered by user
  Future<void> _manualUpdateCheck() async {
    if (_isCheckingUpdate) return;

    setState(() => _isCheckingUpdate = true);
    try {
      await _updateService.manualUpdateCheck(context);
    } finally {
      if (mounted) setState(() => _isCheckingUpdate = false);
    }
  }

  /// Show policy popup after delay
  Future<void> _showInitialPolicyPopup() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) PolicyInfoPopup.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Add top spacing to prevent overlap with buttons
                    const SizedBox(height: 40),

                    // Logo
                    Image.asset(
                      "assets/images/pcmc_logo.jpeg",
                      width: 170.0,
                      height: 170.0,
                    ),

                    // Title text
                    const Text(
                      "पिंपरी चिंचवड महानगरपालिका",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const Text(
                      "पिंपरी- ४११०१८",
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 18),
                    ),
                    const Text(
                      "निवृत्ती वेतनधारक हयातीचे प्रमाणपत्र",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const Text(
                      "(2025-2026)",
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 18),
                    ),

                    const SizedBox(height: 30),

                    // Main action container
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFF92B7F7), width: 3),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Generate Life Certificate\nजीवन प्रमाणपत्र तैयार करा',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () =>
                                LocationPermissionHandler.request(context),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 4,
                              shadowColor: Colors.green.withOpacity(0.3),
                            ),
                            child: const Text(
                              'Click Here\nयेथे क्लिक करा',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Powered by section
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              'Powered by',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
                          ),
                        ),
                        Image.asset(
                          "assets/images/Bank_of_Maharashtra_logo.png",
                          width: 230.0,
                          height: 70.0,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Update buttons positioned at top-right
          Positioned(
            top: 8,
            right: 8,
            child: SafeArea(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _isCheckingUpdate ? null : _manualUpdateCheck,
                    icon: _isCheckingUpdate
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          )
                        : const Icon(Icons.refresh, color: Colors.blue),
                    tooltip: 'Check for updates',
                  ),
                  IconButton(
                    onPressed: () async {
                      await _updateService.openPlayStore(context);
                    },
                    icon: const Icon(Icons.system_update_alt_outlined,
                        color: Colors.green),
                    tooltip: 'Open Play Store',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
