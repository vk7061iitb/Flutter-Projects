import 'dart:io';

import 'package:csv/csv.dart';
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const int version = 1;
  static const String dbname = 'person.db';

    Future<void> initDatabase(Database database) async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'example.db');

    // Open the database
    database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // Create the table
      await db.execute('''
          CREATE TABLE my_table (
            id INTEGER PRIMARY KEY,
            name TEXT,
            age INTEGER
          )
        ''');
    });
  }

  Future<void> insertData(String name, int age, Database database) async {
    await database.insert('my_table', {'name': name, 'age': age});
  }

  Future<List<Map<String, dynamic>>> queryData(Database database) async {
    return await database.query('my_table');
  }

  Future<List<Map<String, dynamic>>> getDataList() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbname);
    final database = await openDatabase(path, version: version);
    final dataList = await database.query('my_table');
    return dataList;
  }

  Future<void> deleteDataList() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbname);
    final database = await openDatabase(path, version: version);
    database.delete('my_table', where: '1');
  }

  Future<void> exportToCsv() async {
    var status = await Permission.storage.status;
    if (status.isGranted) {
      final List<Map<String, dynamic>> dataList = await getDataList();

      final List<List<dynamic>> csvData = [
        ['Name', 'Age']
      ];

      for (final item in dataList) {
        csvData.add([item['name'], item['age']]);
      }

      final csvString = const ListToCsvConverter().convert(csvData);

      // Use getExternalFilesDir to get a directory where you have write access
      Directory? directory = await DownloadsPath.downloadsDirectory();
      final filePath = '${directory?.path}/exported_data.csv';

      final File file = File(filePath);
      await file.writeAsString(csvString);

      // ignore: avoid_print
      print('CSV file exported to: $filePath');
    } else {
      // If permission is not granted, request it
      await Permission.storage.request();
    }
  }
}
