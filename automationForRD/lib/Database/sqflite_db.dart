// ignore_for_file: avoid_debugPrint
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../classes_functions.dart/acceleration_readings.dart';
import '../classes_functions.dart/position_data.dart';

class SQLDatabaseHelper {
  late Database _database;

  /// Initialize the database with tables for accData, GyroData, and windowData
  Future<void> initializeDatabase() async {
    var dbPath = await getDatabasesPath();
    String path = join(dbPath, 'test.db');
    try {
      _database = await openDatabase(
        path,
        onCreate: (db, version) {
          /// Create tables if they don't exist
          db.execute(
            'CREATE TABLE accData(id INTEGER PRIMARY KEY AUTOINCREMENT, a_X REAL, a_Y REAL, a_Z REAL, Time TIMESTAMP)',
          );
          db.execute(
            'CREATE TABLE GyroData(id INTEGER PRIMARY KEY AUTOINCREMENT, g_X REAL, g_Y REAL, g_Z REAL, Time TIMESTAMP)',
          );
          db.execute(
            'CREATE TABLE positionData(id INTEGER PRIMARY KEY AUTOINCREMENT, Latitude REAL, Longitude REAL, Altitude REAL, Time TIMESTAMP)',
          );
        },
        version: 1,
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Insert acceleration data into the accData table in a batch transaction
  Future<void> insertaccData(
      List<AccelerationReadindings> accelerationReadings) async {
    await _database.transaction((txn) async {
      var batch = txn.batch();
      for (var data in accelerationReadings) {
        batch.rawInsert(
            'INSERT INTO accData(a_X, a_Y, a_Z, time) VALUES(?,?,?,?)', [
          data.aX,
          data.aY,
          data.aZ,
          DateFormat('yyyy-MM-dd HH:mm:ss:S').format(data.time)
        ]);
      }
      await batch.commit();
    });
  }

  /// Insert positions data into positionData table
  Future<void> insertpositionData(List<PositionData> positionsData) async {
    await _database.transaction((txn) async {
      var batch = txn.batch();
      for (var posData in positionsData) {
        batch.rawInsert(
            'INSERT INTO positionData(Latitude, Longitude, Altitude, Time) VALUES(?,?,?,?)',
            [
              posData.currentPosition.latitude,
              posData.currentPosition.longitude,
              posData.currentPosition.altitude,
              DateFormat('yyyy-MM-dd HH:mm:ss:S').format(posData.currentTime)
            ]);
      }
      await batch.commit();
    });
  }

  /// Insert Gyroscope data into the GyroData table in a batch transaction
  Future<void> insertGyroData(
      double gX, double gY, double gZ, DateTime time) async {
    await _database.transaction((txn) async {
      await txn.insert(
        'GyroData',
        {
          'g_X': gX,
          'g_Y': gY,
          'g_Z': gZ,
          'Time': DateFormat('yyyy-MM-dd HH:mm:ss:S').format(time),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  /// Retrieve all records from the accData table
  Future<List<Map<String, dynamic>>> getaccdata() async {
    return await _database.transaction((txn) async {
      return txn.query('accData');
    });
  }

  /// Delete all records from accData, GyroData, and windowData tables
  Future<void> deleteAllData() async {
    await _database.transaction((txn) async {
      await txn.delete('accData');
      await txn.delete('positionData');
      await txn.delete('GyroData');
    });
  }

  /// Export data from accData and GyroData tables to CSV files
  Future<String> exportToCSV() async {
    try {
      await requestStoragePermission();

      /// Create folders to store accelrartion and gyroscope data
      String accFoldername = "Acceleration Data";
      String posFoldername = "Position Data";
      Directory? appExternalStorageDir = await getExternalStorageDirectory();
      Directory accDirectory =
          await Directory(join(appExternalStorageDir!.path, accFoldername))
              .create(recursive: true);
      Directory posDirectory =
          await Directory(join(appExternalStorageDir.path, posFoldername))
              .create(recursive: true);

      /// Check if folders exist
      if (await accDirectory.exists()) {
        debugPrint('Folder Already Exists');
        debugPrint("$accDirectory.path");
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

      /// Query data from accData and GyroData tables
      List<Map<String, dynamic>> queryRows1 = await _database.query('accData');
      List<Map<String, dynamic>> queryRows2 = await _database.query('positionData');

      /// Convert data to CSV format
      List<List<dynamic>> csvData1 = [
        ['X-acceleration', 'Y-acceleration', 'Z-acceleration', 'Time'],
        for (var row in queryRows1)
          [row['a_X'], row['a_Y'], row['a_Z'], row['Time']],
      ];

      List<List<dynamic>> csvData2 = [
        ['Latitude', 'Longitude', 'Altitude', 'Time'],
        for (var row in queryRows2)
          [row['Latitude'], row['Longitude'], row['Altitude'], row['Time']],
      ];

      // Convert CSV data to strings
      String accCSV = const ListToCsvConverter().convert(csvData1);
      String posCSV = const ListToCsvConverter().convert(csvData2);

      // Define file paths and names
      String accFileName =
          'acceleration_data${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}.csv';
      String posFileName =
          'pos_data${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}.csv';
      String accPath = '${accDirectory.path}/$accFileName';
      String posPath = '${posDirectory.path}/$posFileName';

      // Create File objects
      File accFile = File(accPath);
      File posFile = File(posPath);

      // Write CSV data to files
      await accFile.writeAsString(accCSV);
      await posFile.writeAsString(posCSV);
      debugPrint('CSV file exported to path : ${accDirectory.path}');
      return 'CSV file exported to path : ${accDirectory.path}';
    } catch (e) {
      debugPrint(e.toString());
      return e.toString();
    }
  }

  /// Close the database connection
  Future<void> close() async {
    _database.close();
  }

  /// Request storage permission using the permission_handler package
  Future<void> requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      debugPrint("Storage Permission Granted");
    } else {
      debugPrint("Storage Permission Denied");
    }
  }
}
