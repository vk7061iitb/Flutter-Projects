import 'dart:developer';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter SQFlite Demo',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _ageController = TextEditingController();
  late Database _database;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'example.db');

    // Open the database
    _database = await openDatabase(path, version: 1,
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

  Future<void> _insertData(String name, int age) async {
    await _database.insert('my_table', {'name': name, 'age': age});
  }

  // ignore: unused_element
  Future<List<Map<String, dynamic>>> _queryData() async {
    return await _database.query('my_table');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQFlite CRUD Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final name = _nameController.text;
                final age = int.tryParse(_ageController.text) ?? 0;

                if (name.isNotEmpty && age > 0) {
                  await _insertData(name, age);
                  log('Data inserted');
                } else {
                  log('Please enter valid data');
                }
              },
              child: const Text('Add Data'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DataListPage()),
                );
              },
              child: const Text('View Data'),
            ),
          ],
        ),
      ),
    );
  }
}

class DataListPage extends StatefulWidget {
  const DataListPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DataListPageState createState() => _DataListPageState();
}

class _DataListPageState extends State<DataListPage> {
  List<Map<String, dynamic>> _dataList = [];

  @override
  void initState() {
    super.initState();
    _getDataList();
  }

  Future<void> _getDataList() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'example.db');

    final database = await openDatabase(path, version: 1);

    final dataList = await database.query('my_table');
    setState(() {
      _dataList = dataList;
    });
  }

  Future<void> _deleteDataList() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'example.db');
    final database = await openDatabase(path, version: 1);

    setState(() {
      database.delete('my_table', where: '1');
    });
  }

  Future<void> _exportToCsv() async {
    final List<List<dynamic>> csvData = [
      ['Name', 'Age']
    ];

    for (final item in _dataList) {
      csvData.add([item['name'], item['age']]);
    }

    final csvString = const ListToCsvConverter().convert(csvData);

    Directory? directory = await DownloadsPath.downloadsDirectory();
    final filePath = '${directory?.path}/exported_data.csv';

    final File file = File(filePath);
    await file.writeAsString(csvString);

    // ignore: avoid_print
    print('CSV file exported to: $filePath');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stored Data'),
      ),
      // ignore: unnecessary_null_comparison
      body: _dataList != null
          ? Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _dataList.length,
                    itemBuilder: (context, index) {
                      final item = _dataList[index];
                      return ListTile(
                        title: Text('Name: ${item['name']}'),
                        subtitle: Text('Age: ${item['age']}'),
                      );
                    },
                  ),
                ),
                Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    ElevatedButton(
      onPressed: () {
        _deleteDataList();
        setState(() {});
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red, // Change the button color
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            const Icon(Icons.delete, color: Colors.white), // Add an icon
            const SizedBox(width: 8), // Add some spacing
            Text(
              'Delete All',
              style: GoogleFonts.raleway(
                color: Colors.white, // Change text color
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
    ElevatedButton(
      onPressed: _exportToCsv,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green, // Change the button color
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            const Icon(Icons.file_download, color: Colors.white), // Add an icon
            const SizedBox(width: 8,), // Add some spacing
            Text(
              'CSV',
              style: GoogleFonts.raleway(
                color: Colors.white, // Change text color
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
  ],
)

              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
