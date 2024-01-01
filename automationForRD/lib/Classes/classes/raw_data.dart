import 'package:geolocator/geolocator.dart';

class RawDataReadings {
  final double xAcc;
  final double yAcc;
  final double zAcc;
  final Position position;
  DateTime time;

  RawDataReadings(
      {required this.xAcc,
      required this.yAcc,
      required this.zAcc,
      required this.position,
      required this.time});
}
