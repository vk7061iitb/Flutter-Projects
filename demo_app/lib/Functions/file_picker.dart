import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

Future<String?> openFilePicker() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      // Return the path of the picked file
      String filePath = result.files.single.path!;
      
      if (kDebugMode) {
        print("File picked: $filePath");
      }

      return filePath;
    } else {
      // User canceled the file picker or no file was picked
      if (kDebugMode) {
        print("File picker canceled or no file picked");
      }

      return null;
    }
  } catch (e) {
    // Handle file picking error
    if (kDebugMode) {
      print("Error picking file: $e");
    }

    return null;
  }
}
