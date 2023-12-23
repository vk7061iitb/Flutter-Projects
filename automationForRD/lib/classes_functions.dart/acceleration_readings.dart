// Acceleration class to store at which time all the components of acceleration has been added
class AccelerationReadindings {
  final double aX;
  final double aY;
  final double aZ;
  DateTime time;

  AccelerationReadindings(
      {required this.aX,
      required this.aY,
      required this.aZ,
      required this.time});
}
