import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  late Position startPosition;
  late Position endPosition;
  final Set<Polyline> _polylines = {};
  LatLng initialCameraPosition = const LatLng(0, 0);
  late LatLng currCameraPosition;
  // Set to store the Markers
  final Set<Marker> _newMarkers = {};
  //Contais the current position obtain through geolocator
  List<Position> positionsList = [];
  late Position currentPosition;
  // Store the total distance between start and end position in meters
  late double totalDistance = 0.0;
  // Note the time when 'Start' button is tapped
  late DateTime startTime;
  // Note the time when 'End' button is tapped
  late DateTime endTime;
  // Stores the time difference between start and end time
  late Duration totalDuration;
  double avgSpeed = 0.0;
  // Bool variable to control the camera animate
  bool flagA = true;
  // Bool variable to stop the readings
  bool flagB = false;
  late LatLngBounds bounds;
  late List<Position> positionList2;
  // Bool varible for Animated crossfade widget
  bool _first = true;

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
    Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1,
    )).listen((Position newposition) {
      setState(() {
        currentPosition = newposition;
        positionsList.add(currentPosition);
        initialCameraPosition =
            LatLng(positionsList[0].latitude, positionsList[0].longitude);
        currCameraPosition = LatLng(
            positionsList[positionsList.length - 1].latitude,
            positionsList[positionsList.length - 1].longitude);
        if (flagA) {
          mapController
              .animateCamera(CameraUpdate.newLatLng(currCameraPosition));
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
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: (controller) {
                mapController = controller;
              },
              padding: const EdgeInsets.all(10),
              mapType: MapType.normal,
              polylines: _polylines,
              markers: _newMarkers,
              initialCameraPosition: CameraPosition(
                target: initialCameraPosition,
                zoom: 15.0,
              ),
            ),
            Positioned(
              top: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15)),
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.add_road_outlined,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          totalDistance.toStringAsFixed(2),
                          style: GoogleFonts.raleway(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(
                        'm',
                        style: GoogleFonts.raleway(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
                top: 10,
                right: 10,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.speed_outlined,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            avgSpeed.toStringAsFixed(2),
                            style: GoogleFonts.raleway(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          'kmph',
                          style: GoogleFonts.raleway(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      )
                    ],
                  ),
                )),
            Positioned(
              bottom: 5,
              left: 16,
              child: AnimatedCrossFade(
                firstChild: ElevatedButton(
                  onPressed: () async => {
                    flagA = true,
                    _first = false,
                    _polylines.clear(),
                    positionsList.clear(),
                    _getCurrentLocation(),
                    _listenToLocationUpdates(),
                    positionsList.clear(),
                    startPosition = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.high,
                    ),
                    removeMarker('SP'),
                    removeMarker('EP'),
                    totalDistance = 0.0,
                    avgSpeed = 0.0,
                    startTime = DateTime.now(),
                    // Adding Marker For Starting Point
                    _newMarkers.add(
                      Marker(
                        markerId: const MarkerId('SP'),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueBlue),
                        position: LatLng(
                            startPosition.latitude, startPosition.longitude),
                        infoWindow:
                            const InfoWindow(title: 'Your Starting Point'),
                      ),
                    ),
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                    fixedSize: MaterialStateProperty.all(const Size(80, 15)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                  child: Text(
                    'Start',
                    style: GoogleFonts.raleway(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                secondChild: ElevatedButton(
                  onPressed: () async => {
                    flagA = false,
                    _first = true,
                    //flagB = false,
                    positionList2 = positionsList.toList(),
                    positionsList.clear(),
                    endPosition = positionList2[positionList2.length - 1],
                    endTime = DateTime.now(),
                    _newMarkers.add(
                      Marker(
                        markerId: const MarkerId('EP'),
                        position:
                            LatLng(endPosition.latitude, endPosition.longitude),
                        infoWindow:
                            const InfoWindow(title: 'Your Ending Point'),
                      ),
                    ),
                    computedrawPolylineBetweenPositions(positionList2),
                    // Updating the total distance
                    totalDistance = Geolocator.distanceBetween(
                        positionList2[0].latitude,
                        positionList2[0].longitude,
                        endPosition.latitude,
                        endPosition.longitude),
                    // Updating the total duration value
                    totalDuration = endTime.difference(startTime),
                    // Calculating avg. speed in kmph
                    avgSpeed =
                        (totalDistance / totalDuration.inSeconds) * 18.0 / 5.0,
                    //bounds = LatLngBounds(southwest: LatLng(positionList2[0].latitude, positionList2[0].longitude), northeast: LatLng(endPosition.latitude, endPosition.longitude)),
                    //mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100)),
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                    fixedSize: MaterialStateProperty.all(const Size(80, 15)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                  child: Text(
                    'End',
                    style: GoogleFonts.raleway(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                crossFadeState: _first
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(seconds: 1),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Method to draw polylines between the points
  void computedrawPolylineBetweenPositions(List<Position> positionsList) {
    _first = true;
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
