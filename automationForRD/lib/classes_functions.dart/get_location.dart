// ignore_for_file: avoid_print

import 'package:geolocator/geolocator.dart';

Future<void> getLocation(bool flagA, Position devicePosition) async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print('Location Access Denied');
      return Future.error('Location permissions are denied');
    }
  }
  if (flagA) {
    try {
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 0,
        ),
      ).listen((Position newPosition) {
        devicePosition = newPosition;
      });
    } catch (e) {
      print('Error: $e');
    }
  }
}
