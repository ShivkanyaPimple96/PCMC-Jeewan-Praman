import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:pcmc_jeevan_praman/kyc_screens/kyc_upload_aadhar_photos_screen.dart';
import 'package:pcmc_jeevan_praman/kyc_screens/photo_click_kyc_screen.dart';

class AadharVerificationKYCScreen extends StatefulWidget {
  final String fullName;
  final String aadharNumber;
  final String mobileNumber;
  final String address;
  final String gender;
  final String ppoNumber;

  const AadharVerificationKYCScreen({
    super.key,
    required this.fullName,
    required this.aadharNumber,
    required this.mobileNumber,
    required this.address,
    required this.ppoNumber,
    required this.gender,
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
  String dateOfBirth = '';
  String pincode = '';
  String liveAddress = '';
  String verificationNote = '';

  final TextEditingController otpController = TextEditingController();
  bool isOtpFieldVisible = false;
  bool isSubmitOtpButtonVisible = true;
  bool isNextButtonVisible = false;
  bool isResponseDataVisible = false;

  // Loading state variables
  bool isVerifyingAadharLoading = false;
  bool isSubmittingOtpLoading = false;
  bool isVerificationSuccessful = false;

  Future<void> verifyAadhar() async {
    try {
      setState(() {
        isVerifyingAadharLoading = true;
      });

      final HttpClient client = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;

      final String apiUrl =
          'https://testingpcmcpensioner.altwise.in/api/aadhar/GetAadharOtp?AadhaarNumber=${widget.aadharNumber}&PPONumber=${widget.ppoNumber}';

      final request = await client.getUrl(Uri.parse(apiUrl));
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final Map<String, dynamic> responseData = json.decode(responseBody);

        print('API Response: $responseData');

        final data = responseData['data'] ?? {};

        setState(() {
          fetchedFullName = data['full_name'] ?? '';
          verificationStatus = data['VerificationStatus'] ?? '';
          clientId = data['client_id'] ?? '';
          otpStatus = data['otp_sent'] == true ? 'OTP Sent' : 'OTP Not Sent';
          isOtpFieldVisible = data['otp_sent'] == true;
          isVerificationSuccessful = true;
        });

        print('Message: ${responseData['message']}');
      } else {
        final responseBody = await response.transform(utf8.decoder).join();
        final Map<String, dynamic> errorData = json.decode(responseBody);
        // await showErrorDialog(
        //     'Failed to verify aadhar number. Please check your aadhar number is correct.\nआधार क्रमांकाची पडताळणी करण्यात अयशस्वी तुमचा आधार क्रमांक तपासा',
        //     shouldNavigate: true);
        await showErrorDialog(
            'Failed to verify aadhar number. Please check your aadhar number is correct.\nआधार क्रमांकाची पडताळणी करण्यात अयशस्वी तुमचा आधार क्रमांक तपासा',
            shouldNavigateToUploadAadhar: true);
      }
    } catch (error) {
      print('Exception in verifyAadhar: $error');
      await showErrorDialog
          // ('An error occurred: $error');
          ('Note: Please check your internet connection\nकृपया तुमचे इंटरनेट कनेक्शन तपासा.');
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

      final HttpClient client = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;

      final String apiUrl =
          'https://testingpcmcpensioner.altwise.in/api/aadhar/SubmitAadharOtp?PPONumber=${widget.ppoNumber}&ClientId=$clientId&Otp=${otpController.text}';

      final request = await client.getUrl(Uri.parse(apiUrl));
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final Map<String, dynamic> responseData = json.decode(responseBody);

        print('OTP API Response: $responseData');

        if (responseData['Success'] == true) {
          final combinedData = responseData['combinedViewModel'];
          final aadhaarDetails = combinedData['AadhaarDetails'];

          setState(() {
            profilePhotoUrl = aadhaarDetails['ProfilePhotoUrl'] ?? '';
            aadhaarName = aadhaarDetails['FullName'] ?? '';
            aadhaarAddress = aadhaarDetails['Address'] ?? '';
            gender = aadhaarDetails['Gender'] ?? '';
            dateOfBirth = aadhaarDetails['DateOfBirth'] ?? '';
            pincode = aadhaarDetails['Pincode'] ?? '';
            liveAddress = aadhaarDetails['LiveAddress'] ?? '';
            verificationStatus = aadhaarDetails['VerificationStatus'] ?? '';
            verificationNote = aadhaarDetails['VerificationNote'] ?? '';

            isResponseDataVisible = true;
            isNextButtonVisible = true;
            isSubmitOtpButtonVisible = false;
            isOtpFieldVisible = false;
          });

          await showSuccessDialog('Aadhaar verified successfully!');
        } else {
          await showErrorDialog(
              responseData['Message'] ?? 'OTP verification failed');
        }
      } else {
        final responseBody = await response.transform(utf8.decoder).join();
        final Map<String, dynamic> errorData = json.decode(responseBody);
        await showErrorDialog('Please Enter Correct OTP\n कृपया योग्य OTP टाका',
            shouldNavigateToUploadAadhar: true);
        // await showErrorDialog(
        //     'Failed to submit OTP. ${errorData['message'] ?? ''}\nOTP सबमिट करण्यात अयशस्वी');
      }
    } catch (error) {
      print('Exception in submitOtp: $error');
      await showErrorDialog
          // ('An error occurred: $error');
          ('Note: Please check your internet connection\nकृपया तुमचे इंटरनेट कनेक्शन तपासा.');
    } finally {
      if (mounted) {
        setState(() {
          isSubmittingOtpLoading = false;
        });
      }
    }
  }

  Future<void> showSuccessDialog(String message) async {
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
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text(
                'Success',
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showErrorDialog(String message,
      {bool shouldNavigate = false,
      bool shouldNavigateToUploadAadhar = false}) async {
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
                // Navigator.of(context).pop(); // Close the dialog

                // if (shouldNavigate) {
                //   // Go back one screen
                //   Navigator.of(context).pop();
                // }

                if (shouldNavigateToUploadAadhar) {
                  // Navigate to UploadAadharPhotos screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => KycUploadAadharPhotosScreen(
                        aadhaarNumber: widget.aadharNumber,
                        ppoNumber: widget.ppoNumber,
                        mobileNumber: widget.mobileNumber,
                        gender: widget.gender,
                        address: widget.address,
                        // addressEnter: widget.addressEnter,
                        // gender: widget.gender,
                        // fullName: widget.fullName,
                        lastSubmit: "",
                      ),
                    ),
                  );
                }
              },
              child: const Text('Ok', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Aadhar Verification [Step-3]',
            style: TextStyle(
              color: Colors.black,
              fontSize: width * 0.045,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF92B7F7),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.012),
              Container(
                padding: EdgeInsets.all(width * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF92B7F7), width: 2),
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
                    Icon(Icons.perm_identity,
                        color: Colors.blue, size: width * 0.06),
                    SizedBox(width: width * 0.025),
                    Expanded(
                      child: Text(
                        'Aadhar Number: ${widget.aadharNumber}',
                        style: TextStyle(
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.012),
              Center(
                  child: Text(
                'Full Name: ${widget.fullName}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: width * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              )),
              SizedBox(height: height * 0.025),
              Center(
                child: !isVerificationSuccessful
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed:
                                isVerifyingAadharLoading ? null : verifyAadhar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF92B7F7),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.1,
                                  vertical: height * 0.012),
                            ),
                            child: isVerifyingAadharLoading
                                // ? const CircularProgressIndicator(
                                //     color: Colors.white)
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Please wait..\nकृपया प्रतीक्षा करा..",
                                        style: TextStyle(
                                          fontSize: width * 0.035,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: height * 0.008),
                                      SizedBox(
                                        height: width * 0.06,
                                        width: width * 0.06,
                                        child: CircularProgressIndicator(
                                          color: Colors.blue,
                                          strokeWidth: 3,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    "Verify Your Aadhar Number\nआधार क्रमांकाची पडताळणी करा",
                                    style: TextStyle(
                                      fontSize: width * 0.045,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                          ),
                          SizedBox(height: height * 0.01),
                          // Text(
                          //   'Note : आधार सोबत लिंक असलेल्या मोबाइल क्रमांकावर आलेला OTP प्रविष्ट  करा',
                          //   style: TextStyle(
                          //     fontSize: width * 0.045,
                          //     color: Colors.red,
                          //   ),
                          //   textAlign: TextAlign.center,
                          // ),
                        ],
                      )
                    : null,
              ),
              SizedBox(height: height * 0.025),
              if (isOtpFieldVisible) ...[
                Text(
                  'Note : आधार सोबत लिंक असलेल्या मोबाइल क्रमांकावर आलेला OTP प्रविष्ट  करा',
                  style: TextStyle(
                    fontSize: width * 0.045,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Enter Aadhar OTP:',
                  style: TextStyle(
                    fontSize: width * 0.045,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: height * 0.012),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: const Color(0xFF92B7F7), width: 2),
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
                    padding: EdgeInsets.symmetric(horizontal: width * 0.03),
                    child: TextField(
                      controller: otpController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'OTP टाका',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        counterText: '',
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.025),
                if (isSubmitOtpButtonVisible)
                  Center(
                    child: ElevatedButton(
                      onPressed: isSubmittingOtpLoading ? null : submitOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF92B7F7),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: width * 0.1, vertical: height * 0.012),
                      ),
                      child: isSubmittingOtpLoading
                          // ? const CircularProgressIndicator(color: Colors.white)
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Please wait..\nकृपया प्रतीक्षा करा..",
                                  style: TextStyle(
                                    fontSize: width * 0.035,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: height * 0.008),
                                SizedBox(
                                  height: width * 0.06,
                                  width: width * 0.06,
                                  child: CircularProgressIndicator(
                                    color: Colors.blue,
                                    strokeWidth: 3,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              "Submit OTP\nOTP सबमिट करा",
                              style: TextStyle(
                                fontSize: width * 0.045,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                    ),
                  ),
              ],
              if (isResponseDataVisible) ...[
                SizedBox(height: height * 0.025),
                Text(
                  'Aadhar Details:',
                  style: TextStyle(
                    fontSize: width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Divider(),
                if (profilePhotoUrl.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(width * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xFF92B7F7), width: 2),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: height * 0.025),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: width * 0.3,
                              width: width * 0.3,
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
                                    return Center(
                                      child: Icon(Icons.error,
                                          size: width * 0.125,
                                          color: Colors.red),
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: width * 0.05),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Name:',
                                    style: TextStyle(
                                      fontSize: width * 0.04,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    aadhaarName,
                                    style: TextStyle(
                                      fontSize: width * 0.045,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const Divider(
                                    color: Colors.grey,
                                    thickness: 2,
                                  ),
                                  SizedBox(height: height * 0.015),
                                  Text(
                                    'Gender:',
                                    style: TextStyle(
                                      fontSize: width * 0.04,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    gender,
                                    style: TextStyle(
                                      fontSize: width * 0.04,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const Divider(
                                    color: Colors.grey,
                                    thickness: 2,
                                  ),
                                  SizedBox(height: height * 0.015),
                                  Text(
                                    'Aadhar Address:',
                                    style: TextStyle(
                                      fontSize: width * 0.04,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    aadhaarAddress,
                                    style: TextStyle(
                                      fontSize: width * 0.04,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.012),
                      ],
                    ),
                  ),
                SizedBox(height: height * 0.025),
              ],
              if (isNextButtonVisible) ...[
                SizedBox(height: height * 0.025),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhotoClickKYCScreen(
                            aadhaarNumber: widget.aadharNumber,
                            ppoNumber: widget.ppoNumber,
                            mobileNumber: widget.mobileNumber,
                            gender: widget.gender,
                            address: widget.address,
                            // addressEnter: widget.address
                            // addressEnter: widget.addressEnter,
                            // gender: widget.gender,
                            // fullName: widget.fullName,
                            lastSubmit: "",
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF92B7F7),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: width * 0.1, vertical: height * 0.012),
                    ),
                    child: Text(
                      'Next',
                      style: TextStyle(
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
              SizedBox(height: height * 0.025),
            ],
          ),
        ),
      ),
    );
  }
}
