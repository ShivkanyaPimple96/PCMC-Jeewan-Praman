import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../config/routes.dart';
import '../providers/kyc_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  Design System
// ═══════════════════════════════════════════════════════════════════════════════
class _D {
  // ── Colours ────────────────────────────────────────────────────────────────
  static const appBarBlue = Color(0xFF92B7F7);
  static const pageBg = Color(0xFFEFEFEF);
  static const inputWhite = Colors.white;
  static const inputGrey = Color(0xFFE8E8E8);
  static const inputBorder = Color(0xFF92B7F7);
  static const textDark = Color(0xFF111111);
  static const textHint = Color(0xFF9E9E9E);
  static const btnGreen = Color(0xFF3D9142);
  static const btnGreenDisabled = Color(0xFFA5D6A7);
  static const resendOrange = Color(0xFFE05000);
  static const errorRed = Color(0xFFDC2626);
  static const approvedBg = Color(0xFFD4EDDA);
  static const approvedBorder = Color(0xFFC3E6CB);
  static const approvedText = Color(0xFF155724);
  static const approvedIcon = Color(0xFF28A745);
  static const pendingBg = Color(0xFFFFF3CD);
  static const pendingBorder = Color(0xFFFFE69C);
  static const pendingIcon = Color(0xFFD97706);

  // ── Rejected colours ───────────────────────────────────────────────────────
  static const rejectedBg = Color(0xFFFFEBEE);
  static const rejectedBorder = Color(0xFFFFCDD2);
  static const rejectedText = Color(0xFFB71C1C);
  static const rejectedIcon = Color(0xFFD32F2F);

  // ── Normalised status constants ────────────────────────────────────────────
  static const String statusApproved = 'application approved';
  static const String statusPending = 'verification in progress';
  static const String statusRejected = 'application rejected';

  static String resolveStatus(String? raw) {
    if (raw == null) return '';
    switch (raw.toLowerCase().trim()) {
      case 'approved':
      case 'application approved':
        return statusApproved;
      case 'pending':
      case 'verification in progress':
        return statusPending;
      case 'rejected':
      case 'application rejected':
        return statusRejected;
      default:
        return raw.toLowerCase().trim();
    }
  }

  // ── Layout ─────────────────────────────────────────────────────────────────
  static const maxWidth = 480.0;
  static const hPad = 18.0;
  static const inputH = 56.0;
  static const btnRadius = 30.0;

  // ── Typography ─────────────────────────────────────────────────────────────
  static const titleEn =
      TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textDark);
  static const titleMr =
      TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textDark);
  static const sectionLabel =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textDark);
  static const nameText =
      TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textDark);
  static const otpLabel =
      TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textDark);
  static const inputText =
      TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: textDark);
  static const btnLine1 =
      TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white);
  static const btnLine2 =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white);
  static const resendText =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: resendOrange);

  // ── InputDecoration factory ────────────────────────────────────────────────
  static InputDecoration inputDec({
    String? hint,
    bool readOnly = false,
    String? errorText,
    EdgeInsetsGeometry pad =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: textHint, fontSize: 16),
        filled: true,
        fillColor: readOnly ? inputGrey : inputWhite,
        counterText: '',
        contentPadding: pad,
        errorText: errorText,
        errorStyle: const TextStyle(
          color: errorRed,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        border: _ob(2),
        enabledBorder: _ob(2),
        focusedBorder: _ob(2.5),
        disabledBorder: _ob(2),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: errorRed, width: 2.5),
        ),
      );

  static OutlineInputBorder _ob(double w) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: inputBorder, width: w),
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
//  Green Pill Button
// ═══════════════════════════════════════════════════════════════════════════════
class _GreenBtn extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String line1;
  final String line2;

  const _GreenBtn({
    required this.onPressed,
    required this.line1,
    required this.line2,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _D.btnGreen,
          disabledBackgroundColor: _D.btnGreenDisabled,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: Colors.black26,
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_D.btnRadius),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(line1, style: _D.btnLine1),
                  const SizedBox(height: 1),
                  Text(line2, style: _D.btnLine2),
                ],
              ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  Screen
// ═══════════════════════════════════════════════════════════════════════════════
class PpoEntryScreen extends StatefulWidget {
  const PpoEntryScreen({super.key});

  @override
  State<PpoEntryScreen> createState() => _PpoEntryScreenState();
}

class _PpoEntryScreenState extends State<PpoEntryScreen> {
  final _ppoController = TextEditingController();
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();
  final _mobileFocus = FocusNode();

  /// 1 = PPO input | 2 = Name + Mobile + Get OTP | 3 = OTP entry
  int _phase = 1;

  // ── Banner state ───────────────────────────────────────────────────────────
  bool _certPending = false;
  bool _certApproved = false;
  bool _certRejected = false;

  // ── Local error for PPO field ──────────────────────────────────────────────
  String? _ppoError; // ← NEW
  String? _mobileError;

  int _countdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _ppoController.dispose();
    _mobileController.dispose();
    _otpController.dispose();
    _mobileFocus.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdown = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _countdown--);
      if (_countdown <= 0) t.cancel();
    });
  }

  void _resetBanners() {
    _certPending = false;
    _certApproved = false;
    _certRejected = false;
  }

  // ── PPO validation ─────────────────────────────────────────────────────────
  // CHANGE 1: validate PPO — must be exactly 1–4 digits before API call.
  // bool _validatePpo() {
  //   final ppo = _ppoController.text.trim();
  //   if (ppo.isEmpty) {
  //     setState(
  //         () => _ppoError = 'PPO number is required / PPO नंबर आवश्यक आहे');
  //     return false;
  //   }
  //   if (!RegExp(r'^\d{1,4}$').hasMatch(ppo)) {
  //     setState(() => _ppoError =
  //         'PPO number must be up to 4 digits / PPO नंबर जास्तीत जास्त 4 अंकी असावा');
  //     return false;
  //   }
  //   setState(() => _ppoError = null);
  //   return true;
  // }

  bool _validatePpo() {
    final ppo = _ppoController.text.trim();
    if (ppo.isEmpty) {
      setState(
          () => _ppoError = 'PPO number is required / PPO नंबर आवश्यक आहे');
      return false;
    }
    // ── NEW: must not start with 0 ─────────────────────────────────────────
    if (ppo.startsWith('0')) {
      setState(() => _ppoError =
          'PPO number cannot start with 0 / PPO नंबर 0 ने सुरू होऊ शकत नाही');
      return false;
    }
    if (!RegExp(r'^\d{1,4}$').hasMatch(ppo)) {
      setState(() => _ppoError =
          'PPO number must be up to 4 digits / PPO नंबर जास्तीत जास्त 4 अंकी असावा');
      return false;
    }
    setState(() => _ppoError = null);
    return true;
  }

  // ── Mobile validation ──────────────────────────────────────────────────────
  bool _validateMobile() {
    final mobile = _mobileController.text.trim();
    if (mobile.isEmpty) {
      setState(() =>
          _mobileError = 'Mobile number is required / मोबाईल नंबर आवश्यक आहे');
      return false;
    }
    if (!RegExp(r'^\d{10}$').hasMatch(mobile)) {
      setState(() => _mobileError =
          'Enter a valid 10-digit mobile number / 10 अंकी मोबाईल नंबर टाका');
      return false;
    }
    setState(() => _mobileError = null);
    return true;
  }

  // ── Step 1 ─────────────────────────────────────────────────────────────────
  Future<void> _checkPpo() async {
    // CHANGE 1 (continued): validate before calling API.
    if (!_validatePpo()) return;

    final ppo = _ppoController.text.trim();
    final provider = context.read<KycProvider>();
    final result = await provider.checkPpo(ppo);
    if (!mounted) return;

    // CHANGE 2: If found == true but name is empty/null, treat as "not found".
    if (!result.found ||
        provider.name == null ||
        provider.name!.trim().isEmpty) {
      setState(() {
        _ppoError = 'PPO number not found / PPO नंबर सापडला नाही';
      });
      return;
    }

    _mobileController.text = provider.mobileNumber ?? '';

    if (provider.isReturningPensioner && result.currentYearCertId != null) {
      final status = _D.resolveStatus(result.currentYearCertStatus);

      _resetBanners();

      if (status == _D.statusApproved) {
        provider.certificateId = result.currentYearCertId;
        provider.verificationStatus = result.currentYearCertStatus;
        provider.currentYearPhotoUrl = result.currentYearPhotoUrl;
        provider.currentYearVideoUrl = result.currentYearVideoUrl;
        setState(() {
          _certApproved = true;
          _phase = 2;
        });
        return;
      }

      if (status == _D.statusPending) {
        setState(() {
          _certPending = true;
          _phase = 2;
        });
        return;
      }

      if (status == _D.statusRejected) {
        provider.certificateId = result.currentYearCertId;
        provider.verificationStatus = result.currentYearCertStatus;
        setState(() {
          _certRejected = true;
          _phase = 2;
        });
        return;
      }
    }

    setState(() => _phase = 2);
  }

  // ── Step 2 ─────────────────────────────────────────────────────────────────
  Future<void> _sendOtp() async {
    if (!_validateMobile()) return;
    final provider = context.read<KycProvider>();
    final success =
        await provider.sendOtp(mobile: _mobileController.text.trim());
    if (success && mounted) {
      _startCountdown();
      setState(() => _phase = 3);
    }
  }

  // ── Step 3 ─────────────────────────────────────────────────────────────────
  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) return;
    final provider = context.read<KycProvider>();
    final success = await provider.verifyOtp(otp);
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.pensionerDetails);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _D.appBarBlue,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Enter PPO Number [Step-1]',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: _D.pageBg,
      body: Consumer<KycProvider>(
        builder: (_, provider, __) => ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _D.maxWidth),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(_D.hPad, 28, _D.hPad, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Enter Pensioner PPO Number',
                  textAlign: TextAlign.center,
                  style: _D.titleEn,
                ),
                const SizedBox(height: 4),
                const Text(
                  'पेन्शनर चा PPO नंबर टाका',
                  textAlign: TextAlign.center,
                  style: _D.titleMr,
                ),
                const SizedBox(height: 28),
                // Provider-level API errors (network, server, etc.)
                if (provider.error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _D.errorRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: _D.errorRed.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      provider.error!,
                      style: const TextStyle(color: _D.errorRed, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_phase == 1)
                  _phase1(provider)
                else if (_phase == 2)
                  _phase2(provider)
                else if (_phase == 3)
                  _phase3(provider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  Phase 1 – PPO input
  // ══════════════════════════════════════════════════════════════════════════
  Widget _phase1(KycProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // CHANGE 1: maxLength=4, digits-only inputFormatter, errorText wired.
        TextField(
          controller: _ppoController,
          decoration: _D.inputDec(
            hint: 'Enter PPO Number ',
            errorText: _ppoError,
          ),
          style: _D.inputText,
          keyboardType: TextInputType.number,
          maxLength: 4,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.done,
          onChanged: (_) {
            if (_ppoError != null) setState(() => _ppoError = null);
          },
          onSubmitted: (_) => _checkPpo(),
        ),
        // Extra space when error is shown (errorText adds its own height).
        SizedBox(height: _ppoError != null ? 8 : 28),
        _GreenBtn(
          onPressed: provider.isLoading ? null : _checkPpo,
          isLoading: provider.isLoading,
          line1: 'Submit PPO Number',
          line2: 'PPO नंबर टाका',
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  Phase 2 – Name + Mobile + Get OTP
  // ══════════════════════════════════════════════════════════════════════════
  Widget _phase2(KycProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _D.inputH,
          child: TextField(
            controller: TextEditingController(text: provider.ppoNo),
            readOnly: true,
            decoration: _D.inputDec(readOnly: true),
            style: _D.inputText,
          ),
        ),
        const SizedBox(height: 20),

        // ── Status banners ─────────────────────────────────────────────────
        if (_certApproved) ...[_approvedBanner(), const SizedBox(height: 16)],
        if (_certPending) ...[_pendingBanner(), const SizedBox(height: 16)],
        if (_certRejected) ...[_rejectedBanner(), const SizedBox(height: 16)],

        if (provider.name != null) ...[
          const Text('निवृत्ती वेतनधारका चे नाव:',
              textAlign: TextAlign.center, style: _D.sectionLabel),
          const SizedBox(height: 6),
          Text(provider.name!, textAlign: TextAlign.center, style: _D.nameText),
          const SizedBox(height: 20),
        ],

        const Text('Enter Your Mobile Number',
            textAlign: TextAlign.center, style: _D.sectionLabel),
        const SizedBox(height: 4),
        const Text(
          'तुमचा मोबाईल नंबर टाका',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555555)),
        ),
        const SizedBox(height: 14),

        // ── Mobile field ───────────────────────────────────────────────────
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextField(
              controller: _mobileController,
              focusNode: _mobileFocus,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: _D.inputDec(
                errorText: _mobileError,
                pad: const EdgeInsets.fromLTRB(16, 18, 76, 18),
              ),
              style: _D.inputText,
              onChanged: (_) {
                if (_mobileError != null) {
                  setState(() => _mobileError = null);
                }
              },
            ),
            Positioned(
              top: 0,
              bottom: _mobileError != null ? 22 : 0,
              right: 12,
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    _mobileFocus.requestFocus();
                    _mobileController.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: _mobileController.text.length,
                    );
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, size: 15, color: Color(0xFF1565C0)),
                      SizedBox(width: 4),
                      Text('Edit',
                          style: TextStyle(
                            color: Color(0xFF1565C0),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        _GreenBtn(
          onPressed: provider.isLoading ? null : _sendOtp,
          isLoading: provider.isLoading,
          line1: 'Get OTP',
          line2: 'OTP मिळवा',
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  Phase 3 – OTP entry
  // ══════════════════════════════════════════════════════════════════════════
  Widget _phase3(KycProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _D.inputH,
          child: TextField(
            controller: TextEditingController(text: provider.ppoNo),
            readOnly: true,
            decoration: _D.inputDec(readOnly: true),
            style: _D.inputText,
          ),
        ),
        const SizedBox(height: 20),

        // ── Status banners ─────────────────────────────────────────────────
        if (_certApproved) ...[_approvedBanner(), const SizedBox(height: 16)],
        if (_certPending) ...[_pendingBanner(), const SizedBox(height: 16)],
        if (_certRejected) ...[_rejectedBanner(), const SizedBox(height: 16)],

        if (provider.name != null) ...[
          const Text('निवृत्ती वेतनधारका चे नाव:',
              textAlign: TextAlign.center, style: _D.sectionLabel),
          const SizedBox(height: 6),
          Text(provider.name!, textAlign: TextAlign.center, style: _D.nameText),
          const SizedBox(height: 20),
        ],
        SizedBox(
          height: _D.inputH,
          child: TextField(
            controller:
                TextEditingController(text: provider.mobileNumber ?? ''),
            readOnly: true,
            decoration: _D.inputDec(readOnly: true),
            style: _D.inputText.copyWith(color: Colors.black54),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Enter OTP (OTP टाका):',
          textAlign: TextAlign.center,
          style: _D.otpLabel,
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: _D.inputH,
          child: TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: _D.inputDec(hint: 'Enter OTP'),
            style: _D.inputText,
            onSubmitted: (_) => _verifyOtp(),
          ),
        ),
        const SizedBox(height: 24),
        _GreenBtn(
          onPressed: provider.isLoading ? null : _verifyOtp,
          isLoading: provider.isLoading,
          line1: 'Submit OTP',
          line2: 'OTP सबमिट करा',
        ),
        const SizedBox(height: 20),
        Center(
          child: _countdown > 0
              ? Text(
                  'Resend OTP in $_countdown seconds',
                  style: _D.resendText,
                )
              : GestureDetector(
                  onTap: _sendOtp,
                  child: const Text(
                    'Resend OTP / OTP पुन्हा पाठवा',
                    style: TextStyle(
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  Banners
  // ══════════════════════════════════════════════════════════════════════════
  Widget _approvedBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _D.approvedBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _D.approvedBorder, width: 2),
      ),
      child: const Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.check_circle, size: 18, color: _D.approvedIcon),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Your life certificate has been approved. Verify via OTP to view your certificate.',
              style: TextStyle(fontSize: 14, color: _D.approvedText),
            ),
          ),
        ]),
        SizedBox(height: 6),
        Text(
          'तुमचे जीवन प्रमाणपत्र मंजूर झाले आहे. प्रमाणपत्र पाहण्यासाठी OTP द्वारे सत्यापित करा.',
          style: TextStyle(fontSize: 12, color: _D.approvedText),
        ),
      ]),
    );
  }

  Widget _pendingBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _D.pendingBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _D.pendingBorder, width: 2),
      ),
      child: const Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.access_time, size: 18, color: _D.pendingIcon),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Your life certificate is under review. Verify via OTP to view its status.',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ]),
        SizedBox(height: 6),
        Text(
          'तुमचे जीवन प्रमाणपत्र पुनरावलोकनाधीन आहे. स्थिती पाहण्यासाठी OTP द्वारे सत्यापित करा.',
          style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
      ]),
    );
  }

  Widget _rejectedBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _D.rejectedBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _D.rejectedBorder, width: 2),
      ),
      child: const Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.cancel, size: 18, color: _D.rejectedIcon),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Your life certificate application was rejected. Verify via OTP to view the details.',
              style: TextStyle(fontSize: 14, color: _D.rejectedText),
            ),
          ),
        ]),
        SizedBox(height: 6),
        Text(
          'तुमचा जीवन प्रमाणपत्र अर्ज नाकारला गेला आहे. तपशीलांसाठी OTP द्वारे सत्यापित करा.',
          style: TextStyle(fontSize: 12, color: _D.rejectedText),
        ),
      ]),
    );
  }
}
