import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

Future<void> openFilePicker() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      // Do something with the picked file
      if (kDebugMode) {
        print("File picked: ${result.files.single.path}");
      }
    } else {
      // User canceled the file picker
      if (kDebugMode) {
        print("File picker canceled");
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print("Error picking file: $e");
    }
  }
}
