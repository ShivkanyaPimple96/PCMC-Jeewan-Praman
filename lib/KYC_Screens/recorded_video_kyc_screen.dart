import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:path/path.dart';
import 'package:pcmc_jeevan_praman/kyc_screens/response_kyc_screen.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerKYCScreen extends StatefulWidget {
  final String videoPath;
  final String recordedDate;
  final String recordedTime;
  final String aadhaarNumber;
  final bool isFrontCamera;
  final String ppoNumber;
  final String mobileNumber;
  final String address;
  final String gender;
  // final String addressEnter;
  // final String gender;
  // final String fullName;
  final String lastSubmit;

  const VideoPlayerKYCScreen({
    super.key,
    required this.videoPath,
    required this.recordedDate,
    required this.recordedTime,
    required this.aadhaarNumber,
    required this.isFrontCamera,
    required this.ppoNumber,

    // required this.addressEnter,
    // required this.gender,
    // required this.fullName,
    required this.lastSubmit,
    required this.mobileNumber,
    required this.address,
    required this.gender,
  });

  @override
  _VideoPlayerKYCScreenState createState() => _VideoPlayerKYCScreenState();
}

class _VideoPlayerKYCScreenState extends State<VideoPlayerKYCScreen> {
  late VideoPlayerController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> submitVideo(BuildContext context) async {
    bool? confirmSubmission = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // Rounded corners
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle_outline,
                  color: Colors.green, size: 28), // Icon
              SizedBox(width: 10),
              Text(
                'Confirm Submission', // Title text
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(thickness: 2.5), // Top divider
              Text(
                'Are you sure you want to submit this Video?\nतुम्हाला खात्री आहे की तुम्ही हा व्हिडिओ सबमिट करू इच्छिता?',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              Divider(thickness: 2.5), // Bottom divider
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(false); // Return false to cancel
              },
            ),
            TextButton(
              child: Text(
                'Submit',
                style: TextStyle(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF92B7F7), // Submit button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0), // Rounded button
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true); // Return true to confirm
              },
            ),
          ],
        );
      },
    );

    // If the user cancels the submission, return early
    if (confirmSubmission != true) {
      return;
    }

    setState(() {
      _isLoading = true; // Start loading when the submission is confirmed
    });

    // try {
    //   // Compress the video
    //   final compressedVideo = await VideoCompress.compressVideo(
    //     widget.videoPath,
    //     quality: VideoQuality.MediumQuality,
    //     deleteOrigin: false,
    //   );

    //   // if (compressedVideo == null ||
    //   //     compressedVideo.filesize! > 10 * 1024 * 1024) {
    //   //   setState(() {
    //   //     _isLoading = false; // Stop loading if the video is too large
    //   //   });
    //   //   showDialog(
    //   //     context: context,
    //   //     builder: (BuildContext context) {
    //   //       return AlertDialog(
    //   //         title: Text('Note '),
    //   //         content:
    //   //             Text('Video is too large. Please record a smaller video.'),
    //   //         actions: [
    //   //           ElevatedButton(
    //   //             onPressed: () {
    //   //               Navigator.of(context).pop(); // Close the dialog
    //   //             },
    //   //             child: Text('OK'),
    //   //           ),
    //   //         ],
    //   //       );
    //   //     },
    //   //   );
    //   //   return;
    //   // }

    //   if (compressedVideo == null) {
    //     // Compression failed, check original video size
    //     final originalVideoFile = File(widget.videoPath);
    //     final originalFileSize = await originalVideoFile.length();

    //     setState(() => _isLoading = false);

    //     if (originalFileSize > 30 * 1024 * 1024) {
    //       // Original video is too large
    //       _showErrorDialog(
    //         context,
    //         'Note',
    //         'Video is too large. Please record a shorter video.\nव्हिडिओ खूप मोठा आहे. कृपया एक लहान व्हिडिओ रेकॉर्ड करा',
    //       );
    //     } else {
    //       // Compression failed for other reasons
    //       _showErrorDialog(
    //         context,
    //         'Note',
    //         'Video submit failed. Please try again.\nव्हिडिओ सबमिट करणे अयशस्वी झाले. कृपया पुन्हा प्रयत्न करा.',
    //       );
    //     }
    //     return;
    //   }

    //   if (compressedVideo.filesize! > 30 * 1024 * 1024) {
    //     setState(() => _isLoading = false);
    //     _showErrorDialog(
    //       context,
    //       'Note',
    //       'Video is too large. Please record a shorter video.\nव्हिडिओ खूप मोठा आहे. कृपया एक लहान व्हिडिओ रेकॉर्ड करा',
    //     );
    //     return;
    //   }

    try {
      // Step 1: Check if original video file exists
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

      // Step 2: Check original video size
      final originalFileSize = await originalVideoFile.length();
      print('Original video size: ${originalFileSize / (1024 * 1024)} MB');

      if (originalFileSize > 50 * 1024 * 1024) {
        // 50 MB limit for original
        setState(() => _isLoading = false);
        _showErrorDialog(
          context,
          'Note',
          'Video is too large. Please record a shorter video.\nव्हिडिओ खूप मोठा आहे. कृपया एक लहान व्हिडिओ रेकॉर्ड करा',
        );
        return;
      }

      // Step 3: Compress the video
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
          // 'Failed to compress video. Please try again.\nव्हिडिओ कॉम्प्रेस करणे अयशस्वी झाले. कृपया पुन्हा प्रयत्न करा.',
        );
        return;
      }

      // Step 4: Validate compressed video
      if (compressedVideo == null || compressedVideo.path == null) {
        setState(() => _isLoading = false);
        _showErrorDialog(
          context,
          'Note',
          'Video submit failed. Please try again.\n कृपया पुन्हा प्रयत्न करा.',
          // 'Video compression failed. Please try again.\nव्हिडिओ कॉम्प्रेशन अयशस्वी झाले. कृपया पुन्हा प्रयत्न करा.',
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

      // Step 5: Prepare video file
      final videoFile = File(compressedVideo.path!);
      if (!await videoFile.exists()) {
        setState(() => _isLoading = false);
        _showErrorDialog(
          context,
          'Note',
          // 'Compressed video file not found. Please try again.\nकॉम्प्रेस केलेली व्हिडिओ फाइल सापडली नाही. कृपया पुन्हा प्रयत्न करा.',
          ' video file not found. Please try again.\nव्हिडिओ फाइल सापडली नाही. कृपया पुन्हा प्रयत्न करा.',
        );
        return;
      }

      // final videoFile = File(compressedVideo.path!);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://testingpcmcpensioner.altwise.in/api/aadhar/submitKycData'),
      );

      // Adding fields and files to the request
      request.fields['AadhaarNumber'] = widget.aadhaarNumber;
      request.fields['PPONumber'] = widget.ppoNumber;
      request.fields['MobileNumber'] = widget.mobileNumber;
      // request.fields['Latitude'] = widget.latitude;
      // request.fields['Longitude'] = widget.longitude;
      request.fields['Address'] = widget.address;
      request.fields['Gender'] = widget.gender;
      request.fields['LastSubmit'] = "Submitted";

      // if (_image != null) {
      //   request.files.add(await http.MultipartFile.fromPath(
      //     'DivyangCertificate',
      //     _image!.path,
      //     filename: basename(_image!.path),
      //     contentType: MediaType('image', 'jpeg'),
      //   ));
      // }

      request.files.add(await http.MultipartFile.fromPath(
        'KycVideo',
        videoFile.path,
        filename: basename(videoFile.path),
        contentType: MediaType('video', 'mp4'),
      ));

      // request.files.add(await http.MultipartFile.fromPath(
      //   'Selfie',
      //   compressedFile.path,
      //   filename: basename(compressedFile.path),
      //   contentType: MediaType('image', 'jpeg'),
      // ));

      // Sending the
      var response = await request.send().timeout(Duration(seconds: 240));
      // var response = await request.send();

      setState(() {
        _isLoading = false; // Hide loader after response
      });

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResponseKYCScreen(
              message:
                  '''You have successfully completed the process for your life certificate.
Your life certificate is currently under verification. You will receive your certificate soon. Thank you for your patience

तुम्ही तुमच्या जीवन प्रमाणपत्राची प्रक्रिया यशस्वीपणे पूर्ण केली आहे.
तुमचे जीवन प्रमाणपत्र सध्या पडताळणीखाली आहे. तुम्हाला तुमचे प्रमाणपत्र लवकरच मिळेल.
तुमच्या संयमाबद्दल धन्यवाद.''',
              success: true,
            ),
          ),
        );

        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => ResponseScreen(
        //       message:
        //           'All data submitted successfully! \nसर्व डेटा यशस्वीरित्या सबमिट केला आहे',
        //       success: true,
        //     ),
        //   ),
        // );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResponseKYCScreen(
              message:
                  'Failed to submit data. Please try again.\nडेटा सबमिट करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा',
              success: false,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Hide loader on error
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResponseKYCScreen(
            message:
                'Failed to submit data. Please try again.\nडेटा सबमिट करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा',
            success: false,
          ),
        ),
      );
    }
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(thickness: 2.5),
            Text(
              message,
              style: TextStyle(fontSize: 16),
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
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
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

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Center(
            child: Text(
              'Upload Video [Step-5]',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          backgroundColor: const Color(0xFF92B7F7),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(width * 0.04),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Recorded Video',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Center(
                  child: Text(
                    'रेकॉर्ड केलेला व्हिडिओ',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: height * 0.02),
                Center(
                  child: Container(
                    width: width * 0.8,
                    height: width * 0.55,
                    // constraints: BoxConstraints(
                    //   maxWidth: 400,
                    //   maxHeight: 300,
                    // ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF7FD),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF92B7F7),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x9B9B9BC1),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _controller.value.isInitialized
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: AspectRatio(
                                aspectRatio: _controller.value.aspectRatio,
                                child: widget.isFrontCamera
                                    ? Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.rotationY(3.14159),
                                        child: VideoPlayer(_controller),
                                      )
                                    : VideoPlayer(_controller),
                              ),
                            )
                          : CircularProgressIndicator(),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.05),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => submitVideo(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF92B7F7),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.1,
                        vertical: height * 0.015,
                      ),
                      minimumSize: Size(width * 0.5, 50),
                    ),
                    child: _isLoading
                        // ? CircularProgressIndicator(
                        //     strokeWidth: 2,
                        //     color: Colors.white,
                        //   )
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
                              SizedBox(height: height * 0.005),
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
                        : const Text(
                            'Submit video\nव्हिडिओ सबमिट करा',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              letterSpacing: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                  ),
                ),
                SizedBox(height: height * 0.02),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(
          width: width,
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.08,
            vertical: height * 0.02,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 243, 163, 33),
                    padding: EdgeInsets.symmetric(
                      vertical: height * 0.015,
                      horizontal: width * 0.04,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Re-Record\nव्हिडिओ परत रेकॉर्ड करा',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: width * 0.025,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: width * 0.04),
              FloatingActionButton(
                onPressed: () async {
                  if (_controller.value.isInitialized) {
                    setState(() {
                      if (_controller.value.isPlaying) {
                        _controller.pause();
                      } else {
                        _controller.play();
                        _controller.setVolume(1.0);
                      }
                    });
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 30,
                    ),
                    Text(
                      "व्हिडिओ प्ले करा",
                      style: TextStyle(fontSize: width * 0.02),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
