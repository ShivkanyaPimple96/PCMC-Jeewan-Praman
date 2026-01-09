import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pcmc_jeevan_praman/kyc_screens/pensioner_detailes_kyc_screen.dart';

class EnterMobileNumberKYCScreen extends StatefulWidget {
  final String ppoNumber;
  const EnterMobileNumberKYCScreen({super.key, required this.ppoNumber});

  @override
  _EnterMobileNumberKYCScreenState createState() =>
      _EnterMobileNumberKYCScreenState();
}

class _EnterMobileNumberKYCScreenState
    extends State<EnterMobileNumberKYCScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isMobileSubmitted = false;
  bool _isLoading = false;
  bool _isOtpLoading = false;
  String _errorMessage = '';
  String _otpErrorMessage = '';
  final String _fullName = '';

  Future<void> _getOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final mobileNumber = _mobileController.text.trim();
      final url = Uri.parse(
          'https://lc.pcmcpensioner.in/api/aadhar/GetOtpUsingMobileNo?PPONumber=${widget.ppoNumber}&MobileNo=$mobileNumber');

      final response = await http.get(url);
      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _isMobileSubmitted = true;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to get OTP. Please try again.';
          if (response.statusCode == 400) {
            _errorMessage = 'Invalid PPO or Mobile Number';
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'An error occurred. Please check your internet connection.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isOtpLoading = true;
      _otpErrorMessage = '';
    });

    try {
      final otp = _otpController.text.trim();
      final url = Uri.parse(
          'https://lc.pcmcpensioner.in/api/aadhar/SubmitOtpUsingPPONo?PPONumber=${widget.ppoNumber}&Otp=$otp');

      final response = await http.get(url);
      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final String pensionType = jsonResponse['Data']?['PensionType'] ?? '';
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PensionerDetailesKYCScreen(
              fullName: _fullName,
              ppoNumber: widget.ppoNumber,
              pensionType: pensionType,
              mobileNumber: _mobileController.text.trim(),
              // pensionType: '', // Pass pension type if available
            ),
          ),
        );
      } else {
        setState(() {
          _otpErrorMessage = 'Invalid OTP. Please try again.';
          if (response.statusCode == 400) {
            _otpErrorMessage = 'Invalid OTP or PPO Number';
          }
        });
      }
    } catch (e) {
      setState(() {
        _otpErrorMessage =
            'An error occurred. Please check your internet connection.';
      });
    } finally {
      setState(() {
        _isOtpLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Enter Mobile Number  [Step-1]',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color(0xFF92B7F7),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Container(
                height: 60,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF92B7F7), width: 2),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'PPO Number: ${widget.ppoNumber}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'निवृत्ती वेतनधारका चे नाव:\n$_fullName',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(
                  child: Text(
                    'Enter your mobile number:',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Container(
                  height: 60,
                  width: 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: const Color(0xFF92B7F7), width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: TextFormField(
                      controller: _mobileController,
                      enabled: !_isMobileSubmitted,
                      keyboardType: TextInputType.phone,
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.black,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter mobile number',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 18,
                        ),
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      validator: (value) {
                        if (!_isMobileSubmitted) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter mobile number';
                          }
                          if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                            return 'Invalid mobile number';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Center(
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              Visibility(
                visible: !_isMobileSubmitted,
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _getOtp();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 35, vertical: 8),
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 5,
                            shadowColor: Colors.teal.withOpacity(0.3),
                          ),
                          child: const Text(
                            "Submit Mobile Number\nमोबाईल नंबर सबमिट करा",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                ),
              ),
              if (_isMobileSubmitted) ...[
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Center(
                    child: Text(
                      'Enter OTP:',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: const Color(0xFF92B7F7), width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.black,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter OTP',
                          hintStyle:
                              TextStyle(color: Colors.grey[600], fontSize: 18),
                        ),
                        validator: (value) {
                          if (_isMobileSubmitted) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter OTP';
                            }
                            if (value.length != 4) {
                              return 'OTP must be 4 digits';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                if (_otpErrorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Center(
                      child: Text(
                        _otpErrorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 30),
                Center(
                  child: _isOtpLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _submitOtp,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 35, vertical: 8),
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 5,
                            shadowColor: Colors.teal.withOpacity(0.3),
                          ),
                          child: const Text(
                            "Submit OTP\nOTP सबमिट करा",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
