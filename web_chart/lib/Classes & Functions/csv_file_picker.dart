import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'data_point.dart';

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
            print('${csvData}');
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

  Future<List<DataPoint>> getCSVdataByRow(
      int accColumn, int timeColumn, List<dynamic> csvData) async {
    List<DataPoint> accData = [];
    DateFormat format = DateFormat("yyyy-MM-dd HH:mm:ss:SSS");
    for (int i = 1; i < csvData.length; i++) {
      accData.add(DataPoint(
          x: format.parse(csvData[i][timeColumn]), y: csvData[i][accColumn]));
    }
    return accData;
  }
}
