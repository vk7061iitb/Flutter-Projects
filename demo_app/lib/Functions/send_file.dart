import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

Future<void> sendFile(String filePath, String fileName) async {
  final file = XFile('$filePath/$fileName');
  try {
    await Share.shareXFiles([file],
        subject: 'Sharing My File', text: 'Here you go!');
  } catch (e) {
    if (kDebugMode) {
      print('Error opening mail app: $e');
    }
  }
}
