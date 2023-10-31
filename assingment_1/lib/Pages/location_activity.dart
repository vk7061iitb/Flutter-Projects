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
  late Position startPosition; // to store location when the start button is tapped
  late Position endPosition; // To store location when end button is tapped
  Set<Polyline> _polylines = {};
  LatLng? initialCameraPosition;
  final Map<String, Marker> _markers = {};
  TextEditingController place1Controller = TextEditingController();
  TextEditingController place2Controller = TextEditingController();


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
            mapType: MapType.normal,
            polylines: _polylines,
            markers: {..._markers.values}.toSet(),
            initialCameraPosition: CameraPosition(
              target: initialCameraPosition ?? const LatLng(0, 0),
              zoom: 15.0,
            ),
          ),

          Positioned(
            bottom: 22,
            left: 16,
            child: ElevatedButton(
              onPressed: () async =>{
                _getCurrentLocation(),
                startPosition = await Geolocator.getCurrentPosition(
                        desiredAccuracy: LocationAccuracy.high,)
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                ),
              ),
              child: const Text(
                'Start',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 22,
            right: 16,
            child: ElevatedButton(
              onPressed: () async =>{
                    endPosition = await Geolocator.getCurrentPosition(
                        desiredAccuracy: LocationAccuracy.high,),
                    drawPolylineBetweenPositions(startPosition, endPosition),
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                ),
              ),
              child: const Text(
                'End',
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

// addMarker Function to add marker at your current position
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

  void drawPolylineBetweenPositions(Position start, Position end) {
    Polyline polyline = Polyline(
      polylineId: const PolylineId('route'),
      color: Colors.blue,
      width: 5,
      points: [
        LatLng(start.latitude, start.longitude),
        LatLng(end.latitude, end.longitude),
      ],
    );

    setState(() {
      _polylines.clear(); // Clear any existing polylines
      _polylines.add(polyline); // Add the new polyline
    });

    // Zoom to fit both start and end positions with some padding
    LatLngBounds bounds = LatLngBounds(southwest: LatLng(start.latitude, start.longitude), northeast: LatLng(end.latitude, end.longitude));
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }
}
