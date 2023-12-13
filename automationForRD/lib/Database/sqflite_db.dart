// ignore_for_file: avoid_print
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLDatabaseHelper {
  late Database _database;

  /// Asynchronous functions allow you to perform operations that may take time, such as database operations,
  /// without blocking the rest of your code.
  Future<void> initializeDatabase() async {
    var dbPath = await getDatabasesPath();
    String path = join(dbPath, 'test.db');
    try {
      _database = await openDatabase(
        path,
        onCreate: (db, version) {
          db.execute(
            'CREATE TABLE testData(id INTEGER PRIMARY KEY, a_X REAL, a_Y REAL, a_Z REAL, Time TIMESTAMP)',
          );
          db.execute(
              'CREATE TABLE GyroData(id INTEGER PRIMARY KEY, g_X REAL, g_Y REAL, g_Z REAL, Time TIMESTAMP)');
        },
        version: 1,
      );
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> insertTestData(
      double aX, double aY, double aZ, DateTime time) async {
    await _database.transaction((txn) async {
      await txn.insert(
        'testData',
        {
          'a_X': aX,
          'a_Y': aY,
          'a_Z': aZ,
          'Time': time.toUtc().toString(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<void> insertGyroData(
      double gX, double gY, double gZ, DateTime time) async {
    await _database.transaction((txn) async {
      await txn.insert(
        'GyroData',
        {
          'g_X': gX,
          'g_Y': gY,
          'g_Z': gZ,
          'Time': time.toUtc().toString(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<List<Map<String, dynamic>>> getTestdata() async {
    return await _database.transaction((txn) async {
      return txn.query('testData');
    });
  }

  Future<void> deleteAllTestData() async {
    await _database.transaction((txn) async {
      await txn.delete('testData');
      await txn.delete('GyroData');
    });
  }

  Future<String> exportToCSV() async {
    try {
      await requestStoragePermission();

      /* // Print the structure of the table
      String tableName = 'GyroData';
      List<Map<String, dynamic>> tableStructure =
          await _database.rawQuery('PRAGMA table_info($tableName);');
      for (var column in tableStructure) {
        print('Column Name: ${column['name']}');
        print('Data Type: ${column['type']}');
        print('Nullable: ${column['notnull'] == 0 ? 'Yes' : 'No'}');
        print('-----');
      } */

      List<Map<String, dynamic>> queryRows1 = await _database.query('testData');
      List<Map<String, dynamic>> queryRows2 = await _database.query('GyroData');
      List<List<dynamic>> csvData1 = [
        ['X-acceleration', 'Y-acceleration', 'Z-acceleration', 'Time'],
        for (var row in queryRows1)
          [row['a_X'], row['a_Y'], row['a_Z'], row['Time']],
      ];

      List<List<dynamic>> csvData2 = [
        ['X-Gyro', 'Y-Gyro', 'Z-Gyro', 'Time'],
        for (var row in queryRows2)
          [row['g_X'], row['g_Y'], row['g_Z'], row['Time']],
      ];

      // Convert CSV data to strings
      String accCSV = const ListToCsvConverter().convert(csvData1);
      String gyroCSV = const ListToCsvConverter().convert(csvData2);

      // Get the path to the documents directory
      Directory? documentDir = await getDownloadsDirectory();
      // Define file paths and names
      String accFileName =
          'acceleration_data${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}.csv';
      String gyroFileName =
          'gyro_data${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}.csv';
      String accPath = '${documentDir!.path}/$accFileName';
      String gyroPath = '${documentDir.path}/$gyroFileName';

       // Create File objects
      File accFile = File(accPath);
      File gyroFile = File(gyroPath);

      // Write CSV data to files
      await accFile.writeAsString(accCSV);
      await gyroFile.writeAsString(gyroCSV);

      print('CSV file exported to path : ${_database.path}');
      return 'CSV file exported to path : ${_database.path}';
    } catch (e) {
      print(e.toString());
      return e.toString();
    }
  }

  Future<void> requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      print("Storage Permission Granted");
    } else {
      print("Storage Permission Denied");
    }
  }
}
