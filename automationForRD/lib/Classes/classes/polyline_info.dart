import 'package:google_maps_flutter/google_maps_flutter.dart';

// Class to store information about a polyline, including its average speed and path details
class PolylineInfo {
  Polyline polyline; // The actual Polyline object
  double avgSpeed; // Average speed along the polyline
  List<LatLng> points; // List of LatLng points defining the polyline
  double pathLength; // Length of the path covered by the polyline

  // Constructor to initialize the PolylineInfo object
  PolylineInfo({
    required this.polyline,
    required this.points,
    required this.avgSpeed,
    required this.pathLength,
  });
}
