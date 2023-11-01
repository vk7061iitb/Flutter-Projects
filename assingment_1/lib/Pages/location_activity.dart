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
  final Set<Polyline> _polylines = {}; // Stores the polyline between start and end position
  LatLng? initialCameraPosition; // Store the latitude and Longitude of start position
  LatLng? finalcameraPosition; // Store the latitude and Longitude of end position
  final Map<String, Marker> _markers = {};
  // Set to store the Markers
  final Set<Marker> _newMarkers = {};
  //Contais the current position obtain through geolocator
  List<Position> positionsList = [];
  late Position currentPosition;
  late Position firstPosition;
  // TextEditingController place1Controller = TextEditingController();
  // TextEditingController place2Controller = TextEditingController();

/*   static final Marker startMarker = Marker(
    markerId: const MarkerId('start'),
    infoWindow: const InfoWindow(title: 'Your Starting Position'),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)); */

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _listenToLocationUpdates();
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
    }
  }

// Function to get the continuous location of user
  void _listenToLocationUpdates() {
    Geolocator.getPositionStream(locationSettings:
    const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1,
    )).listen(
    (Position newposition) {
        setState(() {
          currentPosition = newposition;
          positionsList.add(currentPosition);
        });
    });
  }

// Function to remove a marker with specified "ID"
  void removeMarker(String markerId) {
    setState(() {
      _newMarkers.removeWhere((marker) => marker.markerId.value == markerId);
    });
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
            markers: _newMarkers,
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
                desiredAccuracy: LocationAccuracy.high,),
                _polylines.clear(),
                removeMarker('Your Starting Point'),
                removeMarker('Your Ending Point'),
                // Adding Marker For Starting Point
                _newMarkers.add(
                  Marker(markerId: const MarkerId('Your Starting Point'),
                  position: LatLng(startPosition.latitude, startPosition.longitude),
                  infoWindow: const InfoWindow(
                    title: 'Your Starting Point'
                  ),
                  )
                ),
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
                    finalcameraPosition = LatLng(endPosition.latitude, endPosition.longitude),
                    _newMarkers.add(Marker(
                      markerId: const MarkerId('Your Ending Point'),
                      position: LatLng(positionsList[positionsList.length-1].latitude, positionsList[positionsList.length-1].longitude),
                      infoWindow: const InfoWindow(
                        title: 'Your Ending Point'
                      ),
                      ),),
                      drawPolylineBetweenPositions(positionsList),
                    
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

/* // addMarker Function to add marker at your current position
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
  } */

  void drawPolylineBetweenPositions(List<Position> positionsList) {
  _updatePolylines(positionsList);
}

void _updatePolylines(List<Position> positionsList) {
  List<LatLng> points = [];

  for (int i = 0; i < positionsList.length - 1; i++) {
    points.add(LatLng(positionsList[i].latitude, positionsList[i].longitude));
  }

  Polyline polyline = Polyline(
    polylineId: const PolylineId('updatedroute'),
    color: Colors.blue,
    width: 5,
    points: points,
  );

  _updateState(polyline, points);
}

void _updateState(Polyline polyline, List<LatLng> points) {
  setState(() {
    _polylines.clear(); // Clear any existing polylines
    _polylines.add(polyline); // Add the new polyline

    if (points.isNotEmpty) {
      LatLngBounds bounds = LatLngBounds(southwest: points.first, northeast: points.last);
      mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    }
  });
}
}
