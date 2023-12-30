// Simple moving average for acceleration value received
import 'package:pave_track_master/Classes/classes/data_point.dart';

// Function to calculate the simple moving average of a given list of DataPoints.
List<DataPoint> simpleMovingAverage(List<DataPoint> accData, int parameter) {
  List<DataPoint> smoothedData = [];

  // Iterate through the data points, starting from the (parameter - 1)-th index.
  for (int i = parameter - 1; i < accData.length; i++) {
    double sum = 0.0;

    // Calculate the sum of 'y' values for the current window size 'parameter'.
    for (int j = i; j > i - parameter; j--) {
      sum += accData[j].y;
    }

    // Calculate the average value for the current window and add it to the smoothedData list.
    smoothedData.add(DataPoint(x: accData[i].x, y: sum / parameter));
  }

  return smoothedData;
}