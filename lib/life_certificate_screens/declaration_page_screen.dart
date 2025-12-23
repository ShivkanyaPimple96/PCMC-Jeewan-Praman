import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pcmc_jeevan_praman/life_certificate_screens/response_massage_screen.dart';
import 'package:video_compress/video_compress.dart';

class DeclarationPageScreen extends StatefulWidget {
  final String ppoNumber;
  final String videoPath;
  final String recordedDate;
  final String recordedTime;
  final String imagePath;
  final String aadhaarNumber;
  final String latitude;
  final String longitude;
  final String address;

  final String? hasJob;
  final String mobileNumber;

  const DeclarationPageScreen({
    super.key,
    required this.videoPath,
    required this.recordedDate,
    required this.recordedTime,
    required this.imagePath,
    required this.aadhaarNumber,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.ppoNumber,
    this.hasJob,
    required this.mobileNumber,
  });

  @override
  _DeclarationPageScreenState createState() => _DeclarationPageScreenState();
}

class _DeclarationPageScreenState extends State<DeclarationPageScreen> {
  // File? _image;
  bool isLoading = false;
  String? hasJob;
  String? hasSpouse;
  String? joberrorMessage;
  String? spouseerrorMessage;
  bool _isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController salaryDetailsTitleController =
      TextEditingController();
  final TextEditingController jobJoiningDateController =
      TextEditingController();
  final TextEditingController marriageLocationController =
      TextEditingController();
  final TextEditingController marriageDateController = TextEditingController();

  Future<File> compressImage(String imagePath) async {
    final File imageFile = File(imagePath);
    final Directory tempDir = await getTemporaryDirectory();
    final String targetPath =
        '${tempDir.path}/${basename(imagePath)}_compressed.jpg';

    final XFile? compressedImage =
        await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      targetPath,
      quality: 38,
    );

    return compressedImage != null ? File(compressedImage.path) : imageFile;
  }

  void _validateAndSubmit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      submitVideo(context);
    }
  }

  Future<void> submitVideo(BuildContext context) async {
    bool? confirmSubmission = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        final size = MediaQuery.of(context).size;
        final width = size.width;
        final height = size.height;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(width * 0.05),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle_outline,
                  color: Colors.green, size: width * 0.07),
              SizedBox(width: width * 0.025),
              Expanded(
                child: Text(
                  'Confirm Submission',
                  style: TextStyle(
                      fontSize: width * 0.05, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(thickness: 2.5),
              Text(
                'Are you sure you want to submit this certificate?\nतुम्हाला खात्री आहे की तुम्ही सर्टिफिकेट सबमिट करू इच्छिता?',
                style: TextStyle(fontSize: width * 0.04),
                textAlign: TextAlign.center,
              ),
              Divider(thickness: 2.5),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(color: Colors.red, fontSize: width * 0.04)),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            TextButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(width * 0.03),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: Text('Submit', style: TextStyle(fontSize: width * 0.04)),
            ),
          ],
        );
      },
    );

    if (confirmSubmission != true) return;

    setState(() {
      isLoading = true;
    });

    File compressedFile = await compressImage(widget.imagePath);

    try {
      final originalVideoFile = File(widget.videoPath);
      if (!await originalVideoFile.exists()) {
        setState(() => _isLoading = false);
        _showErrorDialog(
          context,
          'Note ',
          'Video file not found. Please record again.\nव्हिडिओ फाइल सापडली नाही. कृपया पुन्हा रेकॉर्ड करा.',
        );
        return;
      }

      final originalFileSize = await originalVideoFile.length();
      print('Original video size: ${originalFileSize / (1024 * 1024)} MB');

      if (originalFileSize > 50 * 1024 * 1024) {
        setState(() => _isLoading = false);
        _showErrorDialog(
          context,
          'Note',
          'Video is too large. Please record a shorter video.\nव्हिडिओ खूप मोठा आहे. कृपया एक लहान व्हिडिओ रेकॉर्ड करा',
        );
        return;
      }

      MediaInfo? compressedVideo;
      try {
        compressedVideo = await VideoCompress.compressVideo(
          widget.videoPath,
          quality: VideoQuality.LowQuality,
          deleteOrigin: false,
        );
      } catch (compressionError) {
        print('Compression error: $compressionError');
        setState(() => _isLoading = false);
        _showErrorDialog(
          context,
          'Note',
          ' Please try again.\n कृपया पुन्हा प्रयत्न करा.',
        );
        return;
      }

      if (compressedVideo == null || compressedVideo.path == null) {
        setState(() => _isLoading = false);
        _showErrorDialog(
          context,
          'Note',
          'Video submit failed. Please try again.\n कृपया पुन्हा प्रयत्न करा.',
        );
        return;
      }

      print(
          'Compressed video size: ${compressedVideo.filesize! / (1024 * 1024)} MB');

      if (compressedVideo.filesize! > 30 * 1024 * 1024) {
        setState(() => _isLoading = false);
        _showErrorDialog(
          context,
          'Note',
          'Video is too large. Please record a shorter video.\nव्हिडिओ खूप मोठा आहे. कृपया एक लहान व्हिडिओ रेकॉर्ड करा',
        );
        return;
      }

      final videoFile = File(compressedVideo.path!);
      if (!await videoFile.exists()) {
        setState(() => _isLoading = false);
        _showErrorDialog(
          context,
          'Note',
          ' video file not found. Please try again.\nव्हिडिओ फाइल सापडली नाही. कृपया पुन्हा प्रयत्न करा.',
        );
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://testingpcmcpensioner.altwise.in/api/aadhar/SubmitAadharData'),
      );

      request.fields['isHavingJob'] = hasJob ?? "";
      request.fields['isMarried'] = hasSpouse ?? "";
      request.fields['jobTitleAddress'] = jobTitleController.text;
      request.fields['salaryDetails'] = salaryDetailsTitleController.text;
      request.fields['marriageLocation'] = marriageLocationController.text;
      request.fields['jobJoiningDate'] = jobJoiningDateController.text;
      request.fields['marriageDate'] = marriageDateController.text;
      request.fields['PPONumber'] = widget.ppoNumber;
      request.fields['AadhaarNumber'] = widget.aadhaarNumber;
      request.fields['Latitude'] = widget.latitude;
      request.fields['Longitude'] = widget.longitude;
      request.fields['LiveAddress'] = widget.address;
      request.fields['MobileNumber'] = widget.mobileNumber;
      request.fields['LastSubmit'] = "Submitted";

      request.files.add(await http.MultipartFile.fromPath(
        'KycVideo',
        videoFile.path,
        filename: basename(videoFile.path),
        contentType: MediaType('video', 'mp4'),
      ));

      request.files.add(await http.MultipartFile.fromPath(
        'Selfie',
        compressedFile.path,
        filename: basename(compressedFile.path),
        contentType: MediaType('image', 'jpeg'),
      ));

      var response = await request.send().timeout(Duration(seconds: 240));

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResponseScreen(
              mobileNumber: widget.mobileNumber,
              ppoNumber: widget.ppoNumber,
              message:
                  '''You have successfully completed the process for your life certificate.
Your life certificate is currently under verification. You will receive your certificate soon. Thank you for your patience

तुम्ही तुमच्या जीवन प्रमाणपत्राची प्रक्रिया यशस्वीपणे पूर्ण केली आहे.
तुमचे जीवन प्रमाणपत्र सध्या पडताळणीखाली आहे. तुम्हाला तुमचे प्रमाणपत्र लवकरच मिळेल.
तुमच्या संयमाबद्दल धन्यवाद.''',
              success: true,
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResponseScreen(
              mobileNumber: widget.mobileNumber,
              ppoNumber: widget.ppoNumber,
              message:
                  'Failed to submit data. Please try again.\nडेटा सबमिट करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा',
              success: false,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResponseScreen(
            mobileNumber: widget.mobileNumber,
            ppoNumber: widget.ppoNumber,
            message:
                'Failed to submit data. Please try again.\nडेटा सबमिट करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा',
            success: false,
          ),
        ),
      );
    }
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(width * 0.05),
        ),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: width * 0.07),
            SizedBox(width: width * 0.025),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                    fontSize: width * 0.05, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(thickness: 2.5),
            Text(
              message,
              style: TextStyle(fontSize: width * 0.04),
              textAlign: TextAlign.center,
            ),
            Divider(thickness: 2.5),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(width * 0.03),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: TextStyle(fontSize: width * 0.04)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF92B7F7),
        title: Text(
          'Declaration    [Step-5]',
          style: TextStyle(
            color: Colors.black,
            fontSize: width * 0.055,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(width * 0.04),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(width * 0.03),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xFF92B7F7),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(width * 0.02),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'सेवानिवृत्तीनंतर महाराष्ट्र शासनाचे अधिपत्याखालील तसेच सार्वजनिक उपक्रम किंवा स्थानिक प्राधिकरणातील कोणतीही नोकरी स्विकारलेली आहे का ?',
                        style: TextStyle(
                            fontSize: width * 0.045,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: height * 0.012),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                hasJob = 'yes';
                                joberrorMessage = null;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  hasJob == 'yes' ? Colors.blue : Colors.grey,
                              padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.06,
                                  vertical: height * 0.015),
                            ),
                            child: Text('Yes',
                                style: TextStyle(fontSize: width * 0.04)),
                          ),
                          SizedBox(width: width * 0.04),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                hasJob = 'no';
                                joberrorMessage = null;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  hasJob == 'no' ? Colors.blue : Colors.grey,
                              padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.06,
                                  vertical: height * 0.015),
                            ),
                            child: Text('No',
                                style: TextStyle(fontSize: width * 0.04)),
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.01),
                      if (joberrorMessage != null)
                        Text(
                          joberrorMessage!,
                          style: TextStyle(
                              color: Colors.red, fontSize: width * 0.035),
                        ),
                      SizedBox(height: height * 0.02),
                      if (hasJob == 'yes') ...[
                        Text(
                          'कार्यरत असलेली संस्था / कार्यलयाचे नांव व पत्ता',
                          style: TextStyle(
                              fontSize: width * 0.04,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: height * 0.01),
                        TextFormField(
                          controller: jobTitleController,
                          style: TextStyle(fontSize: width * 0.04),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter your job title and address',
                            hintStyle: TextStyle(fontSize: width * 0.035),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: width * 0.03,
                                vertical: height * 0.015),
                          ),
                          validator: (value) {
                            if (hasJob == 'yes' && value!.isEmpty) {
                              return 'This field is required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: height * 0.02),
                        // Text(
                        //   'वेतन व भत्ते / मानधन इ. तपशिल',
                        //   style: TextStyle(
                        //       fontSize: width * 0.04,
                        //       fontWeight: FontWeight.bold),
                        // ),
                        // SizedBox(height: height * 0.01),
                        // TextFormField(
                        //   controller: salaryDetailsTitleController,
                        //   keyboardType: TextInputType.number,
                        //   style: TextStyle(fontSize: width * 0.04),
                        //   decoration: InputDecoration(
                        //     border: OutlineInputBorder(),
                        //     hintText: 'Enter your salary details',
                        //     hintStyle: TextStyle(fontSize: width * 0.035),
                        //     contentPadding: EdgeInsets.symmetric(
                        //         horizontal: width * 0.03,
                        //         vertical: height * 0.015),
                        //   ),
                        //   validator: (value) {
                        //     if (hasJob == 'yes' && value!.isEmpty) {
                        //       return 'This field is required';
                        //     }
                        //     return null;
                        //   },
                        // ),
                        SizedBox(height: height * 0.02),
                        Text(
                          'नवीन नियुक्तीचा दिनांक',
                          style: TextStyle(
                              fontSize: width * 0.04,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: height * 0.01),
                        GestureDetector(
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              String formattedDate =
                                  DateFormat('yyyy-MM-dd').format(pickedDate);
                              setState(() {
                                jobJoiningDateController.text = formattedDate;
                              });
                            }
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: jobJoiningDateController,
                              style: TextStyle(fontSize: width * 0.04),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Select your job joining date',
                                hintStyle: TextStyle(fontSize: width * 0.035),
                                suffixIcon: Icon(Icons.calendar_today,
                                    size: width * 0.05),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: width * 0.03,
                                    vertical: height * 0.015),
                              ),
                              validator: (value) {
                                if (hasJob == 'yes' && value!.isEmpty) {
                                  return 'This field is required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: height * 0.025),
                Container(
                  padding: EdgeInsets.all(width * 0.03),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xFF92B7F7),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(width * 0.02),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'पुनर्विवाह केला आहे का?',
                        style: TextStyle(
                            fontSize: width * 0.045,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: height * 0.012),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                hasSpouse = 'yes';
                                spouseerrorMessage = null;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: hasSpouse == 'yes'
                                  ? Colors.blue
                                  : Colors.grey,
                              padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.06,
                                  vertical: height * 0.015),
                            ),
                            child: Text('Yes',
                                style: TextStyle(fontSize: width * 0.04)),
                          ),
                          SizedBox(width: width * 0.04),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                hasSpouse = 'no';
                                spouseerrorMessage = null;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  hasSpouse == 'no' ? Colors.blue : Colors.grey,
                              padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.06,
                                  vertical: height * 0.015),
                            ),
                            child: Text('No',
                                style: TextStyle(fontSize: width * 0.04)),
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.01),
                      if (spouseerrorMessage != null)
                        Text(
                          spouseerrorMessage!,
                          style: TextStyle(
                              color: Colors.red, fontSize: width * 0.035),
                        ),
                      SizedBox(height: height * 0.02),
                      if (hasSpouse == 'yes') ...[
                        Text(
                          'ठिकाण',
                          style: TextStyle(
                              fontSize: width * 0.04,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: height * 0.01),
                        TextFormField(
                          controller: marriageLocationController,
                          style: TextStyle(fontSize: width * 0.04),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter your job title and address',
                            hintStyle: TextStyle(fontSize: width * 0.035),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: width * 0.03,
                                vertical: height * 0.015),
                          ),
                          validator: (value) {
                            if (hasSpouse == 'yes' && value!.isEmpty) {
                              return 'This field is required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: height * 0.02),
                        Text(
                          'दिनांक',
                          style: TextStyle(
                              fontSize: width * 0.04,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: height * 0.01),
                        GestureDetector(
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              String formattedDate =
                                  DateFormat('yyyy-MM-dd').format(pickedDate);
                              setState(() {
                                marriageDateController.text = formattedDate;
                              });
                            }
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: marriageDateController,
                              style: TextStyle(fontSize: width * 0.04),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Select your job joining date',
                                hintStyle: TextStyle(fontSize: width * 0.035),
                                suffixIcon: Icon(Icons.calendar_today,
                                    size: width * 0.05),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: width * 0.03,
                                    vertical: height * 0.015),
                              ),
                              validator: (value) {
                                if (hasSpouse == 'yes' && value!.isEmpty) {
                                  return 'This field is required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: height * 0.02),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(width * 0.03),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: width * 0.1, vertical: height * 0.02),
                    ),
                    onPressed: isLoading
                        ? null
                        : () {
                            setState(() {
                              if (hasJob == null) {
                                joberrorMessage = 'Please select Yes or No';
                              } else {
                                joberrorMessage = null;
                              }

                              if (hasSpouse == null) {
                                spouseerrorMessage = 'Please select Yes or No ';
                              } else {
                                spouseerrorMessage = null;
                              }

                              if (joberrorMessage == null &&
                                  spouseerrorMessage == null) {
                                _validateAndSubmit(context);
                              }
                            });
                          },
                    child: isLoading
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Please wait..\nकृपया प्रतीक्षा करा..",
                                style: TextStyle(
                                  fontSize: width * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: height * 0.015),
                              SizedBox(
                                height: width * 0.04,
                                width: width * 0.04,
                                child: CircularProgressIndicator(
                                  color: Colors.blue,
                                  strokeWidth: 3,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Submit',
                            style: TextStyle(
                                color: Colors.white, fontSize: width * 0.055),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    jobTitleController.dispose();
    marriageLocationController.dispose();
    salaryDetailsTitleController.dispose();
    jobJoiningDateController.dispose();
    marriageDateController.dispose();
    super.dispose();
  }
}
