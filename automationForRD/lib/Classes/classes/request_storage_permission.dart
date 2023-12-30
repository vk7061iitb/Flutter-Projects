import 'package:pave_track_master/Presentation/widget/snack_bar.dart';
import 'package:permission_handler/permission_handler.dart';

// ignore_for_file: avoid_print
Future<void> requestStoragePermission() async {
  var status = await Permission.storage.request();
  if (status.isGranted) {
    print("Storage Permission Granted");
  } else if (status.isPermanentlyDenied) {
    // Show a dialog or snackbar explaining the issue and how to fix it
    // (e.g., open app settings to grant permission manually)
  } else {
    // Handle other permission states as needed (e.g., denied, temporary denied)
    customSnackBar('Storage Permission Denied: $status');
    print('Storage Permission Denied: $status');
  }
}
