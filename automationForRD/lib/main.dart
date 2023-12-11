import 'package:flutter/material.dart';
import 'package:pave_track_master/Pages/location_activity.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const LocationActivity(),
        // MyRoutes.locationRoute :(context) => const LocationActivity(),
        // MyRoutes.accelerometerRoute :(context) => const AccelerometerActvity(),
      },
    );
  }
}



/*
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:csv/csv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Database _database;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'example.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)',
        );
      },
      version: 1,
    );
  }

  Future<void> _requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      print("Storage Permission Granted");
    } else {
      print("Storage Permission Denied");
    }
  }

  Future<void> _addUser() async {
    await _requestStoragePermission();

    final String name = _nameController.text;
    final String age = _ageController.text;

    await _database.insert(
      'users',
      {'name': name, 'age': age},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    _nameController.clear();
    _ageController.clear();

    print("User added to the database");
  }

  Future<void> _exportToCSV() async {
    await _requestStoragePermission();

    List<Map<String, dynamic>> queryRows = await _database.query('users');

    List<List<dynamic>> csvData = [
      ['ID', 'Name', 'Age'],
      for (var row in queryRows) [row['id'], row['name'], row['age']],
    ];

    String csv = const ListToCsvConverter().convert(csvData);

    String fileName = "users_data.csv";
    String path = '/storage/emulated/0/Download/$fileName';

    File file = File(path);
    await file.writeAsString(csv);

    print("CSV file exported to Downloads folder");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SQLite CRUD Example"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addUser,
              child: const Text('Add User'),
            ),
            ElevatedButton(
              onPressed: _exportToCSV,
              child: const Text('Export to CSV'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserListPage(database: _database)),
                );
              },
              child: const Text('User List'),
            ),
          ],
        ),
      ),
    );
  }
}

class UserListPage extends StatelessWidget {
  final Database database;

  const UserListPage({super.key, required this.database});

  Future<void> _clearData() async {
    await database.delete('users');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User List"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: database.query('users'),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No users found."),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var user = snapshot.data![index];
                    return ListTile(
                      title: Text(user['name']),
                      subtitle: Text(user['age']),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _clearData,
                    child: const Text('Clear Data'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Add code for exporting to CSV here
                    },
                    child: const Text('Export to CSV'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

*/


