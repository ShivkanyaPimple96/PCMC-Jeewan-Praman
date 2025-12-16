import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pcmc_jeevan_praman/kyc_screens/recorded_video_kyc_screen.dart';

class VideoRecordKYCScreen extends StatefulWidget {
  final String aadhaarNumber;
  final String mobileNumber;
  final String ppoNumber;
  final String address;
  final String gender;
  final String lastSubmit;

  const VideoRecordKYCScreen({
    super.key,
    required this.aadhaarNumber,
    required this.ppoNumber,
    required this.lastSubmit,
    required this.mobileNumber,
    required this.address,
    required this.gender,
  });

  @override
  _VideoRecordKYCScreenState createState() => _VideoRecordKYCScreenState();
}

class _VideoRecordKYCScreenState extends State<VideoRecordKYCScreen> {
  late List<CameraDescription> cameras;
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  bool isRecording = false;
  String videoPath = '';
  bool _isBlinking = false;
  Timer? _blinkTimer;
  Timer? _timer;
  int _elapsedTime = 0;
  int duration = 6;
  bool isFrontCamera = true;
  bool? _isTablet;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    initCamera();
  }

  bool isTablet(BuildContext context) {
    if (_isTablet != null) return _isTablet!;
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    _isTablet = shortestSide >= 600;
    return _isTablet!;
  }

  Future<void> initCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showErrorToast("No cameras available");
        return;
      }
      await setCamera(CameraLensDirection.front);
    } catch (e) {
      print('Error initializing camera: $e');
      _showErrorToast("Failed to initialize camera");
    }
  }

  Future<void> setCamera(CameraLensDirection direction) async {
    if (_isInitializing) return;

    try {
      _isInitializing = true;

      // Dispose previous controller
      if (_controller != null) {
        await _controller!.dispose();
        _controller = null;
      }

      final selectedCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == direction,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        selectedCamera,
        ResolutionPreset
            .medium, // Changed from low to medium for better compatibility
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420, // Better compatibility
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      print('Error setting camera: $e');
      _isInitializing = false;
      if (mounted) {
        _showErrorToast("Camera setup failed");
      }
    }
  }

  Future<void> switchCamera() async {
    if (_isInitializing || isRecording) return;

    try {
      if (isFrontCamera) {
        await setCamera(CameraLensDirection.back);
      } else {
        await setCamera(CameraLensDirection.front);
      }
      isFrontCamera = !isFrontCamera;
    } catch (e) {
      print('Error switching camera: $e');
      _showErrorToast("Failed to switch camera");
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _controller?.dispose();
    _blinkTimer?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> startVideoRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      _showErrorToast("Camera not initialized");
      return;
    }

    if (isRecording) return;

    try {
      final Directory extDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${extDir.path}/Videos';
      await Directory(dirPath).create(recursive: true);

      final String filePath =
          '$dirPath/${DateTime.now().millisecondsSinceEpoch}.mp4';

      await _controller!.startVideoRecording();

      setState(() {
        isRecording = true;
        videoPath = filePath;
        _elapsedTime = 0;
      });

      _startBlinking();
      _startTimer();

      // Wait for duration
      await Future.delayed(Duration(seconds: duration));

      // Check if still recording (user might have left screen)
      if (!isRecording || _controller == null) return;

      final XFile videoFile = await _controller!.stopVideoRecording();
      final File recordedFile = File(videoFile.path);

      // Verify file exists and has content
      if (!await recordedFile.exists()) {
        throw Exception("Video file was not created");
      }

      final fileSize = await recordedFile.length();
      if (fileSize == 0) {
        throw Exception("Video file is empty");
      }

      await recordedFile.copy(filePath);

      // Only delete if copy was successful
      if (await File(filePath).exists()) {
        await recordedFile.delete();
      }

      setState(() {
        isRecording = false;
        videoPath = filePath;
      });

      _stopBlinking();
      _timer?.cancel();

      _showSuccessToast("Video Recorded!");

      // Small delay before navigation
      await Future.delayed(Duration(milliseconds: 300));

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerKYCScreen(
              mobileNumber: widget.mobileNumber,
              videoPath: videoPath,
              recordedDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
              recordedTime: DateFormat('HH:mm:ss').format(DateTime.now()),
              aadhaarNumber: widget.aadhaarNumber,
              ppoNumber: widget.ppoNumber,
              isFrontCamera: isFrontCamera,
              gender: widget.gender,
              address: widget.address,
              lastSubmit: "",
            ),
          ),
        );
      }
    } catch (e) {
      print('Error recording video: $e');

      if (isRecording && _controller != null) {
        try {
          await _controller!.stopVideoRecording();
        } catch (stopError) {
          print('Error stopping video after failure: $stopError');
        }
      }

      setState(() {
        isRecording = false;
      });

      _stopBlinking();
      _timer?.cancel();

      String errorMsg = "Recording failed";
      if (e.toString().contains('Camera')) {
        errorMsg = "Camera error occurred";
      } else if (e.toString().contains('permission')) {
        errorMsg = "Camera permission denied";
      }

      _showErrorToast(errorMsg);
    }
  }

  void _startBlinking() {
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _isBlinking = !_isBlinking;
        });
      }
    });
  }

  void _stopBlinking() {
    _blinkTimer?.cancel();
    if (mounted) {
      setState(() {
        _isBlinking = false;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedTime++;
        });
      }

      if (_elapsedTime >= duration) {
        _timer?.cancel();
      }
    });
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  Widget _buildCameraPreview() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final preview = CameraPreview(_controller!);
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // Calculate responsive dimensions
    // Using 90% of screen width with max constraint
    final containerWidth = min(width * 0.9, 350.0);
    // Maintain aspect ratio for height
    final containerHeight = containerWidth * 1.1;

    // Calculate preview dimensions based on container
    final previewWidth = containerHeight * 1.1;
    final previewHeight = containerWidth;

    // Set rotation angle based on camera type
    double rotationAngle = isFrontCamera ? -pi / 2 : pi / 2;

    return Container(
      height: containerHeight,
      width: containerWidth,
      decoration: BoxDecoration(
        border: Border.all(
          color: Color(0xFF92B7F7),
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: rotationAngle,
                child: SizedBox(
                  width: width * 1.1,
                  height: height * 0.35,
                  child: preview,
                ),
              ),
            ),
            if (!isRecording)
              Positioned(
                top: height * 0.020,
                left: width * 0.15,
                right: width * 0.025,
                child: Text(
                  'Make sure your face is clearly visible\nLook left or right side\nPlease look front of the camera',
                  style: TextStyle(
                    fontSize: width * 0.035,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            if (isRecording)
              Positioned(
                right: width * 0.05,
                top: height * 0.015,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Recording... ${_elapsedTime}s',
                      style: TextStyle(
                        fontSize: width * 0.045,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: height * 0.012),
                    Icon(
                      Icons.radio_button_checked,
                      color: _isBlinking ? Colors.red : Colors.transparent,
                      size: width * 0.125,
                    ),
                    Text(
                      'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                      style: TextStyle(
                        fontSize: width * 0.04,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Time: ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                      style: TextStyle(
                        fontSize: width * 0.04,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
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
          title: Center(
            child: Text(
              ' Upload Video [Step-5]',
              style: TextStyle(
                color: Colors.black,
                fontSize: width * 0.045,
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
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 60, color: Colors.red),
                            SizedBox(height: 20),
                            Text(
                              'Camera initialization failed',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: initCamera,
                              child: Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: height * 0.025),
                          Center(
                            child: Text(
                              'Click Pensioner Video',
                              style: TextStyle(
                                fontSize: width * 0.06,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Center(
                            child: Text(
                              'पेंशनधारक व्यक्तीचा व्हिडिओ काढा',
                              style: TextStyle(
                                fontSize: width * 0.045,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: width * 0.02,
                              right: width * 0.02,
                              top: height * 0.030,
                            ),
                            child: _buildCameraPreview(),
                          ),
                          SizedBox(height: height * 0.012),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: (isRecording || _isInitializing)
                                    ? null
                                    : startVideoRecording,
                                icon: Icon(
                                  Icons.videocam,
                                  color: Colors.black,
                                  size: width * 0.05,
                                ),
                                label: Text(
                                  'Start Recording\nव्हिडिओ रेकॉर्ड करा',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: width * 0.04),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF92B7F7),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.1,
                                    vertical: height * 0.012,
                                  ),
                                ),
                              ),
                              SizedBox(width: width * 0.05),
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.switch_camera_sharp,
                                      color: const Color(0xFF92B7F7),
                                      size: width * 0.1,
                                    ),
                                    onPressed: (isRecording || _isInitializing)
                                        ? null
                                        : switchCamera,
                                  ),
                                  Text(
                                    "कॅमेरा बदला",
                                    style: TextStyle(fontSize: width * 0.035),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: height * 0.05),
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
