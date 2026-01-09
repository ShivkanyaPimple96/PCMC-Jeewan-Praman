import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:pcmc_jeevan_praman/kyc_screens/vedio_record_kyc_screen.dart';

class PhotoClickKYCScreen extends StatefulWidget {
  final String aadhaarNumber;
  final String mobileNumber;
  final String ppoNumber;
  final String lastSubmit;
  final String address;
  final String gender;

  const PhotoClickKYCScreen({
    super.key,
    required this.aadhaarNumber,
    required this.ppoNumber,
    required this.lastSubmit,
    required this.mobileNumber,
    required this.address,
    required this.gender,
  });

  @override
  _PhotoClickKYCScreenState createState() => _PhotoClickKYCScreenState();
}

class _PhotoClickKYCScreenState extends State<PhotoClickKYCScreen> {
  File? _image;
  bool _isLoading = false;
  String? _latitude;
  String? _longitude;
  String? _address;

  Future<void> _getImage() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final imagePath = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(camera: frontCamera),
        ),
      );

      if (imagePath != null) {
        setState(() {
          _image = File(imagePath);
          _isLoading = true;
        });

        try {
          await _getCurrentLocation();
        } catch (e) {
          print('Error getting location: $e');
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error accessing camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accessing camera: $e')),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied');
      return;
    }

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _latitude = position.latitude.toString();
      _longitude = position.longitude.toString();
    });

    await _getAddressFromCoordinates(position.latitude, position.longitude);
  }

  Future<void> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        String address = '';
        if (place.street != null) address += '${place.street}, ';
        if (place.subLocality != null) address += '${place.subLocality}, ';
        if (place.locality != null) address += '${place.locality}, ';
        if (place.administrativeArea != null)
          address += '${place.administrativeArea}, ';
        if (place.postalCode != null) address += '${place.postalCode}, ';
        address = address.replaceAll(RegExp(r', $'), '');

        setState(() {
          _address = address;
        });
      } else {
        setState(() {
          _address = 'No address found for these coordinates';
        });
      }
    } catch (e) {
      print('Error getting address: $e');
      setState(() {
        _address = 'Failed to get address';
      });
    }
  }

  Future<File?> _compressImage(File imageFile) async {
    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        '${imageFile.path}_compressed.jpg',
        quality: 50,
        minWidth: 800,
        minHeight: 800,
      );
      return result != null ? File(result.path) : null;
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  Future<bool> _submitPhotoToAPI(File imageFile) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final compressedImage = await _compressImage(imageFile);
      if (compressedImage == null) {
        throw Exception('Image compression failed');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://lc.pcmcpensioner.in/api/aadhar/submitKycData'),
      );

      request.fields['aadhaarNumber'] = widget.aadhaarNumber;
      request.fields['ppoNumber'] = widget.ppoNumber;
      request.fields['latitude'] = _latitude ?? '';
      request.fields['longitude'] = _longitude ?? '';
      request.fields['address'] = _address ?? '';

      request.files.add(await http.MultipartFile.fromPath(
        'Selfie',
        compressedImage.path,
      ));

      var response = await request.send().timeout(Duration(seconds: 240));
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        print('API Response: $responseBody');
        return true;
      } else {
        final errorBody = await response.stream.bytesToString();
        print('API Error: ${response.statusCode} - $errorBody');
        return false;
      }
    } catch (e) {
      print('Error submitting photo: $e');
      return false;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 28),
              SizedBox(width: 10),
              Text(
                'Note',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(thickness: 2.5),
              Text(
                'Failed to submit the photo. Please check your internet connection.\nफोटो सबमिट करण्यात अयशस्वी. कृपया तुमचे इंटरनेट कनेक्शन तपासा.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              Divider(thickness: 2.5),
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSubmitPhotoDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.blue, size: 28),
              SizedBox(width: 10),
              Text(
                'Confirm Submission',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(thickness: 2.5),
              Text(
                'Are you sure you want to submit the photo?\nतुम्हाला खात्री आहे की तुम्ही हा फोटो सबमिट करू इच्छिता?',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              Divider(thickness: 2.5),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                if (_image != null) {
                  final success = await _submitPhotoToAPI(_image!);
                  if (success) {
                    _navigateToVideoRecordScreen();
                  } else {
                    _showErrorDialog();
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToVideoRecordScreen() {
    if (_image != null && _latitude != null && _longitude != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoRecordKYCScreen(
            mobileNumber: widget.mobileNumber,
            aadhaarNumber: widget.aadhaarNumber,
            ppoNumber: widget.ppoNumber,
            gender: widget.gender,
            address: widget.address,
            lastSubmit: "",
          ),
        ),
      );
    }
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
          backgroundColor: const Color(0xFF92B7F7),
          title: Center(
            child: Text(
              'Upload Photo [Step-4]',
              style: TextStyle(
                color: Colors.black,
                fontSize: width * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: height * 0.01,
                  left: width * 0.05,
                  right: width * 0.05,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height * 0.025),
                    Center(
                      child: Text(
                        'Click Pensioner Photo',
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
                        'पेंशनधारक व्यक्तीचा फोटो काढा',
                        style: TextStyle(
                          fontSize: width * 0.045,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(width * 0.025),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        height: height * 0.5,
                        width: width * 0.875,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF7FD),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF92B7F7),
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x9B9B9BC1),
                              blurRadius: 10,
                              spreadRadius: 0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Center(
                                child: _image == null
                                    ? Container(
                                        width: width * 0.625,
                                        height: width * 0.625,
                                        decoration: BoxDecoration(
                                          color: Colors.blueGrey[50],
                                        ),
                                        child: Image.asset(
                                          'assets/images/capture_image.jpeg',
                                          width: width * 0.625,
                                          height: width * 0.625,
                                          fit: BoxFit.contain,
                                        ),
                                      )
                                    : Image.file(
                                        _image!,
                                        height: width * 0.625,
                                        width: width * 0.625,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(width * 0.02),
                              child: ElevatedButton(
                                onPressed: _getImage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF92B7F7),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.08,
                                    vertical: height * 0.015,
                                  ),
                                ),
                                child: Text(
                                  "Click Photo\nफोटो काढा",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: width * 0.04,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.025),
                    if (_image != null)
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _showSubmitPhotoDialog,
                        icon: _isLoading
                            ? SizedBox(
                                width: width * 0.07,
                                height: width * 0.07,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue),
                                ),
                              )
                            : Icon(Icons.send, size: width * 0.07),
                        label: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: width * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: _isLoading
                                    ? 'Please Wait...\n'
                                    : 'Submit Photo\n',
                                style: TextStyle(
                                  color:
                                      _isLoading ? Colors.blue : Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: _isLoading
                                    ? 'कृपया प्रतीक्षा करा...'
                                    : 'फोटो सबमिट करा',
                                style: TextStyle(
                                  color: _isLoading
                                      ? Color(0xFF92B7F7)
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isLoading ? Colors.grey : Color(0xFF92B7F7),
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

// ==================== FIXED CAMERA SCREEN ====================
class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late List<CameraDescription> _cameras;
  late CameraDescription _currentCamera;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _currentCamera = widget.camera;
    _initializeCamera();
    _loadCameras();
  }

  Future<void> _loadCameras() async {
    _cameras = await availableCameras();
  }

  void _initializeCamera() {
    _controller = CameraController(
      _currentCamera,
      ResolutionPreset.low,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  Future<void> _switchCamera() async {
    if (_isInitializing) return;

    setState(() {
      _isInitializing = true;
    });

    try {
      await _controller.dispose();

      if (_currentCamera.lensDirection == CameraLensDirection.front) {
        _currentCamera = _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras.first,
        );
      } else {
        _currentCamera = _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras.first,
        );
      }

      _initializeCamera();
      await _initializeControllerFuture;

      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      print('Error switching camera: $e');
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Get rotation angle based on camera direction
  double _getRotationAngle() {
    if (_currentCamera.lensDirection == CameraLensDirection.front) {
      return -math.pi / 2; // -90 degrees (counter-clockwise) for front camera
    } else {
      return math.pi /
          2; // +90 degrees (clockwise) for back camera - reverse direction
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color(0xFF92B7F7),
        title: const Text('Take Photo', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_ios,
                color: Colors.white, size: 28),
            onPressed: _switchCamera,
            tooltip: 'Switch Camera',
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              !_isInitializing) {
            return Stack(
              children: [
                // FIXED: Rotated Camera Preview by 90 degrees counter-clockwise
                // Works for both front and back cameras
                Center(
                  child: Transform.rotate(
                    angle: _getRotationAngle(), // Dynamic angle based on camera
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: CameraPreview(_controller),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        heroTag: 'flip',
                        onPressed: _switchCamera,
                        backgroundColor: Colors.white70,
                        child: const Icon(Icons.flip_camera_ios,
                            color: Colors.black, size: 28),
                      ),
                      FloatingActionButton(
                        heroTag: 'capture',
                        onPressed: () async {
                          try {
                            await _initializeControllerFuture;
                            final image = await _controller.takePicture();
                            Navigator.pop(context, image.path);
                          } catch (e) {
                            print('Error taking picture: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.camera_alt,
                            color: Colors.black, size: 30),
                      ),
                      SizedBox(width: 56),
                    ],
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _currentCamera.lensDirection ==
                                CameraLensDirection.front
                            ? 'Front Camera'
                            : 'Back Camera',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
        },
      ),
    );
  }
}
