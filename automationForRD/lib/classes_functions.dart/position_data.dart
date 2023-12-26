import 'package:geolocator/geolocator.dart';

class PositionData {
  final Position currentPosition;
  final DateTime currentTime;

  PositionData({required this.currentPosition, required this.currentTime});
}
