import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/routes.dart';
import '../providers/kyc_provider.dart';

class AadhaarVerificationScreen extends StatefulWidget {
  const AadhaarVerificationScreen({super.key});

  @override
  State<AadhaarVerificationScreen> createState() =>
      _AadhaarVerificationScreenState();
}

class _AadhaarVerificationScreenState extends State<AadhaarVerificationScreen> {
  final _otpController = TextEditingController();
  int _phase = 1; // 1=verify button, 2=OTP input, 3=success

  static const String _baseUrl = 'https://lc.pcmcpensioner.in';

  // static const String _baseUrl = 'https://lcapi.shrisoft.co.in';

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _generateOtp() async {
    final provider = context.read<KycProvider>();
    final success = await provider.generateAadhaarOtp();
    if (success && mounted) setState(() => _phase = 2);
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) return;

    final provider = context.read<KycProvider>();
    final success = await provider.verifyAadhaarOtp(otp);

    if (!mounted) return;
    if (success) {
      setState(() => _phase = 3);
    } else if (provider.aadhaarOtpFailed) {
      Navigator.pushReplacementNamed(context, AppRoutes.aadhaarUpload);
    }
  }

  String _fullImageUrl(String relativePath) {
    if (relativePath.startsWith('http://') ||
        relativePath.startsWith('https://')) {
      return relativePath;
    }
    final path = relativePath.startsWith('/') ? relativePath : '/$relativePath';
    return '$_baseUrl$path';
  }

  void _onNext() {
    Navigator.pushReplacementNamed(context, AppRoutes.photoCapture);
  }

  // ── Design tokens ──
  static const Color _primaryBlue = Color(0xFF4A90D9);
  static const Color _borderBlue = Color(0xFF4A90D9);
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textMedium = Color(0xFF444466);
  static const Color _textLight = Color(0xFF888899);
  static const Color _dividerColor = Color(0xFFDDDDDD);
  static const Color _white = Colors.white;
  static const Color _pageBg = Color(0xFFFFFFFF);
  static const Color _red = Color(0xFFE74C3C);
  static const Color _buttonBlue = Color(0xFF6BAED6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFADD8F0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textDark, size: 24),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Aadhar Verification [Step-3]',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        centerTitle: false,
      ),
      backgroundColor: _pageBg,
      body: Consumer<KycProvider>(
        builder: (_, provider, __) {
          // ── No Center wrapper — body starts from top ──
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Aadhaar number card ──
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: _white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _borderBlue, width: 1.8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 28, color: _primaryBlue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style:
                                const TextStyle(fontSize: 16, color: _textDark),
                            children: [
                              const TextSpan(
                                text: 'Aadhar Number: ',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              TextSpan(
                                text: provider.aadhaarNumber ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Full Name — left-aligned, bold, directly below card ──
                if (provider.name != null && provider.name!.isNotEmpty)
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(fontSize: 21, color: _textDark),
                      children: [
                        const TextSpan(
                          text: 'Full Name: ',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: provider.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                const SizedBox(height: 24),

                // ── Phase 1: Verify button ──
                if (_phase == 1)
                  _buildPillButton(
                    onPressed: provider.isLoading ? null : _generateOtp,
                    isLoading: provider.isLoading,
                    label: 'Verify Your Aadhaar Number',
                    sublabel: 'आधार क्रमांकाची पडताळणी करा',
                  ),

                // ── Phase 2: OTP input ──
                if (_phase == 2) _buildOtpCard(provider),

                // ── Phase 3: Aadhaar details ──
                if (_phase == 3) _buildAadhaarDetailsCard(provider),

                // ── Error banner ──
                if (provider.error != null && _phase != 3) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      provider.error!,
                      style: const TextStyle(color: _red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ────────────────────────────────────────────────
  // Aadhaar Details card — photo left, info right
  // ────────────────────────────────────────────────
  Widget _buildAadhaarDetailsCard(KycProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aadhaar Details:',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _primaryBlue,
          ),
        ),
        const SizedBox(height: 6),
        const Divider(color: _dividerColor, thickness: 1.2),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _borderBlue, width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Photo ──
              _buildPhoto(provider),
              const SizedBox(width: 14),
              // ── Info rows ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (provider.aadhaarFullName != null) ...[
                      _detailLabel('Name:'),
                      _detailValue(provider.aadhaarFullName!),
                      _dividerWidget(),
                    ],
                    if (provider.aadhaarGender != null) ...[
                      _detailLabel('Gender:'),
                      _detailValue(provider.aadhaarGender!),
                      _dividerWidget(),
                    ],
                    if (provider.aadhaarDob != null) ...[
                      _detailLabel('DOB:'),
                      _detailValue(provider.aadhaarDob!),
                      _dividerWidget(),
                    ],
                    if (provider.aadhaarFullAddress != null) ...[
                      _detailLabel('Aadhar Address:'),
                      _detailValue(provider.aadhaarFullAddress!),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        _buildPillButton(
          onPressed: _onNext,
          label: 'Next',
          sublabel: null,
        ),
      ],
    );
  }

  Widget _buildPhoto(KycProvider provider) {
    if (provider.aadhaarPhotoUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          _fullImageUrl(provider.aadhaarPhotoUrl!),
          width: 110,
          height: 130,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _photoPlaceholder(
                child: const CircularProgressIndicator(strokeWidth: 2));
          },
          errorBuilder: (context, error, stackTrace) {
            return _photoPlaceholder(
                child: const Icon(Icons.broken_image,
                    size: 40, color: _textLight));
          },
        ),
      );
    }
    return _photoPlaceholder(
        child: const Icon(Icons.person, size: 50, color: _textLight));
  }

  Widget _photoPlaceholder({required Widget child}) {
    return Container(
      width: 110,
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFCCCCCC), width: 1.5),
        color: const Color(0xFFE8E8E8),
      ),
      child: Center(child: child),
    );
  }

  Widget _detailLabel(String label) => Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          color: _textLight,
          fontWeight: FontWeight.w500,
        ),
      );

  Widget _detailValue(String value) => Padding(
        padding: const EdgeInsets.only(top: 2, bottom: 4),
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
      );

  Widget _dividerWidget() => const Divider(
        color: _dividerColor,
        thickness: 1,
        height: 10,
      );

  // ────────────────────────────────────────────────
  // OTP card
  // ────────────────────────────────────────────────
  Widget _buildOtpCard(KycProvider provider) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderBlue, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'आधार सोबत लिंक असलेल्या मोबाइल क्रमांकावर आलेला OTP प्रविष्ट करा',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _textMedium,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Enter OTP received on Aadhaar-linked mobile',
            style: TextStyle(fontSize: 12, color: _textLight),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w600, color: _textDark),
            decoration: InputDecoration(
              hintText: 'OTP टाका / Enter OTP',
              hintStyle: const TextStyle(color: _textLight, fontSize: 14),
              counterText: '',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _borderBlue, width: 1.4),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _primaryBlue, width: 2),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            onSubmitted: (_) => _verifyOtp(),
          ),
          const SizedBox(height: 16),
          _buildPillButton(
            onPressed: provider.isLoading ? null : _verifyOtp,
            isLoading: provider.isLoading,
            label: 'Submit OTP',
            sublabel: 'OTP सबमिट करा',
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────
  // Pill button
  // KEY FIXES:
  //   1. No fixed SizedBox height — was causing overflow
  //   2. mainAxisSize: MainAxisSize.min on inner Column
  //   3. vertical padding drives height instead
  // ────────────────────────────────────────────────
  Widget _buildPillButton({
    required VoidCallback? onPressed,
    bool isLoading = false,
    required String label,
    String? sublabel,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _buttonBlue,
          disabledBackgroundColor: _buttonBlue.withOpacity(0.6),
          foregroundColor: _white,
          shape: const StadiumBorder(),
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            // More vertical room when there is a sublabel
            vertical: sublabel != null ? 13 : 15,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Column(
                // ── shrink-wrap: never fight a fixed parent height ──
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _white,
                    ),
                  ),
                  if (sublabel != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      sublabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _white,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
