import 'package:google_maps_flutter/google_maps_flutter.dart';

class PolylineInfo {
  Polyline polyline;
  double avgSpeed;
  List<LatLng> points;
  double pathLength;

  PolylineInfo({
    required this.polyline,
    required this.points,
    required this.avgSpeed,
    required this.pathLength,
  });
}