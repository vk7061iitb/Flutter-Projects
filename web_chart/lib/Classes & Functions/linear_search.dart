import 'datapoint2.dart';

int customLinearSearch2(List<DataPoint2> dataList, String timeStamp) {
  double timeAsInt1 = double.parse(timeStamp);
  for (int i = 0; i < dataList.length; i += 1) {
    double timeAsInt2 = dataList[i].timeDifference;
    if (timeAsInt2 >= timeAsInt1) {
      return i;
    }
  }

  return -1;
}
