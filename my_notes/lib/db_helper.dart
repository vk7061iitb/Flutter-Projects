import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  late Database _database;
  int dbVersion = 1;

  DatabaseHelper() {
    initializeDatabase();
  }

  Future<void> initializeDatabase() async {
    var databasePath = await getDatabasesPath();
    String localDatabasePath = join(databasePath, 'note.db');
    _database = await openDatabase(
      localDatabasePath,
      version: dbVersion,
      onCreate: (db, version) {
        db.execute(
            'CREATE TABLE NotesTable(id INTEGER PRIMARY KEY AUTOINCREMENT, title VARCHAR NOT NULL, description VARCHAR NOT NULL)');
      },
    );
  }

  Future<int> addNote(String notesTitle, String notesDescription) async {
    int id = -1;
    id = await _database.rawInsert(
        'INSERT INTO NotesTable(title, description) VALUES(?, ?)',
        [notesTitle, notesDescription]);
    return id;
  }

  Future<void> deleteNote(int id) async {
    await _database.delete('NotesTable', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getNotesTitle(int id) async {
    List<Map<String, dynamic>> notesTitle = await _database
        .query('NotesTable', columns: ['title'], whereArgs: [id]);
    return notesTitle;
  }

  Future<void> updateNotesDescription(int id, String newDescription) async {
    await _database.update(
        'NotesTable',
        {
          'description': newDescription,
        },
        where: 'id = ?',
        whereArgs: [id]);
  }

  Future<void> updateNotesTitle(int id, String newTitle) async {
    await _database.update(
        'NotesTable',
        {
          'title': newTitle,
        },
        where: 'id = ?',
        whereArgs: [id]);
  }

  void printTableStructure() async {
    /// Print the structure of the table
    String tableName = 'NotesTable';
    List<Map<String, dynamic>> tableStructure =
        await _database.rawQuery('PRAGMA table_info($tableName);');
    for (var column in tableStructure) {
      debugPrint('Column Name: ${column['name']}');
      debugPrint('Data Type: ${column['type']}');
      debugPrint('Nullable: ${column['notnull'] == 0 ? 'Yes' : 'No'}');
      debugPrint('-----');
    }
  }
}
