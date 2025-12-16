import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pcmc_jeevan_praman/life_certificate_screens/vedio_record_screen.dart';

class PhotoClickScreen extends StatefulWidget {
  final String ppoNumber;
  final String aadhaarNumber;
  final String mobileNumber;

  const PhotoClickScreen({
    super.key,
    required this.aadhaarNumber,
    required this.ppoNumber,
    required this.mobileNumber,
  });

  @override
  _PhotoClickScreenState createState() => _PhotoClickScreenState();
}

class _PhotoClickScreenState extends State<PhotoClickScreen> {
  File? _image;
  bool _isLoading = false;
  String? _latitude;
  String? _longitude;
  String? _address;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
        _isLoading = true; // Start loading
      });

      try {
        // Get the current location after the image is captured
        await _getCurrentLocation();
      } catch (e) {
        print('Error getting location: $e');
      } finally {
        setState(() {
          _isLoading = false; // Stop loading
        });
      }
    } else {
      print('No image selected.');
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    // Request location permissions if not already granted
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print(
          'Location permissions are permanently denied, we cannot request permissions.');
      return;
    }

    // Get the current position
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Update latitude and longitude values
    setState(() {
      _latitude = position.latitude.toString();
      _longitude = position.longitude.toString();
    });

    // Get the address based on the latitude and longitude
    await _getAddressFromCoordinates(position.latitude, position.longitude);
  }

  Future<void> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];

      setState(() {
        _address = ' ${place.locality}, ${place.postalCode}, ${place.country}';
      });
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  Future<void> _showSubmitPhotoDialog() async {
    // Show a confirmation dialog before submitting the photo
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
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
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToVideoRecordScreen();
              },
              child:
                  const Text('Submit', style: TextStyle(color: Colors.white)),
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
          builder: (context) => VideoRecordScreen(
            ppoNumber: widget.ppoNumber,
            imagePath: _image!.path,
            aadhaarNumber: widget.aadhaarNumber,
            latitude: _latitude!,
            longitude: _longitude!,
            address: _address!,
            mobileNumber: widget.mobileNumber,
          ),
        ),
      );
    } else {
      print("No image or location data to submit.");
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
              'Upload Photo  [Step-3]',
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
                        'पेन्शनर व्यक्तीचा फोटो काढा',
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
                    // Display submit button with loader
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
                            : Icon(
                                Icons.send,
                                size: width * 0.07,
                                color: Colors.white,
                              ),
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
                                      _isLoading ? Colors.blue : Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: _isLoading
                                    ? 'कृपया प्रतीक्षा करा...'
                                    : 'फोटो सबमिट करा',
                                style: TextStyle(
                                  color: _isLoading
                                      ? Color(0xFF92B7F7)
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isLoading ? Colors.grey : Colors.green,
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
