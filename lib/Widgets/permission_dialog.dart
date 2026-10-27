import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionDialogs {
  static void showEnableLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue, size: 28),
              SizedBox(width: 10),
              Text(
                'Enable Location',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(thickness: 2.5),
              Text(
                'Location services are disabled. Please enable location to continue.\n'
                'स्थान सेवा अक्षम आहेत. कृपया स्थान सक्षम करा.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              Divider(thickness: 2.5),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onPressed: () async {
                await Geolocator.openLocationSettings();
                Navigator.of(context).pop();
              },
              child: const Text('Enable'),
            ),
          ],
        );
      },
    );
  }

  static void showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Location Permission Denied"),
          content: const Text(
              "You have denied location access. Please allow it from app settings."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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
}