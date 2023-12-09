// Simple moving average for acceleration value received
import 'package:pave_track_master/classes_functions.dart/data_point.dart';

List<DataPoint> simpleMovingAverage(List<DataPoint> accData, int parameter) {
  List<DataPoint> smoothedData = [];
  int count = -1;
  for (int i = parameter - 1; i < accData.length; i++) {
    double avgValue = 0.0;
    count++;
    for (int j = i; j >= count; j--) {
      avgValue += accData[j].y;
    }
    smoothedData.add(DataPoint(x: accData[i].x, y: avgValue / parameter));
  }
  return smoothedData;
}