import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pcmc_jeevan_praman/KYC_Screens/response_screen.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerKYCScreen extends StatefulWidget {
  final String videoPath;
  final String recordedDate;
  final String recordedTime;
  final String imagePath;
  final String aadhaarNumber;
  final String latitude;
  final String longitude;
  final String address;
  final bool isFrontCamera;

  VideoPlayerKYCScreen({
    required this.videoPath,
    required this.recordedDate,
    required this.recordedTime,
    required this.imagePath,
    required this.aadhaarNumber,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.isFrontCamera,
  });

  @override
  _VideoPlayerKYCScreenState createState() => _VideoPlayerKYCScreenState();
}

class _VideoPlayerKYCScreenState extends State<VideoPlayerKYCScreen> {
  late VideoPlayerController _controller;
  bool _isLoading = false; // Variable to track loading state

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {}); // Refresh the screen once the video is initialized
      });
  }

  @override
  void dispose() {
    _controller
        .dispose(); // Dispose of the controller when the widget is disposed
    super.dispose();
  }

  Future<File> compressImage(String imagePath) async {
    final File imageFile = File(imagePath);
    final Directory tempDir = await getTemporaryDirectory();
    final String targetPath =
        '${tempDir.path}/${basename(imagePath)}_compressed.jpg';

    final XFile? compressedImage =
        await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      targetPath,
      quality: 30, // Adjust quality as needed (0 - 100)
    );

    return compressedImage != null ? File(compressedImage.path) : imageFile;
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
                'Are you sure you want to submit this Video?\nतुम्हाला खात्री आहे की तुम्ही हा व्हिडिओ सबमिट करू इच्छिता??',
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
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Submit button color
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

    try {
      // Compress the video
      final compressedVideo = await VideoCompress.compressVideo(
        widget.videoPath,
        quality: VideoQuality.LowQuality,
        deleteOrigin: false,
      );

      if (compressedVideo == null ||
          compressedVideo.filesize! > 10 * 1024 * 1024) {
        setState(() {
          _isLoading = false; // Stop loading if the video is too large
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content:
                  Text('Video is too large. Please record a smaller video.'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      final videoFile = File(compressedVideo.path!);
      File compressedFile = await compressImage(widget.imagePath);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://divyangapi.sddpmc.in/api/aadhar/divyang'),
      );

      // Adding fields and files to the request
      request.fields['AadhaarNumber'] = widget.aadhaarNumber;
      request.fields['Latitude'] = widget.latitude;
      request.fields['Longitude'] = widget.longitude;
      request.fields['LiveAddress'] = widget.address;

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

      request.files.add(await http.MultipartFile.fromPath(
        'Selfie',
        compressedFile.path,
        filename: basename(compressedFile.path),
        contentType: MediaType('image', 'jpeg'),
      ));

      // Sending the request
      var response = await request.send();

      setState(() {
        _isLoading = false; // Hide loader after response
      });

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResponseScreen(
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
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResponseScreen(
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
          builder: (context) => ResponseScreen(
            message:
                'Failed to submit data. Please try again.\nडेटा सबमिट करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा',
            success: false,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Center(
                  child: Container(
                    height: 350,
                    width: 350,
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
                          ? Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Container(
                                  width: 600,
                                  height: 300,
                                  child: AspectRatio(
                                    aspectRatio: _controller.value.aspectRatio,
                                    child: widget.isFrontCamera
                                        ? Transform(
                                            alignment: Alignment.center,
                                            transform: Matrix4.rotationZ(
                                                90 * (3.14159 / 45)),
                                            child: VideoPlayer(_controller),
                                          )
                                        : Transform(
                                            alignment: Alignment.center,
                                            transform: Matrix4.rotationZ(
                                                90 * (3.14159 / 45)),
                                            child: VideoPlayer(_controller),
                                          ),
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  child: Column(
                                    children: [
                                      Text(
                                        'Recorded Date: ${widget.recordedDate}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'Recorded Time: ${widget.recordedTime}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : CircularProgressIndicator(),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => submitVideo(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    backgroundColor: const Color(0xFF92B7F7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(
                          strokeWidth: 2,
                        )
                      : const Text(
                          'Submit video\nव्हिडिओ सबमिट करा',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 243, 163, 33),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Re-Record\nव्हिडिओ परत रेकॉर्ड करा',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FloatingActionButton(
                onPressed: () async {
                  if (_controller.value.isInitialized) {
                    setState(() {
                      if (_controller.value.isPlaying) {
                        _controller.pause();
                      } else {
                        _controller.play();
                        // Set volume to 1.0 (maximum) when playing
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
                    const Text(
                      "व्हिडिओ प्ले करा",
                      style: TextStyle(fontSize: 8),
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
