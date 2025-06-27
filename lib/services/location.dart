import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

// Custom Exception for location-related issues
class LocationException implements Exception {
  final String message;
  LocationException(this.message);

  @override
  String toString() => message; // Make it easy to get the message
}

class Location {
  double? latitude;
  double? longitude;

  Future<void> getCurrentLocation() async {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.low,
      distanceFilter: 100,
    );

    try {
      await _getUserPermissionForLocation();
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      latitude = position.latitude;
      longitude = position.longitude;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      throw LocationException('Error getting position: $e');
      //return Future.error(e);
    }
  }

  Future<void> _getUserPermissionForLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException('Location services are disabled.');
      // return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException('Location permissions are denied');
        //return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      throw LocationException(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
      // return Future.error(
      //   'Location permissions are permanently denied, we cannot request permissions.',
      // );
    }
  }
}

// Global function to show an error dialog
Future<void> showErrorDialog({
  required BuildContext context, // Requires the context from where it's called
  required String title,
  required String message,
  bool showOpenSettingsButton = false, // Optional: for permission errors
  VoidCallback? onOkPressed, // Optional: custom action for OK
  VoidCallback? onSettingsPressed, // Optional: custom action for Settings
}) async {
  // It's crucial that the passed 'context' is valid and mounted.
  // The caller should ensure this.
  if (!Navigator.of(context).mounted) return;

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap a button
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(children: <Widget>[Text(message)]),
        ),
        actions: <Widget>[
          if (showOpenSettingsButton)
            TextButton(
              onPressed:
                  onSettingsPressed ?? // Use provided callback or default
                  () {
                    Geolocator.openAppSettings();
                    Navigator.of(dialogContext).pop();
                  },
              child: const Text('Open Settings'),
            ),
          TextButton(
            onPressed:
                onOkPressed ?? // Use provided callback or default
                () {
                  Navigator.of(dialogContext).pop();
                },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
