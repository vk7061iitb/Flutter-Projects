import 'data_point.dart';

int customLinearSearch(List<DataPoint> dataList, String timeStamp) {
  List<String> parts = timeStamp.split(':');
  int hours1 = int.parse(parts[0]);
  int minutes1 = int.parse(parts[1]);
  int seconds1 = int.parse(parts[2]);

  // Converting to double (total seconds since midnight)
  int timeAsInt1 = hours1 * 3600 + minutes1 * 60 + seconds1;

  for (int i = 0; i < dataList.length; i += 5) {
    List<String> part2 = dataList[i].x.toString().substring(12, 20).split(':');
    int hours2 = int.parse(part2[0]);
    int minutes2 = int.parse(part2[1]);
    int seconds2 = int.parse(part2[2]);
    int timeAsInt2 = hours2 * 3600 + minutes2 * 60 + seconds2;

    if (timeAsInt1 == timeAsInt2) {
      return i;
    }
  }

  return -1;

  /* int left = 0;
  int right = dataList.length - 1;

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
      right = mid - 1;
    } else {
      left = mid + 1;
    }
  }
  return -1; */
}
