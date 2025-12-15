import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pcmc_jeevan_praman/Widgets/permission_dialog_dart';
import 'package:pcmc_jeevan_praman/aadhar_input_screen.dart';

class LocationPermissionHandler {
  static Future<void> request(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      PermissionDialogs.showEnableLocationDialog(context);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        PermissionDialogs.showEnableLocationDialog(context);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      PermissionDialogs.showEnableLocationDialog(context);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AadharInputScreen()),
    );
  }
}
