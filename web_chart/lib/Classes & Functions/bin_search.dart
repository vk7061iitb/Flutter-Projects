import 'data_point.dart';

int customLinearSearch1(List<DataPoint> dataList, String timeStamp) {
  List<String> parts = timeStamp.split(':');
  int hours1 = int.parse(parts[0]);
  int minutes1 = int.parse(parts[1]);
  int seconds1 = int.parse(parts[2]);

  // Converting to double (total seconds since midnight)
  int timeAsInt1 = hours1 * 3600 + minutes1 * 60 + seconds1;

  for (int i = 0; i < dataList.length; i += 5) {
    List<String> part2 = dataList[i].x.toString().substring(11, 19).split(':');
    int hours2 = int.parse(part2[0]);
    int minutes2 = int.parse(part2[1]);
    int seconds2 = int.parse(part2[2]);
    int timeAsInt2 = hours2 * 3600 + minutes2 * 60 + seconds2;

    if (timeAsInt2 >= timeAsInt1) {
      return i;
    }
  }

  return -1;

}
