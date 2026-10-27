import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pcmc_jeevan_praman/kyc_screens/enter_ppo_number_kyc_screen.dart';
import 'package:pcmc_jeevan_praman/life_certificate_screens/view_button_screen.dart';

// ── Inline theme constants (mirrors AppTheme used in PpoEntryScreen) ──
class _Theme {
  static const pageBg = Color(0xFFF5F7FA);
  static const primaryBlue = Color(0xFF1565C0);
  static const headerBlue = Color(0xFF1A5FA8);
  static const textDark = Color(0xFF1A2340);
  static const textSecondary = Color(0xFF6B7280);
  static const red = Color(0xFFDC2626);
  static const pendingOrange = Color(0xFFD97706);
  static const green = Color(0xFF16A34A);
  static const maxBodyWidth = 480.0;
}

// ── Reusable Green button (matches GreenButton widget) ──
class _GreenButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget child;

  const _GreenButton({
    required this.onPressed,
    required this.child,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _Theme.green,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _Theme.green.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : child,
      ),
    );
  }
}

// ── Reusable Blue Pill button (matches BluePillButton widget) ──
class _BluePillButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget child;

  const _BluePillButton({
    required this.onPressed,
    required this.child,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _Theme.primaryBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _Theme.primaryBlue.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : child,
      ),
    );
  }
}

// ── Shared InputDecoration theme (matches AppTheme.inputDecoration) ──
InputDecoration _inputDec({
  String? hintText,
  bool filled = false,
  Color fillColor = _Theme.pageBg,
  EdgeInsetsGeometry contentPadding = const EdgeInsets.fromLTRB(16, 14, 16, 14),
}) {
  return InputDecoration(
    hintText: hintText,
    filled: filled,
    fillColor: fillColor,
    contentPadding: contentPadding,
    counterText: '',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _Theme.primaryBlue, width: 2),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
  );
}

// ════════════════════════════════════════════════════════════
//  Main Screen
// ════════════════════════════════════════════════════════════
class AadharInputScreen extends StatefulWidget {
  const AadharInputScreen({super.key});

  @override
  State<AadharInputScreen> createState() => _AadharInputScreenState();
}

class _AadharInputScreenState extends State<AadharInputScreen> {
  final _ppoController = TextEditingController();
  final _otpController = TextEditingController();
  final _mobileController = TextEditingController();
  final _mobileFocus = FocusNode();

  // phase 1 = PPO input, 2 = Name+Mobile+GetOTP, 3 = OTP entry
  int _phase = 1;
  bool _isLoading = false;
  bool _isMobileEditable = false;

  String? _fullName;
  String? _mobileNumber;
  String? _error;

  int _countdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _ppoController.dispose();
    _otpController.dispose();
    _mobileController.dispose();
    _mobileFocus.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // ── helpers ──────────────────────────────────────────────

  void _startCountdown() {
    _countdown = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _countdown--);
      if (_countdown <= 0) t.cancel();
    });
  }

  void _setError(String? msg) => setState(() => _error = msg);

  // ── API calls ─────────────────────────────────────────────

  Future<void> _checkPpo() async {
    final ppo = _ppoController.text.trim();
    if (ppo.isEmpty) return;
    if (!RegExp(r'^[0-9]{1,5}$').hasMatch(ppo)) {
      _setError('Please enter a valid PPO number (1 to 5 digits).');
      return;
    }
    _setError(null);
    setState(() => _isLoading = true);

    try {
      final url =
          'https://lc.pcmcpensioner.in/api/aadhar/GetDetailsUsingPPONo?PPONumber=$ppo';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final fetchedMobile = (data['data']['MobileNumber'] ?? '') as String;

        setState(() {
          _fullName = data['data']['FullName'] as String?;
          _mobileNumber = fetchedMobile;
          _isMobileEditable = fetchedMobile.isEmpty;
          _mobileController.text = fetchedMobile;
          _phase = 2;
        });
      } else {
        _showKycPopup();
      }
    } catch (_) {
      _setError(
        'Failed to fetch data. Please check your internet connection.\nकृपया तुमचे इंटरनेट कनेक्शन तपासा',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendOtp() async {
    final mobile = _mobileController.text.trim();
    if (!RegExp(r'^[0-9]{10}$').hasMatch(mobile)) {
      _setError('Please enter a valid 10-digit mobile number.');
      return;
    }
    _setError(null);
    _mobileNumber = mobile;
    setState(() => _isLoading = true);

    try {
      final url =
          'https://lc.pcmcpensioner.in/api/aadhar/GetOtpUsingMobileNo?PPONumber=${_ppoController.text}&MobileNo=$mobile';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200 && mounted) {
        _startCountdown();
        setState(() {
          _isMobileEditable = false;
          _phase = 3;
        });
      } else {
        _setError('Error sending OTP. Please try again.');
      }
    } catch (_) {
      _setError(
        'Failed to send OTP. Please try again.\nकृपया पुन्हा प्रयत्न करा.',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) return;
    _setError(null);
    setState(() => _isLoading = true);

    try {
      final url =
          'https://lc.pcmcpensioner.in/api/aadhar/SubmitOtpUsingPPONo?PPONumber=${_ppoController.text}&Otp=$otp';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200 && mounted) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        final data = (responseData['Data'] ?? {}) as Map<String, dynamic>;

        String dateOfBirth = '';
        if (data['DateOfBirth'] != null &&
            (data['DateOfBirth'] as String).isNotEmpty) {
          try {
            final parsed = DateTime.parse(data['DateOfBirth'] as String);
            dateOfBirth =
                '${parsed.year.toString().padLeft(4, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
          } catch (_) {
            dateOfBirth = data['DateOfBirth'] as String;
          }
        }

        final actualMobile = _mobileController.text.isNotEmpty
            ? _mobileController.text
            : (data['MobileNumber'] ?? '') as String;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewButtonScreen(
              statusCode: responseData['StatusCode'] as int,
              messageCode: (responseData['MessageCode'] ?? '') as String,
              message: (responseData['Message'] ?? '') as String,
              verificationStatus: (data['VerificationStatus'] ?? '') as String,
              fullName: (data['FullName'] ?? '') as String,
              mobileNumber: actualMobile,
              address: (data['Addresss'] ?? '') as String,
              createdAt: (data['CreatedAt'] ?? '') as String,
              verificationStatusNote:
                  (data['VerificationStatusNote'] ?? '') as String,
              aadharNumber: (data['AadhaarNumber'] ?? '') as String,
              url: (data['Url'] ?? '') as String,
              profilePhotoUrl: (data['ProfilePhotoUrl'] ?? '') as String,
              dateOfBirth: dateOfBirth,
              ppoNumber: _ppoController.text,
              pensionType: (data['PensionType'] ?? '') as String,
            ),
          ),
        );
      } else {
        _setError('Error ${response.statusCode}. Please try again.');
      }
    } catch (_) {
      _setError(
        'Failed to verify OTP. Please try again.\nकृपया पुन्हा प्रयत्न करा.',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── KYC popup ─────────────────────────────────────────────

  void _showKycPopup() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Note',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Please Complete Your KYC First.\nकृपया प्रथम तुमचे केवायसी पूर्ण करा.',
          style: TextStyle(fontSize: 15),
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EnterPpoNumberKycScreen()),
              ).then((returnedPpo) {
                if (returnedPpo != null) {
                  setState(() => _ppoController.text = returnedPpo as String);
                }
              });
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── AppBar – matches KycHeader ──
      appBar: AppBar(
        backgroundColor: _Theme.headerBlue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Enter PPO Number [Step-1]',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: _Theme.pageBg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _Theme.maxBodyWidth),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Page title ──
                const Text(
                  'Enter Pensioner PPO Number',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _Theme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'पेन्शनर चा PPO नंबर टाका',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: _Theme.textSecondary),
                ),
                const SizedBox(height: 16),

                // ── Error alert ──
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _Theme.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _Theme.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: _Theme.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── Phase content ──
                if (_phase == 1)
                  _buildPhase1()
                else if (_phase == 2)
                  _buildPhase2()
                else if (_phase == 3)
                  _buildPhase3(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════
  //  Phase 1 – PPO input
  // ══════════════════════════════════════════
  Widget _buildPhase1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _ppoController,
          keyboardType: TextInputType.number,
          maxLength: 5,
          decoration: _inputDec(hintText: 'Enter PPO Number'),
          style: const TextStyle(fontSize: 16),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _checkPpo(),
        ),
        const SizedBox(height: 16),
        _GreenButton(
          onPressed: _isLoading ? null : _checkPpo,
          isLoading: _isLoading,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Submit PPO Number',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 2),
              Text(
                'PPO नंबर टाका',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════
  //  Phase 2 – Name + editable mobile + Get OTP
  // ══════════════════════════════════════════
  Widget _buildPhase2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // PPO readonly
        TextField(
          controller: TextEditingController(text: _ppoController.text),
          readOnly: true,
          decoration: _inputDec(filled: true, fillColor: _Theme.pageBg),
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),

        // Pensioner name
        if (_fullName != null) ...[
          const Text(
            'निवृत्ती वेतनधारका चे नाव:',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _Theme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _fullName!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _Theme.textDark,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Mobile label
        const Text(
          'Enter Your Mobile Number',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _Theme.textDark,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'तुमचा मोबाईल नंबर टाका',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: _Theme.textSecondary),
        ),
        const SizedBox(height: 12),

        // Mobile input with Edit icon – mirrors PpoEntryScreen exactly
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextField(
              controller: _mobileController,
              focusNode: _mobileFocus,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              enabled: _isMobileEditable,
              decoration: _inputDec(
                contentPadding: const EdgeInsets.fromLTRB(16, 14, 70, 14),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            Positioned(
              right: 12,
              child: GestureDetector(
                onTap: () {
                  setState(() => _isMobileEditable = !_isMobileEditable);
                  if (_isMobileEditable) {
                    _mobileFocus.requestFocus();
                    _mobileController.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: _mobileController.text.length,
                    );
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isMobileEditable ? Icons.check : Icons.edit,
                      size: 14,
                      color: _isMobileEditable
                          ? _Theme.green
                          : _Theme.primaryBlue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isMobileEditable ? 'Done' : 'Edit',
                      style: TextStyle(
                        color: _isMobileEditable
                            ? _Theme.green
                            : _Theme.primaryBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Get OTP button
        _BluePillButton(
          onPressed: _isLoading ? null : _sendOtp,
          isLoading: _isLoading,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Get OTP',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 2),
              Text(
                'OTP मिळवा',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════
  //  Phase 3 – OTP entry
  // ══════════════════════════════════════════
  Widget _buildPhase3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // PPO readonly
        TextField(
          controller: TextEditingController(text: _ppoController.text),
          readOnly: true,
          decoration: _inputDec(filled: true, fillColor: _Theme.pageBg),
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),

        // Pensioner name
        if (_fullName != null) ...[
          const Text(
            'निवृत्ती वेतनधारका चे नाव:',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _Theme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _fullName!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _Theme.textDark,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Mobile readonly
        TextField(
          controller: TextEditingController(text: _mobileController.text),
          readOnly: true,
          decoration: _inputDec(filled: true, fillColor: _Theme.pageBg),
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),

        // OTP label
        const Text(
          'Enter OTP (OTP टाका):',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _Theme.textDark,
          ),
        ),
        const SizedBox(height: 12),

        // OTP input
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: _inputDec(hintText: 'Enter OTP'),
          style: const TextStyle(fontSize: 16),
          onSubmitted: (_) => _verifyOtp(),
        ),
        const SizedBox(height: 16),

        // Submit OTP green button
        _GreenButton(
          onPressed: _isLoading ? null : _verifyOtp,
          isLoading: _isLoading,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Submit OTP',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 2),
              Text(
                'OTP सबमिट करा',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Resend OTP countdown / link
        Center(
          child: _countdown > 0
              ? Text(
                  'Resend OTP in $_countdown seconds',
                  style: const TextStyle(
                    color: Color(0xFFE05000),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                )
              : GestureDetector(
                  onTap: _sendOtp,
                  child: const Text(
                    'Resend OTP / OTP पुन्हा पाठवा',
                    style: TextStyle(
                      color: _Theme.headerBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

// // import 'dart:async'; // Add this import for Timer
// // import 'dart:convert';
// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:pcmc_jeevan_praman/kyc_screens/enter_ppo_number_kyc_screen.dart';
// import 'package:pcmc_jeevan_praman/life_certificate_screens/view_button_screen.dart';

// class AadharInputScreen extends StatefulWidget {
//   const AadharInputScreen({super.key});

//   @override
//   _AadharInputScreenState createState() => _AadharInputScreenState();
// }

// class _AadharInputScreenState extends State<AadharInputScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _ppoController = TextEditingController();
//   final TextEditingController _otpController = TextEditingController();
//   final TextEditingController _mobileNumberController =
//       TextEditingController(); // New controller for mobile

//   bool _isLoading = false;
//   bool _isSubmitting = false;
//   bool _showGetOtpButton = false;
//   bool _showOtpField = false;
//   bool _isOtpLoading = false;
//   bool _isMobileEditable = false; // Flag to check if mobile is editable
//   String? fullName;
//   String? mobileNumber;
//   bool _isPpoEditable = true; // Add this new variable

//   // Countdown variables
//   int _countdown = 30;
//   bool _isCountdownActive = false;
//   late Timer _timer;

//   String? validatePPONumber(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter your PPO number';
//     } else if (!RegExp(r'^[0-9]{1,5}$').hasMatch(value)) {
//       return 'PPO number must be between 1 to 5 digits';
//     }
//     return null;
//   }

//   String? validateMobileNumber(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter mobile number';
//     } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
//       return 'Mobile number must be 10 digits';
//     }
//     return null;
//   }

//   Future<void> _fetchMobileNumber(String ppoNumber) async {
//     if (ppoNumber.isEmpty || !RegExp(r'^[0-9]{1,5}$').hasMatch(ppoNumber)) {
//       _showInvalidPopup('Please enter a valid PPO number (1 to 5 digits).');
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     final url =
//         'https://lc.pcmcpensioner.in/api/aadhar/GetDetailsUsingPPONo?PPONumber=$ppoNumber';

//     try {
//       final response = await http.get(Uri.parse(url));

//       print('API Response Status: ${response.statusCode}');
//       print(
//           'API Response Body fate3r hittimg adhar input screen: ${response.body}');

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         print('Response Body: ${response.body}');

//         String fetchedMobile = data['data']['MobileNumber'] ?? '';

//         setState(() {
//           fullName = data['data']['FullName'];
//           mobileNumber = fetchedMobile;
//           _isPpoEditable = false; // Make PPO field non-editable after fetch
//           _isMobileEditable = fetchedMobile.isEmpty; // Make editable if empty

//           // Set the controller value
//           if (fetchedMobile.isNotEmpty) {
//             _mobileNumberController.text = fetchedMobile;
//           } else {
//             _mobileNumberController.clear();
//           }

//           _showGetOtpButton = true;
//         });
//       } else {
//         _showInvalidPopup(
//           'Please Complete Your KYC First.\nकृपया प्रथम तुमचे केवायसी पूर्ण करा.',
//           navigateToKycScreen: true,
//         );
//       }
//     } catch (e) {
//       _showInvalidPopup(
//           'Failed to fetch data: Please chack your Internet Connection\nकृपया तुमचे इंटरनेट कनेक्शन तपासा');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _getOtp() async {
//     // Validate mobile number before sending OTP
//     if (_isMobileEditable) {
//       if (_mobileNumberController.text.isEmpty ||
//           !RegExp(r'^[0-9]{10}$').hasMatch(_mobileNumberController.text)) {
//         _showInvalidPopup('Please enter a valid 10-digit mobile number');
//         return;
//       }
//       // Update mobileNumber from the editable field
//       mobileNumber = _mobileNumberController.text;
//     }

//     final url =
//         'https://lc.pcmcpensioner.in/api/aadhar/GetOtpUsingMobileNo?PPONumber=${_ppoController.text}&MobileNo=$mobileNumber';

//     setState(() {
//       _isOtpLoading = true;
//     });

//     try {
//       final response = await http.get(Uri.parse(url));
//       print('Response Status Code: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         print('Response Body: ${response.body}');

//         setState(() {
//           _showGetOtpButton = false;
//           _showOtpField = true;
//           _isMobileEditable = false; // Lock the field after OTP is sent
//           _startCountdown();
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('OTP sent successfully!')),
//         );
//       } else {
//         _showInvalidPopup('Error sending OTP. Please try again.');
//       }
//     } catch (e) {
//       _showInvalidPopup(
//           'Failed to send OTP: काहीतरी चुकीचे झाले आहे. कृपया पुन्हा प्रयत्न करा.');
//     } finally {
//       setState(() {
//         _isOtpLoading = false;
//       });
//     }
//   }

//   Future<void> _submitOtp() async {
//     final otp = _otpController.text;
//     final ppoNumber = _ppoController.text;

//     // Get the actual mobile number from the controller
//     final actualMobileNumber = _mobileNumberController.text;

//     if (otp.isEmpty || otp.length != 4) {
//       _showInvalidPopup('Please enter a valid OTP');
//       return;
//     }

//     final url =
//         'https://lc.pcmcpensioner.in/api/aadhar/SubmitOtpUsingPPONo?PPONumber=$ppoNumber&Otp=$otp';

//     setState(() {
//       _isOtpLoading = true;
//     });

//     try {
//       final response = await http.get(Uri.parse(url));

//       print('Request URL: $url');
//       print('Response Status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseData = json.decode(response.body);
//         print('Response Body: ${response.body}');

//         int statusCode = responseData['StatusCode'];
//         String messageCode = responseData['MessageCode'] ?? '';
//         String message = responseData['Message'] ?? '';

//         Map<String, dynamic> data = responseData['Data'] ?? {};

//         String fullName = data['FullName'] ?? '';
//         // Use actualMobileNumber if user edited it, otherwise use API response
//         String mobileNumber = actualMobileNumber.isNotEmpty
//             ? actualMobileNumber
//             : (data['MobileNumber'] ?? '');
//         // String mobileNumber = data['MobileNumber'] ?? '';
//         String address = data['Addresss'] ?? '';
//         String createdAt = data['CreatedAt'] ?? '';
//         String verificationStatusNote = data['VerificationStatusNote'] ?? '';
//         String verificationStatus = data['VerificationStatus'] ?? '';
//         String aadharNumber = data['AadhaarNumber'] ?? '';
//         String pensionType = data['PensionType'] ?? '';
//         String url = data['Url'] ?? '';
//         String profilePhotoUrl = data['ProfilePhotoUrl'] ?? '';

//         String dateOfBirth = '';

//         if (data['DateOfBirth'] != null && data['DateOfBirth'].isNotEmpty) {
//           try {
//             DateTime parsedDate = DateTime.parse(data['DateOfBirth']);
//             dateOfBirth =
//                 '${parsedDate.year.toString().padLeft(4, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';
//           } catch (e) {
//             print('Failed to parse DateOfBirth: $e');
//             dateOfBirth = data['DateOfBirth'];
//           }
//         }

//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ViewButtonScreen(
//               statusCode: statusCode,
//               messageCode: messageCode,
//               message: message,
//               verificationStatus: verificationStatus,
//               fullName: fullName,
//               mobileNumber: mobileNumber,
//               address: address,
//               createdAt: createdAt,
//               verificationStatusNote: verificationStatusNote,
//               aadharNumber: aadharNumber,
//               url: url,
//               profilePhotoUrl: profilePhotoUrl,
//               dateOfBirth: dateOfBirth,
//               ppoNumber: ppoNumber,
//               pensionType: pensionType,
//             ),
//           ),
//         );
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('OTP Submitted Successfully!')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: Status Code ${response.statusCode}')),
//         );
//       }
//     } catch (e) {
//       _showInvalidPopup(
//           'Failed to send OTP: काहीतरी चुकीचे झाले आहे. कृपया पुन्हा प्रयत्न करा.');
//     } finally {
//       setState(() {
//         _isOtpLoading = false;
//       });
//     }
//   }

//   void _startCountdown() {
//     _isCountdownActive = true;
//     _countdown = 30;
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_countdown == 0) {
//         _timer.cancel();
//         setState(() {
//           _isCountdownActive = false;
//         });
//       } else {
//         setState(() {
//           _countdown--;
//         });
//       }
//     });
//   }

//   Future<void> _submitPPO() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isSubmitting = true;
//       });
//       await _fetchMobileNumber(_ppoController.text);
//       setState(() {
//         _isSubmitting = false;
//       });
//     }
//   }

//   void _showInvalidPopup(String message, {bool navigateToKycScreen = false}) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20.0),
//           ),
//           title: const Text(
//             'Note',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           content: Text(
//             message,
//             style: const TextStyle(fontSize: 16),
//             textAlign: TextAlign.center,
//           ),
//           actions: <Widget>[
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 if (navigateToKycScreen) {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => EnterPpoNumberKycScreen(),
//                     ),
//                   ).then((returnedPpo) {
//                     if (returnedPpo != null) {
//                       setState(() {
//                         _ppoController.text = returnedPpo;
//                       });
//                     }
//                   });
//                 }
//               },
//               child: const Text('Ok'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     if (_isCountdownActive) {
//       _timer.cancel();
//     }
//     _ppoController.dispose();
//     _otpController.dispose();
//     _mobileNumberController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color(0xFF92B7F7),
//         title: const Center(
//           child: Text(
//             'Enter PPO Number [Step-1] ',
//             style: TextStyle(
//               color: Colors.black,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(18.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 const Text(
//                   'Enter Pensioner PPO Number\nपेन्शनर चा PPO नंबर टाका',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 30),
//                 Center(
//                   child: Container(
//                     width: 250,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: Color(0xFF92B7F7), width: 2),
//                     ),
//                     padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                     child: TextFormField(
//                       controller: _ppoController,
//                       keyboardType: TextInputType.number,
//                       maxLength: 5,
//                       validator: validatePPONumber,
//                       enabled: _isPpoEditable, // Add this line

//                       style: const TextStyle(color: Colors.black87),
//                       decoration: InputDecoration(
//                         border: InputBorder.none,
//                         hintText: 'Enter PPO Number',
//                         hintStyle: TextStyle(color: Colors.grey[600]),
//                         counterText: '',
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 if (_isLoading)
//                   const CircularProgressIndicator()
//                 else if (fullName != null && mobileNumber != null) ...[
//                   Text(
//                     ' निवृत्ती वेतनधारका चे नाव: \n $fullName',
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 20),

//                   // Replace the mobile number container section with this code:
// // Replace the mobile number section with this code:
// // Replace the mobile number section with this code:

//                   Column(
//                     children: [
//                       // Mobile Number Field with integrated Edit button
//                       Container(
//                         height: 60,
//                         width: 300,
//                         padding: EdgeInsets.symmetric(
//                             horizontal: 16.0, vertical: 12.0),
//                         decoration: BoxDecoration(
//                           color: _isMobileEditable
//                               ? Colors.white
//                               : Colors.grey[200],
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(
//                             color: _isMobileEditable
//                                 ? Colors.green
//                                 : Color(0xFF92B7F7),
//                             width: 2,
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: TextFormField(
//                                 controller: _mobileNumberController,
//                                 keyboardType: TextInputType.phone,
//                                 enabled: _isMobileEditable,
//                                 maxLength: 10,
//                                 decoration: InputDecoration(
//                                   border: InputBorder.none,
//                                   counterText: '',
//                                   hintText: ' Enter Mobile Number',
//                                   hintStyle: TextStyle(color: Colors.grey[400]),
//                                 ),
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: _isMobileEditable
//                                       ? Colors.black
//                                       : Colors.black54,
//                                 ),
//                                 onChanged: (value) {
//                                   setState(() {
//                                     mobileNumber = value;
//                                   });
//                                 },
//                               ),
//                             ),
//                             // Edit/Done button with icon and text inside the field
//                             if (!_showOtpField)
//                               InkWell(
//                                 onTap: () {
//                                   setState(() {
//                                     _isMobileEditable = !_isMobileEditable;
//                                   });
//                                 },
//                                 child: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Icon(
//                                       _isMobileEditable
//                                           ? Icons.check
//                                           : Icons.edit,
//                                       color: _isMobileEditable
//                                           ? Colors.green
//                                           : Colors.blue,
//                                       size: 18,
//                                     ),
//                                     SizedBox(width: 4),
//                                     Text(
//                                       _isMobileEditable ? 'Done' : 'Edit',
//                                       style: TextStyle(
//                                         color: _isMobileEditable
//                                             ? Colors.green
//                                             : Colors.blue,
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 20),
//                   if (_showGetOtpButton)
//                     ElevatedButton(
//                       onPressed: _isOtpLoading ? null : _getOtp,
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 35, vertical: 10),
//                         backgroundColor: Colors.green,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25),
//                         ),
//                       ),
//                       child: _isOtpLoading
//                           ? const CircularProgressIndicator(
//                               valueColor:
//                                   AlwaysStoppedAnimation<Color>(Colors.white),
//                               strokeWidth: 3,
//                             )
//                           : const Text(
//                               'Get OTP\nOTP मिळवा',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                     ),
//                   if (_showOtpField) ...[
//                     const SizedBox(height: 20),
//                     Text(
//                       'Enter OTP (OTP टाका):',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 20),
//                     Container(
//                       width: 250,
//                       child: TextFormField(
//                         controller: _otpController,
//                         keyboardType: TextInputType.number,
//                         decoration: InputDecoration(
//                           labelText: 'Enter OTP',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide:
//                                 BorderSide(color: Color(0xFF92B7F7), width: 2),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide:
//                                 BorderSide(color: Color(0xFF92B7F7), width: 2),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: _submitOtp,
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 35, vertical: 10),
//                         backgroundColor: Colors.green,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25),
//                         ),
//                       ),
//                       child: _isOtpLoading
//                           ? const CircularProgressIndicator(
//                               valueColor:
//                                   AlwaysStoppedAnimation<Color>(Colors.white),
//                               strokeWidth: 3,
//                             )
//                           : const Text(
//                               'Submit OTP\nOTP सबमिट करा',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                     ),
//                     if (!_isCountdownActive) ...[
//                       const SizedBox(height: 20),
//                       ElevatedButton(
//                         onPressed: _getOtp,
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 35, vertical: 10),
//                           backgroundColor: Colors.blue,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(25),
//                           ),
//                         ),
//                         child: const Text(
//                           'Resend OTP',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ],
//                     if (_isCountdownActive) ...[
//                       const SizedBox(height: 20),
//                       Text(
//                         'Resend OTP in $_countdown seconds',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.red,
//                         ),
//                       ),
//                     ],
//                   ],
//                 ] else
//                   ElevatedButton(
//                     onPressed: _isSubmitting ? null : _submitPPO,
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 35, vertical: 8),
//                       backgroundColor: Colors.green,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(25),
//                       ),
//                     ),
//                     child: _isSubmitting
//                         ? const CircularProgressIndicator(
//                             valueColor:
//                                 AlwaysStoppedAnimation<Color>(Colors.white),
//                             strokeWidth: 3,
//                           )
//                         : const Text(
//                             'Submit PPO Number\n PPO नंबर टाका',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
