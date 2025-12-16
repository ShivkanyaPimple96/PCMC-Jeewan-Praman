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

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    setCamera(CameraLensDirection.front);
  }

  Future<void> setCamera(CameraLensDirection direction) async {
    final selectedCamera =
        cameras.firstWhere((camera) => camera.lensDirection == direction);

    _controller = CameraController(selectedCamera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller!.initialize();
    setState(() {});
  }

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
    _controller?.dispose();
    _blinkTimer?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> startVideoRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final Orientation orientation = MediaQuery.of(context).orientation;
      SystemChrome.setPreferredOrientations([
        orientation == Orientation.portrait
            ? DeviceOrientation.portraitUp
            : DeviceOrientation.landscapeLeft,
      ]);

      final Directory extDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${extDir.path}/Videos';
      await Directory(dirPath).create(recursive: true);

      final String filePath =
          '$dirPath/${DateTime.now().millisecondsSinceEpoch}.mp4';

      await _controller!.startVideoRecording();
      setState(() {
        isRecording = true;
        videoPath = filePath.endsWith('.mp4') ? filePath : '$filePath.mp4';
        _elapsedTime = 0;
        _currentDateTime =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      });

      _startBlinking();
      _startTimer();

      await Future.delayed(Duration(seconds: duration));

      // Stop recording and save file
      final XFile videoFile = await _controller!.stopVideoRecording();
      final File recordedFile = File(videoFile.path);
      await recordedFile.copy(videoPath!);
      await recordedFile.delete();

      setState(() {
        isRecording = false;
      });

      _stopBlinking();
      _timer?.cancel();

      SystemChrome.setPreferredOrientations(DeviceOrientation.values);

      Fluttertoast.showToast(
        msg: "Video Recorded!",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

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

  void _startBlinking() {
    _blinkTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
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

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime++;
      });

      if (_elapsedTime >= duration) {
        _timer?.cancel();
      }
    });
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
    final containerWidth = min(width * 0.9, 345.0);
    // Maintain aspect ratio for height
    final containerHeight = containerWidth * 1.1;

    // Calculate preview dimensions based on container
    // final previewWidth = containerHeight * 1.1;
    // final previewHeight = containerWidth;

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
                top: height * 0.027,
                left: width * 0.15,
                right: width * 0.025,
                child: Text(
                  'Make sure your face is clearly visible\nLook left or right side\nPlease look front of the camera',
                  style: TextStyle(
                    fontSize: width * 0.035,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 3,
                        color: Colors.black54,
                      ),
                    ],
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
                            Center(
                              child: Text(
                                'Capture Pensioner Video',
                                style: TextStyle(
                                  fontSize: width * 0.06,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  letterSpacing: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: height * 0.01),
                            Center(
                              child: Text(
                                'पेन्शनर व्यक्तीचा व्हिडिओ काढा',
                                style: TextStyle(
                                  fontSize: width * 0.045,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: height * 0.025),
                            _buildCameraPreview(),
                            SizedBox(height: height * 0.015),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: isRecording
                                      ? null
                                      : () async {
                                          await startVideoRecording();
                                        },
                                  icon: Icon(
                                    Icons.videocam,
                                    size: width * 0.06,
                                  ),
                                  label: Text(
                                    'Start Recording\nव्हिडिओ रेकॉर्ड करा',
                                    style: TextStyle(
                                      fontSize: width * 0.04,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.green,
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
                                        color: Colors.green,
                                        size: width * 0.1,
                                      ),
                                      onPressed:
                                          isRecording ? null : switchCamera,
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
                            SizedBox(height: height * 0.05),
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
