import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const LatLng currentLocation = LatLng(19.134, 72.911);

class LocationActivity extends StatefulWidget {
  @override
  _LocationActivityState createState() => _LocationActivityState();
}

class _LocationActivityState extends State<LocationActivity> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: currentLocation,
          zoom: 15.0,
        ),
      ),
    );
  }
}
