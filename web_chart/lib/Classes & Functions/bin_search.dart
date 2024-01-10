import 'package:flutter/foundation.dart';
import 'data_point.dart';

int customBinarySearch(List<DataPoint> dataList, String timeStamp) {

  int left = 0;
  int right = dataList.length;

  // Parsing the time string
  List<String> parts = timeStamp.split(':');
  int hours1 = int.parse(parts[0]);
  int minutes1 = int.parse(parts[1]);
  int seconds1 = int.parse(parts[2]);

  // Converting to double (total seconds since midnight)
  int timeAsInt1 = hours1 * 3600 + minutes1 * 60 + seconds1;

  while (left <= right) {
    int mid = left + ((right - left) ~/ 2);

    List<String> part2 =
        dataList[mid].x.toString().substring(12, 20).split(':');
    int hours2 = int.parse(part2[0]);
    int minutes2 = int.parse(part2[1]);
    int seconds2 = int.parse(part2[2]);
    int timeAsInt2 = hours2 * 3600 + minutes2 * 60 + seconds2;

    if (timeAsInt1 == timeAsInt2) {
      return mid;
    } else if (timeAsInt1 < timeAsInt2) {
      left = mid + 1;
    } else {
      right = mid - 1;
    }
  }
  return -1;
}
