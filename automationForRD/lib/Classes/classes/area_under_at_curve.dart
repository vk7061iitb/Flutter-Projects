// Function to caculate the avg. Speed
import 'data_point.dart';

double calculateAreaUnderLineChart(List<DataPoint> accelerationData) {
  double accArea = 0.0;
  double velArea = 0.0;
  double totalDuration = 0.0;
  List<DataPoint> velocityData = [];

  for (int i = 0; i < accelerationData.length - 1; i++) {
    final y1 = accelerationData[i];
    final y2 = accelerationData[i + 1];
    double t2 = (y2.x.hour.toDouble() * 3600 * 1000 +
        y2.x.minute.toDouble() * 60 * 1000 +
        y2.x.second * 1000 +
        y2.x.millisecond);
    double t1 = (y1.x.hour.toDouble() * 3600 * 1000 +
        y1.x.minute.toDouble() * 60 * 1000 +
        y1.x.second * 1000 +
        y1.x.millisecond);
    double dx = (t2 - t1); // Time difference in milisecond
    totalDuration += dx; // total duration of the journey
    double avgAcceleration =
        (y1.y + y2.y) / 2; // avg. acceleration using midpoint rule
    accArea += dx * avgAcceleration; // This area is change in Velocity in mm/s.
    velocityData.add(DataPoint(
        x: y2.x,
        y: accArea / 1000.0)); // adding datapoints for velocity time graph
  }

  for (int i = 0; i < velocityData.length - 1; i++) {
    final x1 = velocityData[i];
    final x2 = velocityData[i + 1];
    Duration duration = x2.x.difference(x1.x);
    double dx1 = duration.inMilliseconds.toDouble();
    double avgVelocity = (x2.y + x1.y) / 2;
    velArea += dx1 * avgVelocity;
  }

  if (totalDuration > 0) {
    double averageSpeed = velArea / totalDuration;
    return averageSpeed;
  } else {
    return 0.0; // Avoid division by zero
  }
}