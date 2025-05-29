import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pcmc_jeevan_praman/KYC_Screens/pensioner_detailes_screen.dart';

class EnterMobileNumberScreen extends StatefulWidget {
  final String ppoNumber;
  const EnterMobileNumberScreen({super.key, required this.ppoNumber});

  @override
  _EnterMobileNumberScreenState createState() =>
      _EnterMobileNumberScreenState();
}

class _EnterMobileNumberScreenState extends State<EnterMobileNumberScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isMobileSubmitted = false;
  final String _fullName = 'Shivani Rajendra Pimple';

// added enter mobile screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Enter Mobile Number  [Step-1]',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
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
              // Center(
              //   child: Container(
              //     height: 60,
              //     width: 300,
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.circular(10),
              //       border:
              //           Border.all(color: const Color(0xFF92B7F7), width: 2),
              //     ),
              //     child: Padding(
              //       padding: const EdgeInsets.symmetric(horizontal: 12),
              //       child: TextFormField(
              //         controller: _mobileController,
              //         enabled: !_isMobileSubmitted,
              //         keyboardType: TextInputType.phone,
              //         inputFormatters: [
              //           FilteringTextInputFormatter.digitsOnly,
              //           LengthLimitingTextInputFormatter(10),
              //         ],
              //         decoration: InputDecoration(
              //           border: InputBorder.none,
              //           hintText: 'Enter mobile number',
              //           hintStyle: TextStyle(color: Colors.grey[600]),
              //           // helperText: 'Must be 10 digits (numbers only)',
              //         ),
              //         validator: (value) {
              //           if (!_isMobileSubmitted) {
              //             if (value == null || value.isEmpty) {
              //               return 'Please enter mobile number';
              //             }
              //             if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
              //               return 'Invalid mobile number';
              //             }
              //           }
              //           return null;
              //         },
              //       ),
              //     ),
              //   ),
              // ),
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
                      // Center text both horizontally and vertically
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(
                        // This controls the entered text size
                        fontSize: 25, // You can increase this as needed
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
                        contentPadding:
                            EdgeInsets.zero, // Remove default padding
                        isDense: true, // Reduce vertical spacing
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
              const SizedBox(height: 30),
              Visibility(
                visible: !_isMobileSubmitted,
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _isMobileSubmitted = true;
                        });
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
                    // style: ElevatedButton.styleFrom(
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 35, vertical: 8),
                    //   backgroundColor: Color(0xFF92B7F7),
                    //   shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(10),
                    //   ),
                    //   elevation: 5,
                    //   shadowColor: Colors.grey.withOpacity(0.3),
                    // ),
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
                          // This controls the entered text size
                          fontSize: 25, // You can increase this as needed
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
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PensionerDetailesScreen(
                              fullName: _fullName,
                              ppoNumber: widget.ppoNumber,
                              mobileNumber: _mobileController.text.trim(),
                            ),
                          ),
                        );
                      }
                    },
                    // style: ElevatedButton.styleFrom(
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 35, vertical: 8),
                    //   backgroundColor: Color(0xFF92B7F7),
                    //   shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(10),
                    //   ),
                    //   elevation: 5,
                    //   shadowColor: Colors.grey.withOpacity(0.3),
                    // ),
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


// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:pcmc_jeevan_praman_with_kyc/KYC_screens/pensioner_detailes_screen.dart';

// class EnterMobileNumberScreen extends StatefulWidget {
//   final String ppoNumber;
//   const EnterMobileNumberScreen({super.key, required this.ppoNumber});

//   @override
//   _EnterMobileNumberScreenState createState() =>
//       _EnterMobileNumberScreenState();
// }

// class _EnterMobileNumberScreenState extends State<EnterMobileNumberScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _mobileController = TextEditingController();
//   final TextEditingController _otpController = TextEditingController();
//   bool _isMobileSubmitted = false;
//   final String _fullName = 'Shivani Rajendra Pimple';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Center(
//           child: Text(
//             'Enter Mobile Number',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         backgroundColor: const Color(0xFF551561),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'PPO Number: ${widget.ppoNumber}', // Use the passed PPO number
//                   // widget.ppoNumber, // Use the passed PPO number
//                   style: const TextStyle(
//                     fontSize: 16,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 Text(
//                   'Full Name: $_fullName',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blueGrey,
//                   ),
//                 ),
//                 const SizedBox(height: 40),
//                 Text(
//                   'Enter your mobile number:',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blueGrey,
//                   ),
//                 ),
//                 const SizedBox(height: 40),
//                 TextFormField(
//                   controller: _mobileController,
//                   enabled: !_isMobileSubmitted,
//                   keyboardType: TextInputType.phone,
//                   inputFormatters: [
//                     FilteringTextInputFormatter.digitsOnly,
//                     LengthLimitingTextInputFormatter(10),
//                   ],
//                   decoration: InputDecoration(
//                     labelText: 'Mobile Number',
//                     hintText: 'Enter 10-digit mobile number',
//                     border: const OutlineInputBorder(),
//                     prefixIcon: const Icon(Icons.phone),
//                     helperText: 'Must be 10 digits (numbers only)',
//                     filled: _isMobileSubmitted,
//                     fillColor: _isMobileSubmitted ? Colors.grey[200] : null,
//                   ),
//                   validator: (value) {
//                     if (!_isMobileSubmitted) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter mobile number';
//                       }
//                       if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
//                         return 'Invalid mobile number';
//                       }
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 40),
//                 Visibility(
//                   visible: !_isMobileSubmitted,
//                   child: Center(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         if (_formKey.currentState!.validate()) {
//                           setState(() {
//                             _isMobileSubmitted = true;
//                           });
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 50, vertical: 10),
//                         backgroundColor: const Color(0xFF551561),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         elevation: 5,
//                       ),
//                       child: const Text(
//                         'Submit Mobile Number\nमोबाईल नंबर सबमिट करा',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                           letterSpacing: 1.5,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//                 ),
//                 if (_isMobileSubmitted) ...[
//                   const SizedBox(height: 40),
//                   Text(
//                     'Enter OTP:',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blueGrey,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   TextFormField(
//                     controller: _otpController,
//                     keyboardType: TextInputType.number,
//                     inputFormatters: [
//                       FilteringTextInputFormatter.digitsOnly,
//                       LengthLimitingTextInputFormatter(4),
//                     ],
//                     decoration: const InputDecoration(
//                       labelText: 'Enter OTP',
//                       hintText: 'Enter 4-digit OTP',
//                       border: OutlineInputBorder(),
//                       helperText: 'Must be 4 digits',
//                     ),
//                     validator: (value) {
//                       if (_isMobileSubmitted) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter OTP';
//                         }
//                         if (value.length != 4) {
//                           return 'OTP must be 4 digits';
//                         }
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 40),
//                   Center(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         if (_formKey.currentState!.validate()) {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => PensionerDetailesScreen(
//                                 fullName: _fullName,
//                                 ppoNumber: widget.ppoNumber,
//                                 mobileNumber: _mobileController.text.trim(),
//                               ),
//                             ),
//                           );
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 50, vertical: 10),
//                         backgroundColor: const Color(0xFF551561),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         elevation: 5,
//                       ),
//                       child: const Text(
//                         'Submit OTP\nOTP सबमिट करा',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                           letterSpacing: 1.5,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _mobileController.dispose();
//     _otpController.dispose();
//     super.dispose();
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class EnterMobileNumberScreen extends StatefulWidget {
//   const EnterMobileNumberScreen({super.key});

//   @override
//   _EnterMobileNumberScreenState createState() =>
//       _EnterMobileNumberScreenState();
// }

// class _EnterMobileNumberScreenState extends State<EnterMobileNumberScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _mobileController = TextEditingController();
//   final TextEditingController _otpController = TextEditingController();
//   bool _isMobileSubmitted = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Center(
//           child: Text(
//             'Enter Mobile Number',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         backgroundColor: const Color(0xFF551561),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Full Name: Shivani Rajendra Pimple ',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blueGrey,
//               ),
//             ),
//             const SizedBox(height: 40),
//             Text(
//               'Enter your mobile number:',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blueGrey,
//               ),
//             ),
//             const SizedBox(height: 40),
//             Form(
//               key: _formKey,
//               child: TextFormField(
//                 controller: _mobileController,
//                 enabled: !_isMobileSubmitted,
//                 keyboardType: TextInputType.phone,
//                 inputFormatters: [
//                   FilteringTextInputFormatter.digitsOnly,
//                   LengthLimitingTextInputFormatter(10),
//                 ],
//                 decoration: InputDecoration(
//                   labelText: 'Mobile Number',
//                   hintText: 'Enter 10-digit mobile number',
//                   border: const OutlineInputBorder(),
//                   prefixIcon: const Icon(Icons.phone),
//                   helperText: 'Must be 10 digits (numbers only)',
//                   filled: _isMobileSubmitted,
//                   fillColor: _isMobileSubmitted ? Colors.grey[200] : null,
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter mobile number';
//                   }
//                   if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
//                     return 'Invalid mobile number';
//                   }
//                   return null;
//                 },
//               ),
//             ),
//             const SizedBox(height: 20),
//             Visibility(
//               visible: !_isMobileSubmitted,
//               child: Center(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {
//                       setState(() {
//                         _isMobileSubmitted = true;
//                       });
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 50, vertical: 10),
//                     backgroundColor: const Color(0xFF551561),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     elevation: 5,
//                   ),
//                   child: const Text(
//                     'Submit Mobile Number',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                       letterSpacing: 1.5,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             if (_isMobileSubmitted) ...[
//               const SizedBox(height: 20),
//               Text(
//                 'Enter OTP:',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blueGrey,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: _otpController,
//                 keyboardType: TextInputType.number,
//                 inputFormatters: [
//                   FilteringTextInputFormatter.digitsOnly,
//                   LengthLimitingTextInputFormatter(4),
//                 ],
//                 decoration: const InputDecoration(
//                   labelText: ' Enter OTP',
//                   hintText: 'Enter 4-digit OTP',
//                   border: OutlineInputBorder(),
//                   helperText: 'Must be 4 digits',
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) return 'Please enter OTP';
//                   if (value.length != 4) return 'OTP must be 4 digits';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 30),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {
//                       setState(() {
//                         _isMobileSubmitted = true;
//                       });
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 50, vertical: 10),
//                     backgroundColor: const Color(0xFF551561),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     elevation: 5,
//                   ),
//                   child: const Text(
//                     'Submit OTP',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                       letterSpacing: 1.5,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _mobileController.dispose();
//     _otpController.dispose();
//     super.dispose();
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class EnterMobileNumberScreen extends StatefulWidget {
//   const EnterMobileNumberScreen({super.key});

//   @override
//   _EnterMobileNumberScreenState createState() =>
//       _EnterMobileNumberScreenState();
// }

// class _EnterMobileNumberScreenState extends State<EnterMobileNumberScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _mobileController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Center(
//           child: Text(
//             'Enter Mobile Number',
//             style: TextStyle(
//               color: Colors.white, // White text color for contrast
//               fontSize: 18, // Font size for the title
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         backgroundColor: Color(0xFF551561),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Display Full Name
//             Text(
//               'Full Name: Shivani Rajendra Pimple ',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blueGrey,
//               ),
//             ),
//             SizedBox(height: 40),
//             Text(
//               'Enter your mobile number:',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blueGrey,
//               ),
//             ),
//             SizedBox(height: 40),
//             // Mobile Number Input Field
//             Form(
//               key: _formKey,
//               child: TextFormField(
//                 controller: _mobileController,
//                 keyboardType: TextInputType.phone,
//                 inputFormatters: [
//                   FilteringTextInputFormatter.digitsOnly,
//                   LengthLimitingTextInputFormatter(10),
//                 ],
//                 decoration: InputDecoration(
//                   labelText: 'Mobile Number',
//                   hintText: 'Enter 10-digit mobile number',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.phone),
//                   helperText: 'Must be 10 digits (numbers only)',
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter mobile number';
//                   }
//                   if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
//                     return 'Invalid mobile number';
//                   }
//                   return null; 
//                 },
//               ),
//             ),
//             SizedBox(height: 20),

//             // Submit Button
//             Center(
//               child: ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     // If form is valid, show success message
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Mobile number validated successfully!'),
//                         backgroundColor: Colors.green,
//                       ),
//                     );
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
//                   backgroundColor: const Color(0xFF551561),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   elevation: 5,
//                   // shadowColor: Colors.green.withOpacity(0.3),
//                 ),
//                 child: Text(
//                   'Submit Mobile Number',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                     letterSpacing: 1.5,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _mobileController.dispose();
//     super.dispose();
//   }
// }
