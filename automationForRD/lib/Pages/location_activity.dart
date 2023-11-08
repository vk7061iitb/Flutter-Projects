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
  late String message;
  // List to store avg. velocity at every 10 meters
  List<double> velocitydata = [1, 2, 3, 4, 5, 6];
  late List<DateTime> t1 = [];
  late List<DateTime> t2 = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _listenToLocationUpdates();
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
    t1.clear();
  }

  void _listenToLocationUpdates() {
    log('_getCurrentLocation Function called');
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
                    setState(() {
                      totalDistance = calculateTotalDistance(positionList2);
                      totalDuration = endTime.difference(startTime);
                      avgSpeed = (totalDistance / totalDuration.inSeconds) *
                          18.0 /
                          5.0;
                      velocitydata.clear();
                      velocitydata.addAll(findAvgVelocity(positionList2, t2));
                      drawPolyline(positionList2, t2);
                    })
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
                width: 75,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: ListView.builder(
                  itemCount: velocitydata.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(
                        velocitydata[index].toStringAsFixed(2),
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ), // Assuming the list contains strings
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

// Function which calculates avg. speed at every 10m and return a list of speeds
  List<double> avgVelocities(List<Position> positionsList, List<DateTime> t) {
    _first = true;
    List<double> velocitydata1 = [];
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

  List<double> totalDistancebetweenPoints(List<Position> pointsPositions) {
    List<double> distance = [];
    LatLng point1;
    LatLng point2;
    for (int i = 0; i < pointsPositions.length - 1; i++) {
      point1 =
          LatLng(pointsPositions[i].latitude, pointsPositions[i].longitude);
      point2 = LatLng(
          pointsPositions[i + 1].latitude, pointsPositions[i + 1].longitude);
      distance.add(Geolocator.distanceBetween(point1.latitude, point1.longitude,
          point2.latitude, point2.longitude));
    }
    return distance;
  }

  // uyfukyckyfvliugbkljbkyifuy
  void drawPolyline(List<Position> positionsList, List<DateTime> time) {
    List<Position> twoPositions = [];
    List<double> avgSpeedsList = [];
    List<DateTime> timeList = [];
    List<int> indexNo = [];
    List<PolylineInfo> polylineObjects = [];

    /* if (positionsList.length <= 1) {
      return avgSpeedsList; // Return an empty list if the positionsList has fewer than 2 points
    } */

    twoPositions.add(positionsList[0]); // Add the initial position
    int i = 0;

    while (i < positionsList.length - 1) {
      int j = i + 1; // Start the inner loop from the next position

      while (j < positionsList.length) {
        double d = Geolocator.distanceBetween(
            positionsList[i].latitude,
            positionsList[i].longitude,
            positionsList[j].latitude,
            positionsList[j].longitude);

        if (d >= 10) {
          twoPositions.add(positionsList[j]);
          timeList.add(time[j]);
          int timeDifference = time[j].difference(time[i]).inSeconds;
          double avgSpeed = (d / timeDifference) * 18.0 / 5;
          avgSpeedsList.add(avgSpeed);
          indexNo.add(j);
          i = j; // Update the outer loop index to the current inner loop index
          break; // Break out of the inner loop once the distance is >= 10 meters
        }

        j++;
      }

      i++;
    }

// Drawing the polylines
    for (int i = 0; i < avgSpeedsList.length; i++) {
      List<LatLng> points = [];

      for (int j = 0; j <= indexNo[i]; i++) {
        points.add(LatLng(positionsList[indexNo[j]].latitude,
            positionsList[indexNo[j]].longitude));
      }

      Polyline polyline = Polyline(
        polylineId: PolylineId('1$i'),
        color: (avgSpeedsList[i] > 2) ? Colors.blue : Colors.red,
        width: 5,
        points: points,
      );

      polylineObjects[i] = PolylineInfo(
          polyline: polyline, avgSpeed: avgSpeedsList[i], points: points);
      setState(() {
        _polylines.clear();
        _polylines.add(polylineObjects[i].polyline);
      });

      points.clear();
    }

    setState(() {
      
    });
  }
}

List<double> findAvgVelocity(
    List<Position> positionsList, List<DateTime> time) {
  List<Position> twoPositions = [];
  List<double> avgSpeedsList = [];
  List<DateTime> timeList = [];
  // List<double> distanceList = [];

  if (positionsList.length <= 1) {
    return avgSpeedsList; // Return an empty list if the positionsList has fewer than 2 points
  }

  twoPositions.add(positionsList[0]); // Add the initial position
  int i = 0;

  while (i < positionsList.length - 1) {
    int j = i + 1; // Start the inner loop from the next position

    while (j < positionsList.length) {
      double d = Geolocator.distanceBetween(
          positionsList[i].latitude,
          positionsList[i].longitude,
          positionsList[j].latitude,
          positionsList[j].longitude);

      if (d >= 10) {
        twoPositions.add(positionsList[j]);
        timeList.add(time[j]);
        int timeDifference = time[j].difference(time[i]).inSeconds;
        double avgSpeed = (d / timeDifference) * 18.0 / 5;
        avgSpeedsList.add(avgSpeed);
        i = j; // Update the outer loop index to the current inner loop index
        break; // Break out of the inner loop once the distance is >= 10 meters
      }

      j++;
    }

    i++;
  }
  return avgSpeedsList;
}

class PolylineInfo {
  Polyline polyline;
  double avgSpeed;
  List<LatLng> points;

  PolylineInfo({
    required this.polyline,
    required this.avgSpeed,
    required this.points,
  });
}
