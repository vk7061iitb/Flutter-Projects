import 'dart:developer';
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
  double avgSpeed = 0.0;
  late LatLngBounds bounds;
  late LatLng currCameraPosition;
  late Position currentPosition;
  late Position endPosition;
  // Note the time when 'End' button is tapped
  late DateTime endTime;

  // Bool variable to control the camera animate
  bool flagA = true;

  // Bool variable to stop the readings
  bool flagB = false;

  LatLng initialCameraPosition = const LatLng(0, 0);
  late GoogleMapController mapController;
  late String message;
  late List<Position> positionList2;
  //Contais the current position obtain through geolocator
  List<Position> positionsList = [];

  late Position startPosition;
  // Note the time when 'Start' button is tapped
  late DateTime startTime;

  late List<DateTime> t1 = [];
  late List<DateTime> t2 = [];
  // Store the total distance between start and end position in meters
  late double totalDistance = 0.0;

  // Stores the time difference between start and end time
  late Duration totalDuration;

  // List to store avg. velocity at every 10 meters
  late List<double> velocitydata = [1,2,3,4,5,6,7];

  // Bool varible for Animated crossfade widget
  bool _first = true;

  // Set to store the Markers
  final Set<Marker> _newMarkers = {};

  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _listenToLocationUpdates();
  }

// Function to remove a marker with specified "ID"
  void removeMarker(String markerId) {
    setState(() {
      _newMarkers.removeWhere((marker) => marker.markerId.value == markerId);
    });
  }

  // Method to draw polylines between the points
  void computedrawPolylineBetweenPositions(
      List<Position> positionsList, List<double> velocitydata) {
    _first = true;
    // Creating a List of points to store Latitude and longitude of all positions

    List<Polyline> polylines = List.generate(
        10, (index) => Polyline(polylineId: PolylineId('updatedroute$index')));
    int sizeV = velocitydata.length;
    List<List<LatLng>> tenPoints = [];

    for (int i = 0; i < sizeV; i++) {
      for (int j = 0; j < 10; j++) {
        if (i * 10 + j < positionsList.length - 1) {
          tenPoints[i].add(LatLng(positionsList[i * 10 + j].latitude,
              positionsList[i * 10 + j].longitude));
        }
      }

      Color safeColor = Colors.green;
      Color unsafeColor = Colors.red;
      bool safe = false;
      // polylines.length = velocitydata.length;
      // Creating Polylines between all the points
      for (int i = 0; i < sizeV; i++) {
        if (velocitydata[i] > 2) {
          safe = true;
        }
        polylines[i] = Polyline(
          polylineId: const PolylineId('updatedroute'),
          color: safe ? safeColor : unsafeColor,
          width: 5,
          points: tenPoints[i],
        );
      }

      setState(() {
        _polylines.addAll(polylines); // Add the new polyline
      });
    }
  }

// Function which calculates avg. speed at every 10m and return a list of speeds
  List<double> avgVelocities(List<Position> positionsList, List<DateTime> t) {
    int deltaT;
    double deltaD = 0.0;
    // ignore: non_constant_identifier_names
    double Vavg;
    List<double> velocitydata1 = [];

    if (t.length > 10) {
      for (int i = 0; i < t.length / 10; i++) {
        deltaT = t[10 * (i + 1) - 1].difference(t[10 * i]).inSeconds;
        for (int j = 0; j < 10 - 1; j++) {
          deltaT = t[10 * i + j + 1].difference(t[10 * i + j]).inSeconds;
          deltaD += Geolocator.distanceBetween(
              positionsList[10 * i + j + 1].latitude,
              positionsList[10 * i + j + 1].longitude,
              positionsList[10 * i + j].latitude,
              positionsList[10 + i + j].longitude);
        }
        Vavg = (deltaD / deltaT) * 5.0 / 18.0;
        velocitydata1.add(Vavg);
        deltaD = 0;
      }
      for (int i = 0; i < t.length % 10 - 1; i++) {
        deltaT = t[i + 1].difference(t[i]).inSeconds;
        deltaD += Geolocator.distanceBetween(
            positionsList[(t.length - t.length % 10) + i + 1].latitude,
            positionsList[(t.length - t.length % 10) + i + 1].longitude,
            positionsList[(t.length - t.length % 10) + i].latitude,
            positionsList[(t.length - t.length % 10) + i].longitude);
        Vavg = (deltaD / deltaT) * 5.0 / 18.0;
        velocitydata1.add(Vavg);
      }
      // If no. of positions are less than 10
    } else {
      deltaT =
          t[t.length - 1].difference(t[(t.length - t.length % 10)]).inSeconds;
      for (int i = 0; i < t.length - 1; i++) {
        deltaD += Geolocator.distanceBetween(
            positionsList[i].latitude,
            positionsList[i].longitude,
            positionsList[i + 1].latitude,
            positionsList[i + 1].longitude);
        Vavg = (deltaD / deltaT) * 5.0 / 18.0;
        velocitydata1.add(Vavg);
      }
      deltaD = 0;
    }
    return velocitydata1;
  }

  // Function to calculate the toatal distance of the positionlist
  double calculateTotalDistance(List<Position> positionsList) {
    double distance = 0.0;
    for (int i = 0; i < positionsList.length - 1; i++) {
      distance += Geolocator.distanceBetween(
          positionsList[i].latitude,
          positionsList[i].longitude,
          positionsList[i + 1].latitude,
          positionsList[i + 1].longitude);
    }
    return distance;
  }

  void reinitializeList() {
  setState(() {
    velocitydata = [4, 5, 6]; // Reinitialize the list with new values
  });
}

  Future<void> _getCurrentLocation() async {
    log('_getCurrentLocation Function called');
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        message = ('Location Access Denied Plese Give Location Access');
        log('Location Access Denied');
        return;
      }
    }
    t1 = [];
  }

// Function to get the continuous location of user
  void _listenToLocationUpdates() {
    log('_listenToLocationUpdates Function called');
    Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1,
    )).listen((Position newposition) {
      setState(() {
        currentPosition = newposition;
        positionsList.add(currentPosition);
        // adding current datetime into the list t1 for each positions
        t1.add(DateTime.now());
        initialCameraPosition =
            LatLng(positionsList[0].latitude, positionsList[0].longitude);
        currCameraPosition = LatLng(
            positionsList[positionsList.length - 1].latitude,
            positionsList[positionsList.length - 1].longitude);
        if (flagA) {
          mapController
              .animateCamera(CameraUpdate.newLatLng(currCameraPosition));

          // Adding a marker for current position of the user
          Marker currMarker = Marker(
            markerId: const MarkerId('CM'),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            position: LatLng(
                currCameraPosition.latitude, currCameraPosition.longitude),
            infoWindow: const InfoWindow(title: 'Your Current Location'),
          );

          removeMarker('CM');
          _newMarkers.add(currMarker);
        }
      });
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
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'PaveTrack Master',
                    style: GoogleFonts.raleway(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 50,
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
              top: 60,
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
                        borderRadius: BorderRadius.all(Radius.circular(50)),
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
              top: 60,
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
                        borderRadius: BorderRadius.all(Radius.circular(50)),
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
              ),
            ),
            Positioned(
              bottom: 5,
              left: 16,
              child: AnimatedCrossFade(
                firstChild: ElevatedButton.icon(
                  onPressed: () async => {
                    flagA = true,
                    _first = false,
                    _polylines.clear(),
                    positionsList.clear(),
                    t1.clear,
                    _getCurrentLocation(),
                    _listenToLocationUpdates(),
                    positionsList.clear(),
                    t1.clear(),
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
                            BitmapDescriptor.hueViolet),
                        position: LatLng(
                            startPosition.latitude, startPosition.longitude),
                        infoWindow:
                            const InfoWindow(title: 'Your Starting Point'),
                      ),
                    ),
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                    // fixedSize: MaterialStateProperty.all(const Size(100, 15)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.directions_car_filled_outlined),
                  label: Text(
                    'Start',
                    style: GoogleFonts.raleway(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                secondChild: ElevatedButton.icon(
                  onPressed: () async => {
                    flagA = false,
                    _first = true,
                    //flagB = false,
                    positionList2 = positionsList.toList(),
                    t2 = t1.toList(),
                    positionsList.clear(),
                    t1.clear(),
                    endPosition = positionList2[positionList2.length - 1],
                    endTime = DateTime.now(),
                    _newMarkers.add(
                      Marker(
                        markerId: const MarkerId('EP'),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueViolet),
                        position:
                            LatLng(endPosition.latitude, endPosition.longitude),
                        infoWindow:
                            const InfoWindow(title: 'Your Ending Position'),
                      ),
                    ),
                    /* velocitydata = avgVelocities(positionList2, t2).toList(),
                    computedrawPolylineBetweenPositions(
                        positionList2, velocitydata), */
                    // Updating the total distance
                    totalDistance = calculateTotalDistance(positionList2),
                    // Updating the total duration value
                    totalDuration = endTime.difference(startTime),
                    // Calculating avg. speed in kmph
                    avgSpeed =
                        (totalDistance / totalDuration.inSeconds) * 18.0 / 5.0,
                    //bounds = LatLngBounds(southwest: LatLng(positionList2[0].latitude, positionList2[0].longitude), northeast: LatLng(endPosition.latitude, endPosition.longitude)),
                    //mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100)),
                    setState(() {
                    velocitydata.clear();
                    velocitydata.add(100);
                    }),
                  },
                  icon: const Icon(Icons.flag_circle_outlined),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                    // fixedSize: MaterialStateProperty.all(const Size(100, 15)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                  label: Text(
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
            ),
            
            Positioned(
              top: 200,
              left: 10,
              child: Container(
                height: 300,
                width: 60,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: ListView.builder(
                  itemCount: velocitydata.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(velocitydata[index]
                          .toString(),
                          style: const TextStyle(
                            color: Colors.black,
                          ),), // Assuming the list contains strings
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
