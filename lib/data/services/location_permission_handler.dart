import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pcmc_jeevan_praman/screens/ppo_entry_screen.dart';
import 'package:pcmc_jeevan_praman/widgets/permission_dialog.dart';

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
      MaterialPageRoute(builder: (context) => const PpoEntryScreen()),
    );
  }
}
