import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pcmc_jeevan_praman/declaration_page_screen.dart';
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
  });

  @override
  _RecordedVideoScreenState createState() => _RecordedVideoScreenState();
}

class _RecordedVideoScreenState extends State<RecordedVideoScreen> {
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

  Future<void> submitVideo(BuildContext context) async {
    setState(() {
      _isLoading = true; // Start loading when the button is clicked
    });

    // Simulating a delay for processing (e.g., video compression)
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false; // Stop loading after the delay
    });

    // Navigate to another screen after the button is pressed
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeclarationPageScreen(
          ppoNumber: widget.ppoNumber,
          latitude: widget.latitude, // Pass latitude to the navigated screen
          longitude: widget.longitude,
          address: widget.address, // Pass longitude to the navigated screen
          videoPath: widget.videoPath, // Use widget.videoPath here
          recordedDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          recordedTime: DateFormat('HH:mm:ss').format(DateTime.now()),
          imagePath: widget.imagePath,
          aadhaarNumber: widget.aadhaarNumber,
        ),
      ),
    );
  }

  void showSubmitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Row(
            children: [
              Icon(Icons.video_call,
                  color: Colors.blue, size: 28), // Icon for video
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
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            ElevatedButton(
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Submit button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onPressed: () {
                // Close the dialog
                submitVideo(context); // Submit video and navigate
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Upload Video   [Step-4]',
            style: TextStyle(
              color: Colors.black, // White text color for contrast
              fontSize: 22, // Font size for the title
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Color(0xFF92B7F7),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Text("Aadhar Number: ${widget.aadhaarNumber}"),
            // Text("Input Field One Value: ${widget.inputFieldOneValue}"),
            // Text(
            //     "Selected Dropdown Value: ${widget.selectedDropdownValue ?? 'None'}"),
            const SizedBox(height: 70),
            Center(
              child: Container(
                height: 400,
                width: 350,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xFF92B7F7), // Red border color
                    width: 2.0, // Border width
                  ),
                  borderRadius: BorderRadius.circular(15), // Rounded corners
                ),
                child: Center(
                  child: _controller.value.isInitialized
                      ? Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Container(
                              width: 600, // Set your desired width
                              height: 300, // Set your desired height
                              child: AspectRatio(
                                  aspectRatio: _controller.value.aspectRatio,
                                  child: widget.isFrontCamera
                                      // this for front camera
                                      ? Transform(
                                          alignment: Alignment.center,
                                          transform: Matrix4.rotationZ(90 *
                                              (3.14159 /
                                                  45)), // Rotate 90 degrees clockwise for the front camera
                                          child: VideoPlayer(_controller),
                                        )
                                      // Transform(
                                      //     alignment: Alignment.center,
                                      //     transform: Matrix4.rotationZ(-90 *
                                      //         (3.14159 /
                                      //             180)), // Rotate 90 degrees counterclockwise for the front camera
                                      //     child: VideoPlayer(_controller),
                                      //   )
                                      // this for back cemera
                                      : Transform(
                                          alignment: Alignment.center,
                                          transform: Matrix4.rotationZ(90 *
                                              (3.14159 /
                                                  45)), // Rotate 90 degrees clockwise for the front camera
                                          child: VideoPlayer(_controller),
                                        )
                                  // Transform(
                                  //     alignment: Alignment.center,
                                  //     transform: Matrix4.rotationZ(3.14159 /
                                  //         2), // Rotate 90 degrees clockwise for the back camera
                                  //     child: VideoPlayer(_controller),
                                  //   ),
                                  ),
                            ),

                            // Positioned widget to show date and time at the top
                            Positioned(
                              top: 10, // Adjust the position as needed
                              child: Column(
                                children: [
                                  Text(
                                    'Recorded Date: ${widget.recordedDate}',
                                    style: TextStyle(
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
                      : CircularProgressIndicator(), // Show a loading indicator while the video is being initialized
                ),
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading
                  ? null // Disable the button if loading
                  : () => showSubmitConfirmationDialog(
                      context), // Show confirmation dialog
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 5,
                shadowColor: Colors.green.withOpacity(0.3),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(
                      strokeWidth: 2, // Loader stroke width
                    )
                  : const Text(
                      'Submit video\nव्हिडिओ सबमिट करा',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
            ),
            const SizedBox(height: 20),
            // Text('Latitude: ${widget.latitude}'), // Display latitude
            // Text('Longitude: ${widget.longitude}'),
            // Text('Address: ${widget.address}'), // Display longitude
            // Text("Video Path: ${widget.videoPath}"),
            // Text("Recorded Date: ${widget.recordedDate}"),
            // Text("Recorded Time: ${widget.recordedTime}"),
            // Text("Image Path: ${widget.imagePath}"),
            // Text(
            //   'Aadhaar Number: ${widget.aadhaarNumber}',
            //   style: TextStyle(fontSize: 16, color: Colors.black),
            // ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Navigate to the previous screen
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor:
                  const Color.fromARGB(255, 243, 163, 33), // Text color
              padding: EdgeInsets.symmetric(
                  vertical: 16, horizontal: 24), // Padding for size and spacing
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    12), // Rounded corners for a smoother design
              ),
              elevation: 5, // Adds shadow for a subtle 3D effect
            ),
            child: Text(
              'Re-Record video\nव्हिडिओ परत रेकॉर्ड करा',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16, // Larger text for better readability
                fontWeight: FontWeight.bold, // Bold for emphasis
              ),
            ), // Button text
          ),
          SizedBox(
            width: 22,
          ),
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
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 30,
                ),
                // Spacing between icon and text
                Text(
                  "व्हिडिओ प्ले करा",
                  style:
                      TextStyle(fontSize: 8), // Adjust the font size as needed
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
