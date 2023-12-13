// ignore_for_file: avoid_print
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLDatabaseHelper {
  late Database _database;

  /// Asynchronous functions allow you to perform operations that may take time, such as database operations,
  /// without blocking the rest of your code.
  Future<void> initializeGDatabase() async {
    var dbPath = await getDatabasesPath();
    String path = join(dbPath, 'test.db');
    try {
      _database = await openDatabase(
        path,
        onCreate: (db, version) {
          return db.execute(
            'CREATE TABLE GyroData(id INTEGER PRIMARY KEY, g_X REAL, g_Y REAL, g_Z REAL)',
          );
        },
        version: 1,
      );
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> insertGyroData(double gX, double gY, double gZ) async {
    await _database.transaction((txn) async {
      await txn.insert(
        'GyroData',
        {'g_X': gX, 'g_Y': gY, 'g_Z': gZ},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<List<Map<String, dynamic>>> getGyrodata() async {
    return await _database.transaction((txn) async {
      return txn.query('GyroData');
    });
  }

  Future<void> deleteAllGyroData() async {
    await _database.transaction((txn) async {
      await txn.delete('GyroData');
    });
  }

  Future<void> requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      print("Storage Permission Granted");
    } else {
      print("Storage Permission Denied");
    }
  }
}
