import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart'; // Import Geocoding
import 'package:geolocator/geolocator.dart'; // Import Geolocator
import 'package:image_picker/image_picker.dart';
import 'package:pcmc_jeevan_praman/Life_certificate_generate_screen/vedio_record_screen.dart';
// Import your new screen

class PhotoClickScreen extends StatefulWidget {
  final String ppoNumber;
  final String aadhaarNumber;

  const PhotoClickScreen({
    super.key,
    required this.aadhaarNumber,
    required this.ppoNumber,
  });

  @override
  _PhotoClickScreenState createState() => _PhotoClickScreenState();
}

class _PhotoClickScreenState extends State<PhotoClickScreen> {
  File? _image;
  bool _isLoading = false;
  String? _latitude;
  String? _longitude;
  String? _address; // Add a variable to store the address

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });

      // Get the current location after the image is captured
      await _getCurrentLocation();
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
            borderRadius: BorderRadius.circular(20.0), // Rounded corners
          ),
          title: const Row(
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
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(thickness: 2.5), // Top divider
              Text(
                'Are you sure you want to submit the photo?\nतुम्हाला खात्री आहे की तुम्ही हा फोटो सबमिट करू इच्छिता?',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              Divider(thickness: 2.5), // Bottom divider
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancle', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Submit button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _navigateToVideoRecordScreen(); // Navigate to the next screen
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
          builder: (context) => VideoRecordScreen(
            ppoNumber: widget.ppoNumber,
            imagePath: _image!.path,
            aadhaarNumber: widget.aadhaarNumber,
            latitude: _latitude!, // Passing latitude
            longitude: _longitude!,
            address: _address!,
            // inputFieldOneValue: widget.inputFieldOneValue,
            // selectedDropdownValue: widget.selectedDropdownValue,
            // Passing longitude
          ),
        ),
      );
    } else {
      print("No image or location data to submit.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Upload Photo  [Step-3]',
            style: TextStyle(
              color: Colors.black, // White text color for contrast
              fontSize: 22, // Font size for the title
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Color(0xFF92B7F7),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 50, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   'Note: Before click photo please turn on your device location',
                  //   style: TextStyle(
                  //     fontSize: 13,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.redAccent,
                  //   ),
                  // ),
                  // Text("Aadhar Number: ${widget.aadhaarNumber}"),
                  // Text("Input Field One Value: ${widget.inputFieldOneValue}"),
                  // Text(
                  //     "Selected Dropdown Value: ${widget.selectedDropdownValue ?? 'None'}"),
                  // Text(
                  //   'Aadhaar Number: ${widget.aadhaarNumber}',
                  //   style: const TextStyle(fontSize: 16, color: Colors.black),
                  // ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Click Pensioner Photo',
                      style: TextStyle(
                        fontSize: 24,
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
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      height: 400,
                      width: 350,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFF92B7F7), // Red border color
                          width: 2.0, // Border width
                        ),
                        borderRadius:
                            BorderRadius.circular(15), // Rounded corners
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Center(
                              child: _image == null
                                  ? Container(
                                      width: 250,
                                      height: 250,
                                      color: Colors.blueGrey,
                                      child: const Center(
                                        child: Text(
                                          'No Image Captured',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Image.file(
                                      _image!,
                                      height: 250,
                                      width: 250,
                                      fit: BoxFit.cover, // Adjust image fit
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: _getImage,
                              child: const Text(
                                "Click Photo\nफोटो काढा",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Display latitude and longitude if available
                  if (_latitude != null && _longitude != null)
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () {
                              if (_image != null &&
                                  _latitude != null &&
                                  _longitude != null) {
                                _showSubmitPhotoDialog(); // Show confirmation dialog before submitting
                              } else {
                                print("No image or location data to submit.");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 5,
                              shadowColor: Colors.green.withOpacity(0.3),
                            ),
                            child: const Text(
                              'Submit Photo\nफोटो सबमिट करा',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                              textAlign: TextAlign.center,
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
}
