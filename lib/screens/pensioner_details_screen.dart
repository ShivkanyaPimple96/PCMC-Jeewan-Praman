import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../config/routes.dart';
import '../providers/kyc_provider.dart';
import '../screens/certificate_webview_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens
// ─────────────────────────────────────────────────────────────────────────────
class _DS {
  static const Color headerBg = Color(0xFF7BBDE4);
  static const Color headerText = Colors.white;
  static const Color pageBg = Color(0xFFF2F5FA);
  static const Color cardBg = Colors.white;
  static const Color cardBorder = Color(0xFF93C4E8);
  static const double cardRadius = 12.0;
  static const double cardBorderWidth = 1.5;
  static const Color labelColor = Color(0xFF8A9BB0);
  static const double labelFontSize = 13.0;
  static const Color valueColor = Color(0xFF1A1A1A);
  static const double valueFontSize = 15.5;
  static const Color divider = Color(0xFFDDE4EE);
  static const Color buttonBg = Color(0xFF3A9BDC);
  static const Color buttonText = Colors.white;
  static const double buttonRadius = 16.0;
  static const double rowPaddingV = 12.0;
  static const double cardPaddingH = 16.0;
  static const double cardPaddingV = 4.0;

  // Validation error color
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color errorBg = Color(0xFFFFF0F0);
  static const Color errorBorder = Color(0xFFFFCDD2);

  // ── Normalised status constants (all lowercase, canonical long-form) ──────
  static const String statusApproved = 'application approved';
  static const String statusPending = 'verification in progress';
  static const String statusRejected = 'application rejected';

  /// Resolves any known raw status string → one of the three canonical values
  /// above, or returns the original (lowercased) value if unrecognised.
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper: build the certificate URL
// ─────────────────────────────────────────────────────────────────────────────
// String _buildCertUrl(String? financialYear, int? certificateId) {
//   if (financialYear == null || certificateId == null) return '';
//   final yearPart = financialYear.replaceAll('-', '_');
//   return 'https://lc.pcmcpensioner.in/Home/view/?lc=${yearPart}_$certificateId';
// }

String _buildCertUrl(String? financialYear, String? ppoNo) {
  if (financialYear == null || ppoNo == null || ppoNo.isEmpty) return '';
  final yearPart = financialYear.replaceAll('-', '_');
  return 'https://lc.pcmcpensioner.in/Home/view/?lc=${yearPart}_$ppoNo';
}

// ─────────────────────────────────────────────────────────────────────────────
// Main Screen
// ─────────────────────────────────────────────────────────────────────────────
class PensionerDetailsScreen extends StatefulWidget {
  const PensionerDetailsScreen({super.key});

  @override
  State<PensionerDetailsScreen> createState() => _PensionerDetailsScreenState();
}

class _PensionerDetailsScreenState extends State<PensionerDetailsScreen> {
  final _aadhaarController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedGender;

  // ── Validation error state ─────────────────────────────────────────────────
  String? _aadhaarError;
  String? _addressError;
  String? _genderError;

  // ── Track whether this screen is in read-only mode ─────────────────────────
  bool _isReadOnly = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<KycProvider>();
    _aadhaarController.text = provider.aadhaarNumber ?? '';
    _addressController.text = provider.address ?? '';
    _selectedGender = provider.gender;
    // NOTE: For rejected status we intentionally do NOT set read-only,
    // so the pensioner can edit and re-submit.
    _isReadOnly = provider.isKycCompleted || provider.isReturningPensioner;
  }

  @override
  void dispose() {
    _aadhaarController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // ── Resolved (canonical) status ────────────────────────────────────────────
  String get _resolvedStatus =>
      _DS.resolveStatus(context.read<KycProvider>().verificationStatus);

  bool get _isPending => _resolvedStatus == _DS.statusPending;
  bool get _isApproved => _resolvedStatus == _DS.statusApproved;
  bool get _isRejected => _resolvedStatus == _DS.statusRejected;

  // ── Exit app (works on Android + iOS) ─────────────────────────────────────
  void _exitApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
  }

  // ── Validate form ──────────────────────────────────────────────────────────
  bool _validateForm() {
    if (_isReadOnly) return true;

    final aadhaar = _aadhaarController.text.trim();
    final address = _addressController.text.trim();

    String? aadhaarErr;
    String? addressErr;
    String? genderErr;

    if (aadhaar.isEmpty) {
      aadhaarErr = 'Aadhaar number is required. / आधार क्रमांक आवश्यक आहे.';
    } else if (!RegExp(r'^\d{12}$').hasMatch(aadhaar)) {
      if (aadhaar.length < 12) {
        aadhaarErr =
            'Aadhaar must be 12 digits — too short. / आधार 12 अंकी असणे आवश्यक आहे — खूप कमी.';
      } else if (aadhaar.length > 12) {
        aadhaarErr =
            'Aadhaar must be 12 digits — too long. / आधार 12 अंकी असणे आवश्यक आहे — खूप जास्त.';
      } else {
        aadhaarErr =
            'Aadhaar must contain digits only. / आधार फक्त अंक असणे आवश्यक आहे.';
      }
    }

    if (address.isEmpty) {
      addressErr = 'Address is required. / पत्ता आवश्यक आहे.';
    }

    if (_selectedGender == null || _selectedGender!.isEmpty) {
      genderErr = 'Please select a gender. / कृपया लिंग निवडा.';
    }

    setState(() {
      _aadhaarError = aadhaarErr;
      _addressError = addressErr;
      _genderError = genderErr;
    });

    return aadhaarErr == null && addressErr == null && genderErr == null;
  }

  // ── Exit dialog (back pressed while PENDING) ───────────────────────────────
  void _showExitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Verification Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: const Text(
            'Your verification is in progress.\nतुमची पडताळणी प्रक्रियेत आहे.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _exitApp();
              },
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Info dialogs ───────────────────────────────────────────────────────────
  void _showPendingInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Verification Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: const Text(
            'Your verification is in progress.\nतुमची पडताळणी प्रक्रियेत आहे.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Single unified back handler ────────────────────────────────────────────
  void _handleBack() {
    if (_isPending) {
      _showExitDialog();
    } else {
      Navigator.of(context).pop();
    }
  }

  // ── Proceed (Generate / Re-generate Life Certificate) ─────────────────────
  Future<void> _proceed() async {
    if (!_validateForm()) return;

    final provider = context.read<KycProvider>();

    if (_isReadOnly) {
      if (!mounted) return;
      if (provider.shouldSkipAadhaarVerification) {
        Navigator.pushReplacementNamed(context, AppRoutes.photoCapture);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.aadhaarVerification);
      }
    } else {
      final success = await provider.savePensionerDetails(
        newAadhaar: _aadhaarController.text.trim(),
        newAddress: _addressController.text.trim(),
        newGender: _selectedGender,
      );
      if (!success || !mounted) return;
      if (provider.shouldSkipAadhaarVerification) {
        Navigator.pushReplacementNamed(context, AppRoutes.photoCapture);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.aadhaarVerification);
      }
    }
  }

  // ── View Certificate ───────────────────────────────────────────────────────
  void _viewCertificate() {
    final provider = context.read<KycProvider>();
    // final url = _buildCertUrl(provider.financialYear, provider.certificateId);
    final url = _buildCertUrl(provider.financialYear, provider.ppoNo);
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Certificate details not available. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CertificateWebViewScreen(url: url)),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer<KycProvider>(
      builder: (_, provider, __) {
        final readOnly =
            provider.isKycCompleted || provider.isReturningPensioner;
        if (_isReadOnly != readOnly) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _isReadOnly = readOnly);
          });
        }

        return WillPopScope(
          onWillPop: () async {
            _handleBack();
            return false;
          },
          child: Scaffold(
            backgroundColor: _DS.pageBg,
            appBar: AppBar(
              backgroundColor: _DS.headerBg,
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: _DS.headerText),
                onPressed: _handleBack,
              ),
              title: const Text(
                'Pensioner Details [Step-2]',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_isReadOnly)
                    _buildReadOnlyCard(provider)
                  else
                    _buildEditableForm(provider),
                  const SizedBox(height: 14),
                  _buildVerificationStatusCard(provider),
                  const SizedBox(height: 18),
                  _buildCtaButton(provider),
                  if (provider.error != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        provider.error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Read-only details card ────────────────────────────────────────────────
  Widget _buildReadOnlyCard(KycProvider provider) {
    return _DetailsCard(
      children: [
        _DetailRow(label: 'PPO Number(पीपीओ नंबर):', value: provider.ppoNo),
        _DetailRow(label: 'Full Name(पूर्ण नाव):', value: provider.name ?? '—'),
        _DetailRow(
          label: 'Aadhar Number(आधार नंबर):',
          value: provider.aadhaarNumber ?? '—',
          showDivider: true,
        ),
        _DetailRow(
          label: 'Pension Type(पेन्शन प्रकार):',
          value: provider.pensionType ?? '—',
          showDivider: true,
        ),
        _DetailRow(
          label: 'Address(पत्ता):',
          value: provider.address ?? '—',
          isLast: true,
        ),
      ],
    );
  }

  // ── Editable form card ────────────────────────────────────────────────────
  Widget _buildEditableForm(KycProvider provider) {
    return _DetailsCard(
      children: [
        _DetailRow(label: 'PPO Number(पीपीओ नंबर):', value: provider.ppoNo),
        _DetailRow(label: 'Full Name(पूर्ण नाव):', value: provider.name ?? '—'),

        // ── Aadhaar field ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Aadhar Number(आधार नंबर):',
                style: TextStyle(
                  fontSize: _DS.labelFontSize,
                  color: _DS.labelColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _aadhaarController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                maxLength: 12,
                decoration: InputDecoration(
                  counterText: '${_aadhaarController.text.length} / 12',
                  errorText: _aadhaarError,
                  errorStyle: const TextStyle(
                    color: _DS.errorColor,
                    fontSize: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _aadhaarError != null
                          ? _DS.errorColor
                          : const Color(0xFFDDE4EE),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color:
                          _aadhaarError != null ? _DS.errorColor : _DS.buttonBg,
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _DS.errorColor),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: _DS.errorColor, width: 1.5),
                  ),
                  filled: _aadhaarError != null,
                  fillColor:
                      _aadhaarError != null ? _DS.errorBg : Colors.transparent,
                  hint: const Text('Enter 12-digit Aadhaar'),
                ),
                onChanged: (_) {
                  if (_aadhaarError != null) {
                    setState(() => _aadhaarError = null);
                  }
                },
              ),
            ],
          ),
        ),

        // ── Gender field ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gender(लिंग):',
                style: TextStyle(
                  fontSize: _DS.labelFontSize,
                  color: _DS.labelColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  errorText: _genderError,
                  errorStyle: const TextStyle(
                    color: _DS.errorColor,
                    fontSize: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _genderError != null
                          ? _DS.errorColor
                          : const Color(0xFFDDE4EE),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color:
                          _genderError != null ? _DS.errorColor : _DS.buttonBg,
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _DS.errorColor),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: _DS.errorColor, width: 1.5),
                  ),
                  filled: _genderError != null,
                  fillColor:
                      _genderError != null ? _DS.errorBg : Colors.transparent,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                hint: const Text('Select Gender / लिंग निवडा'),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedGender = val;
                    _genderError = null;
                  });
                },
              ),
            ],
          ),
        ),

        // ── Address field ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Address(पत्ता):',
                style: TextStyle(
                  fontSize: _DS.labelFontSize,
                  color: _DS.labelColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _addressController,
                maxLines: 3,
                decoration: InputDecoration(
                  errorText: _addressError,
                  errorStyle: const TextStyle(
                    color: _DS.errorColor,
                    fontSize: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _addressError != null
                          ? _DS.errorColor
                          : const Color(0xFFDDE4EE),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color:
                          _addressError != null ? _DS.errorColor : _DS.buttonBg,
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _DS.errorColor),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: _DS.errorColor, width: 1.5),
                  ),
                  filled: _addressError != null,
                  fillColor:
                      _addressError != null ? _DS.errorBg : Colors.transparent,
                  hint: const Text('Enter your address'),
                ),
                onChanged: (_) {
                  if (_addressError != null) {
                    setState(() => _addressError = null);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Verification status card ──────────────────────────────────────────────
  Widget _buildVerificationStatusCard(KycProvider provider) {
    final status = provider.verificationStatus;
    final hasStatus = status != null && status.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: _DS.cardBg,
        borderRadius: BorderRadius.circular(_DS.cardRadius),
        border: Border.all(color: _DS.cardBorder, width: _DS.cardBorderWidth),
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: _DS.cardPaddingH, vertical: _DS.cardPaddingV),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Verification Status(पडताळणी ची सद्यस्थिती):',
              style: TextStyle(
                  fontSize: _DS.labelFontSize,
                  color: _DS.labelColor,
                  fontWeight: FontWeight.w500),
            ),
          ),
          if (hasStatus) ...[
            _StatusBadge(status: status!),
            const SizedBox(height: 8),
          ] else
            const SizedBox(height: 28),
          const Divider(color: _DS.divider, thickness: 1, height: 1),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ── CTA button ─────────────────────────────────────────────────────────────
  // Routes:
  //   statusApproved          → "View Certificate"               (green)
  //   statusPending           → "Verification In Progress"       (blue, info-only)
  //   statusRejected OR null  → "Re-generate Life Certificate"   (blue, navigates)
  //   default (no status)     → "Generate Your Life Certificate" (blue, navigates)
  Widget _buildCtaButton(KycProvider provider) {
    final status = _DS.resolveStatus(provider.verificationStatus);

    // ── Approved ──────────────────────────────────────────────────────────
    if (status == _DS.statusApproved) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _viewCertificate,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF28A745),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_DS.buttonRadius)),
            elevation: 3,
            shadowColor: const Color(0xFF28A745).withValues(alpha: 0.4),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.workspace_premium, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('View Certificate',
                      style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ],
              ),
              SizedBox(height: 3),
              Text('प्रमाणपत्र पहा',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white)),
            ],
          ),
        ),
      );
    }

    // ── Pending ───────────────────────────────────────────────────────────
    if (status == _DS.statusPending) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _showPendingInfoDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: _DS.buttonBg,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_DS.buttonRadius)),
            elevation: 2,
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Verification In Progress',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _DS.buttonText)),
              SizedBox(height: 3),
              Text('पडताळणी प्रगतीपथावर आहे',
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: _DS.buttonText)),
            ],
          ),
        ),
      );
    }

    // ── Rejected OR null/empty → Re-generate / Generate ───────────────────
    // Both cases share the same blue navigating button.
    // Label differs: rejected = "Re-generate", otherwise = "Generate".
    final isRejected = status == _DS.statusRejected;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: provider.isLoading ? null : _proceed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _DS.buttonBg,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_DS.buttonRadius)),
          elevation: 3,
          shadowColor: _DS.buttonBg.withValues(alpha: 0.4),
        ),
        child: provider.isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white)),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Icon only shown for rejected to hint at retry ──────
                  if (isRejected)
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Re-generate Life Certificate',
                          style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: _DS.buttonText),
                        ),
                      ],
                    )
                  else
                    const Text(
                      'Generate Your Life Certificate',
                      style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: _DS.buttonText),
                    ),
                  const SizedBox(height: 3),
                  Text(
                    isRejected
                        ? 'जीवन प्रमाणपत्र पुन्हा तयार करा'
                        : 'जीवन प्रमाणपत्र तयार करा',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _DS.buttonText),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '(${provider.financialYear ?? '2026-2027'})',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _DS.buttonText),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DetailsCard
// ─────────────────────────────────────────────────────────────────────────────
class _DetailsCard extends StatelessWidget {
  final List<Widget> children;
  const _DetailsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _DS.cardBg,
        borderRadius: BorderRadius.circular(_DS.cardRadius),
        border: Border.all(color: _DS.cardBorder, width: _DS.cardBorderWidth),
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: _DS.cardPaddingH, vertical: _DS.cardPaddingV),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DetailRow
// ─────────────────────────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    this.showDivider = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
              top: _DS.rowPaddingV, bottom: isLast ? _DS.rowPaddingV : 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: _DS.labelFontSize,
                      color: _DS.labelColor,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 3),
              Text(value,
                  style: const TextStyle(
                      fontSize: _DS.valueFontSize,
                      color: _DS.valueColor,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        if (!isLast) const Divider(color: _DS.divider, thickness: 1, height: 1),
        if (showDivider) const SizedBox(height: 4),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StatusBadge
// ─────────────────────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final resolved = _DS.resolveStatus(status);

    Color bg, border, text;
    IconData icon;
    String label, marathi;

    if (resolved == _DS.statusApproved) {
      bg = const Color(0xFFE8F9EE);
      border = const Color(0xFF34A853);
      text = const Color(0xFF1E8740);
      icon = Icons.check_circle_outline;
      label = 'Application Approved';
      marathi = 'अर्ज मंजूर';
    } else if (resolved == _DS.statusPending) {
      bg = const Color(0xFFEAF3FB);
      border = _DS.buttonBg;
      text = _DS.buttonBg;
      icon = Icons.hourglass_bottom;
      label = 'Verification In Progress';
      marathi = 'पडताळणी प्रगतीपथावर आहे';
    } else if (resolved == _DS.statusRejected) {
      bg = const Color(0xFFFFEBEE);
      border = const Color(0xFFD32F2F);
      text = const Color(0xFFB71C1C);
      icon = Icons.cancel_outlined;
      label = 'Application Rejected';
      marathi = 'अर्ज नाकारला गेला';
    } else {
      bg = const Color(0xFFF5F5F5);
      border = const Color(0xFFBBBBBB);
      text = const Color(0xFF666666);
      icon = Icons.info_outline;
      label = status;
      marathi = '';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: text, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: text,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5)),
              if (marathi.isNotEmpty)
                Text(marathi, style: TextStyle(color: text, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
