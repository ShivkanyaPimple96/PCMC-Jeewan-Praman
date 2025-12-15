import 'package:flutter/material.dart';
import 'package:pcmc_jeevan_praman/life_certificate_screens/aadhar_detailes_screen.dart';
import 'package:pcmc_jeevan_praman/life_certificate_screens/capture_photo_screen.dart';
import 'package:pcmc_jeevan_praman/life_certificate_screens/view_certificate.dart';

class ViewButtonScreen extends StatefulWidget {
  final int statusCode;
  final String messageCode;
  final String message;
  final String verificationStatus;
  final String fullName;
  final String mobileNumber;
  final String address;
  final String createdAt;
  final String verificationStatusNote;
  final String aadharNumber;
  final String url;
  final String dateOfBirth;
  final String ppoNumber;
  final String pensionType;

  ViewButtonScreen({
    required this.statusCode,
    required this.messageCode,
    required this.message,
    required this.verificationStatus,
    required this.fullName,
    required this.mobileNumber,
    required this.address,
    required this.createdAt,
    required this.verificationStatusNote,
    required this.aadharNumber,
    required this.url,
    required this.dateOfBirth,
    required this.ppoNumber,
    required this.pensionType,
  });

  @override
  _ViewButtonScreenState createState() => _ViewButtonScreenState();
}

class _ViewButtonScreenState extends State<ViewButtonScreen> {
  TextEditingController inputFieldOneController = TextEditingController();
  final List<String> dropdownItems =
      List.generate(10, (index) => 'note${index + 1}');
  String? selectedDropdownValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF92B7F7),
        title: Center(
          child: Text(
            'Pensioner Details [Step-2]',
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xFF92B7F7),
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.verificationStatus == "Kyc Approved")
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 24),
                        SizedBox(width: 8),
                        Text(
                          "Your KYC Is Completed",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 16),
                  _buildTextField('PPO Number(पीपीओ नंबर):', widget.ppoNumber),
                  Divider(thickness: 1, color: Colors.grey[300]),
                  _buildTextField('Full Name(पूर्ण नाव):', widget.fullName),
                  Divider(thickness: 1, color: Colors.grey[300]),
                  _buildTextField(
                      'Aadhar Number(आधार नंबर):', widget.aadharNumber),
                  Divider(thickness: 1, color: Colors.grey[300]),
                  _buildTextField(
                      'Pension Type(पेन्शन प्रकार):', widget.pensionType),
                  Divider(thickness: 1, color: Colors.grey[300]),
                  _buildTextField('Address(पत्ता):', widget.address),
                  Divider(thickness: 1, color: Colors.grey[300]),
                  // _buildTextField(
                  //     'Date of Birth(जन्मतारीख):', widget.dateOfBirth),
                  // Divider(thickness: 1, color: Colors.grey[300]),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.all(12), // Adjust padding as needed
              decoration: BoxDecoration(
                color: Colors.white, // Change background color if needed
                borderRadius:
                    BorderRadius.circular(8), // Optional rounded corners
                border: Border.all(
                  color: Color(0xFF92B7F7),
                  width: 2.0,
                ), // Optional border
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField('Verification Status(पडताळणी ची सद्यस्थिती):',
                      widget.verificationStatus),
                  Divider(thickness: 1, color: Colors.grey[300]),
                  // _buildTextField(
                  //     'Verification Status Note(पडताळणी बद्दल अधिक माहिती):',
                  //     widget.verificationStatusNote),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    if (widget.verificationStatus == "Kyc Approved" ||
        widget.verificationStatus.isEmpty) {
      return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhotoClickScreen(
                ppoNumber: widget.ppoNumber,
                aadhaarNumber: widget.aadharNumber,
                mobileNumber: widget.mobileNumber,

                //
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 8),
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 5,
          shadowColor: Colors.blue.withOpacity(0.3),
        ),
        child: Text(
          "Generate Your Life Certificate\nजीवन प्रमाणपत्र तयार करा",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      );
    } else if (widget.verificationStatus == "Rekyc") {
      return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AadharDetailsScreen(
                ppoNumber: widget.ppoNumber,
                fullName: widget.fullName,
                aadharNumber: widget.aadharNumber,
                address: widget.address,
                dateOfBirth: widget.dateOfBirth,
                verificationStatusNote: widget.verificationStatusNote,
                verificationStatus: widget.verificationStatus,
                statusCode: widget.statusCode,
                messageCode: widget.messageCode,
                message: widget.message,
                mobileNumber: widget.mobileNumber,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 8),
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 5,
          shadowColor: Colors.orange.withOpacity(0.3),
        ),
        child: const Text(
          "Complete Your KYC",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    } else if (widget.verificationStatus == "Verification In Progress") {
      return ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 28,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Verification Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                content: Text(
                  'Your verification is in progress.\nतुमची पडताळणी प्रक्रियेत आहे.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 8),
          backgroundColor: Colors.lightBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          // elevation: 5,
          // shadowColor: const Color.fromARGB(255, 22, 121, 160).withOpacity(0.3),
        ),
        child: const Text(
          "Verification In Progress\nपडताळणी प्रगतीपथावर आहे",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      );
    } else if (widget.verificationStatus == "Application Approved") {
      return ElevatedButton(
        onPressed: () {
          // In your button onPressed
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => CertificateWebViewScreen(url: widget.url),
            ),
            (route) => false, // Removes all previous routes
          );
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => CertificateWebViewScreen(url: widget.url),
          //   ),
          // );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 8),
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 5,
          shadowColor: Colors.grey.withOpacity(0.3),
        ),
        child: const Text(
          "View Certificate\nप्रमाणपत्र पहा",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      );
    } else if (widget.verificationStatus == "Application Rejected") {
      return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhotoClickScreen(
                ppoNumber: widget.ppoNumber,
                aadhaarNumber: widget.aadharNumber,
                mobileNumber: widget.mobileNumber,

                //
              ),
            ),
          );
        },
        // onPressed: () {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => AadharVerificationScreen(
        //         ppoNumber: widget.ppoNumber,
        //         fullName: widget.fullName,
        //         aadharNumber: widget.aadharNumber,
        //         mobileNumber: widget.mobileNumber,
        //         address: widget.address,
        //         dateOfBirth: widget.dateOfBirth,
        //         verificationStatusNote: widget.verificationStatusNote,
        //         inputFieldOneValue:
        //             inputFieldOneController.text, // Get value from input field
        //         selectedDropdownValue:
        //             selectedDropdownValue, // Pass selected dropdown value
        //       ),
        //     ),
        //   );
        //   // Navigator.push(
        //   //     context,
        //   //     MaterialPageRoute(
        //   //       builder: (context) => PhotoClickScreen(
        //   //         aadhaarNumber: widget.aadharNumber,
        //   //         inputFieldOneValue: '',
        //   //       ),
        //   //     ));
        // },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 8),
          backgroundColor: Colors.orangeAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 5,
          shadowColor: Colors.grey.withOpacity(0.3),
        ),
        child: Text(
          "Re-Generate Your Certificate\nपुन्हा जीवन प्रमाणपत्र तयार करा",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return Container(); // Return an empty container if no status matches
    }
  }

  Widget _buildTextField(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
