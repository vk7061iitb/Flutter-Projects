import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'label_data.dart';

List<List<dynamic>> convertLabelTypesToCsvData(List<LabelType> labelTypes) {
  return labelTypes.map((labelType) {
    return [
      labelType.currentTime.toIso8601String(),
      labelType.roadType,
    ];
  }).toList();
}

Future<void> downloadCSV(List<LabelType> labelTypes, String fileName) async {
  // Convert the list of LabelType objects to CSV format
  List<List<dynamic>> csvData = convertLabelTypesToCsvData(labelTypes);

  // Convert the list to CSV format
  String csvContent = const ListToCsvConverter().convert(csvData);

  // Get the app's documents directory
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/$fileName';

  // Write the CSV content to a file
  File file = File(filePath);
  await file.writeAsString(csvContent);

  // Display a share sheet to share the file
  // ignore: deprecated_member_use
  await Share.shareFiles([filePath],
      subject: 'Sharing My File', text: 'Here you go!');
}
