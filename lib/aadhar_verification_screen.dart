// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:pcmc_jeevan_praman/capture_photo_screen.dart';

// // Import the NextScreen here

// class AadharVerificationScreen extends StatefulWidget {
//   final String ppoNumber;
//   final String fullName;
//   final String aadharNumber;
//   final String mobileNumber;
//   final String address;
//   final String dateOfBirth;
//   final String verificationStatusNote;
//   final String inputFieldOneValue;
//   final String? selectedDropdownValue;

//   const AadharVerificationScreen({
//     super.key,
//     required this.fullName,
//     required this.aadharNumber,
//     required this.mobileNumber,
//     required this.address,
//     required this.dateOfBirth,
//     required this.verificationStatusNote,
//     required this.inputFieldOneValue,
//     this.selectedDropdownValue,
//     required this.ppoNumber,
//   });

//   @override
//   _AadharVerificationScreenState createState() =>
//       _AadharVerificationScreenState();
// }

// class _AadharVerificationScreenState extends State<AadharVerificationScreen> {
//   String fetchedFullName = '';
//   String verificationStatus = '';
//   String clientId = '';
//   String otpStatus = '';
//   String profilePhotoUrl = '';
//   String aadhaarName = '';
//   String aadhaarAddress = '';
//   String gender = '';
//   String tblDivyangFullName = '';
//   String tblDivyangAddress = '';

//   final TextEditingController otpController = TextEditingController();
//   bool isOtpFieldVisible = false;
//   bool isSubmitOtpButtonVisible = true;
//   bool isNextButtonVisible = false;

//   // Loading state variables
//   bool isVerifyingAadharLoading = false;
//   bool isSubmittingOtpLoading = false;

//   Future<void> verifyAadhar() async {
//     setState(() {
//       isVerifyingAadharLoading = true; // Show loader
//     });

//     final String apiUrl =
//         'https://lc.pcmcpensioner.in/api/aadhar/GetOtp?aadhaarNumber=${widget.aadharNumber}';

//     try {
//       final response = await http.get(Uri.parse(apiUrl));
//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseData = json.decode(response.body);
//         setState(() {
//           fetchedFullName = responseData['data']['full_name'] ?? '';
//           verificationStatus = responseData['data']['VerificationStatus'] ?? '';
//           clientId = responseData['data']['client_id'] ?? '';
//           otpStatus =
//               responseData['data']['otp_sent'] ? 'OTP Sent' : 'OTP Not Sent';
//           isOtpFieldVisible = true;
//         });
//       } else {
//         showErrorDialog(
//             'Failed to verify Aadhar number.\nआधार क्रमांकाची पडताळणी करण्यात अयशस्वी');
//       }
//     } catch (error) {
//       // showErrorDialog('An error occurred: $error');
//       showErrorDialog('An error occurred: पुन्हा व्हेरिफिकेशन करा');
//     } finally {
//       setState(() {
//         isVerifyingAadharLoading = false; // Hide loader
//       });
//     }
//   }

//   void submitOtp() async {
//     setState(() {
//       isSubmittingOtpLoading = true; // Show loader
//     });

//     final String otp = otpController.text;
//     final String apiUrl =
//         'https://lc.pcmcpensioner.in/api/aadhar/SubmitOtp?ClientId=$clientId&Otp=$otp&AadharNumber=${widget.aadharNumber}';

//     try {
//       final response = await http.get(Uri.parse(apiUrl));
//       print('Submit OTP Response status: ${response.statusCode}');
//       print('Submit OTP Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseData = json.decode(response.body);

//         final combinedViewModel = responseData['combinedViewModel'] ?? {};
//         final aadhaarDetails = combinedViewModel['AadhaarDetails'] ?? {};
//         final tblDivyang = combinedViewModel['TblDivyang'] ?? {};

//         setState(() {
//           otpStatus = responseData['Message'] ?? 'OTP submitted successfully';
//           isSubmitOtpButtonVisible = false;
//           isNextButtonVisible = true;

//           profilePhotoUrl = aadhaarDetails['ProfilePhotoUrl'] ?? '';
//           aadhaarName = aadhaarDetails['FullName'] ?? '';
//           aadhaarAddress = aadhaarDetails['Address'] ?? '';
//           gender = aadhaarDetails['Gender'] ?? '';

//           tblDivyangFullName = tblDivyang['Fullname'] ?? '';
//           tblDivyangAddress = tblDivyang['Address'] ?? '';
//         });
//         // showSuccessDialog('OTP Submitted Successfully!');
//       } else {
//         showErrorDialog('Please Enter Correct OTP\n कृपया योग्य OTP टाका');
//       }
//     } catch (error) {
//       showErrorDialog('An error occurred: पुन्हा व्हेरिफिकेशन करा');
//     } finally {
//       setState(() {
//         isSubmittingOtpLoading = false; // Hide loader
//       });
//     }
//   }

//   void showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20.0), // Rounded corners
//         ),
//         title: const Row(
//           children: [
//             SizedBox(width: 10), // Space between icon and text
//             Text(
//               'Note', // Title text
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Divider(thickness: 2.5), // Top divider
//             Text(
//               message, // Use the passed message
//               style: TextStyle(fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//             Divider(thickness: 2.5), // Bottom divider
//           ],
//         ),
//         actions: <Widget>[
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.green, // Submit button color
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12.0), // Rounded button
//               ),
//             ),
//             onPressed: () {
//               Navigator.of(ctx).pop(); // Close the dialog
//             },
//             child: Text('Ok'),
//           ),
//         ],
//       ),
//     );

//     // showDialog(
//     //   context: context,
//     //   builder: (ctx) => AlertDialog(
//     //     title: Text('Error'),
//     //     content: Text(message),
//     //     actions: [
//     //       TextButton(
//     //         child: Text('Okay'),
//     //         onPressed: () {
//     //           Navigator.of(ctx).pop();
//     //         },
//     //       ),
//     //     ],
//     //   ),
//     // );
//   }

//   void showSuccessDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Success'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             child: const Text('Okay'),
//             onPressed: () {
//               Navigator.of(ctx).pop();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Aadhar Verification [Step-3]',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         backgroundColor: Color(0xFF92B7F7),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 10),
//             Container(
//               padding: EdgeInsets.all(16.0),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: Color(0xFF92B7F7), width: 2),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(Icons.perm_identity, color: Colors.blue, size: 24),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Text(
//                       'Aadhar Number: ${widget.aadharNumber}',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             Center(
//               child: Text(
//                 'निवृत्ती वेतनधारका चे नाव:\n ${widget.fullName}',
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Center(
//               child: ElevatedButton(
//                 onPressed: isVerifyingAadharLoading ? null : verifyAadhar,
//                 style: ElevatedButton.styleFrom(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 35, vertical: 8),
//                   backgroundColor: Colors.green,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(25),
//                   ),
//                   elevation: 5,
//                   shadowColor: Colors.teal.withOpacity(0.3),
//                 ),
//                 child: isVerifyingAadharLoading
//                     ? CircularProgressIndicator(color: Colors.green)
//                     : Text(
//                         "Verify Your Aadhar Number\nआधार क्रमांकाची पडताळणी करा",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             if (isOtpFieldVisible) ...[
//               const Text(
//                 'Enter Aadhar OTP:',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Colors.black54,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: Color(0xFF92B7F7), width: 2),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 12),
//                   child: TextField(
//                     controller: otpController,
//                     decoration: InputDecoration(
//                       border: InputBorder.none,
//                       hintText: 'OTP टाका',
//                       hintStyle: TextStyle(color: Colors.grey[600]),
//                       counterText: '',
//                     ),
//                     keyboardType: TextInputType.number,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 40),
//               if (isSubmitOtpButtonVisible)
//                 Center(
//                   child: ElevatedButton(
//                     onPressed: isSubmittingOtpLoading ? null : submitOtp,
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 30, vertical: 5),
//                       backgroundColor: Colors.green,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(25),
//                       ),
//                       elevation: 5,
//                       shadowColor: Colors.teal.withOpacity(0.3),
//                     ),
//                     child: isSubmittingOtpLoading
//                         ? CircularProgressIndicator(color: Colors.green)
//                         : Text(
//                             "Submit OTP\nOTP सबमिट करा",
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                   ),
//                 ),
//             ],
//             if (isNextButtonVisible) ...[
//               Container(
//                 padding: EdgeInsets.all(16.0), // Adds padding to the container
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: Color(0xFF92B7F7), width: 2),
//                 ),
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 20), // Adds space
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Image Container with professional styling
//                         Container(
//                           height: 120.0,
//                           width: 120.0,
//                           decoration: BoxDecoration(
//                             color: Colors
//                                 .white, // Background for the image container
//                             borderRadius: BorderRadius.circular(
//                                 10), // Smooth rounded corners
//                             boxShadow: [
//                               BoxShadow(
//                                 color:
//                                     Colors.grey.withOpacity(0.3), // Soft shadow
//                                 spreadRadius: 2,
//                                 blurRadius: 10,
//                                 offset: Offset(0,
//                                     5), // Subtle offset for professional look
//                               ),
//                             ],
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(
//                                 10), // Matches container's corners
//                             child: Image.network(
//                               profilePhotoUrl,
//                               errorBuilder: (context, error, stackTrace) {
//                                 return const Center(
//                                   child: Text(
//                                     'Image load error',
//                                     style: TextStyle(color: Colors.redAccent),
//                                   ),
//                                 );
//                               },
//                               loadingBuilder:
//                                   (context, child, loadingProgress) {
//                                 if (loadingProgress == null) return child;
//                                 return Center(
//                                   child: CircularProgressIndicator(
//                                       strokeWidth:
//                                           2.0), // Thinner indicator for professional feel
//                                 );
//                               },
//                               fit: BoxFit
//                                   .cover, // Ensures the image covers the container
//                             ),
//                           ),
//                         ),
//                         const SizedBox(
//                             width:
//                                 20), // Adds space between image and text details

//                         // Aadhaar Details with professional styling
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment
//                                 .start, // Aligns text to start
//                             children: [
//                               Text(
//                                 'Aadhaar Name:',
//                                 style: TextStyle(
//                                   fontSize: 16.0,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors
//                                       .grey[700], // Softer color for label
//                                 ),
//                               ),

//                               Text(
//                                 aadhaarName,
//                                 style: const TextStyle(
//                                   fontSize: 18.0,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors
//                                       .black87, // Professional and clear text color
//                                 ),
//                               ),
//                               const Divider(
//                                 color:
//                                     Colors.grey, // Set the color of the divider
//                                 thickness:
//                                     2, // Set the thickness of the divider
//                               ),
//                               const SizedBox(
//                                   height:
//                                       12.0), // Adds space between text sections
//                               Text(
//                                 'Aadhaar Address:',
//                                 style: TextStyle(
//                                   fontSize: 16.0,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.grey[700],
//                                 ),
//                               ),
//                               Text(
//                                 aadhaarAddress,
//                                 style: const TextStyle(
//                                   fontSize: 16.0,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                               const Divider(
//                                 color:
//                                     Colors.grey, // Set the color of the divider
//                                 thickness:
//                                     2, // Set the thickness of the divider
//                               ),
//                               const SizedBox(height: 12.0),
//                               Text(
//                                 'Gender:',
//                                 style: TextStyle(
//                                   fontSize: 16.0,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.grey[700],
//                                 ),
//                               ),
//                               Text(
//                                 gender,
//                                 style: const TextStyle(
//                                   fontSize: 16.0,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20), // Adds bottom space
//                   ],
//                 ),
//               ),

//               // SizedBox(height: 20),
//               // Image.network(
//               //   profilePhotoUrl,
//               //   errorBuilder: (context, error, stackTrace) {
//               //     return Text('Could not load image');
//               //   },
//               //   loadingBuilder: (context, child, loadingProgress) {
//               //     if (loadingProgress == null) return child;
//               //     return Center(child: CircularProgressIndicator());
//               //   },
//               //   height: 100.0,
//               //   width: 100.0,
//               //   fit: BoxFit.cover,
//               // ),
//               // Text('Aadhaar Name: $aadhaarName'),
//               // Text('Aadhaar Address: $aadhaarAddress'),
//               // Text('Gender: $gender'),
//               const SizedBox(height: 20),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => PhotoClickScreen(
//                           ppoNumber: widget.ppoNumber,
//                           aadhaarNumber: widget.aadharNumber,

//                           //
//                         ),
//                       ),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 50, vertical: 15),
//                     backgroundColor: Colors.green,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                     elevation: 5,
//                     shadowColor: Colors.teal.withOpacity(0.3),
//                   ),
//                   child: const Text(
//                     'Next',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             ],
//             const SizedBox(height: 20),
//             // Text('Verification Status: $verificationStatus'),
//             // Text('OTP Status: $otpStatus'),
//           ],
//         ),
//       ),
//     );
//   }
// }
