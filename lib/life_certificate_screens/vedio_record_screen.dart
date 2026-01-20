import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pcmc_jeevan_praman/life_certificate_screens/recorded_video_screen.dart';

class VideoRecordScreen extends StatefulWidget {
  final String ppoNumber;
  final String imagePath;
  final String aadhaarNumber;
  final String latitude;
  final String longitude;
  final String address;
  final String mobileNumber;

  const VideoRecordScreen({
    super.key,
    required this.imagePath,
    required this.aadhaarNumber,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.ppoNumber,
    required this.mobileNumber,
  });

  @override
  _VideoRecordScreenState createState() => _VideoRecordScreenState();
}

class _VideoRecordScreenState extends State<VideoRecordScreen> {
  late List<CameraDescription> cameras;
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool isRecording = false;
  String? videoPath;
  String? _currentDateTime;
  bool _isBlinking = false;
  Timer? _blinkTimer;
  int duration = 6;
  Timer? _timer;
  int _elapsedTime = 0;
  bool isFrontCamera = true;
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
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
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
        _currentDateTime =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      });

      _startBlinking();
      _startTimer();

      await Future.delayed(Duration(seconds: duration));

      if (!isRecording || _controller == null) return;

      final XFile videoFile = await _controller!.stopVideoRecording();
      final File recordedFile = File(videoFile.path);

      if (!await recordedFile.exists()) {
        throw Exception("Video file was not created");
      }

      final fileSize = await recordedFile.length();
      if (fileSize == 0) {
        throw Exception("Video file is empty");
      }

      await recordedFile.copy(videoPath!);

      if (await File(videoPath!).exists()) {
        await recordedFile.delete();
      }

      setState(() {
        isRecording = false;
      });

      _stopBlinking();
      _timer?.cancel();

      _showSuccessToast("Video Recorded!");

      await Future.delayed(Duration(milliseconds: 300));

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecordedVideoScreen(
              ppoNumber: widget.ppoNumber,
              latitude: widget.latitude,
              longitude: widget.longitude,
              address: widget.address,
              videoPath: videoPath!,
              recordedDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
              recordedTime: DateFormat('HH:mm:ss').format(DateTime.now()),
              imagePath: widget.imagePath,
              aadhaarNumber: widget.aadhaarNumber,
              isFrontCamera: isFrontCamera,
              mobileNumber: widget.mobileNumber,
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
    _blinkTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
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
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
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

    final size = MediaQuery.of(context).size;
    final width = size.width;

    final cameraAspectRatio = _controller!.value.aspectRatio;
    final containerWidth = width * 0.9;
    final containerHeight = containerWidth * 1.2;

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
            Center(
              child: AspectRatio(
                aspectRatio: 1 / cameraAspectRatio,
                child: CameraPreview(_controller!),
              ),
            ),
            if (!isRecording)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
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
              ),
            if (isRecording)
              Positioned(
                right: 16,
                top: 16,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.radio_button_checked,
                            color:
                                _isBlinking ? Colors.red : Colors.transparent,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Recording... ${_elapsedTime}s',
                            style: TextStyle(
                              fontSize: width * 0.04,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                        style: TextStyle(
                          fontSize: width * 0.035,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Time: ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                        style: TextStyle(
                          fontSize: width * 0.035,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
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

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            ' Upload Video  [Step-4]',
            style: TextStyle(
              color: Colors.black,
              fontSize: width * 0.055,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Color(0xFF92B7F7),
      ),
      body: _controller == null
          ? Center(child: CircularProgressIndicator())
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
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.05,
                          vertical: height * 0.02,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Capture Pensioner Video',
                              style: TextStyle(
                                fontSize: width * 0.06,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: height * 0.01),
                            Text(
                              'पेन्शनर व्यक्तीचा व्हिडिओ काढा',
                              style: TextStyle(
                                fontSize: width * 0.045,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: height * 0.025),
                            _buildCameraPreview(),
                            SizedBox(height: height * 0.025),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: (isRecording || _isInitializing)
                                      ? null
                                      : startVideoRecording,
                                  icon: Icon(
                                    Icons.videocam,
                                    size: width * 0.06,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    'Start Recording\nव्हिडिओ रेकॉर्ड करा',
                                    style: TextStyle(
                                      fontSize: width * 0.04,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    disabledBackgroundColor: Colors.grey,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.075,
                                      vertical: height * 0.015,
                                    ),
                                  ),
                                ),
                                SizedBox(width: width * 0.05),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.switch_camera_sharp,
                                        color: (isRecording || _isInitializing)
                                            ? Colors.grey
                                            : Colors.green,
                                        size: width * 0.1,
                                      ),
                                      onPressed:
                                          (isRecording || _isInitializing)
                                              ? null
                                              : switchCamera,
                                    ),
                                    Text(
                                      "कॅमेरा बदला",
                                      style: TextStyle(
                                        fontSize: width * 0.035,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: height * 0.03),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
    );
  }
}
