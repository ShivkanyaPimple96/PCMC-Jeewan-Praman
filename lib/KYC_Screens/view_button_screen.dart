// import 'package:flutter/material.dart';
// import 'package:pcmc_jeevan_praman_with_kyc/kyc_screens/aadhar_verification_screen.dart';

// class ViewButtonScreen extends StatefulWidget {
//   final int statusCode;
//   final String messageCode;
//   final String message;
//   final String verificationStatus;
//   final String fullName;
//   final String mobileNumber;
//   final String address;
//   final String createdAt;
//   final String verificationStatusNote;
//   final String aadharNumber;
//   final String url;
//   final String dateOfBirth;
//   final String gender;
//   final String profilephotoUrl;
//   final String applicationNumber;
//   final String handicaptype;
//   final String handicappercentage;
//   final String schemeName;
//   final String applicantPhotoUrl;
//   final String age;

//   ViewButtonScreen({
//     required this.statusCode,
//     required this.messageCode,
//     required this.message,
//     required this.verificationStatus,
//     required this.fullName,
//     required this.mobileNumber,
//     required this.address,
//     required this.createdAt,
//     required this.verificationStatusNote,
//     required this.aadharNumber,
//     required this.url,
//     required this.dateOfBirth,
//     required this.gender,
//     required this.profilephotoUrl,
//     required this.applicationNumber,
//     required this.handicaptype,
//     required this.age,
//     required this.handicappercentage,
//     required this.schemeName,
//     required this.applicantPhotoUrl,
//   });

//   @override
//   _AadharDetailsScreenState createState() => _AadharDetailsScreenState();
// }

// class _AadharDetailsScreenState extends State<ViewButtonScreen> {
//   TextEditingController inputFieldOneController = TextEditingController();
//   final List<String> dropdownItems =
//       List.generate(10, (index) => 'note${index + 1}');
//   String? selectedDropdownValue;

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: const Color(0xFF551561),
//           title: const Center(
//             child: Text(
//               'Divyang Details [Step-2]',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               // Main Details Container
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFDF7FD), // Background color
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(
//                     color: const Color(0xFFEAAFEA), // Border color #EAAFEA
//                     width: 2,
//                   ),
//                   boxShadow: const [
//                     BoxShadow(
//                       color: Color(0x9B9B9BC1), // Shadow color #9B9B9BC1
//                       blurRadius: 10, // Softness of shadow
//                       spreadRadius: 0, // Spread effect
//                       offset: Offset(0, 2), // Position (x: 0, y: 2)
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     if (widget.verificationStatus == "Kyc Approved")
//                       Row(
//                         children: [
//                           Icon(Icons.check_circle,
//                               color: Colors.green, size: 24),
//                           SizedBox(width: 8),
//                           Text(
//                             "Your KYC Is Completed",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.green,
//                             ),
//                           ),
//                         ],
//                       ),
//                     SizedBox(height: 16),
//                     Center(
//                       child: widget.applicantPhotoUrl.isNotEmpty
//                           ? Image.network(
//                               widget.applicantPhotoUrl,
//                               width: 100, // Set width as needed
//                               height: 100, // Set height as needed
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) {
//                                 return const Text('Image not available');
//                               },
//                             )
//                           : const Text('No Image Available'),
//                     ),

//                     // Center(
//                     //     child: _buildTextField(
//                     //         'Profile Photo', widget.applicantPhotoUrl)),
//                     Divider(thickness: 1, color: Colors.grey[300]),
//                     _buildTextField('Full Name', widget.fullName),
//                     Divider(thickness: 1, color: Colors.grey[300]),
//                     _buildTextField('Aadhar Number', widget.aadharNumber),
//                     Divider(thickness: 1, color: Colors.grey[300]),
//                     _buildTextField('Scheme Name', widget.schemeName),
//                     Divider(thickness: 1, color: Colors.grey[300]),
//                     _buildTextField(
//                         'Application Number', widget.applicationNumber),
//                     Divider(thickness: 1, color: Colors.grey[300]),
//                     // _buildTextField('Aadhar Number', widget.aadharNumber),
//                     // Divider(thickness: 1, color: Colors.grey[300]),
//                     _buildTextField('Mobile Number', widget.mobileNumber),
//                     Divider(thickness: 1, color: Colors.grey[300]),
//                     _buildTextField('Address', widget.address),
//                     Divider(thickness: 1, color: Colors.grey[300]),
//                     _buildTextField('Date of Birth', widget.dateOfBirth),
//                     Divider(thickness: 1, color: Colors.grey[300]),
//                     Row(
//                       children: [
//                         _buildTextField('Gender', widget.gender),
//                         const SizedBox(
//                           width: 150,
//                         ),
//                         _buildTextField('Age', widget.age.toString()),
//                       ],
//                     ),
//                     // Divider(thickness: 1, color: Colors.grey[300]),
//                     // _buildTextField('Age', widget.age.toString()),
//                     Divider(thickness: 1, color: Colors.grey[300]),
//                     _buildTextField('Handicap Type', widget.handicaptype),
//                     Divider(thickness: 1, color: Colors.grey[300]),
//                     _buildTextField(
//                         'Handicap Percentage', widget.handicappercentage),
//                     Divider(thickness: 1, color: Colors.grey[300]),
//                     SizedBox(height: 16),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // New Container for Verification Status
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFDF7FD), // Background color
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(
//                     color: const Color(0xFFEAAFEA), // Border color #EAAFEA
//                     width: 2,
//                   ),
//                   boxShadow: const [
//                     BoxShadow(
//                       color: Color(0x9B9B9BC1), // Shadow color #9B9B9BC1
//                       blurRadius: 10, // Softness of shadow
//                       spreadRadius: 0, // Spread effect
//                       offset: Offset(0, 2), // Position (x: 0, y: 2)
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildTextField(
//                         'Verification Status', widget.verificationStatus),
//                     Divider(thickness: 1, color: Colors.grey[300]),
//                     _buildTextField('Verification Status Note',
//                         widget.verificationStatusNote),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 16),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   _buildActionButton(),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButton() {
//     if (widget.verificationStatus == "") {
//       return ElevatedButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => AadharVerificationScreen(
//                 fullName: widget.fullName,
//                 aadharNumber: widget.aadharNumber,
//                 mobileNumber: widget.mobileNumber,
//                 address: widget.address,
//                 dateOfBirth: widget.dateOfBirth,
//                 verificationStatusNote: widget.verificationStatusNote,
//                 inputFieldOneValue:
//                     inputFieldOneController.text, // Get value from input field
//                 selectedDropdownValue:
//                     selectedDropdownValue, // Pass selected dropdown value
//               ),
//             ),
//           );
//         },
//         style: ElevatedButton.styleFrom(
//           padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 8),
//           backgroundColor: const Color.fromARGB(255, 74, 141, 8),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           elevation: 5,
//           shadowColor: Colors.grey.withOpacity(0.3),
//         ),
//         child: Text(
//           "Generate Your Certificate",
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       );
//     } else if (widget.verificationStatus == "Verification In Progress") {
//       return ElevatedButton(
//         onPressed: () {},
//         style: ElevatedButton.styleFrom(
//           padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 8),
//           backgroundColor: const Color.fromARGB(31, 23, 23, 120),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           elevation: 5,
//           shadowColor: Colors.grey.withOpacity(0.3),
//         ),
//         child: const Text(
//           "Verification In Progress",
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       );
//     } else if (widget.verificationStatus == "Application Approved") {
//       return ElevatedButton(
//         onPressed: () {
//           // Navigator.pushAndRemoveUntil(
//           //   context,
//           //   MaterialPageRoute(
//           //     builder: (context) => CertificateWebViewScreen(url: widget.url),
//           //   ),
//           //   (Route<dynamic> route) => false,
//           // );
//           // Navigator.push(
//           //   context,
//           //   MaterialPageRoute(
//           //     builder: (context) => CertificateWebViewScreen(url: widget.url),
//           //   ),
//           // );
//         },
//         style: ElevatedButton.styleFrom(
//           padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 8),
//           backgroundColor: Colors.orange,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           elevation: 5,
//           shadowColor: Colors.grey.withOpacity(0.3),
//         ),
//         child: const Text(
//           "View Certificate",
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       );
//     } else if (widget.verificationStatus == "Application Rejected") {
//       return ElevatedButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => AadharVerificationScreen(
//                 fullName: widget.fullName,
//                 aadharNumber: widget.aadharNumber,
//                 mobileNumber: widget.mobileNumber,
//                 address: widget.address,
//                 dateOfBirth: widget.dateOfBirth,
//                 verificationStatusNote: widget.verificationStatusNote,
//                 inputFieldOneValue:
//                     inputFieldOneController.text, // Get value from input field
//                 selectedDropdownValue:
//                     selectedDropdownValue, // Pass selected dropdown value
//               ),
//             ),
//           );
//           // Navigator.push(
//           //     context,
//           //     MaterialPageRoute(
//           //       builder: (context) => PhotoClickScreen(
//           //         aadhaarNumber: widget.aadharNumber,
//           //         inputFieldOneValue: '',
//           //       ),
//           //     ));
//         },
//         style: ElevatedButton.styleFrom(
//           padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 8),
//           backgroundColor: Colors.green,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           elevation: 5,
//           shadowColor: Colors.grey.withOpacity(0.3),
//         ),
//         child: Text(
//           "Re-Generate Your Certificate",
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//       );
//     } else {
//       return Container(); // Return an empty container if no status matches
//     }
//   }

//   Widget _buildTextField(String title, String content) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.circle, // Use a circular icon as a bullet point
//                 size: 10, // Adjust the size of the icon
//                 color: Colors.grey[700], // Adjust the color of the icon
//               ),
//               const SizedBox(width: 8), // Add spacing between bullet and title
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey[700],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Text(
//             content,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
