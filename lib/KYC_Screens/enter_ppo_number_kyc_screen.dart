import 'dart:async'; // Add this import for Timer
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pcmc_jeevan_praman/KYC_Screens/enter_mobile_number_kyc_screen.dart';
import 'package:pcmc_jeevan_praman/kyc_screens/pensioner_detailes_kyc_screen.dart';

class EnterPpoNumberKycScreen extends StatefulWidget {
  const EnterPpoNumberKycScreen({super.key});

  @override
  _EnterPpoNumberKycScreenState createState() =>
      _EnterPpoNumberKycScreenState();
}

class _EnterPpoNumberKycScreenState extends State<EnterPpoNumberKycScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ppoController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();

  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _showGetOtpButton = false;
  bool _showOtpField = false;
  bool _isOtpLoading = false;
  String? fullName;
  String? mobileNumber;
  bool _isPpoEditable = true; // Add this new variable

  // Countdown variables
  int _countdown = 30;
  bool _isCountdownActive = false;
  late Timer _timer;

  // String? validatePPONumber(String? value) {
  //   if (value == null || value.isEmpty) {
  //     return 'Please enter your PPO number';
  //   } else if (value.length != 4) {
  //     return 'PPO number must be 4 digits';
  //   } else if (!RegExp(r'^[0-9]{4}$').hasMatch(value)) {
  //     return 'PPO number must contain only digits';
  //   }
  //   return null;
  // }

  String? validatePPONumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your PPO number';
    } else if (!RegExp(r'^[0-9]{1,4}$').hasMatch(value)) {
      return 'PPO number must be between 1 to 4 digits';
    }
    return null;
  }

  Future<void> _fetchMobileNumber(String ppoNumber) async {
    // if (ppoNumber.length != 4 || !RegExp(r'^[0-9]+$').hasMatch(ppoNumber)) {
    //   _showInvalidPopup('Please enter a valid PPO number.');
    //   return;
    // }

    if (ppoNumber.isEmpty || !RegExp(r'^[0-9]{1,4}$').hasMatch(ppoNumber)) {
      _showInvalidPopup('Please enter a valid PPO number (1 to 4 digits).');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url =
        'https://lc.pcmcpensioner.in/api/aadhar/GetDataUsingPPONo?PPONumber=$ppoNumber';

    try {
      final response = await http.get(Uri.parse(url));

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('Response Body: ${response.body}');
        setState(() {
          fullName = data['data']['FullName'];
          mobileNumber = data['data']['MobileNumber'];
          _mobileNumberController.text = mobileNumber ?? '';
          _showGetOtpButton = true;
          _isPpoEditable = false; // Add this line to disable PPO editing
        });
      } else {
        _showInvalidPopup(' Please enter the correct PPO number.');
        // _showInvalidPopup(
        //   'Please Complete Your KYC First.\nकृपया प्रथम तुमचे केवायसी पूर्ण करा.',
        //   navigateToKycScreen: true,
        // );
      }
    } catch (e) {
      _showInvalidPopup(
          'Failed to fetch data: Please chack your Internet Connection\nकृपया तुमचे इंटरनेट कनेक्शन तपासा');
      //  _showInvalidPopup('Failed to fetch data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getOtp() async {
    final url =
        'https://lc.pcmcpensioner.in/api/aadhar/GetOtpUsingMobileNo?PPONumber=${_ppoController.text}&MobileNo=${_mobileNumberController.text}';

    setState(() {
      _isOtpLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(url));
      print('Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Response Body: ${response.body}');

        setState(() {
          _showGetOtpButton = false;
          _showOtpField = true;
          _startCountdown();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent successfully!')),
        );
      } else {
        _showInvalidPopup('Error sending OTP. Please try again.');
      }
    } catch (e) {
      _showInvalidPopup(
          'Failed to send OTP: काहीतरी चुकीचे झाले आहे. कृपया पुन्हा प्रयत्न करा.');
      // _showInvalidPopup('Failed to send OTP: $e');
    } finally {
      setState(() {
        _isOtpLoading = false;
      });
    }
  }

  Future<void> _submitOtp() async {
    final otp = _otpController.text;
    final ppoNumber = _ppoController.text;
    final editedMobileNumber =
        _mobileNumberController.text; // Get the edited mobile number

    // Validate OTP
    if (otp.isEmpty || otp.length != 4) {
      _showInvalidPopup('Please enter a valid OTP');
      return;
    }

    // Validate mobile number
    if (editedMobileNumber.isEmpty || editedMobileNumber.length != 10) {
      _showInvalidPopup('Please enter a valid 10-digit mobile number');
      return;
    }

    final url =
        'https://lc.pcmcpensioner.in/api/aadhar/SubmitOtpUsingPPONo?PPONumber=$ppoNumber&Otp=$otp';

    setState(() {
      _isOtpLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(url));

      print('Request URL: $url');
      print('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('Response Body: ${response.body}');

        // Extract top-level fields
        int statusCode = responseData['StatusCode'];
        String messageCode = responseData['MessageCode'] ?? '';
        String message = responseData['Message'] ?? '';

        // Extract nested 'Data' field
        Map<String, dynamic> data = responseData['Data'] ?? {};

        // Extract fields from 'Data'
        String fullName = data['FullName'] ?? '';
        String pensionType = data['PensionType'] ?? '';
        String address = data['Addresss'] ?? '';
        String createdAt = data['CreatedAt'] ?? '';
        String verificationStatusNote = data['VerificationStatusNote'] ?? '';
        String verificationStatus = data['VerificationStatus'] ?? '';
        String aadharNumber = data['AadhaarNumber'] ?? '';
        String url = data['Url'] ?? '';
        String dateOfBirth = '';

        if (data['DateOfBirth'] != null && data['DateOfBirth'].isNotEmpty) {
          try {
            DateTime parsedDate = DateTime.parse(data['DateOfBirth']);
            dateOfBirth =
                '${parsedDate.year.toString().padLeft(4, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';
          } catch (e) {
            print('Failed to parse DateOfBirth: $e');
            dateOfBirth = data['DateOfBirth'];
          }
        }

        // Navigate and pass the EDITED mobile number from the controller
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PensionerDetailesKYCScreen(
              fullName: fullName,
              mobileNumber: editedMobileNumber, // Pass the edited mobile number
              ppoNumber: ppoNumber,
              pensionType: pensionType,
            ),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP Submitted Successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Status Code ${response.statusCode}')),
        );
      }
    } catch (e) {
      _showInvalidPopup(
          'Failed to send OTP: काहीतरी चुकीचे झाले आहे. कृपया पुन्हा प्रयत्न करा.');
    } finally {
      setState(() {
        _isOtpLoading = false;
      });
    }
  }

  // Start the 30-second countdown
  void _startCountdown() {
    _isCountdownActive = true;
    _countdown = 30; // Reset countdown to 30 seconds
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        _timer.cancel();
        setState(() {
          _isCountdownActive = false; // Stop countdown
        });
      } else {
        setState(() {
          _countdown--;
        });
      }
    });
  }

  Future<void> _submitPPO() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      await _fetchMobileNumber(_ppoController.text);
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showInvalidPopup(String message, {bool navigateToKycScreen = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Text(
            'Note',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            ElevatedButton(
              // onPressed: () {
              //   Navigator.of(context).pop(); // close the dialog
              //   if (navigateToKycScreen) {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) => EnterMobileNumberScreen()),
              //     );
              //   }
              // },

              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                if (navigateToKycScreen) {
                  String currentPpo = _ppoController.text;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EnterMobileNumberKYCScreen(ppoNumber: currentPpo),
                    ),
                  ).then((returnedPpo) {
                    if (returnedPpo != null) {
                      setState(() {
                        _ppoController.text = returnedPpo;
                      });
                    }
                  });
                }
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _mobileNumberController.dispose();
    if (_isCountdownActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF92B7F7),
        title: const Center(
          child: Text(
            'Enter PPO Number[Step-1] ',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  'Enter Pensioner PPO  for KYC\nपेन्शनर चा PPO नंबर टाका',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Center(
                  child: Container(
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xFF92B7F7), width: 2),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: TextFormField(
                      controller: _ppoController,
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                      validator: validatePPONumber,
                      enabled: _isPpoEditable, // Add this line
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter PPO Number',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        counterText: '',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                if (_isLoading)
                  const CircularProgressIndicator()
                else if (fullName != null && mobileNumber != null) ...[
                  Text(
                    ' निवृत्ती वेतनधारका चे नाव: \n $fullName',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Enter Your Mobile Number\nतुमचा मोबाईल नंबर टाका',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 60,
                    width: 300,
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xFF92B7F7), width: 2),
                    ),
                    child: TextFormField(
                      controller: _mobileNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        // labelText: 'Mobile Number',
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      onChanged: (value) {
                        setState(() {
                          mobileNumber = value;
                        });
                      },
                    ),
                    // child: Text(
                    //   'Mobile Number: $mobileNumber',
                    //   style: const TextStyle(
                    //     fontSize: 20,
                    //     fontWeight: FontWeight.bold,
                    //     color: Colors.black,
                    //   ),
                    // ),
                  ),
                  const SizedBox(height: 20),
                  if (_showGetOtpButton)
                    ElevatedButton(
                      onPressed: _isOtpLoading ? null : _getOtp,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 35, vertical: 10),
                        backgroundColor: Color(0xFF92B7F7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isOtpLoading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 3,
                            )
                          : const Text(
                              'Get OTP\nOTP मिळवा',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                    ),
                  if (_showOtpField) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: 170,
                      child: TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Enter OTP',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Color(0xFF92B7F7), width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Color(0xFF92B7F7), width: 2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitOtp,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 35, vertical: 10),
                        backgroundColor: Color(0xFF92B7F7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isOtpLoading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 3,
                            )
                          : const Text(
                              'Submit OTP\nOTP सबमिट करा',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                    ),
                    if (!_isCountdownActive) ...[
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _getOtp,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 35, vertical: 10),
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                    if (_isCountdownActive) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Resend OTP in $_countdown seconds',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ],
                ] else
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitPPO,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 35, vertical: 8),
                      backgroundColor: Color(0xFF92B7F7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 3,
                          )
                        : const Text(
                            'Submit PPO Number\n PPO नंबर टाका',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
