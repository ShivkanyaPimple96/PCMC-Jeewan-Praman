import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pcmc_jeevan_praman/life_certificate_screens/declaration_page_screen.dart';
import 'package:video_player/video_player.dart';

class RecordedVideoScreen extends StatefulWidget {
  final String ppoNumber;
  final String videoPath;
  final String recordedDate;
  final String recordedTime;
  final String imagePath;
  final String aadhaarNumber;
  final String latitude;
  final String longitude;
  final String address;
  final bool isFrontCamera;
  final String mobileNumber;

  RecordedVideoScreen({
    required this.videoPath,
    required this.recordedDate,
    required this.recordedTime,
    required this.imagePath,
    required this.aadhaarNumber,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.isFrontCamera,
    required this.ppoNumber,
    required this.mobileNumber,
  });

  @override
  _RecordedVideoScreenState createState() => _RecordedVideoScreenState();
}

class _RecordedVideoScreenState extends State<RecordedVideoScreen> {
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
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(Duration(seconds: 4));

    setState(() {
      _isLoading = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeclarationPageScreen(
          ppoNumber: widget.ppoNumber,
          latitude: widget.latitude,
          longitude: widget.longitude,
          address: widget.address,
          videoPath: widget.videoPath,
          recordedDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          recordedTime: DateFormat('HH:mm:ss').format(DateTime.now()),
          imagePath: widget.imagePath,
          aadhaarNumber: widget.aadhaarNumber,
          mobileNumber: widget.mobileNumber,
        ),
      ),
    );
  }

  void showSubmitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while loading
      builder: (BuildContext dialogContext) {
        // Use StatefulBuilder to manage dialog state
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              title: Row(
                children: [
                  Icon(Icons.video_call, color: Colors.blue, size: 28),
                  SizedBox(width: 10),
                  Text(
                    'Submit Video',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(thickness: 2.5),
                  Text(
                    'Are you sure you want to submit this video?\nतुम्हाला खात्री आहे की तुम्ही हा व्हिडिओ सबमिट करू इच्छिता?',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  Divider(thickness: 2.5),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Cancel', style: TextStyle(color: Colors.red)),
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                        },
                ),
                ElevatedButton(
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          // Update dialog state to show loader
                          setDialogState(() {
                            setState(() {
                              _isLoading = true;
                            });
                          });

                          // Simulate async operation
                          await Future.delayed(Duration(seconds: 4));

                          // Close the dialog
                          Navigator.of(dialogContext).pop();

                          // Update main screen state
                          setState(() {
                            _isLoading = false;
                          });

                          // Navigate to next screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeclarationPageScreen(
                                ppoNumber: widget.ppoNumber,
                                latitude: widget.latitude,
                                longitude: widget.longitude,
                                address: widget.address,
                                videoPath: widget.videoPath,
                                recordedDate: DateFormat('yyyy-MM-dd')
                                    .format(DateTime.now()),
                                recordedTime: DateFormat('HH:mm:ss')
                                    .format(DateTime.now()),
                                imagePath: widget.imagePath,
                                aadhaarNumber: widget.aadhaarNumber,
                                mobileNumber: widget.mobileNumber,
                              ),
                            ),
                          );
                        },
                ),
              ],
            );
          },
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
          title: const Center(
            child: Text(
              'Upload Video   [Step-4]',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          backgroundColor: Color(0xFF92B7F7),
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
                    height: width * 0.60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF7FD),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Color(0xFF92B7F7),
                        width: 2.0,
                      ),
                    ),
                    child: Center(
                      child: _controller.value.isInitialized
                          ? Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: width * 0.7,
                                    height: width * 0.55,
                                    child: AspectRatio(
                                      aspectRatio:
                                          _controller.value.aspectRatio,
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
                                ),
                                Positioned(
                                  top: 10,
                                  child: Column(
                                    children: [
                                      Text(
                                        'Recorded Date: ${widget.recordedDate}',
                                        style: TextStyle(
                                          fontSize: width * 0.03,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'Recorded Time: ${widget.recordedTime}',
                                        style: TextStyle(
                                          fontSize: width * 0.03,
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
                SizedBox(height: height * 0.05),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => showSubmitConfirmationDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.1,
                        vertical: height * 0.015,
                      ),
                      minimumSize: Size(width * 0.5, 50),
                      elevation: 5,
                      shadowColor: Colors.green.withOpacity(0.3),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          )
                        : const Text(
                            'Submit video\nव्हिडिओ सबमिट करा',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
                    'Re-Record video\nव्हिडिओ परत रेकॉर्ड करा',
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
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
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
