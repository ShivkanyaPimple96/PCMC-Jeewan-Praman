import 'dart:async';
import 'dart:io';
import 'dart:math' show min, pi;

import 'package:camera/camera.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pcmc_jeevan_praman/KYC_Screens/recorded_video_kyc_screen.dart';

class VideoRecordKYCScreen extends StatefulWidget {
  // Constructor to receive necessary user and location details
  // final String imagePath;
  final String aadhaarNumber;
  // final String latitude;
  // final String longitude;
  // final String address;
  // final String frontImagePath;
  // final String backImagePath;
  // // final String inputFieldOneValue;
  // final String? selectedDropdownValue;
  final String lastSubmit;

  const VideoRecordKYCScreen({
    super.key,
    // required this.imagePath,
    required this.aadhaarNumber,
    // required this.latitude,
    // required this.longitude,
    // required this.address,
    // required this.inputFieldOneValue,
    // this.selectedDropdownValue,
    // required this.frontImagePath,
    // required this.backImagePath,
    required this.lastSubmit,
  });

  @override
  _VideoRecordKYCScreenState createState() => _VideoRecordKYCScreenState();
}

class _VideoRecordKYCScreenState extends State<VideoRecordKYCScreen> {
  // Camera-related variables
  late List<CameraDescription> cameras;
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  // Recording control variables
  bool isRecording = false;
  late String videoPath;
  bool _isBlinking = false;
  Timer? _blinkTimer;
  Timer? _timer;
  int _elapsedTime = 0;
  int duration = 6; // Default recording duration: 6 seconds
  bool isFrontCamera = true;

  // Device type detection
  bool? _isTablet;

  @override
  void initState() {
    super.initState();
    // Lock screen orientation to portrait during recording
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    initCamera();
  }

  // Detect if the device is a tablet
  bool isTablet(BuildContext context) {
    if (_isTablet != null) return _isTablet!;

    final shortestSide = MediaQuery.of(context).size.shortestSide;
    _isTablet = shortestSide >= 600; // Standard tablet detection
    return _isTablet!;
  }

  // Initialize available cameras
  Future<void> initCamera() async {
    cameras = await availableCameras();
    setCamera(CameraLensDirection.back); // Start with back camera
  }

  // Set camera based on lens direction
  Future<void> setCamera(CameraLensDirection direction) async {
    final selectedCamera =
        cameras.firstWhere((camera) => camera.lensDirection == direction);

    _controller = CameraController(
      selectedCamera,
      ResolutionPreset.low,
      enableAudio: false, // No audio needed
    );
    _initializeControllerFuture = _controller!.initialize();
    setState(() {});
  }

  // Toggle between front and back camera
  Future<void> switchCamera() async {
    if (isFrontCamera) {
      await setCamera(CameraLensDirection.back);
    } else {
      await setCamera(CameraLensDirection.front);
    }
    isFrontCamera = !isFrontCamera;
  }

  @override
  void dispose() {
    // Reset screen orientation and clean up timers/controllers
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _controller?.dispose();
    _blinkTimer?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  // Start recording video
  Future<void> startVideoRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      Fluttertoast.showToast(
        msg: "Camera not initialized",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    try {
      // Prepare storage path
      final Directory extDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${extDir.path}/Videos';
      await Directory(dirPath).create(recursive: true);

      final String filePath =
          '$dirPath/${DateTime.now().millisecondsSinceEpoch}.mp4';

      // Start recording
      await _controller!.startVideoRecording();
      setState(() {
        isRecording = true;
        videoPath = filePath;
        _elapsedTime = 0;
      });

      _startBlinking(); // Red blinking indicator
      _startTimer(); // Show recording time counter

      // Wait until desired duration completes
      await Future.delayed(Duration(seconds: duration));

      // Stop recording and save file
      final XFile videoFile = await _controller!.stopVideoRecording();
      final File recordedFile = File(videoFile.path);
      await recordedFile.copy(filePath); // Save video
      await recordedFile.delete(); // Remove temporary file

      setState(() {
        isRecording = false;
        videoPath = filePath;
      });

      _stopBlinking();
      _timer?.cancel();

      Fluttertoast.showToast(
        msg: "Video Recorded!",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      // Navigate to video preview screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerKYCScreen(
            // latitude: widget.latitude,
            // longitude: widget.longitude,
            // address: widget.address,
            videoPath: videoPath,
            recordedDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            recordedTime: DateFormat('HH:mm:ss').format(DateTime.now()),
            // imagePath: widget.imagePath,
            aadhaarNumber: widget.aadhaarNumber,
            isFrontCamera: isFrontCamera,
            // frontImagePath: widget.frontImagePath, // Pass front image path
            // backImagePath: widget.backImagePath, // Pass back image path
            // // inputFieldOneValue: widget.inputFieldOneValue,
            // selectedDropdownValue: widget.selectedDropdownValue,
            lastSubmit: "",
          ),
        ),
      );
    } catch (e) {
      print('Error recording video: $e');

      if (isRecording) {
        try {
          await _controller!.stopVideoRecording();
        } catch (stopError) {
          print('Error stopping video after failure: $stopError');
        }

        setState(() {
          isRecording = false;
        });

        _stopBlinking();
        _timer?.cancel();

        await SystemChrome.setPreferredOrientations(DeviceOrientation.values);

        Fluttertoast.showToast(
          msg:
              "Recording failed: ${e.toString().substring(0, min(50, e.toString().length))}",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  // Stop recording manually (not used in auto recording flow)
  Future<void> stopVideoRecording() async {
    if (_controller == null || !_controller!.value.isRecordingVideo) return;

    try {
      final XFile videoFile = await _controller!.stopVideoRecording();
      setState(() {
        isRecording = false;
        videoPath = videoFile.path;
      });

      _stopBlinking();
      _timer?.cancel();
    } catch (e) {
      print('Error stopping video recording: $e');
    }
  }

  // Red blinking indicator for recording
  void _startBlinking() {
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _isBlinking = !_isBlinking;
      });
    });
  }

  void _stopBlinking() {
    _blinkTimer?.cancel();
    setState(() {
      _isBlinking = false;
    });
  }

  // Timer to track elapsed recording time
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime++;
      });

      if (_elapsedTime >= duration) {
        _timer?.cancel();
      }
    });
  }

  // Widget to display camera preview properly with tablet rotation
  Widget _buildCameraPreview() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final bool deviceIsTablet = isTablet(context);
    final preview = CameraPreview(_controller!);
    final previewSize = _controller!.value.previewSize!;
    final cameraAspectRatio = previewSize.height / previewSize.width;

    Widget previewWidget;

    if (deviceIsTablet) {
      // For tablets - rotate 90 degrees to the left (-pi/2 radians)
      previewWidget = Transform.rotate(
        angle: pi + pi, // -90 degrees (rotate left)
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: AspectRatio(
            aspectRatio:
                1 / cameraAspectRatio, // Inverse ratio for 90 degree rotation
            child: preview,
          ),
        ),
      );
    } else {
      // For phones - keep the original aspect ratio
      previewWidget = AspectRatio(
        aspectRatio: cameraAspectRatio,
        child: preview,
      );
    }

    return Center(child: previewWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Center(
            child: Text(
              ' Upload Video [Step-5]',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          backgroundColor: const Color(0xFF92B7F7),
        ),
        body: _controller == null
            ? const Center(child: CircularProgressIndicator())
            : FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          const Center(
                            child: Text(
                              'Click Divyang Video',
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
                              'दिव्यांग व्यक्तीचा व्हिडिओ काढा',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                                top: 30,
                              ),
                              child: Stack(
                                children: [
                                  _buildCameraPreview(),
                                  if (!isRecording)
                                    const Positioned(
                                      top: 22,
                                      left: 40.0,
                                      right: 10.0,
                                      child: Text(
                                        'Make sure your face is clearly visible\nDo not look left or right\nPlease look front of the camera',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  if (isRecording)
                                    Positioned(
                                      right: 40.0,
                                      top: 10.0,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Recording... ${_elapsedTime}s',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Icon(
                                            Icons.radio_button_checked,
                                            color: _isBlinking
                                                ? Colors.red
                                                : Colors.transparent,
                                            size: 50,
                                          ),
                                          Text(
                                            'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            'Time: ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Recording and switch camera buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: isRecording
                                    ? null
                                    : () async {
                                        await startVideoRecording();
                                      },
                                icon: const Icon(
                                  Icons.videocam,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Start Recording\nव्हिडिओ रेकॉर्ड करा',
                                  textAlign: TextAlign.center,
                                ),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: Color(0xFF92B7F7),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 10),
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.switch_camera_sharp,
                                      color: Color(0xFF92B7F7),
                                      size: 40,
                                    ),
                                    onPressed:
                                        isRecording ? null : switchCamera,
                                  ),
                                  const Text("कॅमेरा बदला"),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
      ),
    );
  }
}

// import 'dart:async';
// import 'dart:io';
// import 'dart:math';

// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pcmc_jeevan_praman/KYC_Screens/recorded_video_kyc_screen.dart';

// class VideoRecordKYCScreen extends StatefulWidget {
//   final String imagePath;
//   final String aadhaarNumber;
//   final String latitude;
//   final String longitude;
//   final String address;

//   const VideoRecordKYCScreen({
//     super.key,
//     required this.imagePath,
//     required this.aadhaarNumber,
//     required this.latitude,
//     required this.longitude,
//     required this.address,
//   });

//   @override
//   _VideoRecordKYCScreenState createState() => _VideoRecordKYCScreenState();
// }

// class _VideoRecordKYCScreenState extends State<VideoRecordKYCScreen> {
//   late List<CameraDescription> cameras;
//   CameraController? _controller;
//   Future<void>? _initializeControllerFuture;

//   // Recording control variables
//   bool isRecording = false;
//   late String videoPath;
//   bool _isBlinking = false;
//   Timer? _blinkTimer;
//   Timer? _timer;
//   int _elapsedTime = 0;
//   int duration = 6; // Default recording duration: 6 seconds
//   bool isFrontCamera = true;

//   // Device type detection
//   bool? _isTablet;

//   @override
//   void initState() {
//     super.initState();
//     // Lock screen orientation to portrait during recording
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);
//     initCamera();
//   }

//   // Detect if the device is a tablet
//   bool isTablet(BuildContext context) {
//     if (_isTablet != null) return _isTablet!;

//     final shortestSide = MediaQuery.of(context).size.shortestSide;
//     _isTablet = shortestSide >= 600; // Standard tablet detection
//     return _isTablet!;
//   }

//   // Initialize available cameras
//   Future<void> initCamera() async {
//     cameras = await availableCameras();
//     setCamera(CameraLensDirection.back); // Start with back camera
//   }

//   // Set camera based on lens direction
//   Future<void> setCamera(CameraLensDirection direction) async {
//     final selectedCamera =
//         cameras.firstWhere((camera) => camera.lensDirection == direction);

//     _controller = CameraController(
//       selectedCamera,
//       ResolutionPreset.low,
//       enableAudio: false, // No audio needed
//     );
//     _initializeControllerFuture = _controller!.initialize();
//     setState(() {});
//   }

//   // Toggle between front and back camera
//   Future<void> switchCamera() async {
//     if (isFrontCamera) {
//       await setCamera(CameraLensDirection.back);
//     } else {
//       await setCamera(CameraLensDirection.front);
//     }
//     isFrontCamera = !isFrontCamera;
//   }

//   @override
//   void dispose() {
//     // Reset screen orientation and clean up timers/controllers
//     SystemChrome.setPreferredOrientations(DeviceOrientation.values);
//     _controller?.dispose();
//     _blinkTimer?.cancel();
//     _timer?.cancel();
//     super.dispose();
//   }

//   // Start recording video
//   Future<void> startVideoRecording() async {
//     if (_controller == null || !_controller!.value.isInitialized) {
//       Fluttertoast.showToast(
//         msg: "Camera not initialized",
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//       );
//       return;
//     }

//     try {
//       // Prepare storage path
//       final Directory extDir = await getApplicationDocumentsDirectory();
//       final String dirPath = '${extDir.path}/Videos';
//       await Directory(dirPath).create(recursive: true);

//       final String filePath =
//           '$dirPath/${DateTime.now().millisecondsSinceEpoch}.mp4';

//       // Start recording
//       await _controller!.startVideoRecording();
//       setState(() {
//         isRecording = true;
//         videoPath = filePath;
//         _elapsedTime = 0;
//       });

//       _startBlinking(); // Red blinking indicator
//       _startTimer(); // Show recording time counter

//       // Wait until desired duration completes
//       await Future.delayed(Duration(seconds: duration));

//       // Stop recording and save file
//       final XFile videoFile = await _controller!.stopVideoRecording();
//       final File recordedFile = File(videoFile.path);
//       await recordedFile.copy(filePath); // Save video
//       await recordedFile.delete(); // Remove temporary file

//       setState(() {
//         isRecording = false;
//         videoPath = filePath;
//       });

//       _stopBlinking();
//       _timer?.cancel();

//       Fluttertoast.showToast(
//         msg: "Video Recorded!",
//         backgroundColor: Colors.green,
//         textColor: Colors.white,
//       );

//       // Navigate to video preview screen
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => VideoPlayerKYCScreen(
//             latitude: widget.latitude,
//             longitude: widget.longitude,
//             address: widget.address,
//             videoPath: videoPath,
//             recordedDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
//             recordedTime: DateFormat('HH:mm:ss').format(DateTime.now()),
//             imagePath: widget.imagePath,
//             aadhaarNumber: widget.aadhaarNumber,
//             isFrontCamera: isFrontCamera,
//             // inputFieldOneValue: widget.inputFieldOneValue,
//             // selectedDropdownValue: widget.selectedDropdownValue,
//           ),
//         ),
//       );
//     } catch (e) {
//       print('Error recording video: $e');

//       if (isRecording) {
//         try {
//           await _controller!.stopVideoRecording();
//         } catch (stopError) {
//           print('Error stopping video after failure: $stopError');
//         }

//         setState(() {
//           isRecording = false;
//         });

//         _stopBlinking();
//         _timer?.cancel();

//         await SystemChrome.setPreferredOrientations(DeviceOrientation.values);

//         Fluttertoast.showToast(
//           msg:
//               "Recording failed: ${e.toString().substring(0, min(50, e.toString().length))}",
//           backgroundColor: Colors.red,
//           textColor: Colors.white,
//         );
//       }
//     }
//   }

//   // Stop recording manually (not used in auto recording flow)
//   Future<void> stopVideoRecording() async {
//     if (_controller == null || !_controller!.value.isRecordingVideo) return;

//     try {
//       final XFile videoFile = await _controller!.stopVideoRecording();
//       setState(() {
//         isRecording = false;
//         videoPath = videoFile.path;
//       });

//       _stopBlinking();
//       _timer?.cancel();
//     } catch (e) {
//       print('Error stopping video recording: $e');
//     }
//   }

//   // Red blinking indicator for recording
//   void _startBlinking() {
//     _blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
//       setState(() {
//         _isBlinking = !_isBlinking;
//       });
//     });
//   }

//   void _stopBlinking() {
//     _blinkTimer?.cancel();
//     setState(() {
//       _isBlinking = false;
//     });
//   }

//   // Timer to track elapsed recording time
//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         _elapsedTime++;
//       });

//       if (_elapsedTime >= duration) {
//         _timer?.cancel();
//       }
//     });
//   }

//   Widget _buildCameraPreview() {
//     if (_controller == null || !_controller!.value.isInitialized) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     final preview = CameraPreview(_controller!);
//     final previewSize = _controller!.value.previewSize!;
//     final cameraAspectRatio = previewSize.height / previewSize.width;

//     final isFrontCamera =
//         _controller!.description.lensDirection == CameraLensDirection.front;
//     final isBackCamera =
//         _controller!.description.lensDirection == CameraLensDirection.back;

//     // Set rotation angle based on camera type
//     double rotationAngle = 0;
//     if (isFrontCamera) {
//       rotationAngle = -pi / 2; // 90° left
//     } else if (isBackCamera) {
//       rotationAngle = pi / 2; // 90° right
//     }

//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//         height: 350,
//         width: 650,
//         child: Transform.rotate(
//           angle: rotationAngle,
//           child: AspectRatio(
//             aspectRatio: cameraAspectRatio, // Invert ratio after rotation
//             child: preview,
//           ),
//         ),
//       ),
//     );
//   }

//   // Widget to display camera preview properly with tablet rotation
//   // Widget _buildCameraPreview() {
//   //   if (_controller == null || !_controller!.value.isInitialized) {
//   //     return const Center(child: CircularProgressIndicator());
//   //   }

//   //   final bool deviceIsTablet = isTablet(context);
//   //   final preview = CameraPreview(_controller!);
//   //   final previewSize = _controller!.value.previewSize!;
//   //   final cameraAspectRatio = previewSize.height / previewSize.width;

//   //   Widget previewWidget;

//   //   if (deviceIsTablet) {
//   //     // For tablets - rotate 90 degrees to the left (-pi/2 radians)
//   //     previewWidget = Transform.rotate(
//   //       angle: pi + pi, // -90 degrees (rotate left)
//   //       child: SizedBox(
//   //         width: MediaQuery.of(context).size.width,
//   //         height: MediaQuery.of(context).size.height,
//   //         child: AspectRatio(
//   //           aspectRatio:
//   //               1 / cameraAspectRatio, // Inverse ratio for 90 degree rotation
//   //           child: preview,
//   //         ),
//   //       ),
//   //     );
//   //   } else {
//   //     // For phones - keep the original aspect ratio
//   //     previewWidget = AspectRatio(
//   //       aspectRatio: cameraAspectRatio,
//   //       child: preview,
//   //     );
//   //   }

//   //   return Center(child: previewWidget);
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           title: const Center(
//             child: Text(
//               ' Upload Video [Step-5]',
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           backgroundColor: const Color(0xFF92B7F7),
//         ),
//         body: _controller == null
//             ? const Center(child: CircularProgressIndicator())
//             : FutureBuilder<void>(
//                 future: _initializeControllerFuture,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.done) {
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const SizedBox(height: 20),
//                           const Center(
//                             child: Text(
//                               'Click Divyang Video',
//                               style: TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87,
//                                 letterSpacing: 1.5,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                           const Center(
//                             child: Text(
//                               'दिव्यांग व्यक्तीचा व्हिडिओ काढा',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 color: Colors.black54,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                           Expanded(
//                             child: Padding(
//                               padding: const EdgeInsets.only(
//                                 left: 20,
//                                 right: 20,
//                                 top: 30,
//                               ),
//                               child: Stack(
//                                 children: [
//                                   _buildCameraPreview(),
//                                   if (!isRecording)
//                                     const Positioned(
//                                       top: 22,
//                                       left: 40.0,
//                                       right: 10.0,
//                                       child: Text(
//                                         'Make sure your face is clearly visible\nDo not look left or right\nPlease look front of the camera',
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                         textAlign: TextAlign.left,
//                                       ),
//                                     ),
//                                   if (isRecording)
//                                     Positioned(
//                                       right: 40.0,
//                                       top: 10.0,
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.end,
//                                         children: [
//                                           Text(
//                                             'Recording... ${_elapsedTime}s',
//                                             style: const TextStyle(
//                                               fontSize: 18,
//                                               color: Colors.red,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                           const SizedBox(height: 10),
//                                           Icon(
//                                             Icons.radio_button_checked,
//                                             color: _isBlinking
//                                                 ? Colors.red
//                                                 : Colors.transparent,
//                                             size: 50,
//                                           ),
//                                           Text(
//                                             'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
//                                             style: const TextStyle(
//                                               fontSize: 16,
//                                               color: Colors.white,
//                                             ),
//                                           ),
//                                           Text(
//                                             'Time: ${DateFormat('HH:mm:ss').format(DateTime.now())}',
//                                             style: const TextStyle(
//                                               fontSize: 16,
//                                               color: Colors.white,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           // Recording and switch camera buttons
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               ElevatedButton.icon(
//                                 onPressed: isRecording
//                                     ? null
//                                     : () async {
//                                         await startVideoRecording();
//                                       },
//                                 icon: const Icon(
//                                   Icons.videocam,
//                                   color: Colors.white,
//                                 ),
//                                 label: const Text(
//                                   'Start Recording\nव्हिडिओ रेकॉर्ड करा',
//                                   textAlign: TextAlign.center,
//                                 ),
//                                 style: ElevatedButton.styleFrom(
//                                   foregroundColor: Colors.white,
//                                   backgroundColor: Colors.green,
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 30, vertical: 10),
//                                   textStyle: const TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 20),
//                               Column(
//                                 children: [
//                                   IconButton(
//                                     icon: const Icon(
//                                       Icons.switch_camera_sharp,
//                                       color: Colors.green,
//                                       size: 40,
//                                     ),
//                                     onPressed:
//                                         isRecording ? null : switchCamera,
//                                   ),
//                                   const Text("कॅमेरा बदला"),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 40),
//                         ],
//                       ),
//                     );
//                   } else {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                 },
//               ),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'dart:io';

// import 'package:camera/camera.dart';
// import 'package:divyank_pmc/DivyangPMC/recorded_video_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';

// class VideoRecordScreen extends StatefulWidget {
//   final String imagePath;
//   final String aadhaarNumber;
//   final String latitude;
//   final String longitude;
//   final String address;
//   final String inputFieldOneValue;
//   final String? selectedDropdownValue;

//   const VideoRecordScreen({
//     super.key,
//     required this.imagePath,
//     required this.aadhaarNumber,
//     required this.latitude,
//     required this.longitude,
//     required this.address,
//     required this.inputFieldOneValue,
//     this.selectedDropdownValue,
//   });

//   @override
//   _VideoRecordScreenState createState() => _VideoRecordScreenState();
// }

// class _VideoRecordScreenState extends State<VideoRecordScreen> {
//   late List<CameraDescription> cameras;
//   CameraController? _controller;
//   Future<void>? _initializeControllerFuture;
//   bool isRecording = false;
//   String? videoPath;
// // Variable to hold the current date and time
//   bool _isBlinking = false;
//   Timer? _blinkTimer;
//   int duration = 6; // Video duration in seconds
//   Timer? _timer;
//   int _elapsedTime = 0;
//   bool isFrontCamera = true; // Track the current camera

//   @override
//   void initState() {
//     super.initState();
//     initCamera();
//   }

//   Future<void> initCamera() async {
//     cameras = await availableCameras();
//     // Initialize with the front camera first
//     setCamera(CameraLensDirection.front);
//   }

//   Future<void> setCamera(CameraLensDirection direction) async {
//     final selectedCamera =
//         cameras.firstWhere((camera) => camera.lensDirection == direction);

//     _controller = CameraController(selectedCamera, ResolutionPreset.high);
//     _initializeControllerFuture = _controller!.initialize();
//     setState(() {});
//   }

//   Future<void> switchCamera() async {
//     if (isFrontCamera) {
//       setCamera(CameraLensDirection.back);
//     } else {
//       setCamera(CameraLensDirection.front);
//     }
//     isFrontCamera = !isFrontCamera;
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     _blinkTimer?.cancel();
//     _timer?.cancel();
//     super.dispose();
//   }

//   Future<void> startVideoRecording() async {
//     if (_controller == null || !_controller!.value.isInitialized) return;

//     try {
//       final Orientation orientation = MediaQuery.of(context).orientation;
//       SystemChrome.setPreferredOrientations([
//         orientation == Orientation.portrait
//             ? DeviceOrientation.portraitUp
//             : DeviceOrientation.landscapeRight,
//       ]);

//       final Directory extDir = await getApplicationDocumentsDirectory();
//       final String dirPath = '${extDir.path}/Videos';
//       await Directory(dirPath).create(recursive: true);

//       // Ensure the file ends with .mp4
//       final String filePath =
//           '$dirPath/${DateTime.now().millisecondsSinceEpoch}.mp4';

//       await _controller!.startVideoRecording();
//       setState(() {
//         isRecording = true;
//         videoPath = filePath.endsWith('.mp4')
//             ? filePath
//             : '$filePath.mp4'; // Ensure .mp4 extension
//         _elapsedTime = 0; // Reset the timer
//       });

//       _startBlinking();
//       _startTimer();

//       await Future.delayed(Duration(seconds: duration));
//       await stopVideoRecording();

//       SystemChrome.setPreferredOrientations(DeviceOrientation.values);

//       Fluttertoast.showToast(
//         msg: "Video Recorded!",
//         backgroundColor: Colors.green,
//         textColor: Colors.white,
//       );

//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => VideoPlayerScreen(
//             latitude: widget.latitude, // Pass latitude to the navigated screen
//             longitude:
//                 widget.longitude, // Pass longitude to the navigated screen
//             address: widget.address,
//             videoPath: videoPath!,
//             recordedDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
//             recordedTime: DateFormat('HH:mm:ss').format(DateTime.now()),
//             imagePath: widget.imagePath,
//             aadhaarNumber: widget.aadhaarNumber,
//             isFrontCamera: isFrontCamera,
//             inputFieldOneValue: widget.inputFieldOneValue,
//             selectedDropdownValue:
//                 widget.selectedDropdownValue, // Pass the camera information
//           ),
//         ),
//       );
//     } catch (e) {
//       print('Error recording video: $e');
//     }
//   }

//   Future<void> stopVideoRecording() async {
//     if (_controller == null || !_controller!.value.isRecordingVideo) return;

//     try {
//       final XFile videoFile = await _controller!.stopVideoRecording();
//       setState(() {
//         isRecording = false;
//         videoPath = videoFile.path;
//       });

//       _stopBlinking();
//       _timer?.cancel(); // Stop the timer when recording ends
//     } catch (e) {
//       print('Error stopping video recording: $e');
//     }
//   }

//   void _startBlinking() {
//     _blinkTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
//       setState(() {
//         _isBlinking = !_isBlinking;
//       });
//     });
//   }

//   void _stopBlinking() {
//     _blinkTimer?.cancel();
//     setState(() {
//       _isBlinking = false;
//     });
//   }

//   void _startTimer() {
//     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       setState(() {
//         _elapsedTime++;
//       });

//       if (_elapsedTime >= duration) {
//         _timer?.cancel();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           title: const Center(
//             child: Text(
//               ' Upload Video [Step-5]',
//               style: TextStyle(
//                 color: Colors.white, // White text color for contrast
//                 fontSize: 18, // Font size for the title
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           backgroundColor: const Color(0xFF551561),
//         ),
//         body: _controller == null
//             ? Center(child: CircularProgressIndicator())
//             : FutureBuilder<void>(
//                 future: _initializeControllerFuture,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.done) {
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           // Text("Aadhar Number: ${widget.aadhaarNumber}"),

//                           const SizedBox(
//                             height: 20,
//                           ),
//                           const Center(
//                             child: Text(
//                               'Click Divyang Video',
//                               style: TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87,
//                                 letterSpacing: 1.5,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                           const Center(
//                             child: Text(
//                               'दिव्यांग व्यक्तीचा व्हिडिओ काढा',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 color: Colors.black54,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                           Expanded(
//                             child: Padding(
//                               padding: const EdgeInsets.only(
//                                 left: 20,
//                                 right: 20,
//                                 top: 30,
//                               ),
//                               child: Stack(
//                                 children: [
//                                   CameraPreview(_controller!),
//                                   if (!isRecording)
//                                     const Positioned(
//                                       top: 22,
//                                       left: 10.0,
//                                       right: 10.0,
//                                       child: Text(
//                                         'Make sure your face is clearly visible\nDo not look left or right\nPlease look front of the camera',
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                         textAlign: TextAlign.left,
//                                       ),
//                                     ),
//                                   if (isRecording)
//                                     Positioned(
//                                       right: 10.0,
//                                       top: 10.0,
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.end,
//                                         children: [
//                                           Text(
//                                             'Recording... ${_elapsedTime}s',
//                                             style: const TextStyle(
//                                               fontSize: 18,
//                                               color: Colors.red,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                           const SizedBox(height: 10),
//                                           Icon(
//                                             Icons.radio_button_checked,
//                                             color: _isBlinking
//                                                 ? Colors.red
//                                                 : Colors.transparent,
//                                             size: 50,
//                                           ),
//                                           Text(
//                                             'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
//                                             style: const TextStyle(
//                                               fontSize: 16,
//                                               color: Colors.white,
//                                             ),
//                                           ),
//                                           Text(
//                                             'Time: ${DateFormat('HH:mm:ss').format(DateTime.now())}',
//                                             style: const TextStyle(
//                                               fontSize: 16,
//                                               color: Colors.white,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               ElevatedButton.icon(
//                                 onPressed: isRecording
//                                     ? null
//                                     : () async {
//                                         await startVideoRecording();
//                                       },
//                                 icon: const Icon(
//                                   Icons.videocam,
//                                   color: Colors.white,
//                                 ),
//                                 label: Text(
//                                     'Start Recording\nव्हिडिओ रेकॉर्ड करा'),
//                                 style: ElevatedButton.styleFrom(
//                                   foregroundColor: Colors.white, // Text color
//                                   backgroundColor: const Color(
//                                       0xFF551561), // Button background color
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 30, vertical: 10),
//                                   textStyle: const TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(
//                                         10), // Makes it a perfect rectangle
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 20),
//                               Column(
//                                 children: [
//                                   IconButton(
//                                     icon: Icon(
//                                       Icons.switch_camera_sharp,
//                                       color: Color(0xFF551561),
//                                       size: 40,
//                                     ),
//                                     onPressed: switchCamera,
//                                   ),
//                                   Text("कॅमेरा बदला"),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           const SizedBox(
//                             height: 40,
//                           )
//                         ],
//                       ),
//                     );
//                   } else {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                 },
//               ),
//       ),
//     );
//   }
// }
