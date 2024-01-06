import 'package:custom_marker/marker_icon.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pave_track_master/Presentation/widget/buid_in_row.dart';
import 'package:pave_track_master/Presentation/widget/custom_appbar.dart';
import 'package:tuple/tuple.dart';

import '../../Database/firebasedb_helper.dart';

class PCIpage extends StatefulWidget {
  const PCIpage({super.key});

  @override
  PCIpageState createState() => PCIpageState();
}

class PCIpageState extends State<PCIpage> {
  List<Tuple2<LatLng, LatLng>> datalists = [];
  FirestoreDatabaseHelper firebasedatabase = FirestoreDatabaseHelper();
  final GlobalKey globalKey = GlobalKey();
  LatLng initialCameraPosition = const LatLng(19.125513, 72.915183);
  MapType mapType = MapType.normal;
  final Set<Marker> markersSet = {};
  final Set<Polyline> polylines = {};
  double deviceSpeed = 0.0;
  double deviceSpeedAcurracy = 0.0;

  @override
  void initState() {
    super.initState();
    getdata();
    latlngPoints();
  }

  // Asynchronously listens to location updates
  Future<void> listenToLocationUpdates() async {
    Geolocator.getPositionStream().listen((Position currentPosition) {
      deviceSpeed = currentPosition.speed;
      deviceSpeedAcurracy = currentPosition.speedAccuracy;

    });
  }

  void getdata() async {
    setState(() {});
    await firebasedatabase.retrieveTransformedData();
    datalists = await firebasedatabase.retrieveTransformedData();
  }

  void latlngPoints() async {
    List<LatLng> points = [];
    points.add(const LatLng(19.128698, 72.919805));
    points.add(const LatLng(19.124539, 72.914975));
    points.add(const LatLng(19.123853, 72.909285));
    points.add(const LatLng(19.119398, 72.903820));
    points.add(const LatLng(19.122659, 72.898428));
    points.add(const LatLng(19.124693, 72.894988));
    points.add(const LatLng(19.126105, 72.890695));
    points.add(const LatLng(19.128284, 72.887615));
    points.add(const LatLng(19.129307, 72.883667));

    for (int i = 0; i < points.length; i++) {
      bool flag = i % 2 == 0;
      String bumpType = 'Speed Bump';
      String imgPath = 'assets/Images/speedBump.jpg';
      if (i % 2 == 0) {
        bumpType = 'Poth hole Bump';
        imgPath = 'assets/Images/pothHoleBump2.jpg';
      } else if (i % 3 == 0) {
        bumpType = 'Stone Bump';
        imgPath = 'assets/Images/stoneBump.jpg';
      }

      setState(() {});

      markersSet.add(
        Marker(
          markerId: MarkerId('${i + 1}'),
          icon: await MarkerIcon.markerFromIcon(
              FontAwesomeIcons.circleStop, Colors.black, 35),
          position: LatLng(points[i].latitude, points[i].longitude),
          infoWindow: InfoWindow(
              title: 'Bump ${i + 1}',
              snippet: 'Name of the Road',
              onTap: () {
                onMarkerTapped(MarkerId('${i + 1}'), imgPath, bumpType);
              }),
        ),
      );
      Polyline polyline = Polyline(
        polylineId: PolylineId('polyline${i + 1}'),
        points: [datalists[i].item1, datalists[i].item2],
        color: flag ? Colors.blue : Colors.black,
        width: 4,
        jointType: JointType.round,
      );

      polylines.add(polyline);
    }
  }

  void onMarkerTapped(MarkerId markerId, String imgPath, String bumpType) {
    // Handle marker tap event here
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Road Name (Road ID)',
                style: GoogleFonts.raleway(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              Text(
                'Bump No. ${markerId.value}',
                style: GoogleFonts.raleway(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                ),
              ),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      15.0), // Adjust the radius as needed
                  child: Image.asset(
                    imgPath,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
              ),
              const SizedBox(height: 5.0),
              buildInfoRow('Road Test Site', 'Powai'),
              buildInfoRow('Rate of Recorded Bumps', '90%'),
              buildInfoRow('Type of Bump', bumpType),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              padding: const EdgeInsets.only(top: 150),
              mapType: mapType,
              compassEnabled: true,
              mapToolbarEnabled: true,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              liteModeEnabled: false,
              markers: markersSet,
              polylines: polylines,
              initialCameraPosition: CameraPosition(
                target: initialCameraPosition,
                zoom: 15.0,
                bearing: 0.0,
              ),
            ),
          ),
          Positioned(
            bottom: 5,
            left: 5,
            child: OutlinedButton(
              onPressed: () {
                setState(() {});
                getdata();
                latlngPoints();
                setState(() {});
              },
              child: Text(
                'Recieve Data',
                style: GoogleFonts.raleway(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 5,
            right: 5,
            child: OutlinedButton(
              onPressed: () {
                setState(() {});
                firebasedatabase.deleteAllData();
                latlngPoints();
                setState(() {});
              },
              child: Text(
                'Delete Data',
                style: GoogleFonts.raleway(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(bottomRight:  Radius.circular(5)),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Icon(Icons.speed_outlined),
                    Text(
                      'Speed: $deviceSpeed kmph',
                      style: GoogleFonts.raleway(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Accuracy: $deviceSpeedAcurracy',
                      style: GoogleFonts.raleway(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
