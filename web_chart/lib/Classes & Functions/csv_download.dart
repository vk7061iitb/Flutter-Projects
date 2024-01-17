// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:csv/csv.dart';

void downloadCSV(List<List<dynamic>> csvData, String fileName) {
  // Convert the list to CSV format
  String csvContent = const ListToCsvConverter().convert(csvData);

  // Create a Blob containing the CSV data
  final blob =
      html.Blob([Uint8List.fromList(utf8.encode(csvContent))], 'text/csv');

  // Create a download link
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..target = 'download'
    ..download = fileName;

  // Trigger the download
  html.document.body!.append(anchor);
  anchor.click();

  // Clean up
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}
 