import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationActivity extends StatefulWidget {
  const LocationActivity({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LocationActivityState createState() => _LocationActivityState();
}

class _LocationActivityState extends State<LocationActivity> {
  late GoogleMapController mapController;
  late LocationData _locationData;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _getCurrentLocation() async {
    var location = Location();
    _locationData = await location.getLocation();
    mapController.animateCamera(
      CameraUpdate.newLatLng(
        const LatLng(0, 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Location Activity"),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(_locationData.latitude!, _locationData.longitude!), // Initial position
          zoom: 15.0,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.location_on),
      ),
    );
  }
}
