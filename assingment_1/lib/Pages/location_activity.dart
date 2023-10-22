import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationActivity extends StatefulWidget {
  const LocationActivity({Key? key}) : super(key: key);

  @override
  _LocationActivityState createState() => _LocationActivityState();
}

class _LocationActivityState extends State<LocationActivity> {
  late GoogleMapController mapController;
  LatLng? initialCameraPosition;
  final Map<String, Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      initialCameraPosition = LatLng(position.latitude, position.longitude);
    });

    // When the get location button is tapped then updating the Camera position
    if (initialCameraPosition != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLng(initialCameraPosition!),
      );

      // Add a marker after getting the location
      addMarker('user', initialCameraPosition!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          "Show My Location",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              mapController = controller;
            },
            markers: _markers.values.toSet(),
            initialCameraPosition: CameraPosition(
              target: initialCameraPosition ?? const LatLng(0, 0),
              zoom: 15.0,
            ),
          ),

          Positioned(
            bottom: 22,
            left: 16,
            child: ElevatedButton(
              onPressed: _getCurrentLocation,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                ),
              ),
              child: const Text(
                'Get Location',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// Add Marker Function to add marker at your current position
  addMarker(String id, LatLng location) {
    var marker = Marker(
      markerId: MarkerId(id),
      position: location,
      infoWindow: const InfoWindow(
        title: "Your Current Location",
      ),
    );

    _markers[id] = marker;
    setState(() {});
  }
}
