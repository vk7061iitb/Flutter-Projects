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
  LatLng initialCameraPosition = const LatLng(0, 0);
  // Store the latitude and Longitude of end position
  late LatLng currCameraPosition;
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
  bool flagA = true;
  bool flagB = false;
  late LatLngBounds bounds;
  late List<Position> positionList2;

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
          initialCameraPosition = LatLng(positionsList[0].latitude, positionsList[0].longitude);
          currCameraPosition = LatLng(positionsList[positionsList.length-1].latitude, positionsList[positionsList.length-1].longitude);
          if(flagA){
            mapController.animateCamera(
            CameraUpdate.newLatLng(currCameraPosition));
          }
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
              target: initialCameraPosition,
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
                flagA = true,
                _polylines.clear(),
                positionsList.clear(),
                _getCurrentLocation(),
                _listenToLocationUpdates(),
                positionsList.clear(),
                startPosition = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high,),
                removeMarker('SP'),
                removeMarker('EP'),
                totalDistance = 0.0,
                avgSpeed = 0.0,
                startTime = DateTime.now(),
                // Adding Marker For Starting Point
                _newMarkers.add(
                  Marker(markerId: const MarkerId('SP'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                  position: LatLng(startPosition.latitude, startPosition.longitude),
                  infoWindow: const InfoWindow(
                    title: 'Your Starting Point'
                  ),
                  ),
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

          // End Button
          Positioned(
            bottom: 22,
            left: 100,
            child: ElevatedButton(
              onPressed: () async =>{
                flagA = false,
                //flagB = false,
                positionList2 = positionsList.toList(),
                positionsList.clear(),
                endPosition = positionList2[positionList2.length-1],
                endTime = DateTime.now(),
                _newMarkers.add(Marker(
                  markerId: const MarkerId('EP'),
                  position: LatLng(endPosition.latitude, endPosition.longitude),
                  infoWindow: const InfoWindow(
                    title: 'Your Ending Point'
                  ),
                  ),),
                  computedrawPolylineBetweenPositions(positionList2),
                  // Updating the total distance
                  totalDistance = Geolocator.distanceBetween(positionList2[0].latitude, positionList2[0].longitude, endPosition.latitude, endPosition.longitude),
                  // Updating the total duration value
                  totalDuration = endTime.difference(startTime),
                  // Calculating avg. speed in kmph
                  avgSpeed = (totalDistance/totalDuration.inSeconds)*18.0/5.0,
                  //bounds = LatLngBounds(southwest: LatLng(positionList2[0].latitude, positionList2[0].longitude), northeast: LatLng(endPosition.latitude, endPosition.longitude)),
                  //mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100)),
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
  void computedrawPolylineBetweenPositions(List<Position> positionsList) {

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
  });
}
}