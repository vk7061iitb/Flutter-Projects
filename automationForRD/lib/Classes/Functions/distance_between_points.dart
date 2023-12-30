import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

List<double> totalDistancebetweenPoints(List<Position> pointsPositions) {
  List<double> distance = [];
  LatLng point1;
  LatLng point2;
  for (int i = 0; i < pointsPositions.length - 1; i++) {
    point1 = LatLng(pointsPositions[i].latitude, pointsPositions[i].longitude);
    point2 = LatLng(
        pointsPositions[i + 1].latitude, pointsPositions[i + 1].longitude);
    distance.add(Geolocator.distanceBetween(
        point1.latitude, point1.longitude, point2.latitude, point2.longitude));
  }
  return distance;
}
