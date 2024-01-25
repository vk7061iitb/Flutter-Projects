import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pave_track_master/Classes/classes/raw_data.dart';
import 'package:pave_track_master/Presentation/widget/snack_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:tuple/tuple.dart';

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
            'CREATE TABLE RawData(id INTEGER PRIMARY KEY AUTOINCREMENT, x_acc REAL, y_acc REAL, z_acc REAL, Latitude REAL, Longitude REAL, Time TIMESTAMP)',
          );
          db.execute(
            'CREATE TABLE transformedRawData(id INTEGER PRIMARY KEY AUTOINCREMENT, x_acc REAL, y_acc REAL, z_acc REAL, Latitude REAL, Longitude REAL, Time TIMESTAMP)',
          );
          db.execute(
            'CREATE TABLE timerTable(id INTEGER PRIMARY KEY AUTOINCREMENT, Type VARCHAR(20), Time TIMESTAMP)',
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

  /// Insert acceleration data into the RawData table in a batch transaction
  Future<void> insertRawData(List<RawDataReadings> rawDataReadings) async {
    try {
      await _database.transaction((txn) async {
        var batch = txn.batch();
        for (var data in rawDataReadings) {
          batch.rawInsert(
              'INSERT INTO RawData(x_acc, y_acc, z_acc, Latitude, Longitude, time) VALUES(?,?,?,?,?,?)',
              [
                data.xAcc,
                data.yAcc,
                data.zAcc,
                data.position.latitude,
                data.position.longitude,
                DateFormat('yyyy-MM-dd HH:mm:ss:S').format(data.time)
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

  Future<void> insertTime(List<Tuple2<String, DateTime>> timer) async {
    await _database.transaction((txn) async {
      var batch = txn.batch();
      for (var data in timer) {
        batch.rawInsert('INSERT INTO timerTable(Type, Time) VALUES(?,?)',
            [data.item1, data.item2.toString()]);
      }

      await batch.commit();
    });
  }

  Future<void> insertPCAdata(List<dynamic> pcaAccelerationsData) async {
    await _database.transaction((txn) async {
      try {
        var batch = txn.batch();
        for (var data in pcaAccelerationsData) {
          batch.rawInsert(
              'INSERT INTO transformedRawData(x_acc, y_acc, z_acc, Latitude, Longitude, Time) VALUES(?,?,?,?,?,?)',
              [
                data['H1'],
                data['H2'],
                data['Z'],
                data['Latitude'],
                data['Longitude'],
                data['Time']
              ]);
        }
        await batch.commit();
      } catch (e) {
        if (kDebugMode) {
          print('$e.toString()');
        }
      }
    });
  }

  /// Retrieve all records from the RawData table
  Future<List<Map<String, dynamic>>> getRawData() async {
    return await _database.transaction((txn) async {
      return txn.query('RawData');
    });
  }

  /// Delete all records from RawData, GyroData, and windowData tables
  Future<void> deleteAllData() async {
    await _database.transaction((txn) async {
      await txn.delete('RawData');
      await txn.delete('transformedRawData');
      await txn.delete('timerTable');
    });
  }

  /// Export data from RawData and GyroData tables to CSV files
  Future<String> exportToCSV(String sensorFileName) async {
    try {
      await requestStoragePermission();

      /// Create folders to store accelrartion and gyroscope data
      String rawDataFoldername = "Raw Data";
      String pcarawDataFoldername = "PCA Data";

      Directory? appExternalStorageDir = await getExternalStorageDirectory();

      Directory rawDataDirectory =
          await Directory(join(appExternalStorageDir!.path, rawDataFoldername))
              .create(recursive: true);

      Directory pcarawDataDirectory = await Directory(
              join(appExternalStorageDir.path, pcarawDataFoldername))
          .create(recursive: true);

      /// Check if folders exist
      if (await rawDataDirectory.exists()) {
        debugPrint('Folder Already Exists');
        debugPrint("$rawDataDirectory.path");
      } else {
        debugPrint('Folder Created');
      }

      /// Print the structure of the table
      /*  String tableName = 'windowData';
      List<Map<String, dynamic>> tableStructure =
          await _database.rawQuery('PRAGMA table_info($tableName);');
      for (var column in tableStructure) {
        debugPrint('Column Name: ${column['name']}');
        debugPrint('Data Type: ${column['type']}');
        debugPrint('Nullable: ${column['notnull'] == 0 ? 'Yes' : 'No'}');
        debugPrint('-----');
      } */

      /// Query data from RawData and GyroData tables
      List<Map<String, dynamic>> rawdataQuery =
          await _database.query('RawData');
      List<Map<String, dynamic>> transformedRawDataQuery =
          await _database.query('transformedRawData');

      /// Convert data to CSV format
      List<List<dynamic>> csvRawData = [
        ['x_acc', 'y_acc', 'z_acc', 'Lat', 'Lng', 'Time'],
        for (var row in rawdataQuery)
          [
            row['x_acc'],
            row['y_acc'],
            row['z_acc'],
            row['Latitude'],
            row['Longitude'],
            row['Time']
          ],
      ];

      List<List<dynamic>> csvtransformedRawData = [
        ['x_acc', 'y_acc', 'z_acc', 'Lat', 'Lng', 'Time'],
        for (var row in transformedRawDataQuery)
          [
            row['x_acc'],
            row['y_acc'],
            row['z_acc'],
            row['Latitude'],
            row['Longitude'],
            row['Time']
          ],
      ];

      // Convert CSV data to strings
      String accCSV = const ListToCsvConverter().convert(csvRawData);

      String pcaAccCSV =
          const ListToCsvConverter().convert(csvtransformedRawData);

      // Define file paths and names
      String rawDataFileName =
          'RawData-${DateFormat('MM-dd-HH:mm:ss').format(DateTime.now())}-$sensorFileName.csv';
      String pcarawDataFileName =
          'PCAdata${DateFormat('MM-dd-HH:mm:ss').format(DateTime.now())}-$sensorFileName.csv';

      String accPath = '${rawDataDirectory.path}/$rawDataFileName';
      String pcaAccPath = '${pcarawDataDirectory.path}/$pcarawDataFileName';
      // Create File objects
      File accFile = File(accPath);
      File pcaAccFile = File(pcaAccPath);

      // Write CSV data to files
      await accFile.writeAsString(accCSV);
      await pcaAccFile.writeAsString(pcaAccCSV);

      // ignore: deprecated_member_use
      await Share.shareFiles([accPath],
      subject: 'Sharing My File', text: 'Here you go!');

      debugPrint('CSV file exported to path : ${rawDataDirectory.path}');
      return 'CSV file exported to path : ${rawDataDirectory.path}';
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
