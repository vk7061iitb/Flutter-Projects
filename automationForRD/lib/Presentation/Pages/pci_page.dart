import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pave_track_master/Presentation/widget/buid_in_row.dart';
import 'package:pave_track_master/Presentation/widget/custom_appbar.dart';

class PCIpage extends StatefulWidget {
  const PCIpage({super.key});

  @override
  PCIpageState createState() => PCIpageState();
}

class PCIpageState extends State<PCIpage> {
  final Set<Marker> markersSet = {};
  LatLng initialCameraPosition = const LatLng(19.125513, 72.915183);
  @override
  void initState() {
    super.initState();
    latlngPoints();
  }

  // Asynchronously listens to location updates
  Future<void> listenToLocationUpdates() async {
    Geolocator.getPositionStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: GoogleMap(
        padding: const EdgeInsets.only(top: 150),
        mapType: MapType.normal,
        compassEnabled: true,
        mapToolbarEnabled: true,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        liteModeEnabled: false,
        markers: markersSet,
        initialCameraPosition: CameraPosition(
          target: initialCameraPosition,
          zoom: 15.0,
          bearing: 0.0,
        ),
      ),
    );
  }

  void latlngPoints() {
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
      String bumpType = 'Speed Bump';
      String imgPath = 'assets/Images/speedBump.jpg';
      if(i%2==0){
        bumpType = 'Poth hole Bump';
        imgPath = 'assets/Images/pothHoleBump.jpg';
      }
      else if(i%3==0){
        bumpType = 'Stone Bump';
        imgPath = 'assets/Images/stoneBump.jpg';
      }

      markersSet.add(
        Marker(
          markerId: MarkerId('${i + 1}'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          position: LatLng(points[i].latitude, points[i].longitude),
          infoWindow: InfoWindow(
              title: 'Bump $i',
              snippet: 'Name of the Road',
              onTap: () {
                onMarkerTapped(MarkerId('${i + 1}'),imgPath, bumpType);
              }),
        ),
      );
    }
  }

  void onMarkerTapped(MarkerId markerId, String imgPath, String bumpType ) {
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
                'Road Name OR Road ID',
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
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(15.0), // Adjust the radius as needed
                child: Image.asset(
                  imgPath,
                  width: MediaQuery.of(context).size.width,
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
}
