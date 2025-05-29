import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pcmc_jeevan_praman/recorded_video_screen.dart';

class VideoRecordScreen extends StatefulWidget {
  final String ppoNumber;
  final String imagePath;
  final String aadhaarNumber;
  final String latitude;
  final String longitude;
  final String address;

  const VideoRecordScreen({
    super.key,
    required this.imagePath,
    required this.aadhaarNumber,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.ppoNumber,
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
  String? _currentDateTime; // Variable to hold the current date and time
  bool _isBlinking = false;
  Timer? _blinkTimer;
  int duration = 6; // Video duration in seconds
  Timer? _timer;
  int _elapsedTime = 0;
  bool isFrontCamera = true;
  double rotationAngle = 0; // Track the current camera

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    // Initialize with the front camera first
    setCamera(CameraLensDirection.front);
  }

  Future<void> setCamera(CameraLensDirection direction) async {
    final selectedCamera =
        cameras.firstWhere((camera) => camera.lensDirection == direction);

    _controller = CameraController(selectedCamera, ResolutionPreset.high);
    _initializeControllerFuture = _controller!.initialize();
    setState(() {});
  }

  // Future<void> switchCamera() async {
  //   if (isFrontCamera) {
  //     setCamera(CameraLensDirection.back);
  //   } else {
  //     setCamera(CameraLensDirection.front);
  //   }
  //   isFrontCamera = !isFrontCamera;
  // }

  Future<void> switchCamera() async {
    if (isFrontCamera) {
      setCamera(CameraLensDirection.back);
      rotationAngle = 90; // Rotate back camera by 180 degrees
    } else {
      setCamera(CameraLensDirection.front);
      rotationAngle = -90; // No rotation for front camera
    }
    isFrontCamera = !isFrontCamera;
    setState(() {}); // Update UI with new rotation
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

      // Ensure the file ends with .mp4
      final String filePath =
          '$dirPath/${DateTime.now().millisecondsSinceEpoch}.mp4';

      await _controller!.startVideoRecording();
      setState(() {
        isRecording = true;
        videoPath = filePath.endsWith('.mp4')
            ? filePath
            : '$filePath.mp4'; // Ensure .mp4 extension
        _elapsedTime = 0; // Reset the timer
        _currentDateTime =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      });

      _startBlinking();
      _startTimer();

      await Future.delayed(Duration(seconds: duration));
      await stopVideoRecording();

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
            latitude: widget.latitude, // Pass latitude to the navigated screen
            longitude:
                widget.longitude, // Pass longitude to the navigated screen
            address: widget.address,
            videoPath: videoPath!,
            recordedDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            recordedTime: DateFormat('HH:mm:ss').format(DateTime.now()),
            imagePath: widget.imagePath,
            aadhaarNumber: widget.aadhaarNumber,
            isFrontCamera: isFrontCamera,
            // Pass the camera information
          ),
        ),
      );
    } catch (e) {
      print('Error recording video: $e');
    }
  }

  Future<void> stopVideoRecording() async {
    if (_controller == null || !_controller!.value.isRecordingVideo) return;

    try {
      final XFile videoFile = await _controller!.stopVideoRecording();
      setState(() {
        isRecording = false;
        videoPath = videoFile.path;
      });

      _stopBlinking();
      _timer?.cancel(); // Stop the timer when recording ends
    } catch (e) {
      print('Error stopping video recording: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            ' Upload Video  [Step-4]',
            style: TextStyle(
              color: Colors.black, // White text color for contrast
              fontSize: 22, // Font size for the title
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        const Center(
                          child: Text(
                            'Capture Pensioner Video',
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
                            'पेन्शनर व्यक्तीचा व्हिडिओ काढा',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Center(
                          child: Container(
                            height: 500,
                            width: 350,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xFF92B7F7), // Red border color
                                width: 2.0, // Border width
                              ),
                              borderRadius:
                                  BorderRadius.circular(15), // Rounded corners
                            ),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: 490,
                                    height: 300,
                                    child: _controller != null &&
                                            _controller!.value.isInitialized
                                        ? Transform(
                                            alignment: Alignment.center,
                                            transform: Matrix4.rotationZ(
                                              isFrontCamera
                                                  ? -90 * 3.1415927 / 180
                                                  : 90 *
                                                      3.1415927 /
                                                      180, // Rotate front camera by -90 degrees, back camera by 90 degrees
                                            ),
                                            // transform: Matrix4.rotationZ(
                                            //   isFrontCamera
                                            //       ? -90 * 3.1415927 / 180
                                            //       : 0, // Rotate front camera by -90 degrees, no rotation for back camera
                                            // ),
                                            // transform: Matrix4.rotationZ(
                                            //     rotationAngle * (3.1415927 / 180)),
                                            child: CameraPreview(_controller!),
                                          )
                                        : Center(
                                            child: CircularProgressIndicator()),
                                  ),
                                ),
                                // if (!isRecording)
                                // const Positioned(
                                //   top: 10,
                                //   left: 10.0,
                                //   right: 10.0,
                                //   child: Text(
                                //     'Make sure your face is clearly visible\nDo not look left or right\nPlease look front of the camera',
                                //     style: TextStyle(
                                //       fontSize: 16,
                                //       color: Colors.red,
                                //       fontWeight: FontWeight.bold,
                                //     ),
                                //     textAlign: TextAlign.left,
                                //   ),
                                // ),
                                if (isRecording)
                                  Positioned(
                                    right: 10.0,
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
                                        SizedBox(height: 10),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: isRecording
                                  ? null
                                  : () async {
                                      await startVideoRecording();
                                    },
                              icon: const Icon(Icons.videocam),
                              label:
                                  Text('Start Recording\nव्हिडिओ रेकॉर्ड करा'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 10),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Column(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.switch_camera_sharp,
                                    color: Colors.green,
                                    size: 40,
                                  ),
                                  onPressed: switchCamera,
                                ),
                                Text("कॅमेरा बदला"),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 40,
                        )
                      ],
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
