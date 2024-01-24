import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../Presentation/Widgets/custom_snackbar.dart';
import '../Classes/label_data.dart';

class SQLDatabaseHelper {
  late Database _database;

  /// Initialize the database with tables for RawData, GyroData, and windowData
  Future<void> initializeDatabase() async {
    var dbPath = await getDatabasesPath();
    String path = join(dbPath, 'test.db');
    try {
      _database = await openDatabase(
        path,
        onCreate: (db, version) {
          /// Create tables if they don't exist
          db.execute(
            'CREATE TABLE LabelData(id INTEGER PRIMARY KEY AUTOINCREMENT, Label VARCHAR, Time TIMESTAMP)',
          );
        },
        version: 1,
      );
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  /// Insert acceleration data into the LabelData table in a batch transaction
  Future<void> insertLabelData(List<LabelType> labelDataReadings) async {
    try {
      await _database.transaction((txn) async {
        var batch = txn.batch();
        for (var data in labelDataReadings) {
          batch.rawInsert('INSERT INTO LabelData(Label, Time) VALUES(?,?)', [
            data.roadType,
            DateFormat('yyyy-MM-dd HH:mm:ss:S').format(data.currentTime)
          ]);
        }
        await batch.commit();
      });
    } catch (error) {
      if (kDebugMode) {
        print(error.toString());
      }
    }
  }

  /// Retrieve all records from the RawData table
  Future<List<Map<String, dynamic>>> getLabelData() async {
    return await _database.transaction((txn) async {
      return txn.query('LabelData');
    });
  }

  /// Delete all records from RawData, GyroData, and windowData tables
  Future<void> deleteAllData() async {
    await _database.transaction((txn) async {
      await txn.delete('LabelData');
    });
  }

  /// Export data from RawData and GyroData tables to CSV files
  Future<String> exportToCSV( String fileName) async {
    try {
      await requestStoragePermission();

      /// Create folders to store accelrartion and gyroscope data
      String labelDataFoldername = "label Data";
      Directory? appExternalStorageDir = await getExternalStorageDirectory();
      Directory labelDataDirectory = await Directory(
              join(appExternalStorageDir!.path, labelDataFoldername))
          .create(recursive: true);

      /// Check if folders exist
      if (await labelDataDirectory.exists()) {
        debugPrint('Folder Already Exists');
        debugPrint("$labelDataDirectory.path");
      } else {
        debugPrint('Folder Created');
      }

      /// Query data from RawData and GyroData tables
      List<Map<String, dynamic>> labelDataQuery =
          await _database.query('LabelData');

      /// Convert data to CSV format
      List<List<dynamic>> csvLabelData = [
        ['Label', 'Time'],
        for (var row in labelDataQuery) [row['Label'], row['Time']],
      ];

      // Convert CSV data to strings
      String accCSV = const ListToCsvConverter().convert(csvLabelData);

      // Define file paths and names
      String labelDataFileName =
          '${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}-$fileName.csv';
      String labelDataPath = '${labelDataDirectory.path}/$labelDataFileName';

      // Create File objects
      File labelDataFile = File(labelDataPath);

      // Write CSV data to files
      await labelDataFile.writeAsString(accCSV);

      await Share.shareFiles([labelDataPath],
      subject: 'Sharing My File', text: 'Here you go!');

      debugPrint('CSV file exported to path : ${labelDataDirectory.path}');
      debugPrint('CSV file path : $labelDataPath');
      return 'CSV file exported to path : ${labelDataDirectory.path}';
    } catch (e) {
      debugPrint(e.toString());
      return e.toString();
    }
  }

  /// Close the database connection
  Future<void> close() async {
    await _database.close();
  }

  /// Request storage permission using the permission_handler package
  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      debugPrint("Storage Permission Granted");
    } else if (status.isPermanentlyDenied) {
      // Show a dialog or snackbar explaining the issue and how to fix it
      // (e.g., open app settings to grant permission manually)
    } else {
      // Handle other permission states as needed (e.g., denied, temporary denied)
      customSnackBar('Storage Permission Denied: $status');
      debugPrint('Storage Permission Denied: $status');
    }
  }
}
