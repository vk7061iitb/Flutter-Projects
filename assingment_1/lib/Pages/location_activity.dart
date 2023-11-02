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
  // to store location when the start button is tapped
  late Position startPosition;
  // to store location when the start button is tapped
  late Position endPosition;
  // Stores the polyline between start and end positions
  final Set<Polyline> _polylines = {};
  // Store the latitude and Longitude of start position
  LatLng? initialCameraPosition;
  // Store the latitude and Longitude of end position
  LatLng? finalcameraPosition;
  // Set to store the Markers
  final Set<Marker> _newMarkers = {};
  //Contais the current position obtain through geolocator
  List<Position> positionsList = [];
  late Position currentPosition;
  // Store the total distance between start and end position in meters
  late double totalDistance = 0.0;
  late DateTime startTime ;
  late DateTime endTime ;
  // Stores the time difference between start and end time
  late Duration totalDuration;
  double avgSpeed = 0.0;

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

    setState((){
      initialCameraPosition = LatLng(position.latitude, position.longitude);
    });

    // When the get location button is tapped then updating the Camera position
    /* if (initialCameraPosition != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLng(initialCameraPosition!),
      );
    } */
  }

// Function to get the continuous location of user
  void _listenToLocationUpdates() {
    Geolocator.getPositionStream(locationSettings:
    const LocationSettings(
      accuracy: LocationAccuracy.high,
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
        elevation: 0,
        title: const Text(
          "Location Activity",
          style: TextStyle(
            fontSize: 26,
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
              target: initialCameraPosition!,
              zoom: 15.0,
            ),
          ),

          Positioned(
            top: 5,
            right: 5,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.red
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Total Distance Moved is ${double.parse(totalDistance.toStringAsFixed(2))} m',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600
                ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 40,
            right: 5,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.red
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Avg. Speed is ${double.parse(avgSpeed.toStringAsFixed(2))} kmph',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600
                ),
                ),
              ),
            ),
          ),

          // Start Button
          Positioned(
            bottom: 22,
            left: 16,
            child: ElevatedButton(
              onPressed: () async =>{
                _getCurrentLocation(),
                startPosition = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high,),
                _newMarkers.add(
                  Marker(markerId: const MarkerId('SP'),
                  position: LatLng(startPosition.latitude, startPosition.longitude),
                  infoWindow: const InfoWindow(
                    title: 'Your Starting Point'
                  ),
                  ),
                ),
                removeMarker('SP'),
                removeMarker('EP'),
                _polylines.clear(),
                positionsList.clear(),
                totalDistance = 0.0,
                avgSpeed = 0.0,
                startTime = DateTime.now(),
                // Adding Marker For Starting Point
                
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

          // End Button
          Positioned(
            bottom: 22,
            left: 100,
            child: ElevatedButton(
              onPressed: () async =>{
                    endPosition = positionsList[positionsList.length-1],
                    endTime = DateTime.now(),
                    _newMarkers.add(Marker(
                      markerId: const MarkerId('EP'),
                      position: LatLng(endPosition.latitude, endPosition.longitude),
                      infoWindow: const InfoWindow(
                        title: 'Your Ending Point'
                      ),
                      ),),
                      drawPolylineBetweenPositions(positionsList),
                      // Updating the total distance
                      totalDistance = Geolocator.distanceBetween(startPosition.latitude, startPosition.longitude, endPosition.latitude, endPosition.longitude),
                      // Updating the total duration value
                      totalDuration = endTime.difference(startTime),
                      // Calculating avg. speed in kmph
                      avgSpeed = (totalDistance/totalDuration.inSeconds)*18.0/5.0,
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

  // Method to draw polylines between the points
  void drawPolylineBetweenPositions(List<Position> positionsList) {

    // Creating a List of points to store Latitude and longitude of all positions
  List<LatLng> points = [];

  // Using for loop to add all Positions' latitude & longitude in to points(list)
  for (int i = 0; i < positionsList.length - 1; i++) {
    points.add(LatLng(positionsList[i].latitude, positionsList[i].longitude));
  }
  // Creating Polylines between all the points
  Polyline polyline = Polyline(
    polylineId: const PolylineId('updatedroute'),
    color: Colors.blue,
    width: 5,
    points: points,
  );

  setState(() {
    _polylines.add(polyline); // Add the new polyline

    if (points.isNotEmpty) {
      LatLngBounds bounds = LatLngBounds(southwest: points.first, northeast: points.last);
      mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
      
    }
  });
}
}