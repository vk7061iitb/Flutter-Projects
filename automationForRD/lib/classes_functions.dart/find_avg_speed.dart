import 'package:geolocator/geolocator.dart';

List<double> findAvgVelocity(
    List<Position> positionsList, List<DateTime> time) {
  List<Position> twoPositions = [];
  List<double> avgSpeedsList = [];
  List<DateTime> timeList = [];

  if (positionsList.length <= 1) {
    return avgSpeedsList; // Return an empty list if the positionsList has fewer than 2 points
  }

  twoPositions.add(positionsList[0]); // Add the initial position
  int i = 0;

  while (i < positionsList.length - 1) {
    int j = i + 1; // Start the inner loop from the next position
    double d = 0;
    while (j < positionsList.length) {
      d += Geolocator.distanceBetween(
          positionsList[j - 1].latitude,
          positionsList[j - 1].longitude,
          positionsList[j].latitude,
          positionsList[j].longitude);

      if (d >= 10) {
        twoPositions.add(positionsList[j]);
        timeList.add(time[j]);
        int timeDifference = time[j].difference(time[i]).inSeconds;
        double avgSpeed = (d / timeDifference) * 18.0 / 5;
        avgSpeedsList.add(avgSpeed);
        d = 0;
        i = j; // Update the outer loop index to the current inner loop index
        break; // Break out of the inner loop once the distance is >= 10 meters
      }

      j++;
    }

    i++;
  }
  return avgSpeedsList;
}
