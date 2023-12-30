import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pave_track_master/Classes/Functions/draw_polyline.dart';
import 'package:pave_track_master/Classes/Functions/find_avg_speed.dart';
import 'package:pave_track_master/Presentation/widget/custom_appbar.dart';
import 'package:pave_track_master/Presentation/widget/drawer_widget.dart';

// Define the LocationActivity class which is a StatefulWidget
class LocationActivity extends StatefulWidget {
  const LocationActivity({super.key});

  @override
  // Define the state of the LocationActivity widget
  LocationActivityState createState() => LocationActivityState();
}

class LocationActivityState extends State<LocationActivity> {
  // Initialize various required variables and objects
  late GoogleMapController mapController;
  late Position startPosition;
  late Position endPosition;
  final Set<Polyline> _polylines = {};
  LatLng initialCameraPosition = const LatLng(0, 0);
  late LatLng currCameraPosition;
  final Set<Marker> markersSet = {};
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
  bool isCameraAnimating = true;
  // Bool variable to stop the readings
  bool flagB = false;
  late LatLngBounds bounds;
  late List<Position> positionList2;
  // Bool varible for Animated crossfade widget
  bool _first = true;
  // Bool variable to control the crossfade transition between 'start' and 'end' button
  bool animatedContainer = false;
  late String message;
  // List to store avg. velocity at every 10 meters
  List<double> velocitydata = [];
  // List to store the time when a position is added to the positionlist
  late List<DateTime> t1 = [];
  late List<DateTime> t2 = [];
  bool showPolylineDetais = false;
  List<LatLng> latLogPoints = [];

  @override
  void initState() {
    super.initState();
    _listenToLocationUpdates();
  }
  // Asynchronously listens to location updates
  Future<void> _listenToLocationUpdates() async {
    // Check for location permission and request if denied
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        message = ('Location Access Denied Plese Give Location Access');
        log('Location Access Denied');
        return Future.error('Location permissions are denied');
      }
    }

    t1.clear();
    // Start listening for location changes using Geolocator
    Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1,
    )).listen((Position newposition) {
      setState(() {
        currentPosition = newposition;
        positionsList.add(currentPosition);
        // Adding current datetime into the list t1 for each positions
        t1.add(DateTime.now());
        initialCameraPosition =
            LatLng(positionsList[0].latitude, positionsList[0].longitude);
        currCameraPosition = LatLng(
            positionsList[positionsList.length - 1].latitude,
            positionsList[positionsList.length - 1].longitude);
        if (isCameraAnimating) {
          mapController
              .animateCamera(CameraUpdate.newLatLng(currCameraPosition));
        }
      });
    });
  }

  // Function to remove a marker from the set of markers
  void removeMarker(String markerId) {
    setState(() {
      // Removes a marker based on its marker ID
      markersSet.removeWhere((marker) => marker.markerId.value == markerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Customdrawer(),
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          // Display Google Map and various UI elements on top of it
          Positioned.fill(
            child: GoogleMap(
              onMapCreated: (controller) {
                mapController = controller;
              },
              padding: const EdgeInsets.only(top: 150),
              mapType: MapType.normal,
              polylines: _polylines,
              markers: markersSet,
              compassEnabled: true,
              mapToolbarEnabled: true,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              liteModeEnabled: false,
              initialCameraPosition: CameraPosition(
                target: initialCameraPosition,
                zoom: 15.0,
                bearing: 0.0,
              ),
            ),
          ),
    
          // Widgets displaying distance, speed, buttons to start and end tracking
          /* buildTopBar(),
          startEndButton(), */
        ],
      ),
    );
  }

  Widget buildTopBar() {
    return Stack(
      children: [
        Positioned(
          top: 0,
          child: Container(
            height: 50,
            width: MediaQuery.of(context).size.width,
            color: Colors.black,
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
        Positioned(
          top: 50,
          child: Container(
            height: 80,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
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
      ],
    );
  }

  Widget startEndButton() {
    return Positioned(
      bottom: 5,
      left: 16,
      child: AnimatedCrossFade(
        firstChild: ElevatedButton.icon(
          onPressed: () async => {
            velocitydata.clear(),
            _polylines.clear(),
            positionsList.clear(),
            t1.clear,
            t1.clear(),
            isCameraAnimating = true,
            _first = false,
            _listenToLocationUpdates(),
            startPosition = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
            ),
            removeMarker('SP'),
            removeMarker('EP'),
            totalDistance = 0.0,
            avgSpeed = 0.0,
            startTime = DateTime.now(),
            markersSet.add(
              Marker(
                markerId: const MarkerId('SP'),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueViolet),
                position:
                    LatLng(startPosition.latitude, startPosition.longitude),
                infoWindow: InfoWindow(
                    title: 'Your Starting Point',
                    snippet: 'Description',
                    onTap: () {
                      onMarkerTapped(const MarkerId('SP'));
                    }),
              ),
            ),
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black),
            fixedSize: MaterialStateProperty.all(const Size(110, 15)),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: const BorderSide(color: Colors.white, width: 1.5),
              ),
            ),
          ),
          icon: const Icon(Icons.directions_car_filled_outlined,
              color: Colors.white),
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
            isCameraAnimating = false,
            _first = true,
            positionList2 = positionsList.toList(),
            t2 = t1.toList(),
            positionsList.clear(),
            t1.clear(),
            endPosition = positionList2[positionList2.length - 1],
            endTime = DateTime.now(),
            markersSet.add(
              Marker(
                markerId: const MarkerId('EP'),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueViolet),
                position: LatLng(endPosition.latitude, endPosition.longitude),
                infoWindow: const InfoWindow(title: 'Your Ending Position'),
              ),
            ),
            setState(() {
              totalDistance = calculateTotalDistance(positionList2);
              totalDuration = endTime.difference(startTime);
              avgSpeed = (totalDistance / totalDuration.inSeconds) * 18.0 / 5.0;
              velocitydata.clear();
              velocitydata.addAll(findAvgVelocity(positionList2, t2));
              drawPolyline(positionList2, t2, _polylines);
            })
          },
          icon: const Icon(Icons.flag_circle_outlined, color: Colors.white),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black),
            fixedSize: MaterialStateProperty.all(const Size(110, 15)),
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
        crossFadeState:
            _first ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        duration: const Duration(milliseconds: 100),
      ),
    );
  }

  void onMarkerTapped(MarkerId markerId) {
    // Handle marker tap event here
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Place Name'),
              const SizedBox(height: 8.0),
              Image.network('URL_TO_PLACE_PHOTO',
                  height: 100, width: 100), // Replace with actual URL
              const SizedBox(height: 8.0),
              const Text(
                  "Hello World"),
            ],
          ),
        );
      },
    );
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
}
