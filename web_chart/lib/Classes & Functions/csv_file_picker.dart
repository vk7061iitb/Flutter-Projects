import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'datapoint2.dart';

class PickCSVfile {
  Future<List<dynamic>> getCSV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        withData: true,
        allowedExtensions: ['csv'], // Specify the allowed file types
      );

      if (result != null) {
        if (result.files.single.bytes != null) {
          List<int> fileBytes = result.files.single.bytes!;
          String fileContent = String.fromCharCodes(fileBytes);
          List<dynamic> csvData =
              // ignore: prefer_const_constructors
              CsvToListConverter().convert(fileContent);
          /* if (kDebugMode) {
            print('${csvData[1][0].runtimeType}');
            print('${csvData[1][1].runtimeType}');
          } */

          return csvData;
        } else {
          if (kDebugMode) {
            print('File bytes are null');
          }
          return [];
        }
      } else {
        if (kDebugMode) {
          print('User canceled the file picker');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error picking file: $e");
      }
      return [];
    }
  }

  Future<List<DataPoint2>> getCSVdataByRow(
      int accColumn, int timeColumn, List<dynamic> csvData) async {
    List<DataPoint2> accData = [];
    for (int i = 1; i < csvData.length; i++) {
      accData.add(DataPoint2(
          accValue: csvData[i][accColumn],
          timeDifference: csvData[i][timeColumn].toDouble()));
    }
    return accData;
  }
}
