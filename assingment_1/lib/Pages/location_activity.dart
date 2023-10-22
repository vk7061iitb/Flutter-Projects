import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationActivity extends StatefulWidget {
  const LocationActivity({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LocationActivityState createState() => _LocationActivityState();
}

class _LocationActivityState extends State<LocationActivity> {
  late GoogleMapController mapController;
  LatLng? initialCameraPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Function to get user's current location with his/her permission using Geolocator package
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    // If the permission is denied then exit the function
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Storing the latitude and longitude got from "_getcurrentposition" function in "initialcameraposition"
    setState(() {
      initialCameraPosition = LatLng(position.latitude, position.longitude);
    });

    // When the get location button is tapped then updating the Camera position
    if (initialCameraPosition != null) {
      mapController.animateCamera(
      // Using animate camera for smooth movement of camera view
        CameraUpdate.newLatLng(initialCameraPosition!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("Show My Location",
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
            initialCameraPosition: CameraPosition(
              target: initialCameraPosition ?? const LatLng(0, 0),
              zoom: 15.0,
            ),
          ),
          Positioned(
            bottom: 22,
            left: 16,

  
            // Button to get the current location of the user
            child: ElevatedButton(
             onPressed: _getCurrentLocation,
             style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              ),
             ),
             child: const Text('Get Location',
             style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
             ),),
             )
          ),
        ],
      ),
    );
  }
}
