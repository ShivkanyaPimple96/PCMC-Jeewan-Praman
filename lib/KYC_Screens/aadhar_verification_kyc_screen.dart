import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pcmc_jeevan_praman/KYC_Screens/capture_photo_kyc_screen.dart';
import 'package:pcmc_jeevan_praman/KYC_Screens/kyc_upload_aadhar_photos_screen.dart';

class AadharVerificationKYCScreen extends StatefulWidget {
  final String fullName;
  final String aadharNumber;
  final String mobileNumber;
  final String address;
  // final String dateOfBirth;
  // final String verificationStatusNote;
  // final String inputFieldOneValue;
  final String? selectedDropdownValue;
  final String ppoNumber;

  const AadharVerificationKYCScreen({
    super.key,
    required this.fullName,
    required this.aadharNumber,
    required this.mobileNumber,
    required this.address,
    // required this.dateOfBirth,
    // required this.verificationStatusNote,
    // required this.inputFieldOneValue,
    this.selectedDropdownValue,
    required this.ppoNumber,
  });

  @override
  _AadharVerificationKYCScreenState createState() =>
      _AadharVerificationKYCScreenState();
}

class _AadharVerificationKYCScreenState
    extends State<AadharVerificationKYCScreen> {
  String fetchedFullName = '';
  String verificationStatus = '';
  String clientId = '';
  String otpStatus = '';
  String profilePhotoUrl = '';
  String aadhaarName = '';
  String aadhaarAddress = '';
  String gender = '';
  String tblDivyangFullName = '';
  String tblDivyangAddress = '';

  final TextEditingController otpController = TextEditingController();
  bool isOtpFieldVisible = false;
  bool isSubmitOtpButtonVisible = true;
  bool isNextButtonVisible = false;

  // Loading state variables
  bool isVerifyingAadharLoading = false;
  bool isSubmittingOtpLoading = false;
  bool isVerificationSuccessful = false;

  // File? _frontImage;
  // File? _backImage;

  Future<void> verifyAadhar() async {
    try {
      setState(() {
        isVerifyingAadharLoading = true;
      });

      final String apiUrl =
          'https://testsddpmcapi.altwise.in/api/aadhar/GetDivyangOtpUsingAadharNumber?aadhaarNumber=${widget.aadharNumber}';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        setState(() {
          fetchedFullName = responseData['FullName'] ?? '';
          verificationStatus = responseData['VerificationStatus'] ?? '';
          clientId = responseData['ClientId'] ?? '';
          otpStatus =
              responseData['OtpSent'] == true ? 'OTP Sent' : 'OTP Not Sent';
          isOtpFieldVisible = responseData['OtpSent'] == true;
          isVerificationSuccessful = true;
        });
      } else {
        await showErrorDialog(
            'Failed to verify Aadhar number.\nआधार क्रमांकाची पडताळणी करण्यात अयशस्वी');
      }
    } catch (error) {
      await showErrorDialog(
          'Note : Please check your internet connection\nकृपया तुमचे इंटरनेट कनेक्शन तपासा.');
    } finally {
      if (mounted) {
        setState(() {
          isVerifyingAadharLoading = false;
        });
      }
    }
  }

  Future<void> submitOtp() async {
    try {
      setState(() {
        isSubmittingOtpLoading = true;
      });

      final String otp = otpController.text;
      final String apiUrl =
          'https://testsddpmcapi.altwise.in/api/aadhar/SubmitDivyangOtpUsingAadharNumberAndOtp?ClientId=$clientId&Otp=$otp&AadharNumber=${widget.aadharNumber}';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final newcombinedViewModel = responseData['newcombinedViewModel'] ?? {};
        final aadhaarDetails =
            newcombinedViewModel['tblDivyangAadharDetails'] ?? {};
        final tblDivyang = newcombinedViewModel['tblDivyangDetails'] ?? {};

        setState(() {
          otpStatus = responseData['Message'] ?? 'OTP submitted successfully';
          isSubmitOtpButtonVisible = false;
          isNextButtonVisible = true;

          profilePhotoUrl = aadhaarDetails['ProfilePhotoUrl'] ?? '';
          aadhaarName = aadhaarDetails['FullName'] ?? '';
          aadhaarAddress = aadhaarDetails['Address'] ?? '';
          gender = aadhaarDetails['Gender'] ?? '';

          tblDivyangFullName = tblDivyang['Fullname'] ?? '';
          tblDivyangAddress = tblDivyang['Address'] ?? '';
        });
      } else {
        await showErrorDialog(
            'Please Enter Correct OTP\n कृपया योग्य OTP टाका');
      }
    } catch (error) {
      await showErrorDialog(
          'Note : Please check your internet connection\nकृपया तुमचे इंटरनेट कनेक्शन तपासा.');
    } finally {
      if (mounted) {
        setState(() {
          isSubmittingOtpLoading = false;
        });
      }
    }
  }

  Future<void> showErrorDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Row(
            children: [
              SizedBox(width: 10),
              Text(
                'Note',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(thickness: 2.5),
              Text(
                message,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const Divider(thickness: 2.5),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => KycUploadAadharPhotosScreen(
                      aadhaarNumber: widget.aadharNumber,
                      lastSubmit: "",
                    ),
                  ),
                );
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Aadhar Verification [Step-3]',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF92B7F7),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF92B7F7),
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x9B9B9BC1),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.perm_identity,
                        color: Colors.blue, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Aadhar Number: ${widget.aadharNumber}',
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
              const SizedBox(height: 10),
              Center(
                  child: Text(
                'Full Name: ${widget.fullName}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )),
              const SizedBox(height: 20),
              if (!isVerificationSuccessful)
                Center(
                  child: ElevatedButton(
                    onPressed: isVerifyingAadharLoading ? null : verifyAadhar,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 35, vertical: 8),
                      backgroundColor: const Color(0xFF92B7F7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                      shadowColor: Colors.teal.withOpacity(0.3),
                    ),
                    child: isVerifyingAadharLoading
                        ? const CircularProgressIndicator(color: Colors.blue)
                        : Text(
                            "Verify Your Aadhar Number\nआधार क्रमांकाची पडताळणी करा",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                  ),
                ),
              const SizedBox(height: 20),
              if (isOtpFieldVisible) ...[
                const Text(
                  'Enter Aadhar OTP:',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF92B7F7),
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x9B9B9BC1),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: otpController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'OTP टाका',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        counterText: '',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                if (isSubmitOtpButtonVisible)
                  Center(
                    child: ElevatedButton(
                      onPressed: isSubmittingOtpLoading ? null : submitOtp,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 5),
                        backgroundColor: const Color(0xFF92B7F7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        shadowColor: Colors.teal.withOpacity(0.3),
                      ),
                      child: isSubmittingOtpLoading
                          ? const CircularProgressIndicator(color: Colors.blue)
                          : Text(
                              "Submit OTP\nOTP सबमिट करा",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                    ),
                  ),
              ],
              if (isNextButtonVisible) ...[
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color(0xFF92B7F7), width: 2),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 120.0,
                            width: 120.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                profilePhotoUrl,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Text(
                                      'Image load error',
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.0),
                                  );
                                },
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Aadhaar Name:',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  aadhaarName,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Divider(
                                  color: Colors.grey,
                                  thickness: 2,
                                ),
                                const SizedBox(height: 12.0),
                                Text(
                                  'Aadhaar Address:',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  aadhaarAddress,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Divider(
                                  color: Colors.grey,
                                  thickness: 2,
                                ),
                                const SizedBox(height: 12.0),
                                Text(
                                  'Gender:',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  gender,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhotoClickKYCScreen(
                            aadhaarNumber: widget.aadharNumber,
                            // frontImagePath: _frontImage?.path ??
                            //     '', // Provide empty string as default
                            // backImagePath: _backImage?.path ??
                            //     '', // Provide empty string as default
                            // selectedDropdownValue: widget.selectedDropdownValue,
                            lastSubmit: "",
                            // aadharNumber: widget.aadharNumber,
                          ),
                        ),
                      );
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => PhotoClickScreen(
                      //       aadhaarNumber: widget.aadharNumber,
                      //       frontImagePath: _frontImage!.path,
                      //       backImagePath: _backImage!.path,
                      //       // inputFieldOneValue: widget.inputFieldOneValue,
                      //       selectedDropdownValue: widget.selectedDropdownValue,
                      //       aadharNumber: '',
                      //     ),
                      //   ),
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      backgroundColor: const Color(0xFF92B7F7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 5,
                      shadowColor: Colors.teal.withOpacity(0.3),
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class AadharVerificationScreen extends StatefulWidget {
//   final String ppoNumber;
//   final String fullName;
//   final String mobileNumber;
//   final String aadharNumber;
//   final String address;
//   final String gender;

//   const AadharVerificationScreen({
//     super.key,
//     required this.ppoNumber,
//     required this.fullName,
//     required this.mobileNumber,
//     required this.aadharNumber,
//     required this.address,
//     required this.gender,
//   });

//   @override
//   State<AadharVerificationScreen> createState() =>
//       _AadharVerificationScreenState();
// }

// class _AadharVerificationScreenState extends State<AadharVerificationScreen> {
//   final TextEditingController otpController = TextEditingController();
//   bool isVerifyingAadharLoading = false;
//   bool isOtpFieldVisible = false;
//   bool isSubmitOtpButtonVisible = false;
//   bool isSubmittingOtpLoading = false;
//   bool isNextButtonVisible = false;

//   String profilePhotoUrl =
//       'https://via.placeholder.com/150'; // Placeholder image
//   String aadhaarName = '';
//   String aadhaarAddress = '';

//   void verifyAadhar() async {
//     setState(() {
//       isVerifyingAadharLoading = true;
//     });

//     // Simulate Aadhar verification process
//     await Future.delayed(const Duration(seconds: 2));

//     setState(() {
//       isVerifyingAadharLoading = false;
//       isOtpFieldVisible = true;
//       isSubmitOtpButtonVisible = true;
//     });
//   }

//   void submitOtp() async {
//     setState(() {
//       isSubmittingOtpLoading = true;
//     });

//     // Simulate OTP submission process
//     await Future.delayed(const Duration(seconds: 2));

//     setState(() {
//       isSubmittingOtpLoading = false;
//       isNextButtonVisible = true;
//       aadhaarName = widget.fullName;
//       aadhaarAddress = widget.address;
//     });
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
//         backgroundColor: const Color(0xFF92B7F7),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 10),
//             Container(
//               padding: const EdgeInsets.all(16.0),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: const Color(0xFF92B7F7), width: 2),
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
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text(
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
//                   border: Border.all(color: const Color(0xFF92B7F7), width: 2),
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
//                         ? const CircularProgressIndicator(color: Colors.white)
//                         : const Text(
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
//               const SizedBox(height: 30),
//               Container(
//                 padding: const EdgeInsets.all(16.0),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: const Color(0xFF92B7F7), width: 2),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.3),
//                       blurRadius: 10,
//                       offset: const Offset(0, 5),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       height: 120,
//                       width: 120,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         color: Colors.white,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.3),
//                             blurRadius: 10,
//                             offset: const Offset(0, 5),
//                           ),
//                         ],
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: Image.network(
//                           profilePhotoUrl,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) =>
//                               const Center(
//                             child: Text('Image load error',
//                                 style: TextStyle(color: Colors.redAccent)),
//                           ),
//                           loadingBuilder: (context, child, progress) =>
//                               progress == null
//                                   ? child
//                                   : const Center(
//                                       child: CircularProgressIndicator(
//                                           strokeWidth: 2)),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 20),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Aadhaar Name:',
//                               style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.grey[700])),
//                           Text(aadhaarName,
//                               style: const TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.black87)),
//                           const Divider(color: Colors.grey, thickness: 2),
//                           const SizedBox(height: 12),
//                           Text('Aadhaar Address:',
//                               style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.grey[700])),
//                           Text(aadhaarAddress,
//                               style: const TextStyle(
//                                   fontSize: 16, color: Colors.black87)),
//                           const Divider(color: Colors.grey, thickness: 2),
//                           const SizedBox(height: 12),
//                           Text('Gender:',
//                               style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.grey[700])),
//                           Text(widget.gender,
//                               style: const TextStyle(
//                                   fontSize: 16, color: Colors.black87)),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:pcmc_jeevan_praman_with_kyc/KYC_screens/capture_photo_screen.dart';

// class AadharVerificationScreen extends StatefulWidget {
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
//     try {
//       setState(() {
//         isVerifyingAadharLoading = true;
//       });

//       final String apiUrl =
//           'https://divyangapi.sddpmc.in/api/aadhar/GetDivyangOtpUsingAadharNumber?aadhaarNumber=${widget.aadharNumber}';

//       final response = await http.get(Uri.parse(apiUrl));

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseData = json.decode(response.body);

//         setState(() {
//           fetchedFullName = responseData['FullName'] ?? '';
//           verificationStatus = responseData['VerificationStatus'] ?? '';
//           clientId = responseData['ClientId'] ?? '';
//           otpStatus =
//               responseData['OtpSent'] == true ? 'OTP Sent' : 'OTP Not Sent';
//           isOtpFieldVisible = responseData['OtpSent'] == true;
//         });
//       } else {
//         await showErrorDialog(
//             'Failed to verify Aadhar number.\nआधार क्रमांकाची पडताळणी करण्यात अयशस्वी');
//       }
//     } catch (error) {
//       await showErrorDialog('An error occurred: $error');
//     } finally {
//       if (mounted) {
//         setState(() {
//           isVerifyingAadharLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> submitOtp() async {
//     try {
//       setState(() {
//         isSubmittingOtpLoading = true;
//       });

//       final String otp = otpController.text;
//       final String apiUrl =
//           'https://divyangapi.sddpmc.in/api/aadhar/SubmitDivyangOtpUsingAadharNumberAndOtp?ClientId=$clientId&Otp=$otp&AadharNumber=${widget.aadharNumber}';

//       final response = await http.get(Uri.parse(apiUrl));

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseData = json.decode(response.body);
//         final newcombinedViewModel = responseData['newcombinedViewModel'] ?? {};
//         final aadhaarDetails =
//             newcombinedViewModel['tblDivyangAadharDetails'] ?? {};
//         final tblDivyang = newcombinedViewModel['tblDivyangDetails'] ?? {};

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
//       } else {
//         await showErrorDialog(
//             'Please Enter Correct OTP\n कृपया योग्य OTP टाका');
//       }
//     } catch (error) {
//       await showErrorDialog('An error occurred: $error');
//     } finally {
//       if (mounted) {
//         setState(() {
//           isSubmittingOtpLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> showErrorDialog(String message) async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20.0),
//           ),
//           title: const Row(
//             children: [
//               SizedBox(width: 10),
//               Text(
//                 'Note',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Divider(thickness: 2.5),
//               Text(
//                 message,
//                 style: const TextStyle(fontSize: 16),
//                 textAlign: TextAlign.center,
//               ),
//               const Divider(thickness: 2.5),
//             ],
//           ),
//           actions: <Widget>[
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.0),
//                 ),
//               ),
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Ok'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           title: const Text(
//             'Aadhar Verification [Step-3]',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           backgroundColor: const Color(0xFF551561),
//         ),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 10),
//               Container(
//                 padding: const EdgeInsets.all(16.0),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(
//                     color: const Color(0xFFEAAFEA),
//                     width: 2,
//                   ),
//                   boxShadow: const [
//                     BoxShadow(
//                       color: Color(0x9B9B9BC1),
//                       blurRadius: 10,
//                       spreadRadius: 0,
//                       offset: Offset(0, 2),
//                     )
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.perm_identity,
//                         color: Colors.blue, size: 24),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: Text(
//                         'Aadhar Number: ${widget.aadharNumber}',
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Center(
//                   child: Text(
//                 'Full Name: ${widget.fullName}',
//                 style: const TextStyle(
//                   color: Colors.black,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               )),
//               const SizedBox(height: 20),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: isVerifyingAadharLoading ? null : verifyAadhar,
//                   style: ElevatedButton.styleFrom(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 35, vertical: 8),
//                     backgroundColor: const Color(0xFF551561),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     elevation: 5,
//                     shadowColor: Colors.teal.withOpacity(0.3),
//                   ),
//                   child: isVerifyingAadharLoading
//                       ? const CircularProgressIndicator(color: Colors.blue)
//                       : Text(
//                           "Verify Your Aadhar Number\nआधार क्रमांकाची पडताळणी करा",
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               if (isOtpFieldVisible) ...[
//                 const Text(
//                   'Enter Aadhar OTP:',
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: Colors.black54,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(
//                       color: const Color(0xFFEAAFEA),
//                       width: 2,
//                     ),
//                     boxShadow: const [
//                       BoxShadow(
//                         color: Color(0x9B9B9BC1),
//                         blurRadius: 10,
//                         spreadRadius: 0,
//                         offset: Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     child: TextField(
//                       controller: otpController,
//                       decoration: InputDecoration(
//                         border: InputBorder.none,
//                         hintText: 'OTP टाका',
//                         hintStyle: TextStyle(color: Colors.grey[600]),
//                         counterText: '',
//                       ),
//                       keyboardType: TextInputType.number,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 40),
//                 if (isSubmitOtpButtonVisible)
//                   Center(
//                     child: ElevatedButton(
//                       onPressed: isSubmittingOtpLoading ? null : submitOtp,
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 30, vertical: 5),
//                         backgroundColor: const Color(0xFF551561),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         elevation: 5,
//                         shadowColor: Colors.teal.withOpacity(0.3),
//                       ),
//                       child: isSubmittingOtpLoading
//                           ? const CircularProgressIndicator(color: Colors.blue)
//                           : Text(
//                               "Submit OTP\nOTP सबमिट करा",
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                     ),
//                   ),
//               ],
//               if (isNextButtonVisible) ...[
//                 Container(
//                   padding: const EdgeInsets.all(16.0),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: Colors.purple, width: 2),
//                   ),
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 20),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             height: 120.0,
//                             width: 120.0,
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(10),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.grey.withOpacity(0.3),
//                                   spreadRadius: 2,
//                                   blurRadius: 10,
//                                   offset: const Offset(0, 5),
//                                 ),
//                               ],
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(10),
//                               child: Image.network(
//                                 profilePhotoUrl,
//                                 errorBuilder: (context, error, stackTrace) {
//                                   return const Center(
//                                     child: Text(
//                                       'Image load error',
//                                       style: TextStyle(color: Colors.redAccent),
//                                     ),
//                                   );
//                                 },
//                                 loadingBuilder:
//                                     (context, child, loadingProgress) {
//                                   if (loadingProgress == null) return child;
//                                   return const Center(
//                                     child: CircularProgressIndicator(
//                                         strokeWidth: 2.0),
//                                   );
//                                 },
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 20),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Aadhaar Name:',
//                                   style: TextStyle(
//                                     fontSize: 16.0,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.grey[700],
//                                   ),
//                                 ),
//                                 Text(
//                                   aadhaarName,
//                                   style: const TextStyle(
//                                     fontSize: 18.0,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.black87,
//                                   ),
//                                 ),
//                                 const Divider(
//                                   color: Colors.grey,
//                                   thickness: 2,
//                                 ),
//                                 const SizedBox(height: 12.0),
//                                 Text(
//                                   'Aadhaar Address:',
//                                   style: TextStyle(
//                                     fontSize: 16.0,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.grey[700],
//                                   ),
//                                 ),
//                                 Text(
//                                   aadhaarAddress,
//                                   style: const TextStyle(
//                                     fontSize: 16.0,
//                                     color: Colors.black87,
//                                   ),
//                                 ),
//                                 const Divider(
//                                   color: Colors.grey,
//                                   thickness: 2,
//                                 ),
//                                 const SizedBox(height: 12.0),
//                                 Text(
//                                   'Gender:',
//                                   style: TextStyle(
//                                     fontSize: 16.0,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.grey[700],
//                                   ),
//                                 ),
//                                 Text(
//                                   gender,
//                                   style: const TextStyle(
//                                     fontSize: 16.0,
//                                     color: Colors.black87,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Center(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => PhotoClickScreen(
//                             aadhaarNumber: widget.aadharNumber,
//                             inputFieldOneValue: widget.inputFieldOneValue,
//                             selectedDropdownValue: widget.selectedDropdownValue,
//                           ),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 50, vertical: 15),
//                       backgroundColor: const Color(0xFF551561),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(25),
//                       ),
//                       elevation: 5,
//                       shadowColor: Colors.teal.withOpacity(0.3),
//                     ),
//                     child: const Text(
//                       'Next',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ),
//               ],
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:convert';

// import 'package:divyank_pmc/DivyangPMC/capture_photo_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// // Import the NextScreen here

// class AadharVerificationScreen extends StatefulWidget {
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
//         'https://divyangverifydata.pcmcdivyang.com/api/aadhar/GetDivyangOtpUsingAadharNumber?aadhaarNumber=${widget.aadharNumber}';

//     try {
//       final response = await http.get(Uri.parse(apiUrl));
//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseData = json.decode(response.body);

//         setState(() {
//           fetchedFullName = responseData['FullName'] ?? '';
//           verificationStatus = responseData['VerificationStatus'] ?? '';
//           clientId = responseData['ClientId'] ?? '';
//           otpStatus =
//               responseData['OtpSent'] == true ? 'OTP Sent' : 'OTP Not Sent';
//           isOtpFieldVisible = responseData['OtpSent'] == true;
//         });
//       } else {
//         showErrorDialog(
//             'Failed to verify Aadhar number.\nआधार क्रमांकाची पडताळणी करण्यात अयशस्वी');
//       }
//     } catch (error) {
//       showErrorDialog('An error occurred: $error');
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
//         'https://divyangverifydata.pcmcdivyang.com/api/aadhar/SubmitDivyangOtpUsingAadharNumberAndOtp?ClientId=$clientId&Otp=$otp&AadharNumber=${widget.aadharNumber}';

//     try {
//       final response = await http.get(Uri.parse(apiUrl));
//       print('Submit OTP Response status: ${response.statusCode}');
//       print('Submit OTP Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseData = json.decode(response.body);

//         final newcombinedViewModel = responseData['newcombinedViewModel'] ?? {};
//         final aadhaarDetails =
//             newcombinedViewModel['tblDivyangAadharDetails'] ?? {};
//         final tblDivyang = newcombinedViewModel['tblDivyangDetails'] ?? {};

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
//       showErrorDialog('An error occurred: $error');
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
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           title: const Text(
//             'Aadhar Verification [Step-3]',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           backgroundColor: const Color(0xFF551561),
//         ),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 10),
//               Container(
//                 padding: EdgeInsets.all(16.0),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
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
//                 child: Row(
//                   children: [
//                     const Icon(Icons.perm_identity,
//                         color: Colors.blue, size: 24),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: Text(
//                         'Aadhar Number: ${widget.aadharNumber}',
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Center(
//                   child: Text(
//                 'Full Name: ${widget.fullName}',
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               )),
//               const SizedBox(height: 20),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: isVerifyingAadharLoading ? null : verifyAadhar,
//                   style: ElevatedButton.styleFrom(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 35, vertical: 8),
//                     backgroundColor: const Color(0xFF551561),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     elevation: 5,
//                     shadowColor: Colors.teal.withOpacity(0.3),
//                   ),
//                   child: isVerifyingAadharLoading
//                       ? CircularProgressIndicator(color: Colors.blue)
//                       : Text(
//                           "Verify Your Aadhar Number\nआधार क्रमांकाची पडताळणी करा",
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               if (isOtpFieldVisible) ...[
//                 const Text(
//                   'Enter Aadhar OTP:',
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: Colors.black54,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(
//                       color: const Color(0xFFEAAFEA), // Border color #EAAFEA
//                       width: 2,
//                     ),
//                     boxShadow: const [
//                       BoxShadow(
//                         color: Color(0x9B9B9BC1), // Shadow color #9B9B9BC1
//                         blurRadius: 10, // Softness of shadow
//                         spreadRadius: 0, // Spread effect
//                         offset: Offset(0, 2), // Position (x: 0, y: 2)
//                       ),
//                     ],
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     child: TextField(
//                       controller: otpController,
//                       decoration: InputDecoration(
//                         border: InputBorder.none,
//                         hintText: 'OTP टाका',
//                         hintStyle: TextStyle(color: Colors.grey[600]),
//                         counterText: '',
//                       ),
//                       keyboardType: TextInputType.number,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 40),
//                 if (isSubmitOtpButtonVisible)
//                   Center(
//                     child: ElevatedButton(
//                       onPressed: isSubmittingOtpLoading ? null : submitOtp,
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 30, vertical: 5),
//                         backgroundColor: const Color(0xFF551561),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         elevation: 5,
//                         shadowColor: Colors.teal.withOpacity(0.3),
//                       ),
//                       child: isSubmittingOtpLoading
//                           ? CircularProgressIndicator(color: Colors.blue)
//                           : Text(
//                               "Submit OTP\nOTP सबमिट करा",
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                     ),
//                   ),
//               ],
//               if (isNextButtonVisible) ...[
//                 Container(
//                   padding:
//                       EdgeInsets.all(16.0), // Adds padding to the container
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: Colors.purple, width: 2),
//                   ),
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 20), // Adds space
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Image Container with professional styling
//                           Container(
//                             height: 120.0,
//                             width: 120.0,
//                             decoration: BoxDecoration(
//                               color: Colors
//                                   .white, // Background for the image container
//                               borderRadius: BorderRadius.circular(
//                                   10), // Smooth rounded corners
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.grey
//                                       .withOpacity(0.3), // Soft shadow
//                                   spreadRadius: 2,
//                                   blurRadius: 10,
//                                   offset: Offset(0,
//                                       5), // Subtle offset for professional look
//                                 ),
//                               ],
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(
//                                   10), // Matches container's corners
//                               child: Image.network(
//                                 profilePhotoUrl,
//                                 errorBuilder: (context, error, stackTrace) {
//                                   return const Center(
//                                     child: Text(
//                                       'Image load error',
//                                       style: TextStyle(color: Colors.redAccent),
//                                     ),
//                                   );
//                                 },
//                                 loadingBuilder:
//                                     (context, child, loadingProgress) {
//                                   if (loadingProgress == null) return child;
//                                   return Center(
//                                     child: CircularProgressIndicator(
//                                         strokeWidth:
//                                             2.0), // Thinner indicator for professional feel
//                                   );
//                                 },
//                                 fit: BoxFit
//                                     .cover, // Ensures the image covers the container
//                               ),
//                             ),
//                           ),
//                           const SizedBox(
//                               width:
//                                   20), // Adds space between image and text details

//                           // Aadhaar Details with professional styling
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment
//                                   .start, // Aligns text to start
//                               children: [
//                                 Text(
//                                   'Aadhaar Name:',
//                                   style: TextStyle(
//                                     fontSize: 16.0,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors
//                                         .grey[700], // Softer color for label
//                                   ),
//                                 ),

//                                 Text(
//                                   aadhaarName,
//                                   style: const TextStyle(
//                                     fontSize: 18.0,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors
//                                         .black87, // Professional and clear text color
//                                   ),
//                                 ),
//                                 const Divider(
//                                   color: Colors
//                                       .grey, // Set the color of the divider
//                                   thickness:
//                                       2, // Set the thickness of the divider
//                                 ),
//                                 const SizedBox(
//                                     height:
//                                         12.0), // Adds space between text sections
//                                 Text(
//                                   'Aadhaar Address:',
//                                   style: TextStyle(
//                                     fontSize: 16.0,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.grey[700],
//                                   ),
//                                 ),
//                                 Text(
//                                   aadhaarAddress,
//                                   style: const TextStyle(
//                                     fontSize: 16.0,
//                                     color: Colors.black87,
//                                   ),
//                                 ),
//                                 const Divider(
//                                   color: Colors
//                                       .grey, // Set the color of the divider
//                                   thickness:
//                                       2, // Set the thickness of the divider
//                                 ),
//                                 const SizedBox(height: 12.0),
//                                 Text(
//                                   'Gender:',
//                                   style: TextStyle(
//                                     fontSize: 16.0,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.grey[700],
//                                   ),
//                                 ),
//                                 Text(
//                                   gender,
//                                   style: const TextStyle(
//                                     fontSize: 16.0,
//                                     color: Colors.black87,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20), // Adds bottom space
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Center(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => PhotoClickScreen(
//                             aadhaarNumber: widget.aadharNumber,
//                             inputFieldOneValue: widget.inputFieldOneValue,
//                             selectedDropdownValue: widget.selectedDropdownValue,
//                             //
//                           ),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 50, vertical: 15),
//                       backgroundColor: const Color(0xFF551561),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(25),
//                       ),
//                       elevation: 5,
//                       shadowColor: Colors.teal.withOpacity(0.3),
//                     ),
//                     child: const Text(
//                       'Next',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ),
//               ],
//               const SizedBox(height: 20),
//               // Text('Verification Status: $verificationStatus'),
//               // Text('OTP Status: $otpStatus'),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
