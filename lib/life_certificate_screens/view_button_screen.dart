// import 'package:flutter/material.dart';
// import 'package:pcmc_jeevan_praman/life_certificate_screens/aadhar_detailes_screen.dart';
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
  final String profilePhotoUrl;

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
    required this.profilePhotoUrl,
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

                  if (widget.verificationStatus == "Kyc Approved")
                    SizedBox(height: 16),

                  // Profile photo and details row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left side - Details Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCompactTextField(
                                'PPO Number(पीपीओ नंबर):', widget.ppoNumber),
                            SizedBox(height: 12),
                            _buildCompactTextField(
                                'Full Name(पूर्ण नाव):', widget.fullName),
                            SizedBox(height: 12),
                            _buildCompactTextField('Aadhar Number(आधार नंबर):',
                                widget.aadharNumber),
                          ],
                        ),
                      ),

                      SizedBox(width: 16),

                      // Right side - Profile Photo
                      if (widget.profilePhotoUrl.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color(0xFF92B7F7),
                              width: 3.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: Image.network(
                              widget.profilePhotoUrl,
                              width: 80,
                              height: 150,
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return Container(
                                  width: 80,
                                  height: 150,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                      color: Color(0xFF92B7F7),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (BuildContext context, Object error,
                                  StackTrace? stackTrace) {
                                return Container(
                                  width: 100,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey[600],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 16),
                  Divider(thickness: 1, color: Colors.grey[300]),
                  _buildTextField(
                      'Pension Type(पेन्शन प्रकार):', widget.pensionType),
                  Divider(thickness: 1, color: Colors.grey[300]),
                  _buildTextField('Address(पत्ता):', widget.address),
                  Divider(thickness: 1, color: Colors.grey[300]),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Color(0xFF92B7F7),
                  width: 2.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField('Verification Status(पडताळणी ची सद्यस्थिती):',
                      widget.verificationStatus),
                  Divider(thickness: 1, color: Colors.grey[300]),
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

  Widget _buildCompactTextField(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          content,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
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
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => CertificateWebViewScreen(url: widget.url),
            ),
            (route) => false,
          );
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
              ),
            ),
          );
        },
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
      return Container();
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
