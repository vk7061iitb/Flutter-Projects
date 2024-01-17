// Datapoint class to store time and Net acceleration value
class DataPoint {
  DateTime x;
  final double y;
  DataPoint({required this.x, required this.y});

  List<dynamic> toCSVrow() {
    return [x, y];
  }
}
