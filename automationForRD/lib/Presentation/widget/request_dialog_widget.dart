import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestStoragePermissionDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Storage Permission Required'),
      content: const Text('This app needs storage permission to export data. '
          'Please grant permission from app settings.'),
      actions: [
        TextButton(
          onPressed: () => openAppSettings(),
          child: const Text('Open Settings'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}
