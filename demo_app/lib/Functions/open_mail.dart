import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openMailCompose(String filePath, String fileName) async {
  // Replace with the path and name of the file you want to attach

  // Replace with the recipient's email address
  String recipientEmail = 'vk5418232@gmail.com';

  // Construct the mailto URL
  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

// ···
  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: recipientEmail,
    query: encodeQueryParameters(<String, String>{
      'subject': 'Example Subject & Symbols are allowed!',
      'body': 'Please find the attached file.',
    }),
  );

  launchUrl(emailLaunchUri);
  try {
    // Launch the mail app
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      throw 'Could not launch $emailLaunchUri';
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error opening mail app: $e');
    }
  }
}
