// Function to request location access
import 'package:flutter/foundation.dart';
import 'package:location/location.dart';

Future<void> requestLocationAccess() async {
  try {
    // Create a Location instance
    Location location = Location();

    // Variables to track service and permission status
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location service is enabled
    serviceEnabled = await location.serviceEnabled();

    // If location service is not enabled, request the user to enable it
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      // If the user still doesn't enable the service, exit the function
      if (!serviceEnabled) {
        return;
      }
    }

    // Check the current location permission status
    permissionGranted = await location.hasPermission();

    // If permission is denied, request the user to grant permission
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      // If the user doesn't grant permission, exit the function
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    // Location access successfully granted
  } catch (error) {
    if (kDebugMode) {
      print(error.toString());
    }
  }
}
