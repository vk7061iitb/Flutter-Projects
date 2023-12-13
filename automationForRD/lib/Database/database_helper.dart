import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pave_track_master/Database/acceleration_db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

/* serves as an intermediary between your application code and the database, providing a set of methods and functionalities to interact with the database in a clean and organized manner. */

class DatabaseHelper {
  final String _dbname = 'accelerationData.db';
  final int _version = 1;

  Future<int> addAccelerationData(AccelerationData accelerationData, String accelerationType) async {
    final db = await getDB();
    return await db.insert("AccelerationData", accelerationData.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateAccelerationData(AccelerationData accelerationData) async {
    final db = await getDB();
    return await db.update("AccelerationData", accelerationData.toJson(),
        where: 'id = ?',
        whereArgs: [accelerationData.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> deleteAccelerationData(AccelerationData accelerationData) async {
    final db = await getDB();
    return await db.delete(
      "AccelerationData",
      where: 'id = ?',
      whereArgs: [accelerationData.id],
    );
  }

  Future<Database> getDB() async {
    try {
      return openDatabase(join(await getDatabasesPath(), _dbname),
          version: _version,
          onCreate: (db, version) async => await db.execute(
              "CREATE TABLE AccelerationData(id INTEGER PRIMARY KEY, accelerationValueType TEXT NOT NULL, accelerationValue TEXT NOT NULL),"));
    } catch (e) {
      // Handle the exception (e.g., print an error message or log it)
      log("Error opening database: $e");
      rethrow; // Re-throw the exception to propagate it further
    }
  }

  Future<List<AccelerationData>> getAllAccelerationData() async {
    final db = await getDB();
    List<Map<String, dynamic>> maps = await db.query("AccelerationData");

    return List.generate(
        maps.length, (index) => AccelerationData.fromJson(maps[index]));
  }

Future<void> exportToCsv() async {
  try {
    // Request storage permission
    var status = await Permission.storage.request();
    
    if (status == PermissionStatus.granted) {
      // Permission granted, proceed with exporting data
      List<AccelerationData> dataList = await getAllAccelerationData();

      // Get the app's documents directory
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String filePath = '${documentsDirectory.path}/acceleration_data.csv';

      // Create and write to the CSV file
      File csvFile = File(filePath);
      csvFile.writeAsStringSync('ID,AccelerationValueType,AccelerationValue\n');
      for (AccelerationData data in dataList) {
        csvFile.writeAsStringSync('${data.id},${data.accelerationValue}\n', mode: FileMode.append);
      }

      log('Data exported to $filePath');
    } else {
      // Permission denied
      log('Permission denied for storage. Unable to export data.');
    }
  } catch (e) {
    log('Error exporting data: $e');
  }
}

  // New method to add acceleration data to the database
  Future<int> addAccelerationDataToDatabase(
      double accelerationValue, String accelerationType) async {
    try {
      AccelerationData accelerationData = AccelerationData(
        id: 0, // Set the id to 0 for auto-increment
        accelerationValue: accelerationValue,
      );
      return await addAccelerationData(accelerationData, accelerationType);
    } catch (e) {
      log('Error adding acceleration data to the database: $e');
      rethrow;
    }
  }
}
