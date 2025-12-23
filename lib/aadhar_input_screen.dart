// import 'dart:async'; // Add this import for Timer
// import 'dart:convert';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pcmc_jeevan_praman/kyc_screens/enter_ppo_number_kyc_screen.dart';
import 'package:pcmc_jeevan_praman/life_certificate_screens/view_button_screen.dart';


class AadharInputScreen extends StatefulWidget {
  const AadharInputScreen({super.key});

  @override
  _AadharInputScreenState createState() => _AadharInputScreenState();
}

class _AadharInputScreenState extends State<AadharInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ppoController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _mobileNumberController =
      TextEditingController(); // New controller for mobile

  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _showGetOtpButton = false;
  bool _showOtpField = false;
  bool _isOtpLoading = false;
  bool _isMobileEditable = false; // Flag to check if mobile is editable
  String? fullName;
  String? mobileNumber;
  bool _isPpoEditable = true; // Add this new variable

  // Countdown variables
  int _countdown = 30;
  bool _isCountdownActive = false;
  late Timer _timer;

  String? validatePPONumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your PPO number';
    } else if (!RegExp(r'^[0-9]{1,5}$').hasMatch(value)) {
      return 'PPO number must be between 1 to 5 digits';
    }
    return null;
  }

  String? validateMobileNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter mobile number';
    } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return 'Mobile number must be 10 digits';
    }
    return null;
  }

  Future<void> _fetchMobileNumber(String ppoNumber) async {
    if (ppoNumber.isEmpty || !RegExp(r'^[0-9]{1,5}$').hasMatch(ppoNumber)) {
      _showInvalidPopup('Please enter a valid PPO number (1 to 5 digits).');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url =
        'https://testingpcmcpensioner.altwise.in/api/aadhar/GetDetailsUsingPPONo?PPONumber=$ppoNumber';

    try {
      final response = await http.get(Uri.parse(url));

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('Response Body: ${response.body}');

        String fetchedMobile = data['data']['MobileNumber'] ?? '';

        setState(() {
          fullName = data['data']['FullName'];
          mobileNumber = fetchedMobile;
          _isPpoEditable = false; // Make PPO field non-editable after fetch
          _isMobileEditable = fetchedMobile.isEmpty; // Make editable if empty

          // Set the controller value
          if (fetchedMobile.isNotEmpty) {
            _mobileNumberController.text = fetchedMobile;
          } else {
            _mobileNumberController.clear();
          }

          _showGetOtpButton = true;
        });
      } else {
        _showInvalidPopup(
          'Please Complete Your KYC First.\nकृपया प्रथम तुमचे केवायसी पूर्ण करा.',
          navigateToKycScreen: true,
        );
      }
    } catch (e) {
      _showInvalidPopup(
          'Failed to fetch data: Please chack your Internet Connection\nकृपया तुमचे इंटरनेट कनेक्शन तपासा');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getOtp() async {
    // Validate mobile number before sending OTP
    if (_isMobileEditable) {
      if (_mobileNumberController.text.isEmpty ||
          !RegExp(r'^[0-9]{10}$').hasMatch(_mobileNumberController.text)) {
        _showInvalidPopup('Please enter a valid 10-digit mobile number');
        return;
      }
      // Update mobileNumber from the editable field
      mobileNumber = _mobileNumberController.text;
    }

    final url =
        'https://testingpcmcpensioner.altwise.in/api/aadhar/GetOtpUsingMobileNo?PPONumber=${_ppoController.text}&MobileNo=$mobileNumber';

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
          _isMobileEditable = false; // Lock the field after OTP is sent
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
          'Failed to send OTP: काहीतरी चुकीचे झाले आहे. कृपया पुन्हा प्रयत्न करा.');
    } finally {
      setState(() {
        _isOtpLoading = false;
      });
    }
  }

  Future<void> _submitOtp() async {
    final otp = _otpController.text;
    final ppoNumber = _ppoController.text;

    // Get the actual mobile number from the controller
    final actualMobileNumber = _mobileNumberController.text;

    if (otp.isEmpty || otp.length != 4) {
      _showInvalidPopup('Please enter a valid OTP');
      return;
    }

    final url =
        'https://testingpcmcpensioner.altwise.in/api/aadhar/SubmitOtpUsingPPONo?PPONumber=$ppoNumber&Otp=$otp';

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

        int statusCode = responseData['StatusCode'];
        String messageCode = responseData['MessageCode'] ?? '';
        String message = responseData['Message'] ?? '';

        Map<String, dynamic> data = responseData['Data'] ?? {};

        String fullName = data['FullName'] ?? '';
        // Use actualMobileNumber if user edited it, otherwise use API response
        String mobileNumber = actualMobileNumber.isNotEmpty
            ? actualMobileNumber
            : (data['MobileNumber'] ?? '');
        // String mobileNumber = data['MobileNumber'] ?? '';
        String address = data['Addresss'] ?? '';
        String createdAt = data['CreatedAt'] ?? '';
        String verificationStatusNote = data['VerificationStatusNote'] ?? '';
        String verificationStatus = data['VerificationStatus'] ?? '';
        String aadharNumber = data['AadhaarNumber'] ?? '';
        String pensionType = data['PensionType'] ?? '';
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

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewButtonScreen(
              statusCode: statusCode,
              messageCode: messageCode,
              message: message,
              verificationStatus: verificationStatus,
              fullName: fullName,
              mobileNumber: mobileNumber,
              address: address,
              createdAt: createdAt,
              verificationStatusNote: verificationStatusNote,
              aadharNumber: aadharNumber,
              url: url,
              dateOfBirth: dateOfBirth,
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

  void _startCountdown() {
    _isCountdownActive = true;
    _countdown = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        _timer.cancel();
        setState(() {
          _isCountdownActive = false;
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
              onPressed: () {
                Navigator.of(context).pop();
                if (navigateToKycScreen) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EnterPpoNumberKycScreen(),
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
    if (_isCountdownActive) {
      _timer.cancel();
    }
    _ppoController.dispose();
    _otpController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF92B7F7),
        title: const Center(
          child: Text(
            'Enter PPO Number [Step-1] ',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
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
                  'Enter Pensioner PPO Number\nपेन्शनर चा PPO नंबर टाका',
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
                    width: 250,
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
                  // Mobile Number Container - Editable or Display
                  // Container(
                  //   width: 300,
                  //   padding: EdgeInsets.all(_isMobileEditable ? 0 : 16.0),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(10),
                  //     border: Border.all(color: Color(0xFF92B7F7), width: 2),
                  //   ),
                  //   child: _isMobileEditable
                  //       ? TextFormField(
                  //           controller: _mobileController,
                  //           keyboardType: TextInputType.phone,
                  //           maxLength: 10,
                  //           validator: validateMobileNumber,
                  //           style: const TextStyle(
                  //             fontSize: 20,
                  //             fontWeight: FontWeight.bold,
                  //             color: Colors.black,
                  //           ),
                  //           decoration: InputDecoration(
                  //             labelText: 'Enter Mobile Number',
                  //             labelStyle: TextStyle(color: Colors.grey[700]),
                  //             border: InputBorder.none,
                  //             contentPadding: EdgeInsets.all(16.0),
                  //             counterText: '',
                  //           ),
                  //         )
                  //       : Text(
                  //           'Mobile Number: ${_mobileController.text}',
                  //           style: const TextStyle(
                  //             fontSize: 20,
                  //             fontWeight: FontWeight.bold,
                  //             color: Colors.black,
                  //           ),
                  //           textAlign: TextAlign.center,
                  //         ),
                  // ),
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
                        backgroundColor: Colors.green,
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
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                    ),
                  if (_showOtpField) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: 250,
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
                        backgroundColor: Colors.green,
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
                                color: Colors.white,
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
                      backgroundColor: Colors.green,
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
                              color: Colors.white,
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
//   final TextEditingController _mobileController =
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
//         'https://testingpcmcpensioner.altwise.in/api/aadhar/GetDetailsUsingPPONo?PPONumber=$ppoNumber';

//     try {
//       final response = await http.get(Uri.parse(url));

//       print('API Response Status: ${response.statusCode}');
//       print('API Response Body: ${response.body}');

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
//             _mobileController.text = fetchedMobile;
//           } else {
//             _mobileController.clear();
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
//       if (_mobileController.text.isEmpty ||
//           !RegExp(r'^[0-9]{10}$').hasMatch(_mobileController.text)) {
//         _showInvalidPopup('Please enter a valid 10-digit mobile number');
//         return;
//       }
//       // Update mobileNumber from the editable field
//       mobileNumber = _mobileController.text;
//     }

//     final url =
//         'https://testingpcmcpensioner.altwise.in/api/aadhar/GetOtpUsingMobileNo?PPONumber=${_ppoController.text}&MobileNo=$mobileNumber';

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
//     final actualMobileNumber = _mobileController.text;

//     if (otp.isEmpty || otp.length != 4) {
//       _showInvalidPopup('Please enter a valid OTP');
//       return;
//     }

//     final url =
//         'https://testingpcmcpensioner.altwise.in/api/aadhar/SubmitOtpUsingPPONo?PPONumber=$ppoNumber&Otp=$otp';

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
//     _mobileController.dispose();
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
//                   // Mobile Number Container - Editable or Display
//                   Container(
//                     width: 300,
//                     padding: EdgeInsets.all(_isMobileEditable ? 0 : 16.0),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: Color(0xFF92B7F7), width: 2),
//                     ),
//                     child: _isMobileEditable
//                         ? TextFormField(
//                             controller: _mobileController,
//                             keyboardType: TextInputType.phone,
//                             maxLength: 10,
//                             validator: validateMobileNumber,
//                             style: const TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black,
//                             ),
//                             decoration: InputDecoration(
//                               labelText: 'Enter Mobile Number',
//                               labelStyle: TextStyle(color: Colors.grey[700]),
//                               border: InputBorder.none,
//                               contentPadding: EdgeInsets.all(16.0),
//                               counterText: '',
//                             ),
//                           )
//                         : Text(
//                             'Mobile Number: ${_mobileController.text}',
//                             style: const TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
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
