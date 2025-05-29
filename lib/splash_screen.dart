import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pcmc_jeevan_praman/aadhar_input_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:in_app_update/in_app_update.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AppUpdateInfo? _updateInfo;
  bool isFlexibleUpdateDownload = false;
  @override
  void initState() {
    super.initState();

    checkForUpdate();

    Future.wait([
      checkForUpdate(),
      Future.delayed(const Duration(seconds: 2)),
    ]).then((_) {
      if (mounted) {
        _showInfoPopup(context);
      }
    });
  }

  //checking for update to download
  Future<void> checkForUpdate() async {
    try {
      _updateInfo = await InAppUpdate.checkForUpdate();

      if (!mounted) return;

      if (_updateInfo?.updateAvailability ==
          UpdateAvailability.updateAvailable) {
        if (_updateInfo!.immediateUpdateAllowed) {
          _showUpdateDialog();
        } else if (_updateInfo!.flexibleUpdateAllowed) {
          _showUpdateNotification();
        }
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
    }
  }

  // void checkForUpdate() async {
  //   await Future.delayed(Duration(seconds: 9));

  //   _showUpdateDialog();
  //   _showUpdateNotification();
  // }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Update Available'),
        content: const Text(
            'A new version of the app is available. Please update to continue.'),
        actions: [
          TextButton(
            onPressed: () {
              performImmediateUpdate();
              Navigator.of(context).pop();
            },
            child: const Text('Update'),
          ),
          SizedBox(
            width: 5,
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Canle'),
          ),
        ],
      ),
    );
  }

  void _showUpdateNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('A new update is available'),
        action: SnackBarAction(
          label: 'Update',
          onPressed: performFlexibleUpdate,
        ),
      ),
    );
  }

  Future<void> performImmediateUpdate() async {
    try {
      await InAppUpdate.performImmediateUpdate();
    } catch (e) {
      print('Immediate update failed: $e');
    }
  }

  Future<void> performFlexibleUpdate() async {
    try {
      await InAppUpdate.startFlexibleUpdate();

      await InAppUpdate.completeFlexibleUpdate();
    } catch (e) {
      print('Flexible update failed: $e');
    }
  }

  Future<void> _requestLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Show a dialog to enable location services
      _showEnableLocationDialog(context);
      return;
    }

    // Check permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showPermissionDeniedDialog(context);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showPermissionDeniedDialog(context);
      return;
    }

    // If permission granted, proceed to AadharInputScreen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AadharInputScreen()),
    );
  }

  void _showInfoPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.only(top: 233.0), // Add 40px top padding
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Image.asset(
                    "assets/images/policy_image.jpeg",
                    fit: BoxFit.contain,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(05.0),
                    child: IconButton(
                      icon: const Icon(Icons.cancel,
                          size: 40, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEnableLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // Rounded corners
          ),
          title: const Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue, size: 28), // Icon
              SizedBox(width: 10),
              Text(
                'Enable Location', // Title text
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(thickness: 2.5), // Top divider
              Text(
                'Location services are disabled. Please enable location to continue.\n'
                'स्थान सेवा अक्षम आहेत. कृपया स्थान सक्षम करा.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              Divider(thickness: 2.5), // Bottom divider
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onPressed: () async {
                await Geolocator.openLocationSettings();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Enable'),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Location Permission Denied"),
          content: const Text(
              "You have denied location access. Please allow it from app settings."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await openAppSettings();
                Navigator.pop(context);
              },
              child: const Text("Open Settings"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/pcmc_logo.jpeg",
                    width: 170.0,
                    height: 170.0,
                  ),
                  const Text(
                    "पिंपरी चिंचवड महानगरपालिका",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Text(
                    "पिंपरी- ४११०१८",
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
                  ),
                  const Text(
                    "निवृत्ती वेतनधारक हयातीचे प्रमाणपत्र",
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
                  ),
                  const Text(
                    "(2025-2026)",
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xFF92B7F7), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Generate  Life Certificate\n जीवन प्रमाणपत्र तैयार करा',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => _requestLocationPermission(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 4,
                            shadowColor: Colors.green.withOpacity(0.3),
                          ),
                          child: const Text(
                            'Click Here\nयेथे क्लिक करा',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 50),
                  Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            'Powered by',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ),
                      ),
                      Image.asset(
                        "assets/images/Bank_of_Maharashtra_logo.png",
                        width: 230.0,
                        height: 70.0,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:pcmc_jeevan_praman/aadhar_input_screen.dart';
// import 'package:permission_handler/permission_handler.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Show popup after 3 seconds
//     Future.delayed(const Duration(seconds: 2), () {
//       if (mounted) {
//         _showInfoPopup(context);
//       }
//     });
//   }

//   Future<void> _requestLocationPermission(BuildContext context) async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     // Check if location services are enabled
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       // Show a dialog to enable location services
//       _showEnableLocationDialog(context);
//       return;
//     }

//     // Check permission status
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         _showPermissionDeniedDialog(context);
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       _showPermissionDeniedDialog(context);
//       return;
//     }

//     // If permission granted, proceed to AadharInputScreen
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => AadharInputScreen()),
//     );
//   }

//   void _showInfoPopup(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return Dialog(
//           insetPadding: EdgeInsets.zero,
//           backgroundColor: Colors.transparent,
//           child: Padding(
//             padding: const EdgeInsets.only(top: 233.0), // Add 40px top padding
//             child: ConstrainedBox(
//               constraints: BoxConstraints(
//                 maxWidth: MediaQuery.of(context).size.width * 0.9,
//                 maxHeight: MediaQuery.of(context).size.height * 0.9,
//               ),
//               child: Stack(
//                 alignment: Alignment.topRight,
//                 children: [
//                   Image.asset(
//                     "assets/images/policy_image.jpeg",
//                     fit: BoxFit.contain,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(05.0),
//                     child: IconButton(
//                       icon: const Icon(Icons.cancel,
//                           size: 40, color: Colors.white),
//                       onPressed: () => Navigator.of(context).pop(),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _showEnableLocationDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20.0), // Rounded corners
//           ),
//           title: const Row(
//             children: [
//               Icon(Icons.location_on, color: Colors.blue, size: 28), // Icon
//               SizedBox(width: 10),
//               Text(
//                 'Enable Location', // Title text
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           content: const Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Divider(thickness: 2.5), // Top divider
//               Text(
//                 'Location services are disabled. Please enable location to continue.\n'
//                 'स्थान सेवा अक्षम आहेत. कृपया स्थान सक्षम करा.',
//                 style: TextStyle(fontSize: 16),
//                 textAlign: TextAlign.center,
//               ),
//               Divider(thickness: 2.5), // Bottom divider
//             ],
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Cancel', style: TextStyle(color: Colors.red)),
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//             ),
//             TextButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue, // Button color
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.0),
//                 ),
//               ),
//               onPressed: () async {
//                 await Geolocator.openLocationSettings();
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//               child: const Text('Enable'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showPermissionDeniedDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Location Permission Denied"),
//           content: const Text(
//               "You have denied location access. Please allow it from app settings."),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text("Cancel"),
//             ),
//             TextButton(
//               onPressed: () async {
//                 await openAppSettings();
//                 Navigator.pop(context);
//               },
//               child: const Text("Open Settings"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(),
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Center(
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Image.asset(
//                     "assets/images/pcmc_logo.jpeg",
//                     width: 170.0,
//                     height: 170.0,
//                   ),
//                   const Text(
//                     "पिंपरी चिंचवड महानगरपालिका",
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//                   ),
//                   const Text(
//                     "पिंपरी- ४११०१८",
//                     style:
//                         TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
//                   ),
//                   const Text(
//                     "निवृत्ती वेतनधारक हयातीचे प्रमाणपत्र",
//                     style:
//                         TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
//                   ),
//                   const Text(
//                     "(2025-2026)",
//                     style:
//                         TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
//                   ),
//                   const SizedBox(
//                     height: 30,
//                   ),
//                   Container(
//                     padding: const EdgeInsets.all(15),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: Color(0xFF92B7F7), width: 3),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.red.withOpacity(0.5),
//                           spreadRadius: 5,
//                           blurRadius: 7,
//                           offset: const Offset(0, 3),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         Text(
//                           'Generate  Life Certificate\n जीवन प्रमाणपत्र तैयार करा',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blue[900],
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         ElevatedButton(
//                           onPressed: () => _requestLocationPermission(context),
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 50, vertical: 15),
//                             backgroundColor: Colors.green,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(25),
//                             ),
//                             elevation: 4,
//                             shadowColor: Colors.green.withOpacity(0.3),
//                           ),
//                           child: const Text(
//                             'Click Here\nयेथे क्लिक करा',
//                             style: TextStyle(fontSize: 18, color: Colors.white),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 50),
//                   Column(
//                     children: [
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 15),
//                           child: Text(
//                             'Powered by',
//                             style: TextStyle(fontSize: 18, color: Colors.black),
//                           ),
//                         ),
//                       ),
//                       Image.asset(
//                         "assets/images/Bank_of_Maharashtra_logo.png",
//                         width: 230.0,
//                         height: 70.0,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:pcmc_jeevan_praman/aadhar_input_screen.dart';
// import 'package:permission_handler/permission_handler.dart';

// class SplashScreen extends StatelessWidget {
//   const SplashScreen({super.key});

//   Future<void> _requestLocationPermission(BuildContext context) async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     // Check if location services are enabled
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       // Show a dialog to enable location services
//       _showEnableLocationDialog(context);
//       return;
//     }

//     // Check permission status
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         _showPermissionDeniedDialog(context);
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       _showPermissionDeniedDialog(context);
//       return;
//     }

//     // If permission granted, proceed to AadharInputScreen
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => AadharInputScreen()),
//     );
//   }

//   void _showEnableLocationDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20.0), // Rounded corners
//           ),
//           title: const Row(
//             children: [
//               Icon(Icons.location_on, color: Colors.blue, size: 28), // Icon
//               SizedBox(width: 10),
//               Text(
//                 'Enable Location', // Title text
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           content: const Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Divider(thickness: 2.5), // Top divider
//               Text(
//                 'Location services are disabled. Please enable location to continue.\n'
//                 'स्थान सेवा अक्षम आहेत. कृपया स्थान सक्षम करा.',
//                 style: TextStyle(fontSize: 16),
//                 textAlign: TextAlign.center,
//               ),
//               Divider(thickness: 2.5), // Bottom divider
//             ],
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Cancel', style: TextStyle(color: Colors.red)),
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//             ),
//             TextButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue, // Button color
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.0),
//                 ),
//               ),
//               onPressed: () async {
//                 await Geolocator.openLocationSettings();
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//               child: const Text('Enable'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showPermissionDeniedDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Location Permission Denied"),
//           content: const Text(
//               "You have denied location access. Please allow it from app settings."),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text("Cancel"),
//             ),
//             TextButton(
//               onPressed: () async {
//                 await openAppSettings();
//                 Navigator.pop(context);
//               },
//               child: const Text("Open Settings"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//             // border: Border.all(
//             //     color: Colors.red, width: 5), // Red border for the whole screen
//             ),
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Center(
//             child: SingleChildScrollView(
//               child: Column(
//                 // mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Image.asset(
//                     "assets/images/pcmc_logo.jpeg",
//                     width: 170.0, // Adjust the width as needed
//                     height: 170.0, // Adjust the height as needed
//                   ),
//                   const Text(
//                     "पिंपरी चिंचवड महानगरपालिका",
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//                   ),
//                   const Text(
//                     "पिंपरी- ४११०१८",
//                     style:
//                         TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
//                   ),
//                   const Text(
//                     "निवृत्ती वेतनधारक हयातीचे प्रमाणपत्र",
//                     style:
//                         TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
//                   ),
//                   const Text(
//                     "(2025-2026)",
//                     style:
//                         TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
//                   ),
//                   // const Text(
//                   //   "(2025-2026)",
//                   //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//                   // ),
//                   const SizedBox(
//                     height: 30,
//                   ),
//                   // First Container: Contains Generate Divyang Life Certificate text and Click Here button
//                   Container(
//                     padding: const EdgeInsets.all(15),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(
//                           color: Color(0xFF92B7F7), width: 3), // Red border
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.red.withOpacity(0.5), // Red shadow
//                           spreadRadius: 5,
//                           blurRadius: 7,
//                           offset: const Offset(0, 3),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         // Heading Text
//                         Text(
//                           'Generate  Life Certificate\n जीवन प्रमाणपत्र तैयार करा',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blue[900], // Blue text color
//                           ),
//                         ),
//                         const SizedBox(
//                             height: 20), // Space between text and button

//                         // Click Here Button
//                         ElevatedButton(
//                           onPressed: () => _requestLocationPermission(context),

//                           // Navigator.push(
//                           //   context,
//                           //   MaterialPageRoute(
//                           //       builder: (context) => AadharInputScreen()),
//                           // );
//                           // Handle the click event

//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 50, vertical: 15),
//                             backgroundColor: Colors.green,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(25),
//                             ),
//                             elevation: 4,
//                             shadowColor: Colors.green.withOpacity(0.3),
//                           ),
//                           child: const Text(
//                             'Click Here\nयेथे क्लिक करा',
//                             style: TextStyle(fontSize: 18, color: Colors.white),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 50),
//                   Column(
//                     children: [
//                       Align(
//                         alignment: Alignment
//                             .centerLeft, // Aligns only this text to the left
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 15),
//                           child: Text(
//                             'Powered by',
//                             style: TextStyle(fontSize: 18, color: Colors.black),
//                           ),
//                         ),
//                       ),
//                       // This adds the 10 pixel space
//                       Image.asset(
//                         "assets/images/Bank_of_Maharashtra_logo.png",
//                         width: 230.0,
//                         height: 70.0,
//                       ),
//                     ],
//                   ),
//                   // Space between the two containers
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
