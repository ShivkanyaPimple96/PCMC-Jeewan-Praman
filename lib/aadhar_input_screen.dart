import 'dart:async'; // Add this import for Timer
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pcmc_jeevan_praman/KYC_Screens/enter_mobile_number_screen.dart';
import 'package:pcmc_jeevan_praman/view_button_screen.dart';

class AadharInputScreen extends StatefulWidget {
  const AadharInputScreen({super.key});

  @override
  _AadharInputScreenState createState() => _AadharInputScreenState();
}

class _AadharInputScreenState extends State<AadharInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ppoController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _showGetOtpButton = false;
  bool _showOtpField = false;
  bool _isOtpLoading = false;
  String? fullName;
  String? mobileNumber;

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
        'https://lc.pcmcpensioner.in/api/aadhar/GetDetailsUsingPPONo?PPONumber=$ppoNumber';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('Response Body: ${response.body}');
        setState(() {
          fullName = data['data']['FullName'];
          mobileNumber = data['data']['MobileNumber'];
          _showGetOtpButton = true;
        });
      } else {
        // _showInvalidPopup(
        //     'Error: ${response.statusCode}. Please enter the correct PPO number.');
        _showInvalidPopup(
          'Note: ${response.statusCode}. Please Complete Your KYC First.\nकृपया प्रथम तुमचे केवायसी पूर्ण करा.',
          navigateToKycScreen: true,
        );
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
        'https://lc.pcmcpensioner.in/api/aadhar/GetOtpUsingMobileNo?PPONumber=${_ppoController.text}&MobileNo=$mobileNumber';

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

    // Validate OTP
    if (otp.isEmpty || otp.length != 4) {
      _showInvalidPopup('Please enter a valid OTP');
      return;
    }

    final url =
        'https://lc.pcmcpensioner.in/api/aadhar/SubmitOtpUsingPPONo?PPONumber=$ppoNumber&Otp=$otp';

    setState(() {
      _isOtpLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(url));

      print('Request URL: $url'); // Print the request URL
      print(
          'Response Status: ${response.statusCode}'); // Print response status code
      // Print response body
      if (response.statusCode == 200) {
        // Parse the entire response body
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
        String mobileNumber = data['MobileNumber'] ?? '';
        String address = data['Addresss'] ?? '';
        String createdAt = data['CreatedAt'] ?? '';
        String verificationStatusNote = data['VerificationStatusNote'] ?? '';
        String verificationStatus = data['VerificationStatus'] ?? '';
        String aadharNumber = data['AadhaarNumber'] ?? '';
        String url = data['Url'] ?? '';
        String dateOfBirth = '';

        if (data['DateOfBirth'] != null && data['DateOfBirth'].isNotEmpty) {
          try {
            // Parse the DateOfBirth string from the API
            DateTime parsedDate = DateTime.parse(data['DateOfBirth']);
            // Format the date to 'yyyy-MM-dd'
            dateOfBirth =
                '${parsedDate.year.toString().padLeft(4, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';
          } catch (e) {
            print('Failed to parse DateOfBirth: $e');
            // Fallback to the original value if parsing fails
            dateOfBirth = data['DateOfBirth'];
          }
        }

        // Navigate to the ViewButtonScreen and pass all the fields
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
            ),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP Submitted Successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Status Code $response.statusCode')),
        );
      }
    } catch (e) {
      _showInvalidPopup(
          'Failed to send OTP: काहीतरी चुकीचे झाले आहे. कृपया पुन्हा प्रयत्न करा.');
      // _showInvalidPopup('Failed to submit OTP: $e');
      // _showInvalidPopup('Failed to submit OTP: $e');
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
                          EnterMobileNumberScreen(ppoNumber: currentPpo),
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

  // void _showInvalidPopup(String message) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20.0),
  //         ),
  //         title: const Text(
  //           'Note',
  //           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //         ),
  //         content: Text(
  //           message,
  //           style: const TextStyle(fontSize: 16),
  //           textAlign: TextAlign.center,
  //         ),
  //         actions: <Widget>[
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('Ok'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  void dispose() {
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
            'Enter PPO Number   [Step-1] ',
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
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
                    width: 170,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xFF92B7F7), width: 2),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: TextFormField(
                      controller: _ppoController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      validator: validatePPONumber,
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
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xFF92B7F7), width: 2),
                    ),
                    child: Text(
                      'Mobile Number: $mobileNumber',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
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
                    TextFormField(
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



// import 'dart:convert'; // For jsonEncode

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class AadharInputScreen extends StatefulWidget {
//   @override
//   _AadharInputScreenState createState() => _AadharInputScreenState();
// }

// class _AadharInputScreenState extends State<AadharInputScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _aadharController = TextEditingController();
//   final TextEditingController _mobileController =
//       TextEditingController(); // Controller for mobile number
//   final TextEditingController _otpController =
//       TextEditingController(); // Controller for OTP
//   bool _isLoading =
//       false; // To control the loading state for fetching Aadhar name
//   bool _isSubmitting =
//       false; // To control the loading state of the Submit button
//   bool _isOtpSent = false; // To control the visibility of OTP input
//   bool _isLoadingOtp = false; // To control loading state of Get OTP button
//   Map<String, dynamic>? _responseData; // To hold the parsed API response data

//   String? validateAadharNumber(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter your Aadhar number';
//     } else if (value.length != 12) {
//       return 'Aadhar number must be 12 digits';
//     } else if (!RegExp(r'^[0-9]{12}$').hasMatch(value)) {
//       return 'Aadhar number must contain only digits';
//     }
//     return null;
//   }

//   Future<void> _fetchAadharName(String aadharNumber) async {
//     setState(() {
//       _isLoading = true; // Start loading
//       _responseData = null; // Clear previous response
//     });

//     final url =
//         'https://divyangverify.pcmcdivyang.com/api/aadhar/GetAadharName?aadhaarNumber=$aadharNumber';

//     try {
//       final response = await http.get(Uri.parse(url));

//       print(
//           'Response status: ${response.statusCode}'); // Print the response status
//       print('Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         // If the server returns a 200 OK response, parse the response
//         final Map<String, dynamic> data = json.decode(response.body);
//         setState(() {
//           _responseData = data; // Store the parsed response data
//         });
//       } else {
//         setState(() {
//           _responseData = {
//             'message': 'Error: ${response.statusCode}'
//           }; // Handle error
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _responseData = {
//           'message': 'Failed to fetch data: $e'
//         }; // Handle exception
//       });
//     } finally {
//       setState(() {
//         _isLoading = false; // Stop loading
//       });
//     }
//   }

//   Future<void> _getOtp(String aadharNumber, String mobileNumber) async {
//     setState(() {
//       _isLoadingOtp = true; // Start loading on Get OTP button
//     });

//     final url =
//         'https://divyangverify.pcmcdivyang.com/api/aadhar/GetOtpUsingMobileNumber?aadhaarNumber=$aadharNumber&mobileNo=$mobileNumber';

//     try {
//       final response = await http.get(Uri.parse(url));

//       print(
//           'Get OTP Response status: ${response.statusCode}'); // Print the response status
//       print(
//           'Get OTP Response body: ${response.body}'); // Print the response body

//       if (response.statusCode == 200) {
//         // If OTP is sent successfully
//         setState(() {
//           _isOtpSent = true; // Show the OTP input field and Next button
//         });
//       } else {
//         // Handle error case
//         print('Error getting OTP: ${response.body}');
//       }
//     } catch (e) {
//       print('Failed to get OTP: $e'); // Handle exception
//     } finally {
//       setState(() {
//         _isLoadingOtp = false; // Stop loading on Get OTP button
//       });
//     }
//   }

//   Future<void> _submitAadhar() async {
//     // Ensure the form is valid before submitting
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isSubmitting = true; // Start loading on the Submit button
//       });
//       // Call the API to fetch Aadhar name
//       await _fetchAadharName(_aadharController.text);
//       setState(() {
//         _isSubmitting = false; // Stop loading on the Submit button
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Enter Aadhar Number'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _aadharController,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(
//                   labelText: 'Aadhar Number',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLength: 12, // Limiting input to 12 digits
//                 validator: validateAadharNumber,
//               ),
//               const SizedBox(height: 20),
//               // Show loader
//               if (_isLoading)
//                 CircularProgressIndicator()
//               else ...[
//                 // Show the submit button only if there's no response message
//                 if (_responseData == null)
//                   ElevatedButton(
//                     onPressed: _isSubmitting ? null : _submitAadhar,
//                     child: _isSubmitting
//                         ? SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(
//                               valueColor:
//                                   AlwaysStoppedAnimation<Color>(Colors.white),
//                               strokeWidth: 3,
//                             ),
//                           )
//                         : const Text('Submit'),
//                   ),
//                 // Show the response message if available
//                 if (_responseData != null)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         if (_responseData!['status_code'] == 200)
//                           Column(
//                             children: [
//                               // Display the full name
//                               Text(
//                                 'Full Name: ${_responseData!['data']?['full_name'] ?? 'N/A'}',
//                                 style: TextStyle(color: Colors.blue),
//                               ),
//                               const SizedBox(height: 20),
//                               // TextField for mobile number
//                               TextFormField(
//                                 controller: _mobileController,
//                                 keyboardType: TextInputType.phone,
//                                 decoration: const InputDecoration(
//                                   labelText: 'Enter Mobile Number',
//                                   border: OutlineInputBorder(),
//                                 ),
//                                 maxLength: 10, // Limiting input to 10 digits
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'Please enter your mobile number';
//                                   } else if (value.length != 10) {
//                                     return 'Mobile number must be 10 digits';
//                                   } else if (!RegExp(r'^[0-9]{10}$')
//                                       .hasMatch(value)) {
//                                     return 'Mobile number must contain only digits';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                               const SizedBox(height: 20),
//                               // Show Get OTP button only if OTP is not sent
//                               if (!_isOtpSent)
//                                 ElevatedButton(
//                                   onPressed: () {
//                                     if (_mobileController.text.isNotEmpty &&
//                                         _responseData != null) {
//                                       // Call the API to get OTP using the entered Aadhar and mobile number
//                                       _getOtp(_aadharController.text,
//                                           _mobileController.text);
//                                     } else {
//                                       // Show an error if the mobile number is empty or Aadhar response is not available
//                                       print(
//                                           'Please enter a valid mobile number and ensure Aadhar information is fetched.');
//                                     }
//                                   },
//                                   child: _isLoadingOtp
//                                       ? SizedBox(
//                                           height: 20,
//                                           width: 20,
//                                           child: CircularProgressIndicator(
//                                             valueColor:
//                                                 AlwaysStoppedAnimation<Color>(
//                                                     Colors.white),
//                                           ),
//                                         )
//                                       : const Text('Get OTP'),
//                                 ),
//                               // Show OTP input field and Next button after OTP is sent
//                               if (_isOtpSent) ...[
//                                 TextFormField(
//                                   controller: _otpController,
//                                   keyboardType: TextInputType.number,
//                                   decoration: const InputDecoration(
//                                     labelText: 'Enter OTP',
//                                     border: OutlineInputBorder(),
//                                   ),
//                                   maxLength: 6, // Limiting input to 6 digits
//                                   validator: (value) {
//                                     if (value == null || value.isEmpty) {
//                                       return 'Please enter the OTP';
//                                     } else if (value.length != 6) {
//                                       return 'OTP must be 6 digits';
//                                     }
//                                     return null;
//                                   },
//                                 ),
//                                 const SizedBox(height: 20),
//                                 ElevatedButton(
//                                   onPressed: () {
//                                     // Handle Next button click
//                                     // Add your logic here to navigate to the next screen or process OTP
//                                     print(
//                                         'Entered OTP: ${_otpController.text}');
//                                   },
//                                   child: const Text('Next'),
//                                 ),
//                               ],
//                             ],
//                           )
//                         else
//                           Text(
//                             'Error: ${_responseData!['message'] ?? 'Unknown error'}',
//                             style: TextStyle(color: Colors.red),
//                           ),
//                       ],
//                     ),
//                   ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




// import 'dart:convert'; // For jsonEncode

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class AadharInputScreen extends StatefulWidget {
//   @override
//   _AadharInputScreenState createState() => _AadharInputScreenState();
// }

// class _AadharInputScreenState extends State<AadharInputScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _aadharController = TextEditingController();
//   final TextEditingController _mobileController =
//       TextEditingController(); // Controller for mobile number
//   bool _isLoading = false; // To control the loading state
//   bool _isSubmitting =
//       false; // To control the loading state of the Submit button
//   bool _isOtpLoading =
//       false; // To control the loading state of the Get OTP button
//   Map<String, dynamic>? _responseData; // To hold the parsed API response data

//   String? validateAadharNumber(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter your Aadhar number';
//     } else if (value.length != 12) {
//       return 'Aadhar number must be 12 digits';
//     } else if (!RegExp(r'^[0-9]{12}$').hasMatch(value)) {
//       return 'Aadhar number must contain only digits';
//     }
//     return null;
//   }

//   Future<void> _fetchAadharName(String aadharNumber) async {
//     setState(() {
//       _isLoading = true; // Start loading
//       _responseData = null; // Clear previous response
//     });

//     final url =
//         'https://divyangverify.pcmcdivyang.com/api/aadhar/GetAadharName?aadhaarNumber=$aadharNumber';

//     try {
//       final response = await http.get(Uri.parse(url));

//       print(
//           'Response status: ${response.statusCode}'); // Print the response status
//       print('Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         // If the server returns a 200 OK response, parse the response
//         final Map<String, dynamic> data = json.decode(response.body);
//         setState(() {
//           _responseData = data; // Store the parsed response data
//         });
//       } else {
//         setState(() {
//           _responseData = {
//             'message': 'Error: ${response.statusCode}'
//           }; // Handle error
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _responseData = {
//           'message': 'Failed to fetch data: $e'
//         }; // Handle exception
//       });
//     } finally {
//       setState(() {
//         _isLoading = false; // Stop loading
//       });
//     }
//   }

//   Future<void> _getOtp(String aadharNumber, String mobileNumber) async {
//     setState(() {
//       _isOtpLoading = true; // Start loading for OTP request
//     });

//     final url =
//         'https://divyangverify.pcmcdivyang.com/api/aadhar/GetOtpUsingMobileNumber?aadhaarNumber=$aadharNumber&mobileNo=$mobileNumber';

//     try {
//       final response = await http.get(Uri.parse(url));

//       print(
//           'Get OTP Response status: ${response.statusCode}'); // Print the response status
//       print(
//           'Get OTP Response body: ${response.body}'); // Print the response body

//       if (response.statusCode == 200) {
//         // Optionally, you can process the response data here
//         final Map<String, dynamic> data = json.decode(response.body);
//         // Handle success case (you can show a success message)
//         print(
//             'OTP sent successfully: ${data['message']}'); // Print any success message from the response
//       } else {
//         // Handle error case
//         print('Error getting OTP: ${response.body}');
//       }
//     } catch (e) {
//       print('Failed to get OTP: $e'); // Handle exception
//     } finally {
//       setState(() {
//         _isOtpLoading = false; // Stop loading for OTP request
//       });
//     }
//   }

//   Future<void> _submitAadhar() async {
//     // Ensure the form is valid before submitting
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isSubmitting = true; // Start loading on the Submit button
//       });
//       // Call the API to fetch Aadhar name
//       await _fetchAadharName(_aadharController.text);
//       setState(() {
//         _isSubmitting = false; // Stop loading on the Submit button
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Enter Aadhar Number'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _aadharController,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(
//                   labelText: 'Aadhar Number',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLength: 12, // Limiting input to 12 digits
//                 validator: validateAadharNumber,
//               ),
//               const SizedBox(height: 20),
//               // Show loader
//               if (_isLoading)
//                 CircularProgressIndicator()
//               else ...[
//                 // Show the submit button only if there's no response message
//                 if (_responseData == null)
//                   ElevatedButton(
//                     onPressed: _isSubmitting ? null : _submitAadhar,
//                     child: _isSubmitting
//                         ? SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(
//                               valueColor:
//                                   AlwaysStoppedAnimation<Color>(Colors.white),
//                               strokeWidth: 3,
//                             ),
//                           )
//                         : const Text('Submit'),
//                   ),
//                 // Show the response message if available
//                 if (_responseData != null)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         if (_responseData!['status_code'] == 200)
//                           Column(
//                             children: [
//                               // Display the full name
//                               Text(
//                                 'Full Name: ${_responseData!['data']?['full_name'] ?? 'N/A'}',
//                                 style: TextStyle(color: Colors.blue),
//                               ),
//                               const SizedBox(
//                                   height:
//                                       20), // Spacing between the name and mobile input
//                               // TextField for mobile number
//                               TextFormField(
//                                 controller: _mobileController,
//                                 keyboardType: TextInputType.phone,
//                                 decoration: const InputDecoration(
//                                   labelText: 'Enter Mobile Number',
//                                   border: OutlineInputBorder(),
//                                 ),
//                                 maxLength: 10, // Limiting input to 10 digits
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'Please enter your mobile number';
//                                   } else if (value.length != 10) {
//                                     return 'Mobile number must be 10 digits';
//                                   } else if (!RegExp(r'^[0-9]{10}$')
//                                       .hasMatch(value)) {
//                                     return 'Mobile number must contain only digits';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                               const SizedBox(
//                                   height:
//                                       20), // Spacing between the mobile input and button
//                               ElevatedButton(
//                                 onPressed: _isOtpLoading
//                                     ? null // Disable the button if OTP is loading
//                                     : () {
//                                         if (_mobileController.text.isNotEmpty &&
//                                             _responseData != null) {
//                                           // Call the API to get OTP using the entered Aadhar and mobile number
//                                           _getOtp(_aadharController.text,
//                                               _mobileController.text);
//                                         } else {
//                                           // Show an error if the mobile number is empty or Aadhar response is not available
//                                           print(
//                                               'Please enter a valid mobile number and ensure Aadhar information is fetched.');
//                                         }
//                                       },
//                                 child: _isOtpLoading
//                                     ? SizedBox(
//                                         height: 20,
//                                         width: 20,
//                                         child: CircularProgressIndicator(
//                                           valueColor:
//                                               AlwaysStoppedAnimation<Color>(
//                                                   Colors.white),
//                                           strokeWidth: 3,
//                                         ),
//                                       )
//                                     : const Text('Get OTP'),
//                               ),
//                             ],
//                           )
//                         else
//                           Text(
//                             _responseData!['message'] ?? 'Unknown error',
//                             style: TextStyle(color: Colors.red),
//                           ),
//                       ],
//                     ),
//                   ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// import 'dart:convert'; // For jsonEncode

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class AadharInputScreen extends StatefulWidget {
//   @override
//   _AadharInputScreenState createState() => _AadharInputScreenState();
// }

// class _AadharInputScreenState extends State<AadharInputScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _aadharController = TextEditingController();
//   final TextEditingController _mobileController =
//       TextEditingController(); // Controller for mobile number
//   bool _isLoading = false; // To control the loading state
//   Map<String, dynamic>? _responseData; // To hold the parsed API response data

//   String? validateAadharNumber(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter your Aadhar number';
//     } else if (value.length != 12) {
//       return 'Aadhar number must be 12 digits';
//     } else if (!RegExp(r'^[0-9]{12}$').hasMatch(value)) {
//       return 'Aadhar number must contain only digits';
//     }
//     return null;
//   }

//   Future<void> _fetchAadharName(String aadharNumber) async {
//     setState(() {
//       _isLoading = true; // Start loading
//       _responseData = null; // Clear previous response
//     });

//     final url =
//         'https://divyangverify.pcmcdivyang.com/api/aadhar/GetAadharName?aadhaarNumber=$aadharNumber';

//     try {
//       final response = await http.get(Uri.parse(url));

//       print(
//           'Response status: ${response.statusCode}'); // Print the response status
//       print('Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         // If the server returns a 200 OK response, parse the response
//         final Map<String, dynamic> data = json.decode(response.body);
//         setState(() {
//           _responseData = data; // Store the parsed response data
//         });
//       } else {
//         setState(() {
//           _responseData = {
//             'message': 'Error: ${response.statusCode}'
//           }; // Handle error
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _responseData = {
//           'message': 'Failed to fetch data: $e'
//         }; // Handle exception
//       });
//     } finally {
//       setState(() {
//         _isLoading = false; // Stop loading
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Enter Aadhar Number'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _aadharController,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(
//                   labelText: 'Aadhar Number',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLength: 12, // Limiting input to 12 digits
//                 validator: validateAadharNumber,
//               ),
//               const SizedBox(height: 20),
//               // Show loader
//               if (_isLoading)
//                 CircularProgressIndicator()
//               else ...[
//                 // Show the submit button only if there's no response message
//                 if (_responseData == null)
//                   ElevatedButton(
//                     onPressed: () {
//                       if (_formKey.currentState!.validate()) {
//                         // If the form is valid, call the API
//                         _fetchAadharName(_aadharController.text);
//                       }
//                     },
//                     child: const Text('Submit'),
//                   ),
//                 // Show the response message if available
//                 if (_responseData != null)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         if (_responseData!['status_code'] == 200)
//                           Column(
//                             children: [
//                               // Display the full name
//                               Text(
//                                 'Full Name: ${_responseData!['data']?['full_name'] ?? 'N/A'}',
//                                 style: TextStyle(color: Colors.blue),
//                               ),
//                               const SizedBox(
//                                   height:
//                                       20), // Spacing between the name and mobile input
//                               // TextField for mobile number
//                               TextFormField(
//                                 controller: _mobileController,
//                                 keyboardType: TextInputType.phone,
//                                 decoration: const InputDecoration(
//                                   labelText: 'Enter Mobile Number',
//                                   border: OutlineInputBorder(),
//                                 ),
//                                 maxLength: 10, // Limiting input to 10 digits
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'Please enter your mobile number';
//                                   } else if (value.length != 10) {
//                                     return 'Mobile number must be 10 digits';
//                                   } else if (!RegExp(r'^[0-9]{10}$')
//                                       .hasMatch(value)) {
//                                     return 'Mobile number must contain only digits';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                               const SizedBox(
//                                   height:
//                                       20), // Spacing between the mobile input and button
//                               ElevatedButton(
//                                 onPressed: () {
//                                   // Add your Get OTP logic here
//                                   print(
//                                       'Get OTP button pressed for mobile number: ${_mobileController.text}');
//                                 },
//                                 child: const Text('Get OTP'),
//                               ),
//                             ],
//                           )
//                         else
//                           Text(
//                             _responseData!['message'] ?? 'Unknown error',
//                             style: TextStyle(color: Colors.red),
//                           ),
//                       ],
//                     ),
//                   ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




// import 'dart:convert'; // For jsonEncode

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class AadharInputScreen extends StatefulWidget {
//   @override
//   _AadharInputScreenState createState() => _AadharInputScreenState();
// }

// class _AadharInputScreenState extends State<AadharInputScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _aadharController = TextEditingController();
//   bool _isLoading = false; // To control the loading state
//   Map<String, dynamic>? _responseData; // To hold the parsed API response data

//   String? validateAadharNumber(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter your Aadhar number';
//     } else if (value.length != 12) {
//       return 'Aadhar number must be 12 digits';
//     } else if (!RegExp(r'^[0-9]{12}$').hasMatch(value)) {
//       return 'Aadhar number must contain only digits';
//     }
//     return null;
//   }

//   Future<void> _fetchAadharName(String aadharNumber) async {
//     setState(() {
//       _isLoading = true; // Start loading
//       _responseData = null; // Clear previous response
//     });

//     final url =
//         'https://divyangverify.pcmcdivyang.com/api/aadhar/GetAadharName?aadhaarNumber=$aadharNumber';

//     try {
//       final response = await http.get(Uri.parse(url));

//       print(
//           'Response status: ${response.statusCode}'); // Print the response status
//       print('Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         // If the server returns a 200 OK response, parse the response
//         final Map<String, dynamic> data = json.decode(response.body);
//         setState(() {
//           _responseData = data; // Store the parsed response data
//         });
//       } else {
//         setState(() {
//           _responseData = {
//             'message': 'Error: ${response.statusCode}'
//           }; // Handle error
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _responseData = {
//           'message': 'Failed to fetch data: $e'
//         }; // Handle exception
//       });
//     } finally {
//       setState(() {
//         _isLoading = false; // Stop loading
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Enter Aadhar Number'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _aadharController,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(
//                   labelText: 'Aadhar Number',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLength: 12, // Limiting input to 12 digits
//                 validator: validateAadharNumber,
//               ),
//               const SizedBox(height: 20),
//               // Show loader
//               if (_isLoading)
//                 CircularProgressIndicator()
//               else ...[
//                 // Show the submit button only if there's no response message
//                 if (_responseData == null)
//                   ElevatedButton(
//                     onPressed: () {
//                       if (_formKey.currentState!.validate()) {
//                         // If the form is valid, call the API
//                         _fetchAadharName(_aadharController.text);
//                       }
//                     },
//                     child: const Text('Submit'),
//                   ),
//                 // Show the response message if available
//                 if (_responseData != null)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         if (_responseData!['status_code'] == 200)
//                           Column(
//                             children: [
//                               // Ensure to access the correct keys based on your response structure
//                               Text(
//                                 'Full Name: ${_responseData!['data']?['full_name'] ?? 'N/A'}',
//                                 style: TextStyle(color: Colors.blue),
//                               ),

//                               // Add more fields as needed
//                             ],
//                           )
//                         else
//                           Text(
//                             _responseData!['message'] ?? 'Unknown error',
//                             style: TextStyle(color: Colors.red),
//                           ),
//                       ],
//                     ),
//                   ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



// import 'dart:convert'; // For jsonEncode

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class AadharInputScreen extends StatefulWidget {
//   @override
//   _AadharInputScreenState createState() => _AadharInputScreenState();
// }

// class _AadharInputScreenState extends State<AadharInputScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _aadharController = TextEditingController();
//   bool _isLoading = false; // To control the loading state
//   String? _responseMessage; // To hold the API response message

//   String? validateAadharNumber(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter your Aadhar number';
//     } else if (value.length != 12) {
//       return 'Aadhar number must be 12 digits';
//     } else if (!RegExp(r'^[0-9]{12}$').hasMatch(value)) {
//       return 'Aadhar number must contain only digits';
//     }
//     return null;
//   }

//   Future<void> _fetchAadharName(String aadharNumber) async {
//     setState(() {
//       _isLoading = true; // Start loading
//       _responseMessage = null; // Clear previous response
//     });

//     final url =
//         'https://divyangverify.pcmcdivyang.com/api/aadhar/GetAadharName?aadhaarNumber=$aadharNumber';

//     try {
//       final response = await http.get(Uri.parse(url));

//       print(
//           'Response status: ${response.statusCode}'); // Print the response status
//       print('Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         // If the server returns a 200 OK response, parse the response
//         final Map<String, dynamic> data = json.decode(response.body);
//         setState(() {
//           _responseMessage = data.toString(); // Store the response message
//         });
//       } else {
//         setState(() {
//           _responseMessage = 'Error: ${response.statusCode}'; // Handle error
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _responseMessage = 'Failed to fetch data: $e'; // Handle exception
//       });
//     } finally {
//       setState(() {
//         _isLoading = false; // Stop loading
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Enter Aadhar Number'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _aadharController,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(
//                   labelText: 'Aadhar Number',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLength: 12, // Limiting input to 12 digits
//                 validator: validateAadharNumber,
//               ),
//               const SizedBox(height: 20),
//               // Show loader
//               if (_isLoading)
//                 CircularProgressIndicator()
//               else ...[
//                 // Show the submit button only if there's no response message
//                 if (_responseMessage == null)
//                   ElevatedButton(
//                     onPressed: () {
//                       if (_formKey.currentState!.validate()) {
//                         // If the form is valid, call the API
//                         _fetchAadharName(_aadharController.text);
//                       }
//                     },
//                     child: const Text('Submit'),
//                   ),
//                 // Show the response message if available
//                 if (_responseMessage != null)
//                   Text(
//                     _responseMessage!,
//                     style: TextStyle(color: Colors.blue),
//                   ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';

// class AadharInputScreen extends StatefulWidget {
//   @override
//   _AadharInputScreenState createState() => _AadharInputScreenState();
// }

// class _AadharInputScreenState extends State<AadharInputScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _aadharController = TextEditingController();

//   String? validateAadharNumber(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter your Aadhar number';
//     } else if (value.length != 12) {
//       return 'Aadhar number must be 12 digits';
//     } else if (!RegExp(r'^[0-9]{12}$').hasMatch(value)) {
//       return 'Aadhar number must contain only digits';
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Enter Aadhar Number'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _aadharController,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(
//                   labelText: 'Aadhar Number',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLength: 12, // Limiting input to 12 digits
//                 validator: validateAadharNumber,
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     // If the form is valid, display a snackbar or perform the action
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Aadhar number is valid!')),
//                     );
//                   }
//                 },
//                 child: const Text('Submit'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
